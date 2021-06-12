# Order seafood

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