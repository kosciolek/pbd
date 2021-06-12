# Insert_client_person

Inserts a client that is a [person](../Tables/client_person) and automatically creates a relevant row in the [client](../Tables/client) table.

This function inserts only the minimal information required to create a person client. Additional information should be added manually.
## Usage example

```sql
exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
```

## Definition

```sql
CREATE OR
ALTER PROCEDURE insert_client_person @first_name varchar(255),
                                     @second_name varchar(255),
                                     @phone_number varchar(255)
AS
BEGIN
    BEGIN TRAN;
    DECLARE @id INT
    INSERT INTO client DEFAULT VALUES;
    SET @id = scope_identity()
    INSERT INTO client_person SELECT @id, @first_name, @second_name, @phone_number
    COMMIT TRAN;
    SELECT * from client_person WHERE id = @id
END
```