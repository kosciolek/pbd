# CopySeatLimit

An utility function that copies the [seat limit](../Tables/seat_limit) from the source day to the target day.


## Usage example

```sql
exec copySeatLimit @dateFrom = '2021-12-12', @dateTo = '2021-05-07'
```

## Definition

```sql
CREATE OR
ALTER PROCEDURE copySeatLimit @dateFrom DATE, @dateTo DATE
AS
BEGIN
    BEGIN TRAN;
    if (@dateFrom IS NULL OR @dateTo IS NULL)
        begin
            raiserror ('dateFrom and dateTo must be not null', 11, 1);
            return
        end


    if not exists(SELECT day as next_day, seats from seat_limit WHERE day = @dateFrom)
        BEGIN
            raiserror ('The source day does not have a seat limit set.', 11, 1)
            return;
        END

    insert into seat_limit (day, seats)
    SELECT @dateTo as dateTo, seats
    from seat_limit
    WHERE day = @dateFrom;
    COMMIT TRAN;
END
```