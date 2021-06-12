# Client_person


Holds information about individual [clients](client).
## Definition

```sql
CREATE TABLE client_person
(
    id           INT PRIMARY KEY FOREIGN KEY REFERENCES client (id),
    first_name   varchar(255) NOT NULL,
    second_name  varchar(255) NOT NULL,
    phone_number varchar(9)   NOT NULL CHECK (LEN(phone_number) = 9),

    CONSTRAINT client_person_unique UNIQUE (first_name, second_name, phone_number)
);
```