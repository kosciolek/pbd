- [Copy seat limit - error](#copy-seat-limit---error)
- [Copy seat limit - any day to any day](#copy-seat-limit---any-day-to-any-day)
- [Copy seat limit - from previous day](#copy-seat-limit---from-previous-day)
- [Register product type](#register-product-type)
- [Register product type - invalid tax](#register-product-type---invalid-tax)
- [Register product availability](#register-product-availability)
- [Register product availability - invalid price](#register-product-availability---invalid-price)
- [Copy product availability - from previous day](#copy-product-availability---from-previous-day)
- [Place an order, show all products per order](#place-an-order-show-all-products-per-order)
- [Place an order, add an item - product not available that day](#place-an-order-add-an-item---product-not-available-that-day)
- [Show orders awaiting acceptation](#show-orders-awaiting-acceptation)
- [Accept an order](#accept-an-order)
- [Show orders awaiting completion](#show-orders-awaiting-completion)
- [List products available today](#list-products-available-today)
- [Make reservation - error, no seat limit set](#make-reservation---error-no-seat-limit-set)
- [Make reservation](#make-reservation)
- [Make reservation - error, only one per order](#make-reservation---error-only-one-per-order)
- [Make reservation - error, not paid enough](#make-reservation---error-not-paid-enough)
- [Make reservation](#make-reservation-1)
- [Make reservation - colliding](#make-reservation---colliding)
- [Make active discount - error, not paid enough + eligibility](#make-active-discount---error-not-paid-enough--eligibility)
- [Make discount](#make-discount)
- [Make discount - error, two active at once](#make-discount---error-two-active-at-once)
- [Product report](#product-report)
- [Order seafood - error, not a seafood-enabled day](#order-seafood---error-not-a-seafood-enabled-day)
- [Order seafood - error, not before last monday](#order-seafood---error-not-before-last-monday)
- [Order seafood](#order-seafood)
- [Active discount, passive discount, price multipliers, price table daily for client](#active-discount-passive-discount-price-multipliers-price-table-daily-for-client)

### Copy seat limit - error

```sql
BEGIN TRANSACTION;

INSERT INTO seat_limit (day, seats) values ('2021-05-06', 10);

-- core
exec copySeatLimit @dateFrom = '2021-12-12', @dateTo = '2021-05-07'

SELECT * from seat_limit;

ROLLBACK TRANSACTION;
```

### Copy seat limit - any day to any day

```sql
BEGIN TRANSACTION;

INSERT INTO seat_limit (day, seats) values ('2021-05-06', 10);

-- core
exec copySeatLimit @dateFrom = '2021-05-06', @dateTo = '2021-05-07'

SELECT * from seat_limit;

ROLLBACK TRANSACTION;
```

### Copy seat limit - from previous day

```sql
BEGIN TRANSACTION;

INSERT INTO seat_limit (day, seats) values ('2021-05-06', 10);

-- core
exec copySeatLimitFromPreviousDay @date = '2021-05-07'

SELECT * from seat_limit;

ROLLBACK TRANSACTION;
```

### Register product type

```sql
BEGIN TRANSACTION;

-- core
insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.')

select * from product

ROLLBACK TRANSACTION;
```

### Register product type - invalid tax

```sql
BEGIN TRANSACTION;

-- core
insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 1.34, 'Najlepsze ziemniaczusie.')

select * from product

ROLLBACK TRANSACTION;
```

### Register product availability

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 0.5, 'Najlepsze ziemniaczusie.')

-- core
insert into product_availability (product_id, price, date) VALUES ('Super Ekstra Ziemniaczki', 12.40, '2021-05-06')

select * from product_availability;

ROLLBACK TRANSACTION;
```

### Register product availability - invalid price

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniczaki', 0.5, 'Najlepsze ziemniaczusie.')

-- core
insert into product_availability (product_id, price, date) VALUES ('Super Ekstra Ziemniczaki', -12.40, '2021-05-06')

select * from product_availability;

ROLLBACK TRANSACTION;
```

### Copy product availability - from previous day

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 0.5, 'Najlepsze ziemniaczusie.')

insert into product_availability (product_id, price, date) VALUES ('Super Ekstra Ziemniaczki', 12.40, '2021-05-06')

-- core
exec copyProductsAvailableFromPreviousDay @date = '2021-05-07'
exec copyProductsAvailableFromPreviousDay @date = '2021-05-08'
exec copyProductsAvailableFromPreviousDay @date = '2021-05-09'

select * from product_availability;

ROLLBACK TRANSACTION;
```

### Place an order, show all products per order

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 9.40, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Mix Sałat', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Mix Sałat', 9.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 6.00, CONVERT(date, getdate()));

-- core
insert into [order] (preferred_serve_time, date_placed, order_owner_id)
values (getdate(), getdate(), (select top 1 id from client_person));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Barszcz z jajkiem'


select * from products_per_order;

ROLLBACK TRANSACTION;
```

### Place an order, add an item - product not available that day

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
DECLARE @client1 int = (select top 1 id
                        from client_person);


insert into product (id, tax_percent, description, isSeafood)
values ('Owoce morza - miks', 0.23, 'Super ekstra najlepsze.', 1);
insert into product_availability (product_id, price, date)
VALUES ('Owoce morza - miks', 300, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(day, 2, getdate()));
DECLARE @order1 INT = scope_identity();

-- core
exec addProduct @order_id = @order1, @product_id = 'Owoce morza - miks'

ROLLBACK TRANSACTION;
```

### Show orders awaiting acceptation


```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 9.40, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Mix Sałat', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Mix Sałat', 9.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 6.00, CONVERT(date, getdate()));

insert into [order] (preferred_serve_time, date_placed, order_owner_id)
values (getdate(), getdate(), (select top 1 id from client_person));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Barszcz z jajkiem'

-- core
select * from awaiting_acceptation;

ROLLBACK TRANSACTION;
```

### Accept an order 

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 9.40, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Mix Sałat', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Mix Sałat', 9.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 6.00, CONVERT(date, getdate()));

insert into [order] (preferred_serve_time, date_placed, order_owner_id)
values (getdate(), getdate(), (select top 1 id from client_person));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Barszcz z jajkiem'

-- core
exec change_order_state @order_id = @order_id, @state = 'accepted'

select * from [order]; -- date_accepted changed as well

ROLLBACK TRANSACTION;
```

### Show orders awaiting completion

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 9.40, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Mix Sałat', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Mix Sałat', 9.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 6.00, CONVERT(date, getdate()));

insert into [order] (preferred_serve_time, date_placed, order_owner_id)
values (getdate(), getdate(), (select top 1 id from client_person));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Barszcz z jajkiem'

exec change_order_state @order_id = @order_id, @state = 'accepted'

-- core
select * from awaiting_completion;

ROLLBACK TRANSACTION;
```

### List products available today

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 9.40, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Mix Sałat', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Mix Sałat', 9.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 6.00, dateadd(day, 1, CONVERT(date, getdate())));

-- core
-- select * from product_availability where date = convert(date, getdate())
select * from todays_products;

ROLLBACK TRANSACTION;
```

### Make reservation - error, no seat limit set

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 10, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values ((select top 1 id from client_person), dateadd(hour, 2, getdate()));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'

-- core
INSERT INTO reservation (order_id, duration_minutes, seats) values (@order_id, 90, 3)

ROLLBACK TRANSACTION;
```

### Make reservation

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 10, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values ((select top 1 id from client_person), dateadd(hour, 2, getdate()));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'

-- core
insert into seat_limit (day, seats) values (CONVERT(date, getdate()), 6)
INSERT INTO reservation (order_id, duration_minutes, seats) values (@order_id, 90, 3)

ROLLBACK TRANSACTION;
```

### Make reservation - error, only one per order

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 10, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values ((select top 1 id from client_person), dateadd(hour, 2, getdate()));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'

-- core
insert into seat_limit (day, seats) values (CONVERT(date, getdate()), 6)
INSERT INTO reservation (order_id, duration_minutes, seats) values (@order_id, 90, 3)
INSERT INTO reservation (order_id, duration_minutes, seats) values (@order_id, 90, 3)

select * from reservations;

ROLLBACK TRANSACTION;
```

### Make reservation - error, not paid enough

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 10, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'

insert into seat_limit (day, seats)
values (CONVERT(date, getdate()), 6)

-- core
INSERT INTO reservation (order_id, duration_minutes, seats)
values (@order1, 90, 3)

select * from reservations;

ROLLBACK TRANSACTION;
```

### Make reservation

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 10, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'

insert into seat_limit (day, seats)
values (CONVERT(date, getdate()), 6)

-- core
INSERT INTO reservation (order_id, duration_minutes, seats)
values (@order1, 90, 3)

select * from reservations;

ROLLBACK TRANSACTION;
```

### Make reservation - colliding

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Bardzo Drogie Ziemniaczki', 0.23, 'Bardzo drogie ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Bardzo Drogie Ziemniaczki', 300, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order2, @product_id = 'Bardzo Drogie Ziemniaczki'

insert into seat_limit (day, seats)
values (CONVERT(date, getdate()), 6)

-- core

-- Reservations overlap, and together they take more seats than available
INSERT INTO reservation (order_id, duration_minutes, seats)
values (@order1, 120, 3) -- change duration to 30, and it'll work
INSERT INTO reservation (order_id, duration_minutes, seats)
values (@order2, 90, 4)

select * from reservations;

ROLLBACK TRANSACTION;
```

### Make active discount - error, not paid enough + eligibility

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Bardzo Drogie Ziemniaczki', 0.23, 'Bardzo drogie ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Bardzo Drogie Ziemniaczki', 300, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'

-- core
insert into discount (date_start, client_person_id) values (dateadd(day, 2, convert(date, getdate())), @client1);

select * from discount_eligibility;

ROLLBACK TRANSACTION;
```

### Make discount

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Bardzo Drogie Ziemniaczki', 0.23, 'Bardzo drogie ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Bardzo Drogie Ziemniaczki', 300, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'

-- core
-- select * from discount_eligibility; -- will show eligibility
insert into discount (date_start, client_person_id) values (dateadd(day, 2, convert(date, getdate())), @client1);

select * from discount_eligibility;

ROLLBACK TRANSACTION;
```

### Make discount - error, two active at once

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Bardzo Drogie Ziemniaczki', 0.23, 'Bardzo drogie ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Bardzo Drogie Ziemniaczki', 300, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'

-- core
insert into discount (date_start, client_person_id) values (dateadd(day, 2, convert(date, getdate())), @client1);
insert into discount (date_start, client_person_id) values (dateadd(day, 4, convert(date, getdate())), @client1);

select * from discount_eligibility;

ROLLBACK TRANSACTION;
```

### Product report

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Bardzo Drogie Ziemniaczki', 0.23, 'Bardzo drogie ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Bardzo Drogie Ziemniaczki', 300, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.23);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 9.00, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();

exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'

-- core
select * from product_report;

ROLLBACK TRANSACTION;
```

### Order seafood - error, not a seafood-enabled day

```sql
BEGIN TRANSACTION;

declare @pon1 date = '06-01-2021';
declare @wt1 date = '06-02-2021';
declare @sr1 date = '06-03-2021';
declare @czw1 date = '06-04-2021';
declare @pia1 date = '06-05-2021';
declare @sob1 date = '06-06-2021';
declare @ndz1 date = '06-07-2021';

declare @pon2 date = '06-08-2021';
declare @wt2 date = '06-09-2021';
declare @sr2 date = '06-10-2021';
declare @czw2 date = '06-11-2021';
declare @pia2 date = '06-12-2021';
declare @sob2 date = '06-13-2021';
declare @ndz2 date = '06-14-2021';

declare @ordering_day DATE = @pon1;
declare @serving_day DATE = @wt1;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
DECLARE @client1 int = (select top 1 id
                        from client_person);


insert into product (id, tax_percent, description, isSeafood)
values ('Owoce morza - miks', 0.23, 'Super ekstra najlepsze.', 1);
insert into product_availability (product_id, price, date)
VALUES ('Owoce morza - miks', 300, @serving_day);


--core
insert into [order] (order_owner_id, date_placed, preferred_serve_time)
values (@client1, @ordering_day, @serving_day);
DECLARE @order1 INT = scope_identity();

exec addProduct @order_id = @order1, @product_id = 'Owoce morza - miks'

ROLLBACK TRANSACTION;
```

### Order seafood - error, not before last monday

```sql
BEGIN TRANSACTION;

declare @pon1 date = '06-01-2021';
declare @wt1 date = '06-02-2021';
declare @sr1 date = '06-03-2021';
declare @czw1 date = '06-04-2021';
declare @pia1 date = '06-05-2021';
declare @sob1 date = '06-06-2021';
declare @ndz1 date = '06-07-2021';

declare @pon2 date = '06-08-2021';
declare @wt2 date = '06-09-2021';
declare @sr2 date = '06-10-2021';
declare @czw2 date = '06-11-2021';
declare @pia2 date = '06-12-2021';
declare @sob2 date = '06-13-2021';
declare @ndz2 date = '06-14-2021';

declare @ordering_day DATE = @wt2;
declare @serving_day DATE = @pia2;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
DECLARE @client1 int = (select top 1 id
                        from client_person);


insert into product (id, tax_percent, description, isSeafood)
values ('Owoce morza - miks', 0.23, 'Super ekstra najlepsze.', 1);
insert into product_availability (product_id, price, date)
VALUES ('Owoce morza - miks', 300, @serving_day);


--core
insert into [order] (order_owner_id, date_placed, preferred_serve_time)
values (@client1, @ordering_day, @serving_day);
DECLARE @order1 INT = scope_identity();

exec addProduct @order_id = @order1, @product_id = 'Owoce morza - miks'

ROLLBACK TRANSACTION;
```

### Order seafood 

```sql
BEGIN TRANSACTION;

declare @pon1 date = '06-01-2021';
declare @wt1 date = '06-02-2021';
declare @sr1 date = '06-03-2021';
declare @czw1 date = '06-04-2021';
declare @pia1 date = '06-05-2021';
declare @sob1 date = '06-06-2021';
declare @ndz1 date = '06-07-2021';

declare @pon2 date = '06-08-2021';
declare @wt2 date = '06-09-2021';
declare @sr2 date = '06-10-2021';
declare @czw2 date = '06-11-2021';
declare @pia2 date = '06-12-2021';
declare @sob2 date = '06-13-2021';
declare @ndz2 date = '06-14-2021';

declare @ordering_day DATE = @sob1;
declare @serving_day DATE = @pia2;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
DECLARE @client1 int = (select top 1 id
                        from client_person);


insert into product (id, tax_percent, description, isSeafood)
values ('Owoce morza - miks', 0.23, 'Super ekstra najlepsze.', 1);
insert into product_availability (product_id, price, date)
VALUES ('Owoce morza - miks', 300, @serving_day);


--core
insert into [order] (order_owner_id, date_placed, preferred_serve_time)
values (@client1, @ordering_day, @serving_day);
DECLARE @order1 INT = scope_identity();

exec addProduct @order_id = @order1, @product_id = 'Owoce morza - miks'

ROLLBACK TRANSACTION;
```

### Active discount, passive discount, price multipliers, price table daily for client

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
DECLARE @client1 int = (select top 1 id
                        from client_person);
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);



insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 9.40, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Mix Sałat', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Mix Sałat', 9.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 6.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Trufle', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Trufle', 150, CONVERT(date, getdate()));


DECLARE @cnt INT = 0;

WHILE @cnt < 10
    BEGIN

        insert into [order] (order_owner_id, preferred_serve_time)
        values (@client1, dateadd(hour, 2, getdate()));
        DECLARE @order1 INT = scope_identity();

        exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
        exec addProduct @order_id = @order1, @product_id = 'Mix Sałat'
        exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
        exec addProduct @order_id = @order1, @product_id = 'Trufle'
        exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
        exec addProduct @order_id = @order1, @product_id = 'Mix Sałat'
        exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
        exec addProduct @order_id = @order1, @product_id = 'Trufle'

        insert into [order] (order_owner_id, preferred_serve_time)
        values (@client2, dateadd(hour, 3, getdate()));
        DECLARE @order2 INT = scope_identity();

        exec addProduct @order_id = @order2, @product_id = 'Mix sałat'

        SET @cnt = @cnt + 1;
    END;

select * from passive_discounts;

/*select * from price_multipliers;*/

/*insert into discount (date_start, client_person_id) values (convert(date, getdate()), @client1);
select * from price_multipliers;*/

/*select * from price_table_daily_for_client;*/
ROLLBACK TRANSACTION;
```