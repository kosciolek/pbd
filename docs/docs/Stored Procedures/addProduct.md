# AddProduct

Adds a [product](../Tables/product) to the list of products ordered for an [order](../Tables/order). 

Note this requires an appropriate [product availability](../Tables/product_availability) to be present.

This procedure automatically calculates the effective price of the added product, including [discounts](../Tables/discount).
## Usage example
```sql
exec addProduct @order_id = 23, @product_id = 'Kotlet schabowy'
```
## Definition

```sql
CREATE OR
ALTER PROCEDURE addProduct @order_id int, @product_id varchar(255)
AS
BEGIN
    BEGIN TRAN;
    if (@order_id IS NULL OR @product_id IS NULL)
        begin
            raiserror ('order_id and product_id must not be null', 11, 1);
            return
        end


    if ((select order_owner_id from [order] where id = @order_id) is null OR
        dbo.getClientType((select order_owner_id from [order] where id = @order_id)) = 'company')
        begin
            insert into order_product (order_id, effective_price, product_id)
            values (@order_id, (select price
                                from product_availability pa
                                where pa.product_id = @product_id
                                  AND pa.date = CONVERT(date,
                                            (select preferred_serve_time from [order] o where o.id = @order_id))),
                    @product_id);
        end
    else
        begin
            insert into order_product (order_id, effective_price, product_id)
            values (@order_id, (select multiplier
                                from price_multipliers
                                where client_id = (select order_owner_id from [order] where id = @order_id)) *
                               (select price
                                from product_availability pa
                                where pa.product_id = @product_id
                                  AND pa.date = CONVERT(date,
                                            (select preferred_serve_time from [order] o where o.id = @order_id))),
                    @product_id);
        end
    COMMIT TRAN;
END;
```