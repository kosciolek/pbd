# Order_product

Holds information about all products ordered for an order.

## Definitnion

```sql
create table order_product
(
    order_id        INT            NOT NULL FOREIGN KEY REFERENCES [order] (id),
    effective_price DECIMAL(18, 2) NOT NULL CHECK (effective_price > 0),
    product_id      varchar(255)   NOT NULL FOREIGN KEY REFERENCES product (id),

    INDEX order_product_order_id (order_id)
);
```