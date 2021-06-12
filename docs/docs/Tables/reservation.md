# Reservation

Holds information about a potential reservation made for an [order](order).
## Definition

```sql
create table reservation
(
    order_id         INT PRIMARY KEY FOREIGN KEY REFERENCES [order] (id),
    duration_minutes INT NOT NULL DEFAULT 90,
    seats            INT NOT NULL DEFAULT 2 CHECK (seats >= 2),

    INDEX order_associated_employee_order_id NONCLUSTERED (order_id)
);
```