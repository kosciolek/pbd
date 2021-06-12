# GetEffectivePrice

Returns the effective price of a product for a client for a given day. This includes discounts.
## Usage example

```sql
dbo.getEffectivePrice('2021-05-23', 23, 'Kotlet Schabowy')
```

## Definition

```sql
CREATE OR
ALTER FUNCTION dbo.getEffectivePrice(@product_availability_date DATE, @client_id INT, @product_id varchar(255))
    RETURNS DECIMAL(18, 2) AS
BEGIN

    if (@product_availability_date is null or @product_id is null)
        begin
            return cast('Neither date nor product_id can be null.' as int);
        end

    SET @product_availability_date = convert(date, @product_availability_date);


    DECLARE @result DECIMAL(18, 2);
    if (@client_id is null)
        begin
            SELECT @result = price from product_availability where date = @product_availability_date;
        end
    else
        begin
            SELECT @result = (select price from product_availability where date = @product_availability_date) *
                             (select multiplier from price_multipliers where client_id = @client_id);
        end
    RETURN @result;
END
```