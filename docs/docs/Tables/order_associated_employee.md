# Order_associated_employee

Holds information about employees associated with an order, that was made in a company's name.
## Definition

```sql
CREATE TABLE order_associated_employee
(
    employee_id INT NOT NULL FOREIGN KEY REFERENCES client_employee (id),
    order_id    INT NOT NULL FOREIGN KEY REFERENCES [order] (id),

    INDEX order_associated_employee_order_id (order_id),
)
```