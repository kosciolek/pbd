# Seafood_allowed_early_const

Holds days on which seafood may be ordered. Whether a product is a seafood or not is governed by [product](product).

## Default values

```sql
INSERT INTO seafood_allowed_early_const
VALUES ('thursday'),
       ('friday'),
       ('saturday');
```

## Definition

```sql
create table seafood_allowed_early_const
(
    day varchar(24) NOT NULL CHECK (day IN
                                    ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday')),
);
```