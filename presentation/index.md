```sql
BEGIN TRANSACTION

insert client default values;
DECLARE @id INT = scope_identity();

insert client_company (id, name, phone_number, nip) values (@id, 'Some Company', '789456867', '1010101010');

insert client_person (id, first_name, second_name, phone_number) values (@id, 'Jan', 'Kowalzgi', '123321123')

ROLLBACK TRANSACTION


BEGIN TRANSACTION

insert client default values;
DECLARE @id INT = scope_identity();

insert client_person (id, first_name, second_name, phone_number) values (@id, 'Jan', 'Kowalzgi', '123321123')

insert client_company (id, name, phone_number, nip) values (@id, 'Some Company', '789456867', '1010101010');

ROLLBACK TRANSACTION
```