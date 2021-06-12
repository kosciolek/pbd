# Insert_client_company

Inserts a client that is a [company](../Tables/client_company) and automatically creates a relevant row in the [client](../Tables/client) table.

This function inserts only the minimal information required to create a company client. Additional information should be added manually.
## Usage example

```sql
exec insert_client_person @name = 'Jankowski & Friends', @phone_number = '645867354', @nip = '7892713452'
```
## Definition

```sql
CREATE OR
ALTER PROCEDURE insert_client_company @name varchar(255),
                                      @phone_number varchar(9),
                                      @nip VARCHAR(10)
AS
BEGIN
    BEGIN TRAN;
    DECLARE @id INT
    INSERT INTO client DEFAULT VALUES;
    SET @id = scope_identity()
    INSERT INTO client_company SELECT @id, @name, @phone_number, @nip
    COMMIT TRAN;
    SELECT * from client_company WHERE id = @id
END
```