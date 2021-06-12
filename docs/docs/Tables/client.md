# Client

Holds all client IDs, regardless of whether they're a [company](client_company) or a [person](client_person).

Used to refer to a client, when the type of the client is not relevant.

## Definition

```sql
CREATE TABLE client
(
    id INT IDENTITY (1, 1) PRIMARY KEY,
);
```