# CopyProductAvailability

An utility function that copies all [product availability](../Tables/product_availability) from the source day to the target day.


## Usage example

```sql
exec copyProductAvailability @dateFrom = '2021-05-07', @dateTo = '2021-05-09'
```

## Definition

```sql
CREATE OR
ALTER PROCEDURE copyProductAvailability @dateFrom DATE, @dateTo DATE
AS
BEGIN
    BEGIN TRAN;
    if (@dateFrom IS NULL OR @dateTo IS NULL)
        begin
            raiserror ('dateFrom and dateTo must be not null', 11, 1);
            return;
        end

    if not exists(SELECT date from product_availability WHERE date = @dateFrom)
        BEGIN
            raiserror ('The source day does have any products available.', 11, 1)
            return
        END

    insert into product_availability (product_id, price, date)
    SELECT product_id, price, @dateTo
    from product_availability
    WHERE date = @dateFrom;
    COMMIT TRAN;
END
```