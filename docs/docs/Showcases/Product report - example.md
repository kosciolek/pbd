# Product report - example

```sql
select month, count(product_price) as 'amount of orders', sum(product_price) as 'total prices' from product_report where year = 2018 and hour between 10 and 12 group by month order by month asc;
```