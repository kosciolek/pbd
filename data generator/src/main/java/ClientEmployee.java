import com.github.javafaker.Faker;

import java.util.Locale;

public class ClientEmployee {
    public int companyId;
    public String firstName;
    public String secondName;
    public String phoneNumber;
    public int clientEmployeeId;

    public ClientEmployee(int companyId, int clientEmployeeId){
        Faker faker = new Faker(new Locale("pl"));
        this.companyId = companyId;
        this.firstName = faker.name().firstName();
        this.secondName = faker.name().lastName();
        this.phoneNumber = faker.number().digits(9);
        this.clientEmployeeId = clientEmployeeId;
    }
}
