import com.github.javafaker.Faker;

import java.util.LinkedList;
import java.util.Locale;

public class ClientCompany {
    public int id;
    public String name;
    public String nip;
    public String phoneNumber;
    public LinkedList<ClientEmployee> listOfEmployees;

    public ClientCompany(int id){
        Faker faker = new Faker(new Locale("pl"));
        this.id = id;
        this.name = faker.company().name();
        this.nip = faker.number().digits(10);
        this.phoneNumber = faker.number().digits(9);
        listOfEmployees = new LinkedList<>();
    }
}
