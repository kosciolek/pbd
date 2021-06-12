# Order

Holds information about an order.

## States

* `placed` - the order has been made by a client, but reviewed by the staff
* `accepted` - accepted by the staff and waits to be served
* `rejected` - rejected by the staff
* `completed` - the order has been successfully completed
## Definition

```sql
create table [order]
(
    id                   int IDENTITY (1, 1) PRIMARY KEY,

    preferred_serve_time DATETIME NOT NULL DEFAULT GETDATE(),
    isTakeaway           BIT      NOT NULL DEFAULT 0,

    order_owner_id       INT FOREIGN KEY REFERENCES client (id),


    state                varchar(24)       default 'placed' CHECK (state in ('placed', 'accepted', 'rejected', 'completed')),

    date_placed          DATETIME not null default getdate(),
    date_accepted        datetime,
    date_rejected        datetime,
    date_completed       datetime,

    note                 varchar(2048),

    CONSTRAINT preferred_serve_time_bigger_than_date_placed CHECK (preferred_serve_time >= date_placed),
    INDEX order_state NONCLUSTERED (state),
    INDEX order_preferred_serve_time NONCLUSTERED (preferred_serve_time),
    INDEX order_date_placed NONCLUSTERED (date_placed),
    INDEX order_date_accepted NONCLUSTERED (date_accepted),
    INDEX order_date_rejected NONCLUSTERED (date_rejected),
    INDEX order_date_completed NONCLUSTERED (date_completed),
);
```