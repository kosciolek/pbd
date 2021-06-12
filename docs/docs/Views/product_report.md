# Product_report

A generic view to facilitate insight into sales and creating various product and order-related reports.

## Usage examples

#### Show the monthly amount and total prices of orders made during lunch time in 2018
```sql
select month, count(product_price) as 'amount of orders', sum(product_price) as 'total prices'
from product_report
where year = 2018
  and hour between 10 and 12
group by month
order by month asc;
```

#### Show the count and total prices of orders, grouped by months and weekdays
```sql
select DATENAME(WEEKDAY, GETDATE()) as weekday,
       count(product_price)         as 'amount of orders',
       sum(product_price)           as 'total prices'
from product_report
group by month, DATENAME(WEEKDAY, GETDATE())
```

#### Show the count and total prices of orders, grouped by hours
```sql
select hour,
       count(product_price)         as 'amount of orders',
       sum(product_price)           as 'total prices'
from product_report
group by hour
```

## Definition

```sql
CREATE OR ALTER VIEW dbo.product_report AS
SELECT o.id               AS       "order_id",
       p.id               as       "product_id",
       pa.price           as       product_price,
       op.effective_price as       "effective_price",
       o.state            as       order_state,
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
         FULL JOIN product_availability pa on p.id = pa.product_id AND pa.date = CONVERT(date, o.date_placed)
where p.id is not null;
```