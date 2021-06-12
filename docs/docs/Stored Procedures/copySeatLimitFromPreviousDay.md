# CopySeatLimitFromPreviousDay

An utility function built on top of [copySeatLimit](copySeatLimit) that copies the [seat limit](../Tables/seat_limit) to the target day from the previous day.


## Usage example

```sql
exec copyProductsAvailableFromPreviousDay @date = '2021-05-07'
```

## Definition

```sql
CREATE OR
ALTER PROCEDURE copySeatLimitFromPreviousDay @date DATE
AS
BEGIN
    BEGIN TRAN;
    if (@date IS NULL)
        SET @date = dateadd(day, 1, convert(date, getdate())); -- from today to tomorrow is default

    DECLARE @fromDate DATE;
    SET @fromDate = dateadd(day, -1, @date);
    exec copySeatLimit @fromDate, @date
    COMMIT TRAN;
END
GO
```