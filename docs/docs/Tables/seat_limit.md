# Seat_limit

Holds information about the amount of seats available for [reservations](reservation) on a given day.
## Definition

```sql
CREATE TABLE seat_limit
(
    day   DATE PRIMARY KEY,
    seats INT NOT NULL,
)
```