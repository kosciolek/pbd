import com.github.javafaker.Faker;

import java.time.LocalDate;
import java.util.LinkedList;
import java.util.Locale;

public class SeaFoodDishes {
    public String name;
    public double defaultPrice;
    public double tax;
    public LinkedList<LocalDate> datesAvailable;

    public SeaFoodDishes(){
        Faker faker = new Faker(new Locale("pl"));
        this.name = faker.food().sushi();
        this.defaultPrice = faker.number().numberBetween(50, 70);
        this.tax = 1;
        this.datesAvailable = new LinkedList<>();
    }
}
