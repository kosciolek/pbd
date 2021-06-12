# Const

Holds various constant values.

Only one row of this table may exist in the database.

:::caution
The values in this table should be set only at the creation of a database and be constant throughout its lifecycle. Changing them may result in improper discount calculations (e.g. a client that previous had a discount might not have it anymore).
:::

## Definition

```sql
create table const
(
    z1                           int            NOT NULL DEFAULT 10,
    k1                           decimal(18, 2) NOT NULL DEFAULT 30 CHECK (k1 > 0),
    r1                           decimal(4, 2)  NOT NULL DEFAULT 0.03 CHECK (r1 BETWEEN 0 AND 1), -- percent

    k2                           decimal(18, 2) NOT NULL DEFAULT 1000 CHECK (k2 > 0),
    r2                           decimal(4, 2)  NOT NULL DEFAULT 0.05 CHECK (r2 BETWEEN 0 AND 1), -- percent
    d1                           int            NOT NULL DEFAULT 7,

    min_orders_cheap_reservation int            NOT NULL DEFAULT 5,
    cheap_reservation_price      DECIMAL(18, 2) NOT NULL DEFAULT 50 CHECK (cheap_reservation_price > 0),
    expensive_reservation_price  DECIMAL(18, 2) NOT NULL DEFAULT 200 CHECK (expensive_reservation_price > 0),

    max_reservation_minutes      INT            NOT NULL DEFAULT 1440 CHECK (max_reservation_minutes > 0
        ),

-- ensure only one row exists
    Lock                         char(1)        not null DEFAULT 'X',
    constraint PK_T1 PRIMARY KEY (Lock),
    constraint CK_T1_Locked CHECK (Lock = 'X')
);
```