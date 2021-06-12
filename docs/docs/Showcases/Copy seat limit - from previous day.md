# Copy seat limit - from previous day

```sql
BEGIN TRANSACTION;

INSERT INTO seat_limit (day, seats) values ('2021-05-06', 10);

-- core
exec copySeatLimitFromPreviousDay @date = '2021-05-07'

SELECT * from seat_limit;

ROLLBACK TRANSACTION;
```