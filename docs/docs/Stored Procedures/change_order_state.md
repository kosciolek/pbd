# Change_order_state

Changes the state of an [order](../Tables/order).

This procedure automatically sets the relevant date, i.e. `date_placed`, `date_accepted`, `date_completed`, `date_rejected` etc.


## Definition

```sql
CREATE OR
ALTER PROCEDURE change_order_state @order_id varchar(255), @state varchar(24)
AS
BEGIN
    IF (@state not in ('placed', 'accepted', 'rejected', 'completed'))
        begin
            raiserror ('@state must be in placed, completed, rejected or completed', 11, 1)
            return
        end

    IF not EXISTS(SELECT id FROM [order] WHERE id = @order_id)
        begin
            raiserror ('Such an order either does not exist or is already accepted, rejected or completed.', 11, 1)
            return
        end


    if (@state = 'placed')
        UPDATE [order] SET state = 'placed', date_placed = getdate() WHERE id = @order_id
    ELSE
        if (@state = 'accepted')
            UPDATE [order] SET state = 'accepted', date_accepted = getdate() WHERE id = @order_id
        ELSE
            if (@state = 'rejected')
                UPDATE [order] SET state = 'rejected', date_rejected = getdate() WHERE id = @order_id
            ELSE
                if (@state = 'completed')
                    UPDATE [order] SET state = 'completed', date_completed = getdate() WHERE id = @order_id

END
```