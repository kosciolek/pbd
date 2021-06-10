-- TABLES & INDEXES

DROP TABLE IF EXISTS product;
create table product
(
    id          varchar(255)  NOT NULL PRIMARY KEY,
    tax_percent DECIMAL(4, 2) NOT NULL CHECK (tax_percent BETWEEN 0 AND 1),
    isSeafood   BIT           NOT NULL DEFAULT 0,
    description VARCHAR(2048),

    INDEX product_isSeafood NONCLUSTERED (isSeafood), -- klient moze chce wyszukac tylko owoce moza lub je wylaczyc
);

DROP TABLE IF EXISTS product_availability;
CREATE TABLE product_availability
(
    product_id varchar(255)   NOT NULL FOREIGN KEY REFERENCES product (id),
    price      DECIMAL(18, 2) NOT NULL CHECK (price > 0),
    date       DATE           NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (product_id, date),
    INDEX product_availability_price NONCLUSTERED (price), -- klient moze chcec sortowac produkty po cenie itp
    INDEX product_availability_date NONCLUSTERED (date),   -- joiny
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

    CONSTRAINT client_person_unique UNIQUE (first_name, second_name, phone_number)
);

drop table if EXISTS client_company;
CREATE TABLE client_company
(
    id           INT PRIMARY KEY FOREIGN KEY REFERENCES client (id),
    name         varchar(255)       NOT NULL,
    phone_number varchar(9)         NOT NULL CHECK (LEN(phone_number) = 9),
    nip          VARCHAR(10) UNIQUE NOT NULL CHECK (LEN(nip) = 10),
);

DROP TABLE IF EXISTS client_employee;
CREATE TABLE client_employee
(
    id           INT IDENTITY (1, 1) PRIMARY KEY,
    company_id   INT          NOT NULL FOREIGN KEY REFERENCES client_company (id),
    first_name   varchar(255) NOT NULL,
    second_name  varchar(255) NOT NULL,
    phone_number varchar(9) CHECK (LEN(phone_number) = 9),

    CONSTRAINT client_employee_unique UNIQUE (first_name, second_name, phone_number)

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

    preferred_serve_time DATETIME NOT NULL DEFAULT GETDATE(),
    isTakeaway           BIT      NOT NULL DEFAULT 0,

    order_owner_id       INT FOREIGN KEY REFERENCES client (id),


    state                varchar(24)       default 'placed' CHECK (state in ('placed', 'accepted', 'rejected', 'completed')),

    date_placed          DATETIME not null default getdate(),
    date_accepted        datetime,
    date_rejected        datetime,
    date_completed       datetime,

    note                 varchar(2048),

    CONSTRAINT preferred_serve_time_bigger_than_date_placed CHECK (preferred_serve_time >= date_placed),
    INDEX order_state NONCLUSTERED (state),                            -- funkcjonowanie restauracji
    INDEX order_preferred_serve_time NONCLUSTERED (preferred_serve_time), -- funkcjonowanie restauracji
    INDEX order_date_placed NONCLUSTERED (date_placed),             -- funkcjonowanie restauracji
    INDEX order_date_accepted NONCLUSTERED (date_accepted),             -- funkcjonowanie restauracji
    INDEX order_date_rejected NONCLUSTERED (date_rejected),             -- funkcjonowanie restauracji
    INDEX order_date_completed NONCLUSTERED (date_completed),             -- funkcjonowanie restauracji
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
    order_id        INT            NOT NULL FOREIGN KEY REFERENCES [order] (id),
    effective_price DECIMAL(18, 2) NOT NULL CHECK (effective_price > 0),
    product_id      varchar(255)   NOT NULL FOREIGN KEY REFERENCES product (id),

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
    RETURN dateadd(week,datediff(week,0, @date),0)
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
    BEGIN TRAN;
    DECLARE @id INT
    INSERT INTO client DEFAULT VALUES;
    SET @id = scope_identity()
    INSERT INTO client_person SELECT @id, @first_name, @second_name, @phone_number
    COMMIT TRAN;
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
    BEGIN TRAN;
    DECLARE @id INT
    INSERT INTO client DEFAULT VALUES;
    SET @id = scope_identity()
    INSERT INTO client_company SELECT @id, @name, @phone_number, @nip
    COMMIT TRAN;
    SELECT * from client_company WHERE id = @id
END
GO


-- Marks an order as accepted
CREATE OR
ALTER PROCEDURE change_order_state @order_id varchar(255), @state varchar(24)
AS
BEGIN
    IF (@state not in ('placed', 'accepted', 'rejected', 'completed'))
        begin
            raiserror ('@state must be in placed, completed, rejected or completed', 11, 1)
            return
        end

    IF not EXISTS(SELECT id FROM [order] WHERE id = @order_id)
        begin
            raiserror ('Such an order either does not exist or is already accepted, rejected or completed.', 11, 1)
            return
        end


    if (@state = 'placed')
        UPDATE [order] SET state = 'placed', date_placed = getdate() WHERE id = @order_id
    ELSE
        if (@state = 'accepted')
            UPDATE [order] SET state = 'accepted', date_accepted = getdate() WHERE id = @order_id
        ELSE
            if (@state = 'rejected')
                UPDATE [order] SET state = 'rejected', date_rejected = getdate() WHERE id = @order_id
            ELSE
                if (@state = 'completed')
                    UPDATE [order] SET state = 'completed', date_completed = getdate() WHERE id = @order_id

END
GO

-- Copies seat availability
CREATE OR
ALTER PROCEDURE copySeatLimit @dateFrom DATE, @dateTo DATE
AS
BEGIN
    BEGIN TRAN;
    if (@dateFrom IS NULL OR @dateTo IS NULL)
        begin
            raiserror ('dateFrom and dateTo must be not null', 11, 1);
            return
        end


    if not exists(SELECT day as next_day, seats from seat_limit WHERE day = @dateFrom)
        BEGIN
            raiserror ('The source day does not have a seat limit set.', 11, 1)
            return;
        END

    insert into seat_limit (day, seats)
    SELECT @dateTo as dateTo, seats
    from seat_limit
    WHERE day = @dateFrom;
    COMMIT TRAN;
END
GO

-- Copies product availability
CREATE OR
ALTER PROCEDURE copyProductAvailability @dateFrom DATE, @dateTo DATE
AS
BEGIN
    BEGIN TRAN;
    if (@dateFrom IS NULL OR @dateTo IS NULL)
        begin
            raiserror ('dateFrom and dateTo must be not null', 11, 1);
            return;
        end

    if not exists(SELECT date from product_availability WHERE date = @dateFrom)
        BEGIN
            raiserror ('The source day does have any products available.', 11, 1)
            return
        END

    insert into product_availability (product_id, price, date)
    SELECT product_id, price, @dateTo
    from product_availability
    WHERE date = @dateFrom;
    COMMIT TRAN;
END
GO

-- Copies the seat limit to a day from its previous day
CREATE OR
ALTER PROCEDURE copySeatLimitFromPreviousDay @date DATE
AS
BEGIN
    BEGIN TRAN;
    if (@date IS NULL)
        SET @date = dateadd(day, 1, convert(date, getdate())); -- from today to tomorrow is default

    DECLARE @fromDate DATE;
    SET @fromDate = dateadd(day, -1, @date);
    exec copySeatLimit @fromDate, @date
    COMMIT TRAN;
END
GO


-- Copies products available to a day from its previous day
CREATE OR
ALTER PROCEDURE copyProductsAvailableFromPreviousDay @date DATE
AS
BEGIN
    BEGIN TRAN;
    if (@date IS NULL)
        SET @date = dateadd(day, 1, convert(date, getdate())); -- from today to tomorrow is default

    DECLARE @fromDate DATE;
    SET @fromDate = dateadd(day, -1, @date);
    exec copyProductAvailability @fromDate, @date
    COMMIT TRAN;
END
GO

-- Adds a products to an order, respecting price multipliers
CREATE OR
ALTER PROCEDURE addProduct @order_id int, @product_id varchar(255)
AS
BEGIN
    BEGIN TRAN;
    if (@order_id IS NULL OR @product_id IS NULL)
        begin
            raiserror ('order_id and product_id must not be null', 11, 1);
            return
        end


    if ((select order_owner_id from [order] where id = @order_id) is null OR
        dbo.getClientType((select order_owner_id from [order] where id = @order_id)) = 'company')
        begin
            insert into order_product (order_id, effective_price, product_id)
            values (@order_id, (select price
                                from product_availability pa
                                where pa.product_id = @product_id
                                  AND pa.date = CONVERT(date,
                                            (select preferred_serve_time from [order] o where o.id = @order_id))),
                    @product_id);
        end
    else
        begin
            insert into order_product (order_id, effective_price, product_id)
            values (@order_id, (select multiplier
                                from price_multipliers
                                where client_id = (select order_owner_id from [order] where id = @order_id)) *
                               (select price
                                from product_availability pa
                                where pa.product_id = @product_id
                                  AND pa.date = CONVERT(date,
                                            (select preferred_serve_time from [order] o where o.id = @order_id))),
                    @product_id);
        end
    COMMIT TRAN;
END;
GO;

-- VIEWS

CREATE OR ALTER VIEW dbo.awaiting_acceptation
AS
SELECT *
FROM [order] o
         LEFT JOIN reservation r on o.id = r.order_id
WHERE o.state = 'placed'
GO;

CREATE OR ALTER VIEW dbo.awaiting_completion
AS
SELECT *
FROM [order] o
         LEFT JOIN reservation r on o.id = r.order_id
WHERE o.state = 'accepted'
GO;

CREATE OR ALTER VIEW dbo.products_per_order AS
SELECT o.id AS "order_id", p.id as "product_id", effective_price, pa.price as product_price
FROM [order] o
         LEFT JOIN order_product op on o.id = op.order_id
         LEFT JOIN product p ON op.product_id = p.id
         LEFT JOIN product_availability pa on p.id = pa.product_id AND pa.date = CONVERT(date, o.date_placed)
GO;

CREATE OR ALTER VIEW dbo.orders_per_client AS
SELECT o.id                    AS "order_id",
       o.order_owner_id        as "client_id",
       o.date_placed             as "date_placed",
       SUM(op.effective_price) as "effective_price",
       o.state                 as "state"
FROM [order] o
         INNER JOIN order_product op on o.id = op.order_id
GROUP BY o.id, o.date_placed, o.order_owner_id, o.state;
GO;

-- todo test
CREATE OR ALTER VIEW dbo.company_spendings AS
SELECT cc.id, cc.name, cc.nip, opc.date_placed, effective_price
FROM client_company cc
         LEFT JOIN orders_per_client opc ON opc.client_id = cc.id
WHERE opc.state = 'completed';
GO;

CREATE OR ALTER VIEW dbo.company_spendings_per_month AS
SELECT cs.name,
       cs.nip,
       DATEPART(Year, cs.date_placed)  as 'year',
       DATEPART(Month, cs.date_placed) as 'month',
       SUM(effective_price)          as 'total_spendings'
from company_spendings cs
GROUP BY cs.nip, cs.name, DATEPART(Year, cs.date_placed), DATEPART(Month, cs.date_placed);
GO;

CREATE OR ALTER VIEW [dbo].[price_table_daily] AS
SELECT p.id, pa.date, sum(pa.price) as 'price'
FROM product_availability pa
         LEFT JOIN product p ON p.id = pa.product_id
GROUP BY p.id, pa.date
GO;

CREATE OR ALTER VIEW dbo.todays_products AS
select *
from [dbo].[price_table_daily]
where date = convert(date, getdate());
go;

CREATE OR ALTER VIEW dbo.product_report AS
SELECT o.id               AS     "order_id",
       p.id               as     "product_id",
       pa.price           as     product_price,
       op.effective_price as     "effective_price",
       o.state            as     order_state,
       isSeafood,
       o.isTakeaway,
       p.tax_percent,
       year(date_placed)           'year',
       month(date_placed)          'month',
       day(date_placed)            'day',
       datepart(hour, date_placed) 'hour'
FROM [order] o
         FULL JOIN order_product op on o.id = op.order_id
         FULL JOIN product p ON op.product_id = p.id
         FULL JOIN product_availability pa on p.id = pa.product_id AND pa.date = CONVERT(date, o.date_placed) where p.id is not null;
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

GO;
CREATE OR ALTER VIEW [dbo].[total_spendings_per_client] AS
select client_id, sum(effective_price) as 'total_spent'
from orders_per_client
group by client_id;
GO;


CREATE OR ALTER VIEW [dbo].discount_eligibility AS
SELECT client_id,
       total_spent                                     as 'total_spent',
       iif(has_discounts = 0, 0, COUNT(client_id))     as 'discounts_count',
       IIF((iif(has_discounts = 0, 1, COUNT(client_id) + 1)) *
           (select k2 from const) < total_spent, 1, 0) as 'eligible'
FROM (select *, iif(d.id is not null, 1, 0) as 'has_discounts'
      from (select client_id, sum(effective_price) as 'total_spent'
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

CREATE OR ALTER VIEW [dbo].[passive_discounts] AS
select client_id
from orders_per_client
where dbo.getClientType(client_id) = 'person'
  and effective_price >= (select k1 from const)
GROUP BY client_id
HAVING COUNT(client_id) >= (select z1 from const);
GO;

CREATE OR ALTER VIEW [dbo].[price_multipliers] AS
SELECT id                             as client_id,
       1 - IIF(EXISTS(SELECT client_id from passive_discounts where client_id = id), (select r1 from const), 0) -
       IIF(EXISTS(SELECT id from discounts WHERE active = 1 AND client_person_id = client_person.id),
           (select r2 from const), 0) as 'multiplier'
from client_person
GO;

CREATE OR ALTER VIEW [dbo].[price_table_daily_for_client] AS
SELECT cp.id                         as 'client_id',
       p.id                          as 'product_id',
       pa.date                       as 'availability_date',
       sum(pa.price)                 as 'price',
       sum(pa.price) * pm.multiplier as 'effective_price'
FROM product_availability pa
         LEFT JOIN product p ON p.id = pa.product_id
         FULL JOIN client_person cp ON 1 = 1
         LEFT JOIN price_multipliers pm ON pm.client_id = cp.id
GROUP BY cp.id, p.id, pa.date, pm.multiplier;
GO;


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
                       INNER JOIN client_company cc ON cc.id = cp.id)
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
            return;
        END;
    return

END
GO;

-- Assert that all seafood is to be served on a seafood-enabled day and placed before the last monday
CREATE OR ALTER TRIGGER trSeafood_order_product
    ON order_product
    AFTER INSERT, UPDATE
    AS
BEGIN
    -- todo: should fire on order and product as well?


    if EXISTS(SELECT o.id as date
              FROM inserted op
                       LEFT JOIN [order] o ON o.id = op.order_id
                       LEFT JOIN product p ON op.product_id = p.id
              WHERE p.isSeafood = 1
                AND (DATENAME(WEEKDAY, CONVERT(DATE, preferred_serve_time)) NOT IN
                     (SELECT day FROM seafood_allowed_early_const) OR
                     o.date_placed >= dateadd(day, 1, dbo.getPrevMonday(o.preferred_serve_time)))
        )
        BEGIN
            RAISERROR ('A seafood product may only be served on a seafood-enabled day and before the last monday (including).', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;

CREATE OR ALTER TRIGGER trSeafood_order_product
    ON order_product
    AFTER INSERT, UPDATE
    AS
BEGIN
    -- todo: should fire on order and product as well?


    if EXISTS(    SELECT o.id as date
              FROM inserted op
                  LEFT JOIN [order] o ON o.id = op.order_id
                       LEFT JOIN product p ON op.product_id = p.id
              WHERE p.isSeafood = 1
                AND (DATENAME(WEEKDAY, CONVERT(DATE, preferred_serve_time)) NOT IN
                     (SELECT day FROM seafood_allowed_early_const) OR
                     o.date_placed > dbo.getPrevMonday(o.preferred_serve_time))
)
        BEGIN
            RAISERROR ('A seafood product may only be served on a seafood-enabled day and before the last monday (including).', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;

-- Assert that there's enough free seats for every reservation
-- (This should be rewritten to use dbo.reservations, which is an indexed view, but I'll keep this trigger just to showcase)
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
            return
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
            return
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
            return;
        END;
    return
END
GO;

CREATE OR ALTER TRIGGER trNoReservationsOnAnonymousOrders
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN

    if EXISTS(select o.id
              from inserted r
                       left join [order] o on r.order_id = o.id
              where o.order_owner_id is null)
        BEGIN
            RAISERROR ('To make a reservation for an order, the order must have an owner.', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;

--todo paid enough to make a reservation
CREATE OR ALTER TRIGGER trReservationsPaidEnough
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN


    if EXISTS(select o.id
              from inserted r
                       left join [order] o on r.order_id = o.id
                       left join order_product op on o.id = op.order_id
              where order_owner_id is not null
                and (select sum(effective_price) 'price'
                     from order_product inner_op
                     where inner_op.order_id = r.order_id) <
                    iif((select count(inner_o.id)
                         from [order] inner_o
                         where inner_o.order_owner_id = o.order_owner_id) >=
                        (select min_orders_cheap_reservation from const),
                        (select cheap_reservation_price from const), (select expensive_reservation_price from const)))
        BEGIN
            RAISERROR ('The cost limit for a reservation has not been passed.', 16, 1);
            ROLLBACK TRANSACTION;
            return
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

    if EXISTS(SELECT client_id, effective_price as 'total_spent', COUNT(client_id) as 'discounts_count'
              FROM discount as d
                       INNER JOIN (select client_id, sum(effective_price) as 'effective_price'
                                   from orders_per_client opc
                                   group by client_id) as spendings
                                  ON spendings.client_id = d.client_person_id
              where d.client_person_id in (select client_person_id from inserted)
              GROUP BY client_id, effective_price
              HAVING (COUNT(client_id) * @k2) > effective_price)
        BEGIN
            RAISERROR ('For at least one of the inserted discounts, the client''s total spendings are not enough.', 16, 1);
            ROLLBACK TRANSACTION;
            return
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
            return;
        END;
    return
END
GO;

CREATE OR
ALTER FUNCTION dbo.getEffectivePrice(@product_availability_date DATE, @client_id INT, @product_id varchar(255))
    RETURNS DECIMAL(18, 2) AS
BEGIN

    if (@product_availability_date is null or @product_id is null)
        begin
            return cast('Neither date nor product_id can be null.' as int);
        end

    SET @product_availability_date = convert(date, @product_availability_date);


    DECLARE @result DECIMAL(18, 2);
    if (@client_id is null)
        begin
            SELECT @result = price from product_availability where date = @product_availability_date;
        end
    else
        begin
            SELECT @result = (select price from product_availability where date = @product_availability_date) *
                             (select multiplier from price_multipliers where client_id = @client_id);
        end
    RETURN @result;
END
GO;