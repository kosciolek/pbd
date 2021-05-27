
- [All companies and their spendings, sorted highest to lowest](#all-companies-and-their-spendings-sorted-highest-to-lowest)
- [Information about products of an order](#information-about-products-of-an-order)

#### All companies and their spendings, sorted highest to lowest
```sql
select name, sum(price) from company_spendings group by name order by sum(price) desc
```

#### Information about products of an order
```sql
select * from products_per_order where order_id = 1;
```

todo...