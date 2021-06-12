---
title: List of all Guards & implementations
sidebar_position: 2
---

## List

* `trCheckOnlyOneClientLinked_client` - Checks that for a given `id` inside [client](../Tables/client), there is only one client in either [client_person](../Tables/client_person) or [client_company](../Tables/client_company). Checks the client_person table.
* `trCheckOnlyOneClientLinked_company` - Checks that for a given `id` inside [client](../Tables/client), there is only one client in either [client_person](../Tables/client_person) or [client_company](../Tables/client_company). Checks the client_company table.
* `trProductAvailable` - Check that every [product](../Tables/product) [attached](../Tables/product_order) to an [order](../Tables/order) is [available](../Tables/product_availability) on that day.
* `trSeafood_order_product` - Checks that all seafood is ordered on a [seafood-enabled](../Tables/seafood_enabled_early_const) day **and** it is ordered before the last preceding monday.
* `trFreeSeatsReservation` - Checks that for every [reservation](../Tables/reservation), at all points in time, there is enough [free seats](../Tables/seat_limit).
* `trNoReservationForTakeaways_order` - Checks that takeaway orders have no reservation attached. Checks the order table.
* `trNoReservationForTakeaways_reservation` - Checks that takeaway orders have no reservation attached. Checks the reservation table.
* `trReservationsTimeLimit` - Checks that every [reservation](../Tables/reservation) respects the max reservation time limit implemented in [const](../Tables/const).
* `trNoReservationsOnAnonymousOrders` - Checks that anonymous orders (no [client](../Tables/client) attached) have no reservation attached.
* `trReservationsPaidEnough` - Checks that for every [reservation](../Tables/reservation) the client has paid enough. Takes parameters from [const](../Tables/const).
* `trDiscount_enough_spent` - Checks that for every [discount](../Tables/discount) the client has spent enough. Takes parameters from [const](../Tables/const).
* `trDiscount_one_discount_at_once` - Checks that for no client two [active discounts](../Tables/discount) are active at once.


## Implementations

```sql
CREATE OR ALTER TRIGGER trCheckOnlyOneClientLinked_client
    ON client_person
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT *
              FROM inserted cp
                       INNER JOIN client_company cc ON cc.id = cp.id)
        BEGIN
            RAISERROR ('A client can be only linked to one client_person or one client_company at once.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN
        END;
END;
GO

CREATE OR ALTER TRIGGER trCheckOnlyOneClientLinked_company
    ON client_company
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT *
              FROM inserted cc
                       INNER JOIN client_person AS cp
                                  ON cc.id = cp.id
        )
        BEGIN
            RAISERROR ('A client can be only linked to one client_person or one client_company at once.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN
        END;
END;
GO

-- Assert that every ordered product is available that day
CREATE OR ALTER TRIGGER trProductAvailable
    ON order_product
    AFTER INSERT, UPDATE
    AS
BEGIN

    if EXISTS(SELECT pa.date as availability_date
              FROM inserted i
                       INNER JOIN [order] o ON i.order_id = o.id
                       INNER JOIN product p ON p.id = i.product_id
                       LEFT JOIN product_availability pa
                                 ON p.id = pa.product_id AND pa.date = CONVERT(DATE, o.preferred_serve_time)
              WHERE pa.date IS NULL)
        BEGIN
            RAISERROR ('A product may only be ordered when it is available.', 16, 1);
            ROLLBACK TRANSACTION;
            return;
        END;
    return

END
GO;

-- Assert that all seafood is to be served on a seafood-enabled day and placed before the last monday
CREATE OR ALTER TRIGGER trSeafood_order_product
    ON order_product
    AFTER INSERT, UPDATE
    AS
BEGIN
    -- todo: should fire on order and product as well?


    if EXISTS(SELECT o.id as date
              FROM inserted op
                       LEFT JOIN [order] o ON o.id = op.order_id
                       LEFT JOIN product p ON op.product_id = p.id
              WHERE p.isSeafood = 1
                AND (DATENAME(WEEKDAY, CONVERT(DATE, preferred_serve_time)) NOT IN
                     (SELECT day FROM seafood_allowed_early_const) OR
                     o.date_placed > dbo.getPrevMonday(o.preferred_serve_time))
        )
        BEGIN
            RAISERROR ('A seafood product may only be served on a seafood-enabled day and before the last monday (including).', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;

-- Assert that there's enough free seats for every reservation
-- (This should be rewritten to use dbo.reservations, which is an indexed view, but I'll keep this trigger just to showcase)
CREATE OR ALTER TRIGGER trFreeSeatsReservation
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN
    -- This perhaps could be optimized. In its current form, a linear scan through orders must be made to establish how many seats are taken at a given datetime. The current crude optimization trick is to scan only orders made in the last max_reservation_minutes minutes, and preferred_serve_time is indexed

    DECLARE cur CURSOR FOR
        SELECT order_id, duration_minutes, seats FROM inserted

    DECLARE @order_id int, @duration_minutes INT, @seats INT;
    DECLARE @this_start_time DATETIME, @this_end_time DATETIME;
    DECLARE @seats_taken INT;
    DECLARE @seat_limit INT;
    DECLARE @max_reservation_minutes INT;

    SELECT @max_reservation_minutes = max_reservation_minutes FROM const;

    OPEN cur;
    FETCH NEXT FROM cur INTO @order_id, @duration_minutes, @seats

    WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @this_start_time = preferred_serve_time FROM [order] o WHERE o.id = @order_id;
            SELECT @this_end_time = DATEADD(minute, @duration_minutes, o.preferred_serve_time)
            FROM [order] o
            WHERE o.id = @order_id;
            SELECT @seat_limit = seats FROM seat_limit sl WHERE sl.day = CONVERT(DATE, @this_start_time);

            IF (@seat_limit IS NULL)
                BEGIN
                    RAISERROR ('A seat limit was not set for a day for which a reservation has been made.', 16, 1);
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;

            SELECT @seats_taken = (SELECT SUM(r.seats) AS seats_taken
                                   FROM [order] o
                                            LEFT JOIN reservation r on o.id = r.order_id
                                   WHERE (o.preferred_serve_time BETWEEN DATEADD(MINUTE, -@max_reservation_minutes, @this_start_time) AND @this_end_time)
                                     AND NOT (o.preferred_serve_time > @this_end_time OR
                                              DATEADD(MINUTE, r.duration_minutes, o.preferred_serve_time) <
                                              @this_start_time));

            if (@seats_taken > @seat_limit)
                BEGIN
                    RAISERROR ('A reservation may be only made when enough seats are free.', 16, 1);
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;

            FETCH NEXT FROM cur INTO @order_id, @duration_minutes, @seats
        END;
    CLOSE cur;
    DEALLOCATE cur;

    RETURN;
END
GO;

-- Assert takeaway orders do not have reservations
CREATE OR ALTER TRIGGER trNoReservationForTakeaways_order
    ON [order]
    AFTER INSERT, UPDATE
    AS
BEGIN

    if EXISTS(SELECT id
              from inserted o
                       INNER JOIN reservation r ON o.id = r.order_id AND o.isTakeaway = 1)
        BEGIN
            RAISERROR ('A takeaway order must not have a reservation.', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;

-- Assert takeaway orders do not have reservations
CREATE OR ALTER TRIGGER trNoReservationForTakeaways_reservation
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN
    if EXISTS(SELECT id
              from inserted r
                       INNER JOIN [order] o ON o.id = r.order_id AND o.isTakeaway = 1)
        BEGIN
            RAISERROR ('A takeaway order must not have a reservation.', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;

-- Assert reservations are not longer than the limit
CREATE OR ALTER TRIGGER trReservationsTimeLimit
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN

    DECLARE @max_reservation_minutes INT;
    SELECT @max_reservation_minutes = max_reservation_minutes FROM const;

    if EXISTS(SELECT order_id from inserted r WHERE r.duration_minutes > @max_reservation_minutes)
        BEGIN
            RAISERROR ('A reservation cannot exceed the reservation time limit.', 16, 1);
            ROLLBACK TRANSACTION;
            return;
        END;
    return
END
GO;

CREATE OR ALTER TRIGGER trNoReservationsOnAnonymousOrders
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN

    if EXISTS(select o.id
              from inserted r
                       left join [order] o on r.order_id = o.id
              where o.order_owner_id is null)
        BEGIN
            RAISERROR ('To make a reservation for an order, the order must have an owner.', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;


CREATE OR ALTER TRIGGER trReservationsPaidEnough
    ON reservation
    AFTER INSERT, UPDATE
    AS
BEGIN


    if EXISTS(select o.id
              from inserted r
                       left join [order] o on r.order_id = o.id
                       left join order_product op on o.id = op.order_id
              where order_owner_id is not null
                and (select sum(effective_price) 'price'
                     from order_product inner_op
                     where inner_op.order_id = r.order_id) <
                    iif((select count(inner_o.id)
                         from [order] inner_o
                         where inner_o.order_owner_id = o.order_owner_id) >=
                        (select min_orders_cheap_reservation from const),
                        (select cheap_reservation_price from const), (select expensive_reservation_price from const)))
        BEGIN
            RAISERROR ('The cost limit for a reservation has not been passed.', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;


-- Assert that the client has spent enough to make a discount
CREATE OR ALTER TRIGGER trDiscount_enough_spent
    ON discount
    AFTER INSERT, UPDATE
    AS
BEGIN

    DECLARE @k2 DECIMAL(18, 2);
    SELECT @k2 = k2 FROM const;

    if EXISTS(SELECT client_id, effective_price as 'total_spent', COUNT(client_id) as 'discounts_count'
              FROM discount as d
                       INNER JOIN (select client_id, sum(effective_price) as 'effective_price'
                                   from orders_per_client opc
                                   group by client_id) as spendings
                                  ON spendings.client_id = d.client_person_id
              where d.client_person_id in (select client_person_id from inserted)
              GROUP BY client_id, effective_price
              HAVING (COUNT(client_id) * @k2) > effective_price)
        BEGIN
            RAISERROR ('For at least one of the inserted discounts, the client''s total spendings are not enough.', 16, 1);
            ROLLBACK TRANSACTION;
            return
        END;
    return
END
GO;


-- Assert that a user does not have two discounts at once
CREATE OR ALTER TRIGGER trDiscount_one_discount_at_once
    ON discount
    AFTER INSERT, UPDATE
    AS
BEGIN
    select *
    from inserted id
             inner join discounts d on id.client_person_id = d.client_person_id and d.id != id.id
    WHERE NOT (id.date_start > d.date_end OR
               dateadd(DAY, (select d1 from const), id.date_start) < d.date_start)
    if EXISTS(select *
              from inserted id
                       inner join discounts d on id.client_person_id = d.client_person_id and d.id != id.id
              WHERE NOT (id.date_start > d.date_end OR
                         dateadd(DAY, (select d1 from const), id.date_start) < d.date_start)
        )
        BEGIN
            RAISERROR ('A client must not have two discounts active at once.', 16, 1);
            ROLLBACK TRANSACTION;
            return;
        END;
    return
END
GO;
```