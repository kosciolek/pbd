# Client_employee

Holds information about [clients](client) who are employees, for whom an [order](order) was made on the behalf of their [company](client_company).
## Definition

```sql
CREATE TABLE client_employee
(
    id           INT IDENTITY (1, 1) PRIMARY KEY,
    company_id   INT          NOT NULL FOREIGN KEY REFERENCES client_company (id),
    first_name   varchar(255) NOT NULL,
    second_name  varchar(255) NOT NULL,
    phone_number varchar(9) CHECK (LEN(phone_number) = 9),

    CONSTRAINT client_employee_unique UNIQUE (first_name, second_name, phone_number)
);
```