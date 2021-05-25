import com.github.javafaker.Faker;
import java.util.Locale;

public class ClientPerson {
    public int id;
    public String firstName;
    public String secondName;
    public String phoneNumber;
    public int numberOfOrdersAbove30 = 0;
    public boolean hasDiscount = false;


    public ClientPerson(int id){
        Faker faker = new Faker(new Locale("pl"));
        this.id = id;
        this.firstName = faker.name().firstName();
        this.secondName = faker.name().lastName();
        this.phoneNumber = faker.number().digits(9);
    }
}
