DROP TABLE IF EXISTS product;
create table product
(
    id            int IDENTITY (1,1) PRIMARY KEY,
    name          varchar(255)   NOT NULL,
    default_price DECIMAL(18, 2) NOT NULL CHECK (default_price > 0),
    tax_percent   DECIMAL(4, 2)  NOT NULL CHECK (tax_percent BETWEEN 0 AND 1),
);

DROP TABLE IF EXISTS product_availability;
CREATE TABLE product_availability
(
    product_id INT            NOT NULL FOREIGN KEY REFERENCES product (id),
    price      DECIMAL(18, 2) NOT NULL CHECK (price > 0),
    date       DATE           NOT NULL DEFAULT GETDATE(),

    CONSTRAINT product_id_date_unique UNIQUE (product_id, date)
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

    amount_of_seats              INT            NOT NULL DEFAULT 12,

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
drop table if EXISTS discount;
create table discount
(
    id               int IDENTITY (1, 1) PRIMARY KEY,
    date_start       DATE NOT NULL,
    client_person_id INT  NOT NULL FOREIGN KEY REFERENCES client_person (id),
);


-- TODO check that ordered product is available today
drop table if EXISTS [order];
create table [order]
(
    id                   int IDENTITY (1, 1) PRIMARY KEY,
    placed_at            datetime NOT NULL DEFAULT GETDATE(),

    preferred_serve_time DATETIME NOT NULL DEFAULT getdate(),
    isTakeaway           BIT      NOT NULL DEFAULT 0,

    order_owner_id       INT      NOT NULL FOREIGN KEY REFERENCES client (id),

    accepted             bit      NOT NULL DEFAULT 0,
    rejection_time       datetime,
    rejection_reason     varchar(2048),

    CONSTRAINT preferred_serve_time_bigger_than_placed_at CHECK (preferred_serve_time >= placed_at)
);


-- If a company places an order for its employees...
DROP TABLE IF EXISTS order_associated_employee;
CREATE TABLE order_associated_employee
(
    employee_id INT NOT NULL FOREIGN KEY REFERENCES client_employee (id),
    order_id    INT NOT NULL FOREIGN KEY REFERENCES [order] (id),
)

-- TODO TRIGGER - jesli sa owoce, to mozna max do poniedzialku poprzedzajacego zamowienie
drop table if EXISTS order_product;
create table order_product
(
    order_id   INT NOT NULL FOREIGN KEY REFERENCES [order] (id),
    product_id INT NOT NULL FOREIGN KEY REFERENCES product (id), -- CHECK that the product is not a seafood, or it was ordered on a seafood-enabled day
);

drop table if EXISTS reservation;
create table reservation
(
    order_id         INT NOT NULL FOREIGN KEY REFERENCES [order] (id),
    duration_minutes INT NOT NULL DEFAULT 90,
    seats            INT NOT NULL DEFAULT 2 CHECK (seats >= 2),
);

DROP TABLE IF EXISTS seat_limit_override;
CREATE TABLE seat_limit_override
(
    day        DATE PRIMARY KEY,
    seat_limit INT NOT NULL,
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
    SELECT @result = (SELECT seat_limit FROM seat_limit_override WHERE day = @date);
    IF @result IS NULL
        SELECT @result = (SELECT amount_of_seats FROM const);
    RETURN @result;
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


-- TRIGGERS

-- Ensure a client is linked either to a company or a person, but not both
CREATE OR ALTER TRIGGER trCheckOnlyOneClientLinked_client
    ON client_person
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT *
              FROM client_company cc
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

CREATE OR ALTER TRIGGER trCheckOnlyOneClientLinked_company
    ON client_company
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT *
              FROM client_company cc
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

    DECLARE @order_id INT
    SELECT @order_id = (SELECT order_id FROM inserted)

    DECLARE
        @order_date DATE
    SELECT @order_date = (SELECT CONVERT(DATE, placed_at) from [order] o where @order_id = o.id);

    if NOT EXISTS(SELECT product_id
                  FROM product_availability
                  WHERE date = @order_date)
        BEGIN
            RAISERROR ('A product may only be ordered when it is available.', 16, 1);
            ROLLBACK TRANSACTION;
        END;
    return
END
GO;

-- VIEWS

GO;
CREATE OR ALTER VIEW dbo.unaccepted_orders
AS
SELECT *
FROM [order] o
         LEFT JOIN reservation r on o.id = r.order_id
WHERE o.accepted = 0;
GO;

CREATE OR ALTER VIEW dbo.products_per_order AS
SELECT o.id AS "order_id", p.name
FROM [order] o
         LEFT JOIN order_product op on o.id = op.order_id
         LEFT JOIN product p ON op.product_id = p.id
GO;

CREATE OR ALTER VIEW dbo.order_price AS
SELECT o.id AS "order_id", o.order_owner_id as "client_id", o.placed_at, SUM(pa.price) as "price"
FROM [order] o
         LEFT JOIN order_product op on o.id = op.order_id
         LEFT JOIN product_availability pa on (op.product_id = pa.product_id AND CONVERT(DATE, o.placed_at) = pa.date)
GROUP BY o.id, o.placed_at, o.order_owner_id;
GO;

-- todo test
CREATE OR ALTER VIEW dbo.company_spendings AS
SELECT cc.id, cc.name, cc.nip, op.placed_at, price
FROM client_company cc
         LEFT JOIN order_price op ON op.client_id = cc.id
GO;

CREATE OR ALTER VIEW dbo.company_spendings_per_month AS
SELECT cs.name, cs.nip, SUM(cs.price) as 'price_total'
from company_spendings cs
GROUP BY cs.nip, cs.name, DATEPART(Year, cs.placed_at), DATEPART(Month, cs.placed_at);
GO;

CREATE OR ALTER VIEW dbo.products_available_per_day AS
SELECT p.name, pa.date
FROM product_availability pa
         LEFT JOIN product p ON p.id = pa.product_id;
GO;