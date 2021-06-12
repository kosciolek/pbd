# CopyProductsAvailableFromPreviousDay

An utility function built on top of [copyProductAvailability](copyProductAvailability) that copies all [product availability](../Tables/product_availability) to the target day from the previous day.


## Usage example

```sql
exec copyProductsAvailableFromPreviousDay @date = '2021-05-07'
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