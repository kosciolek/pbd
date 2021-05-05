
DROP TABLE IF EXISTS product;
create table product
(
    id            int IDENTITY (1,1) PRIMARY KEY,
    name          varchar(255)   NOT NULL,
    default_price DECIMAL(18, 2) NOT NULL CHECK (default_price > 0),
    tax_percent   DECIMAL(4, 2)  NOT NULL CHECK (tax_percent BETWEEN 0 AND 1),
);

DROP TABLE IF EXISTS product_per_day;
CREATE TABLE product_per_day
(
    product_id INT            NOT NULL FOREIGN KEY REFERENCES product (id),
    price      DECIMAL(18, 2) NOT NULL CHECK (price > 0),
    date       DATE           NOT NULL DEFAULT GETDATE(),
    active     bit            NOT NULL DEFAULT 1,
);

drop table if EXISTS address;
CREATE TABLE address
(
    id              int IDENTITY (1, 1) PRIMARY KEY,
    city            varchar(255) NOT NULL,
    street          VARCHAR(255) NOT NULL,
    building_number INT          NOT NULL,
    apt_number      int,
);

drop table if EXISTS client;
create table client
(
    id                 UNIQUEIDENTIFIER DEFAULT newid() PRIMARY KEY,
    default_address_id int foreign key REFERENCES address (id),
);

drop table if EXISTS client_person;
CREATE TABLE client_person
(
    id           UNIQUEIDENTIFIER PRIMARY KEY FOREIGN KEY REFERENCES client (id),
    first_name   varchar(255) NOT NULL,
    second_name  varchar(255) NOT NULL,
    phone_number varchar(255) CHECK (LEN(phone_number) = 9),
);

drop table if EXISTS client_company;
CREATE TABLE client_company
(
    id           UNIQUEIDENTIFIER PRIMARY KEY FOREIGN KEY REFERENCES client (id),
    name         varchar(255) NOT NULL,
    phone_number varchar(255) NOT NULL CHECK (LEN(phone_number) = 9),
    nip          VARCHAR(255) NOT NULL CHECK (LEN(nip) = 10),
);

DROP TABLE IF EXISTS client_employee;
CREATE TABLE client_employee
(
    id           UNIQUEIDENTIFIER default newid() PRIMARY KEY,
    company_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES client_company (id),
    first_name   varchar(255)     NOT NULL,
    second_name  varchar(255)     NOT NULL,
    phone_number varchar(255) CHECK (LEN(phone_number) = 9),
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

    min_people_reservation       INT            NOT NULL DEFAULT 2,

    min_orders_cheap_reservation int            NOT NULL DEFAULT 5,
    cheap_reservation_price      DECIMAL(18, 2) NOT NULL DEFAULT 50 CHECK (cheap_reservation_price > 0),
    expensive_reservation_price  DECIMAL(18, 2) NOT NULL DEFAULT 200 CHECK (expensive_reservation_price > 0),

    default_seats                INT            NOT NULL DEFAULT 16,
);

drop table if EXISTS discount;
create table discount
(
    id               int IDENTITY (1, 1) PRIMARY KEY,
    date_start       DATETIME         NOT NULL,
    client_person_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES client_person (id),
);

drop table if EXISTS orders; -- should be singular, but 'order' is a keyword
create table orders
(
    id               int IDENTITY (1, 1) PRIMARY KEY,
    placed_at        datetime         NOT NULL DEFAULT GETDATE(),

    order_owner_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES client (id),


    accepted         bit              NOT NULL DEFAULT 0,
    rejection_time   datetime,
    rejection_reason TEXT,
);


-- If a company places an order for its employees...
DROP TABLE IF EXISTS order_associated_client;
CREATE TABLE order_associated_employee
(
    employee_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES client_employee (id),
    order_id    INT              NOT NULL FOREIGN KEY REFERENCES orders (id),
)

drop table if EXISTS order_product;
create table order_product
(
    order_id   INT NOT NULL FOREIGN KEY REFERENCES orders (id),
    product_id INT NOT NULL FOREIGN KEY REFERENCES product (id), -- CHECK that the product is not a seafood, or it was ordered on a seafood-enabled day
);

DROP TABLE if EXISTS delivery;
create table delivery
(
    address_id              int FOREIGN KEY REFERENCES address (id), -- null means order owner's default address
    order_id                INT NOT NULL FOREIGN KEY REFERENCES orders (id),
    preferred_delivery_time datetime,                                -- null means ASAP -- HIGHER than the order's placed_at
    delivered_time          datetime,                                -- greater than order's placed_at -- HIGHER than the order's placed_at
);

drop table if EXISTS reservation;
create table reservation
(
    id         INT IDENTITY (1, 1) PRIMARY KEY,
    order_id   INT      NOT NULL FOREIGN KEY REFERENCES orders (id),
    start_time datetime NOT NULL DEFAULT GETDATE(),
    end_time   datetime NOT NULL DEFAULT DATEADD(hour, 2, GETDATE()),
    CONSTRAINT end_time_bigger_than_start_time CHECK (end_time > start_time)
);

DROP TABLE IF EXISTS seat;
CREATE TABLE seat
(
    id   INT PRIMARY KEY,
)

DROP TABLE IF EXISTS seat_availability;
CREATE TABLE seat_availability
(
    seat_id INT NOT NULL FOREIGN KEY REFERENCES seat(id),
    date DATE NOT NULL
)

DROP TABLE IF EXISTS reservation_seats;
CREATE TABLE reservation_seats
(
    seat_id        INT NOT NULL FOREIGN KEY REFERENCES seat(id),
    reservation_id INT NOT NULL FOREIGN KEY REFERENCES reservation (id),
);

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

/*DROP FUNCTION IF EXISTS get_c;
CREATE FUNCTION get_client (
    @seat_id UNIQUEIDENTIFIER,
    @date DATE
)
RETURNS BIT
AS BEGIN
RETURN
    END*/