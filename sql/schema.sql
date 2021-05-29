-- TABLES & INDEXES

DROP TABLE IF EXISTS product;
create table product
(
    id            int IDENTITY (1,1) PRIMARY KEY,
    name          varchar(255)   NOT NULL,
    default_price DECIMAL(18, 2) NOT NULL CHECK (default_price > 0),
    tax_percent   DECIMAL(4, 2)  NOT NULL CHECK (tax_percent BETWEEN 0 AND 1),
    isSeafood     BIT            NOT NULL DEFAULT 0,

    INDEX product_isSeafood NONCLUSTERED (isSeafood), -- klient moze chce wyszukac tylko owoce moza lub je wylaczyc
    INDEX product_name NONCLUSTERED (name),           -- klient moze wyszukowac po nazwie
);

DROP TABLE IF EXISTS product_availability;
CREATE TABLE product_availability
(
    product_id INT            NOT NULL FOREIGN KEY REFERENCES product (id),
    price      DECIMAL(18, 2) NOT NULL CHECK (price > 0),
    date       DATE           NOT NULL DEFAULT GETDATE(),

    CONSTRAINT product_id_date_unique UNIQUE (product_id, date),
    INDEX product_availability_product_id NONCLUSTERED (product_id), -- joiny
    INDEX product_availability_price NONCLUSTERED (price),           -- klient moze chcec sortowac produkty po cenie itp
    INDEX product_availability_date NONCLUSTERED (date),             -- joiny
);


drop table if EXISTS client;
create table client
(
    id INT IDENTITY (1, 1) PRIMARY KEY,
);

drop table if EXISTS client_person;
CREATE TABLE client_person
(
    id           INT PRIMARY KEY FOREIGN KEY REFERENCES client (id),
    first_name   varchar(255) NOT NULL,
    second_name  varchar(255) NOT NULL,
    phone_number varchar(9)   NOT NULL CHECK (LEN(phone_number) = 9),
);

drop table if EXISTS client_company;
CREATE TABLE client_company
(
    id           INT PRIMARY KEY FOREIGN KEY REFERENCES client (id),
    name         varchar(255) NOT NULL,
    phone_number varchar(9)   NOT NULL CHECK (LEN(phone_number) = 9),
    nip          VARCHAR(10)  NOT NULL CHECK (LEN(nip) = 10),
);

DROP TABLE IF EXISTS client_employee;
CREATE TABLE client_employee
(
    id           INT IDENTITY (1, 1) PRIMARY KEY,
    company_id   INT          NOT NULL FOREIGN KEY REFERENCES client_company (id),
    first_name   varchar(255) NOT NULL,
    second_name  varchar(255) NOT NULL,
    phone_number varchar(9) CHECK (LEN(phone_number) = 9),

    -- INDEX client_employee_company_id NONCLUSTERED (company_id), -- listowanie wszystkich pracownikow firmy... raczej rzadko uzywane?
);

drop table if EXISTS const;
create table const
(
    z1                           int            NOT NULL DEFAULT 10,
    k1                           decimal(18, 2) NOT NULL DEFAULT 30 CHECK (k1 > 0),
    r1                           decimal(4, 2)  NOT NULL DEFAULT 0.03 CHECK (r1 BETWEEN 0 AND 1), -- percent

    k2                           decimal(18, 2) NOT NULL DEFAULT 1000 CHECK (k2 > 0),
    r2                           decimal(4, 2)  NOT NULL DEFAULT 0.05 CHECK (r2 BETWEEN 0 AND 1), -- percent
    d1                           int            NOT NULL DEFAULT 7,

    min_orders_cheap_reservation int            NOT NULL DEFAULT 5,
    cheap_reservation_price      DECIMAL(18, 2) NOT NULL DEFAULT 50 CHECK (cheap_reservation_price > 0),
    expensive_reservation_price  DECIMAL(18, 2) NOT NULL DEFAULT 200 CHECK (expensive_reservation_price > 0),

    max_reservation_minutes      INT            NOT NULL DEFAULT 1440 CHECK (max_reservation_minutes > 0
        ),

-- ensure only one row exists
    Lock                         char(1)        not null DEFAULT 'X',
    constraint PK_T1 PRIMARY KEY (Lock),
    constraint CK_T1_Locked CHECK (Lock = 'X')
);
INSERT INTO const DEFAULT
VALUES;

-- TODO a trigger that checks the discount can be made
-- the user has spent enough money
-- the user does not have already a discount applied
-- TODO: stworzyc indexy, beda potrzebne do powyzeszego triggera
drop table if EXISTS discount;
create table discount
(
    id               int IDENTITY (1, 1) PRIMARY KEY,
    date_start       DATE NOT NULL,
    client_person_id INT  NOT NULL FOREIGN KEY REFERENCES client_person (id),
);


drop table if EXISTS [order];
create table [order]
(
    id                   int IDENTITY (1, 1) PRIMARY KEY,
    placed_at            datetime NOT NULL DEFAULT GETDATE(),

    preferred_serve_time DATETIME NOT NULL DEFAULT GETDATE(),
    isTakeaway           BIT      NOT NULL DEFAULT 0,

    order_owner_id       INT FOREIGN KEY REFERENCES client (id),

    accepted             bit      NOT NULL DEFAULT 0,
    rejection_time       datetime,
    rejection_reason     varchar(2048),

    completed            BIT               DEFAULT 0,

    CONSTRAINT preferred_serve_time_bigger_than_placed_at CHECK (preferred_serve_time >= placed_at),
    INDEX order_accepted NONCLUSTERED (accepted),                         -- funkcjonowanie restauracji
    INDEX order_preferred_serve_time NONCLUSTERED (preferred_serve_time), -- funkcjonowanie restauracji
    INDEX order_preferred_placed_at NONCLUSTERED (placed_at),             -- funkcjonowanie restauracji
);


-- If a company places an order for its employees...
DROP TABLE IF EXISTS order_associated_employee;
CREATE TABLE order_associated_employee
(
    employee_id INT NOT NULL FOREIGN KEY REFERENCES client_employee (id),
    order_id    INT NOT NULL FOREIGN KEY REFERENCES [order] (id),

    INDEX order_associated_employee_order_id (order_id), -- joiny przy listowaniu pracownikow dla danego zamowienia
)

drop table if EXISTS order_product;
create table order_product
(
    order_id   INT            NOT NULL FOREIGN KEY REFERENCES [order] (id),
    price      DECIMAL(18, 2) NOT NULL CHECK (price > 0),
    product_id INT            NOT NULL FOREIGN KEY REFERENCES product (id),

    INDEX order_product_order_id (order_id) -- joiny przy listowaniu produktow danego zamowienia
);

drop table if EXISTS reservation;
create table reservation
(
    order_id         INT PRIMARY KEY FOREIGN KEY REFERENCES [order] (id),
    duration_minutes INT NOT NULL DEFAULT 90,
    seats            INT NOT NULL DEFAULT 2 CHECK (seats >= 2),

    INDEX order_associated_employee_order_id NONCLUSTERED (order_id) -- joiny przy znajdowaniu rezerwacji
);

DROP TABLE IF EXISTS seat_limit;
CREATE TABLE seat_limit
(
    day   DATE PRIMARY KEY,
    seats INT NOT NULL,
)

drop table if EXISTS seafood_allowed_early_const;
create table seafood_allowed_early_const
(
    day varchar(24) NOT NULL CHECK (day IN
                                    ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday')),
);

INSERT INTO seafood_allowed_early_const
VALUES ('thursday'),
       ('friday'),
       ('saturday');



GO;
-- FUNCTIONS
CREATE OR
ALTER FUNCTION dbo.getMaxSeatsForDate(@date DATE)
    RETURNS INT AS
BEGIN
    DECLARE @result INT;
    SELECT @result = (SELECT seats FROM seat_limit WHERE day = @date);
    RETURN @result;
END
GO;


-- Returns the last monday before this date
CREATE OR
ALTER FUNCTION dbo.getPrevMonday(@date DATE)
    RETURNS DATE AS
BEGIN
    RETURN DATEADD(DAY, (DATEDIFF(DAY, 0, @date) / 7) * 7 - 7, 0)
END
GO;

CREATE OR
ALTER FUNCTION dbo.getClientType(@client_id INT)
    RETURNS varchar(20) AS
BEGIN
    if (exists(select id from client_person where id = @client_id))
        BEGIN
            RETURN 'person'
        END
    else
        if (exists(select id from client_company where id = @client_id))
            BEGIN
                RETURN 'company'
            END;

    return cast('No such client.' as int);
END
GO;

-- STORED PROCEDURES
GO
;
-- Helps to insert a client_person, automatically creating a client for it
CREATE OR
ALTER PROCEDURE insert_client_person @first_name varchar(255),
                                     @second_name varchar(255),
                                     @phone_number varchar(255)
AS
BEGIN
    DECLARE @id INT
    INSERT INTO client DEFAULT VALUES;
    SET @id = scope_identity()
    INSERT INTO client_person SELECT @id, @first_name, @second_name, @phone_number
    SELECT * from client_person WHERE id = @id
END
GO

-- Helps to insert a client_company, automatically creating a client for it
CREATE OR
ALTER PROCEDURE insert_client_company @name varchar(255),
                                      @phone_number varchar(9),
                                      @nip VARCHAR(10)
AS
BEGIN
    DECLARE @id INT
    INSERT INTO client DEFAULT VALUES;
    SET @id = scope_identity()
    INSERT INTO client_company SELECT @id, @name, @phone_number, @nip
    SELECT * from client_company WHERE id = @id
END
GO


-- Marks an order as accepted
CREATE OR
ALTER PROCEDURE accept_order @order_id varchar(255)
AS
BEGIN
    IF EXISTS(SELECT id FROM [order] WHERE id = @order_id AND accepted = 0)
        BEGIN
            UPDATE [order] SET accepted = 1 WHERE id = @order_id
        END
    ELSE
        BEGIN
            raiserror ('Such an order either does not exist or is already accepted.', 11, 1)
        END
END
GO

-- Copies seat availability
CREATE OR
ALTER PROCEDURE copySeatLimit @dateFrom DATE, @dateTo DATE
AS
BEGIN
    if (@dateFrom IS NULL OR @dateTo IS NULL)
        raiserror ('dateFrom and dateTo must be not null', 11, 1);


    if not exists(SELECT day as next_day, seats from seat_limit WHERE day = @dateFrom)
        BEGIN
            raiserror ('The source day does not have a seat limit set.', 11, 1)
        END

    insert into seat_limit (day, seats)
    SELECT @dateTo as dateTo, seats
    from seat_limit
    WHERE day = @dateFrom;
END
GO

-- Copies product availability
CREATE OR
ALTER PROCEDURE copyProductAvailability @dateFrom DATE, @dateTo DATE
AS
BEGIN
    if (@dateFrom IS NULL OR @dateTo IS NULL)
        raiserror ('dateFrom and dateTo must be not null', 11, 1);

    if not exists(SELECT date from product_availability WHERE date = @dateFrom)
        BEGIN
            raiserror ('The source day does have any products available.', 11, 1)
        END

    insert into product_availability (product_id, price, date)
    SELECT product_id, price, @dateTo
    from product_availability
    WHERE date = @dateFrom;
END
GO

-- Copies the seat limit to a day from its previous day
CREATE OR
ALTER PROCEDURE copySeatLimitFromPreviousDay @date DATE
AS
BEGIN
    if (@date IS NULL)
        SET @date = dateadd(day, 1, convert(date, getdate())); -- from today to tomorrow is default

    DECLARE @fromDate DATE;
    SET @fromDate = dateadd(day, -1, @date);
    exec copySeatLimit @fromDate, @date
END
GO


-- Copies products available to a day from its previous day
CREATE OR
ALTER PROCEDURE copyProductsAvailableFromPreviousDay @date DATE
AS
BEGIN
    if (@date IS NULL)
        SET @date = dateadd(day, 1, convert(date, getdate())); -- from today to tomorrow is default

    DECLARE @fromDate DATE;
    SET @fromDate = dateadd(day, -1, @date);
    exec copyProductAvailability @fromDate, @date
END
GO

-- VIEWS

CREATE OR ALTER VIEW dbo.unaccepted_orders
AS
SELECT *
FROM [order] o
         LEFT JOIN reservation r on o.id = r.order_id
WHERE o.accepted = 0
  AND o.rejection_time IS NULL;
GO;

CREATE OR ALTER VIEW dbo.products_per_order AS
SELECT o.id AS "order_id", p.name as "product_name", pa.price as product_price
FROM [order] o
         LEFT JOIN order_product op on o.id = op.order_id
         LEFT JOIN product p ON op.product_id = p.id
         LEFT JOIN product_availability pa on p.id = pa.product_id AND pa.date = CONVERT(date, o.placed_at)
GO;

CREATE OR ALTER VIEW dbo.orders_per_client AS
SELECT o.id             AS "order_id",
       o.order_owner_id as "client_id",
       o.placed_at      as "placed_at",
       SUM(pa.price)    as "price",
       o.accepted       as "accepted",
       o.rejection_time as "rejection_time"
FROM [order] o
         INNER JOIN order_product op on o.id = op.order_id
         INNER JOIN product_availability pa on (op.product_id = pa.product_id AND CONVERT(DATE, o.placed_at) = pa.date)
GROUP BY o.id, o.placed_at, o.order_owner_id, o.rejection_time, o.accepted;
GO;

-- todo test
CREATE OR ALTER VIEW dbo.company_spendings AS
SELECT cc.id, cc.name, cc.nip, opc.placed_at, price
FROM client_company cc
         LEFT JOIN orders_per_client opc ON opc.client_id = cc.id
WHERE opc.rejection_time IS NULL;
GO;

CREATE OR ALTER VIEW dbo.company_spendings_per_month AS
SELECT cs.name,
       cs.nip,
       DATEPART(Year, cs.placed_at)  as 'year',
       DATEPART(Month, cs.placed_at) as 'month',
       SUM(cs.price)                 as 'price_total'
from company_spendings cs
GROUP BY cs.nip, cs.name, DATEPART(Year, cs.placed_at), DATEPART(Month, cs.placed_at);
GO;

CREATE OR ALTER VIEW dbo.products_available_per_day AS
SELECT p.name, pa.date
FROM product_availability pa
         LEFT JOIN product p ON p.id = pa.product_id;
GO;

-- View the start and the end time of every reservation
CREATE OR ALTER VIEW [dbo].[reservations]
    WITH SCHEMABINDING
AS
SELECT o.preferred_serve_time                                      as start_time,
       DATEADD(minute, r.duration_minutes, o.preferred_serve_time) as end_time,
       r.seats                                                     as seats,
       o.id                                                        as order_id
FROM dbo.reservation r
         INNER JOIN [dbo].[order] o ON r.order_id = o.id;
GO;

CREATE UNIQUE CLUSTERED INDEX idx_reservations_start_end ON dbo.reservations (start_time, end_time, order_id);

CREATE OR ALTER VIEW [dbo].[total_spendings_per_client] AS
select client_id, sum(price) as 'total_spent'
from orders_per_client
group by client_id;
GO;


CREATE OR ALTER VIEW [dbo].discount_eligibility AS
SELECT client_id,
       total_spent                                       as 'total_spent',
       iif(has_discounts = 0, 0, COUNT(client_id))       as 'discounts_count',
       IIF(((COUNT(client_id) + 1) *
            (select k2 from const)) < total_spent, 1, 0) as 'eligible'
FROM (select *, iif(d.id is not null, 1, 0) as 'has_discounts'
      from (select client_id, sum(price) as 'total_spent'
            from orders_per_client opc
            group by client_id) as _spendings
               LEFT JOIN discount d ON d.client_person_id = _spendings.client_id) as spendings
GROUP BY client_id, total_spent, has_discounts;
GO;

CREATE OR ALTER VIEW [dbo].discounts AS
SELECT *,
       DATEADD(DAY, (select d1 from const), d.date_start) as 'date_end',
       iif(DATEADD(DAY, (select d1 from const), d.date_start) >= getdate() AND d.date_start <= getdate(), 1,
           0)                                             as 'active'
from discount d;
go;

CREATE OR ALTER VIEW [dbo].passive_discounts AS
select client_id
from orders_per_client
where dbo.getClientType(client_id) = 'person'
  and price >= (select k1 from const)
GROUP BY client_id
HAVING COUNT(client_id) >= (select z1 from const);
go;

-- TRIGGERS

-- Ensure a client is linked either to a company or a person, but not both
CREATE OR ALTER TRIGGER trCheckOnlyOneClientLinked_client
    ON client_person
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT *
              FROM inserted cp
                       LEFT JOIN client_company cc ON cc.id = cp.id)
        BEGIN
            RAISERROR ('A client can be only linked to one client_person or one client_company at once.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN
        END;
END;
GO

CREATE OR ALTER TRIGGER trCheckOnlyOneClientLinked_company
    ON client_company
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT *
              FROM inserted cc
                       INNER JOIN client_person AS cp
                                  ON cc.id = cp.id
        )
        BEGIN
            RAISERROR ('A client can be only linked to one client_person or one client_company at once.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN
        END;
END;
GO

-- Assert that every ordered product is available that day
CREATE OR ALTER TRIGGER trProductAvailable
    ON order_product
    AFTER INSERT, UPDATE
    AS
BEGIN

    if EXISTS(SELECT pa.date as availability_date
              FROM inserted i
                       INNER JOIN [order] o ON i.order_id = o.id
                       INNER JOIN product p ON p.id = i.product_id
                       LEFT JOIN product_availability pa
                                 ON p.id = pa.product_id AND pa.date = CONVERT(DATE, o.preferred_serve_time)
              WHERE pa.date IS NULL)
        BEGIN
            RAISERROR ('A product may only be ordered when it is available.', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return

END
GO;

-- Assert that all seafood is to be served on a seafood-enabled day and placed before the last monday
CREATE OR ALTER TRIGGER trSeafood
    ON [order]
    AFTER INSERT, UPDATE
    AS
BEGIN
    -- todo: should fire on order_poduct and product as well?

    if EXISTS(SELECT o.id as date
              FROM inserted o
                       LEFT JOIN order_product op ON o.id = op.order_id
                       LEFT JOIN product p ON op.product_id = p.id
              WHERE p.isSeafood = 1
                AND (DATENAME(WEEKDAY, CONVERT(DATE, preferred_serve_time)) NOT IN
                     (SELECT day FROM pbd1.dbo.seafood_allowed_early_const) OR
                     o.placed_at > dbo.getPrevMonday(o.preferred_serve_time)))
        BEGIN
            RAISERROR ('A seafood product may only be served on a seafood-enabled day and before the last monday (including).', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return
END
GO;

-- todo: TEST
-- todo: rewrite to use [dbo].[reservations]
-- Assert that there's enough free seats for every reservation
CREATE OR ALTER TRIGGER trFreeSeatsReservation
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN
    -- This perhaps could be optimized. In its current form, a linear scan through orders must be made to establish how many seats are taken at a given datetime. The current crude optimization trick is to scan only orders made in the last max_reservation_minutes minutes, and preferred_serve_time is indexed

    DECLARE cur CURSOR FOR
        SELECT order_id, duration_minutes, seats FROM inserted

    DECLARE @order_id int, @duration_minutes INT, @seats INT;
    DECLARE @this_start_time DATETIME, @this_end_time DATETIME;
    DECLARE @seats_taken INT;
    DECLARE @seat_limit INT;
    DECLARE @max_reservation_minutes INT;

    SELECT @max_reservation_minutes = max_reservation_minutes FROM const;

    OPEN cur;
    FETCH NEXT FROM cur INTO @order_id, @duration_minutes, @seats

    WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @this_start_time = preferred_serve_time FROM [order] o WHERE o.id = @order_id;
            SELECT @this_end_time = DATEADD(minute, @duration_minutes, o.preferred_serve_time)
            FROM [order] o
            WHERE o.id = @order_id;
            SELECT @seat_limit = seats FROM seat_limit sl WHERE sl.day = CONVERT(DATE, @this_start_time);

            IF (@seat_limit IS NULL)
                BEGIN
                    RAISERROR ('A seat limit was not set for a day for which a reservation has been made.', 16, 1);
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;

            SELECT @seats_taken = (SELECT SUM(r.seats) AS seats_taken
                                   FROM [order] o
                                            LEFT JOIN reservation r on o.id = r.order_id
                                   WHERE (o.preferred_serve_time BETWEEN DATEADD(MINUTE, -@max_reservation_minutes, @this_start_time) AND @this_end_time)
                                     AND NOT (o.preferred_serve_time > @this_end_time OR
                                              DATEADD(MINUTE, r.duration_minutes, o.preferred_serve_time) <
                                              @this_start_time));

            if (@seats_taken > @seat_limit)
                BEGIN
                    RAISERROR ('A reservation may be only made when enough seats are free.', 16, 1);
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;

            FETCH NEXT FROM cur INTO @order_id, @duration_minutes, @seats
        END;
    CLOSE cur;
    DEALLOCATE cur;

    RETURN;
END
GO;

-- Assert takeaway orders do not have reservations
CREATE OR ALTER TRIGGER trNoReservationForTakeaways_order
    ON [order]
    AFTER INSERT, UPDATE
    AS
BEGIN

    if EXISTS(SELECT id
              from inserted o
                       INNER JOIN reservation r ON o.id = r.order_id AND o.isTakeaway = 1)
        BEGIN
            RAISERROR ('A takeaway order must not have a reservation.', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return
END
GO;

-- Assert takeaway orders do not have reservations
CREATE OR ALTER TRIGGER trNoReservationForTakeaways_reservation
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN
    if EXISTS(SELECT id
              from inserted r
                       INNER JOIN [order] o ON o.id = r.order_id AND o.isTakeaway = 1)
        BEGIN
            RAISERROR ('A takeaway order must not have a reservation.', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return
END
GO;

-- Assert reservations are not longer than the limit
CREATE OR ALTER TRIGGER trReservationsTimeLimit
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN

    DECLARE @max_reservation_minutes INT;
    SELECT @max_reservation_minutes = max_reservation_minutes FROM const;

    if EXISTS(SELECT order_id from inserted r WHERE r.duration_minutes > @max_reservation_minutes)
        BEGIN
            RAISERROR ('A reservation cannot exceed the reservation time limit.', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return
END
GO;


-- Assert that the client has spent enough to make a discount
CREATE OR ALTER TRIGGER trDiscount_enough_spent
    ON discount
    AFTER INSERT, UPDATE
    AS
BEGIN

    DECLARE @k2 DECIMAL(18, 2);
    SELECT @k2 = k2 FROM const;

    if EXISTS(SELECT client_id, price as 'total_spent', COUNT(client_id) as 'discounts_count'
              FROM discount as d
                       INNER JOIN (select client_id, sum(price) as 'price'
                                   from orders_per_client opc
                                   group by client_id) as spendings
                                  ON spendings.client_id = d.client_person_id
              where d.client_person_id in (select client_person_id from inserted)
              GROUP BY client_id, spendings.price
              HAVING (COUNT(client_id) * @k2) > price)
        BEGIN
            RAISERROR ('For at least one of the inserted discounts, the client''s total spendings are not enough.', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return
END
GO;


-- Assert that a user does not have two discounts at once
CREATE OR ALTER TRIGGER trDiscount_one_discount_at_once
    ON discount
    AFTER INSERT, UPDATE
    AS
BEGIN
    select *
    from inserted id
             inner join discounts d on id.client_person_id = d.client_person_id and d.id != id.id
    WHERE NOT (id.date_start > d.date_end OR
               dateadd(DAY, (select d1 from const), id.date_start) < d.date_start)
    if EXISTS(select *
              from inserted id
                       inner join discounts d on id.client_person_id = d.client_person_id and d.id != id.id
              WHERE NOT (id.date_start > d.date_end OR
                         dateadd(DAY, (select d1 from const), id.date_start) < d.date_start)
        )
        BEGIN
            RAISERROR ('A client must not have two discounts active at once.', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return
END
GO;


-- ROLES

-- todo
CREATE LOGIN admin WITH PASSWORD = 'Password123';
CREATE USER admin FOR LOGIN admin;