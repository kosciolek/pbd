# Copy seat limit - any day to any day

```sql
BEGIN TRANSACTION;

INSERT INTO seat_limit (day, seats) values ('2021-05-06', 10);

-- core
exec copySeatLimit @dateFrom = '2021-05-06', @dateTo = '2021-05-07'

SELECT * from seat_limit;

ROLLBACK TRANSACTION;
```