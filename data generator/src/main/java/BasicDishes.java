import com.github.javafaker.Faker;

import java.time.LocalDate;
import java.util.LinkedList;


public class BasicDishes {
    public String name;
    public double defaultPrice;
    public double tax;
    public LinkedList<LocalDate> datesAvailable;
    public boolean isSeafood;

    public BasicDishes(){
        Faker faker = new Faker();
        this.name = faker.food().dish();
        this.defaultPrice = faker.number().numberBetween(40, 70);
        this.tax = 1;
        this.datesAvailable = new LinkedList<>();
    }
}
