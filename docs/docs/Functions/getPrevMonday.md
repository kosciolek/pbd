# GetPrevMonday

Returns the date of the last monday before the given date.

Used to validate seafood orders.
## Usage example

```sql
dbo.getPrevMonday(CONVERT(DATE, GETDATE()))
```

## Definition

```sql
CREATE OR
ALTER FUNCTION dbo.getPrevMonday(@date DATE)
    RETURNS DATE AS
BEGIN
    RETURN dateadd(week,datediff(week,0, @date),0)
END
```