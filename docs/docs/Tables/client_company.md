# Client_company

Holds information about [clients](client) who are a company.
## Definition

```sql
CREATE TABLE client_company
(
    id           INT PRIMARY KEY FOREIGN KEY REFERENCES client (id),
    name         varchar(255)       NOT NULL,
    phone_number varchar(9)         NOT NULL CHECK (LEN(phone_number) = 9),
    nip          VARCHAR(10) UNIQUE NOT NULL CHECK (LEN(nip) = 10),
);
```