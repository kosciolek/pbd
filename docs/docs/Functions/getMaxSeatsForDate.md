# GetMaxSeatsForDate

Returns the amount of seats free for the given day.
## Usage example

```sql
dbo.getMaxSeatsForDate(CONVERT(DATE, GETDATE()))
```
## Definition

```sql
CREATE OR
ALTER FUNCTION dbo.getMaxSeatsForDate(@date DATE)
    RETURNS INT AS
BEGIN
    DECLARE @result INT;
    SELECT @result = (SELECT seats FROM seat_limit WHERE day = @date);
    RETURN @result;
END
```