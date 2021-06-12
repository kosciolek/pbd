# Product

Holds information about product types.

This table exists for every product type, regardless of whether it's active or not. Whether a product may be ordered on a given day is governed by [product_availability](product_availability).
## Definition

```sql
create table product
(
    id          varchar(255)  NOT NULL PRIMARY KEY,
    tax_percent DECIMAL(4, 2) NOT NULL CHECK (tax_percent BETWEEN 0 AND 1),
    isSeafood   BIT           NOT NULL DEFAULT 0,
    description VARCHAR(2048),

    INDEX product_isSeafood NONCLUSTERED (isSeafood),
);
```