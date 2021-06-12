# Product_availability

Holds information about [products](product) able to be ordered on any given day.
## Definition

```sql
CREATE TABLE product_availability
(
    product_id varchar(255)   NOT NULL FOREIGN KEY REFERENCES product (id),
    price      DECIMAL(18, 2) NOT NULL CHECK (price > 0),
    date       DATE           NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (product_id, date),
    INDEX product_availability_price NONCLUSTERED (price),
    INDEX product_availability_date NONCLUSTERED (date),
);
```