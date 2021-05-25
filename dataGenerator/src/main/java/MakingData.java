import com.github.javafaker.Faker;

import java.sql.Time;
import java.time.LocalDate;
import java.time.Month;
import java.util.*;

public class MakingData {
    
    public LinkedList<Clients> listOfClients;
    public LinkedList<ClientCompany> listOfClientCompanies;
    public LinkedList<ClientPerson> listOfClientPeople;
    public LinkedList<ClientEmployee> listOfClientEmployees;
    public LinkedList<BasicDishes> listOfProducts1;
    public LinkedList<SeaFoodDishes> listOfProducts2;
    public LinkedList<Order> listOfOrders;

    public MakingData(){
        this.listOfClients = new LinkedList<>();
        this.listOfClientCompanies = new LinkedList<>();
        this.listOfClientEmployees = new LinkedList<>();
        this.listOfClientPeople = new LinkedList<>();
        this.listOfProducts1 = new LinkedList<>();
        this.listOfProducts2 = new LinkedList<>();
        this.listOfOrders = new LinkedList<>();
    }

    public void makeListOfClients(){

        for(int i = 0; i<10000; i++){
            listOfClients.add(new Clients());
        }
    }

    public void makeListOfClientPeople(){
        
        for(int i = 1; i<=9700; i++){
            listOfClientPeople.add(new ClientPerson(i));
        }
 
    }

    public void makeListOfClientCompanies(){

        for(int i = 9701; i<=10000; i++){
            listOfClientCompanies.add(new ClientCompany(i));
        }
    }

    public void makeListOfClientEmployees(){
        Faker faker = new Faker();
        int clientEmployeeId = 1;
        for(int i = 9701; i<=10000; i++){
            int j = faker.number().numberBetween(2, 21);
            if(j!=0){
                while(j>0){
                    ClientEmployee clientEmployee = new ClientEmployee(i, clientEmployeeId);
                    listOfClientEmployees.add(clientEmployee);
                    listOfClientCompanies.get(i - 9701).listOfEmployees.add(clientEmployee);
                    clientEmployeeId++;
                    j--;
                }
            }
        }
    }

    //list of basic dishes with no seafood
    public void  makeListOfProducts1(){

        for(int i = 0; i<300; i++){
            listOfProducts1.add(new BasicDishes());
        }
        
    }
    //list of seafood dishes
    public void makeListOfProducts2(){

        for(int i = 0; i<20; i++){
            listOfProducts2.add(new SeaFoodDishes());
        }
    }

    public LinkedList<ProductAvailability> makeListOfProductsAvailability1(LocalDate menusDate, List<BasicDishes> listOfProducts){

        LinkedList<ProductAvailability> listOfProductAvailability = new LinkedList<>();

        LinkedList<Integer> idsOfProductsInMenu = new LinkedList<>();
        
        ArrayList<Integer> list = new ArrayList<>();
        for (int i=1; i<=300; i++) {
            list.add(i);
        }
        Collections.shuffle(list);
        for (int i=0; i<50; i++) {
            idsOfProductsInMenu.add(list.get(i));
        }

        for(int element : idsOfProductsInMenu){
            listOfProductAvailability.add(new ProductAvailability(element, listOfProducts.get(element-1).defaultPrice, menusDate.toString()));
            listOfProducts1.get(element-1).datesAvailable.add(menusDate);
        }

        return listOfProductAvailability;
    }

    public LinkedList<ProductAvailability> makeListOfProductsAvailability2(LocalDate menusDate, List<SeaFoodDishes> listOfProducts){

        LinkedList<ProductAvailability> listOfProductAvailability = new LinkedList<>();

        LinkedList<Integer> idsOfProductsInMenu = new LinkedList<>();


        ArrayList<Integer> list = new ArrayList<>();
        for (int i=301; i<=320; i++) {
            list.add(i);
        }
        Collections.shuffle(list);
        for (int i=0; i<5; i++) {
            idsOfProductsInMenu.add(list.get(i));
        }

        for(int element : idsOfProductsInMenu){
            listOfProductAvailability.add(new ProductAvailability(element, listOfProducts.get(element - 301).defaultPrice, menusDate.toString()));
            listOfProducts2.get(element - 301).datesAvailable.add(menusDate);
        }

        return listOfProductAvailability;
    }

    public void makeListOfOrders(){
        LocalDate startDateOfRestaurant = LocalDate.of( 2018 , Month.MAY , 24);
        LocalDate startDatePlus3Years = LocalDate.of( 2021 , Month.MAY , 24);

        Faker faker = new Faker();
        int numberOfOrders;
        final int millisIn22Hours = 22*60*60*1000;
        final int millisIn10Hours = 10*60*60*1000;

        while(startDateOfRestaurant.isBefore(startDatePlus3Years)){
            numberOfOrders = faker.number().numberBetween(40, 60);

            for(int i = 0; i<numberOfOrders; i++){
                String date = startDateOfRestaurant.toString();
                String dateTime = startDateOfRestaurant.toString() + " " + new Time(faker.number().numberBetween(millisIn10Hours, millisIn22Hours)).toString();
                int isTakeaway = faker.number().numberBetween(0, 2);
                int isReservation = 0;
                if(isTakeaway == 0){
                    isReservation = faker.number().numberBetween(0, 2);
                }

                String preferredServeTime = dateTime;
                int reservationSeats = 0;
                double costOfOrder = 0;
                int companysEmployeeId = 0;
                LocalDate reservationDate = null;
                boolean addADiscountForClientPerson = false;
                LinkedList<Integer> listOfProductsOrdered = new LinkedList<>();

                if(isReservation==1){
                    reservationDate = startDateOfRestaurant.plusDays(faker.number().numberBetween(1, 10));
                    preferredServeTime = reservationDate.toString() + " " + new Time(faker.number().numberBetween(millisIn10Hours, millisIn22Hours)).toString();
                    reservationSeats = faker.number().numberBetween(2, 6);
                }
                int numberOfBasicProducts = faker.number().numberBetween(2, 6);

                ArrayList<Integer> list = new ArrayList<>();
                for (int j=1; j<=300; j++) {
                    list.add(j);
                }
                Collections.shuffle(list);
                int iteratorPrime = 0;
                while(listOfProductsOrdered.size() < numberOfBasicProducts && iteratorPrime < 300) {
                    for(int iterator = 0; iterator<this.listOfProducts1.get(list.get(iteratorPrime) - 1).datesAvailable.size(); iterator++){
                        if(this.listOfProducts1.get(list.get(iteratorPrime) - 1).datesAvailable.get(iterator).isAfter(startDateOfRestaurant.plusDays(-1)) &&
                                this.listOfProducts1.get(list.get(iteratorPrime) - 1).datesAvailable.get(iterator).isBefore(startDateOfRestaurant.plusDays(14))){
                            listOfProductsOrdered.add(list.get(iteratorPrime));
                            System.out.println("dodaje sie czy nie");
                            costOfOrder += listOfProducts1.get(list.get(iteratorPrime) - 1).defaultPrice;
                        }
                    }
                    iteratorPrime++;

                }
                if(isReservation == 1 && reservationDate.isAfter(startDateOfRestaurant.plusDays(5))){
                    int numberOfSeaFoodProducts = faker.number().numberBetween(0, 3);
                    ArrayList<Integer> list2 = new ArrayList<>();
                    for (int j=301; j<=320; j++) {
                        list2.add(j);
                    }
                    Collections.shuffle(list2);
                    iteratorPrime = 0;
                    while((listOfProductsOrdered.size() < numberOfSeaFoodProducts + numberOfBasicProducts) && iteratorPrime < 20 ) {
                        for(int iterator = 0; iterator<this.listOfProducts2.get(list2.get(iteratorPrime) - 301).datesAvailable.size(); iterator++){
                            if(this.listOfProducts2.get(list2.get(iteratorPrime) - 301).datesAvailable.get(iterator).isBefore(startDateOfRestaurant.plusDays(14)) &&
                                    this.listOfProducts2.get(list2.get(iteratorPrime) - 301).datesAvailable.get(iterator).isAfter(startDateOfRestaurant.plusDays(-1))){
                                listOfProductsOrdered.add(list2.get(iteratorPrime));
                                costOfOrder += listOfProducts2.get(list2.get(iteratorPrime) - 301).defaultPrice;
                            }
                        }
                        iteratorPrime++;
                    }
                }

                int clientId = faker.number().numberBetween(1, 10001);
                if(clientId <= 9700){
                    if(costOfOrder > 30){
                        listOfClientPeople.get(clientId-1).numberOfOrdersAbove30++;
                    }
                    if(listOfClientPeople.get(clientId-1).hasDiscount){
                        costOfOrder = costOfOrder * 0.97;
                    }
                    if(listOfClientPeople.get(clientId-1).numberOfOrdersAbove30>5 && !listOfClientPeople.get(clientId - 1).hasDiscount){
                        costOfOrder = costOfOrder * 0.97;
                        listOfClientPeople.get(clientId-1).hasDiscount = true;
                        addADiscountForClientPerson = true;
                        System.out.println("czy zmienia sie discount");
                    }

                }
                else{
                    companysEmployeeId = listOfClientCompanies.get(clientId-9701).listOfEmployees.get(faker.number()
                            .numberBetween(1, listOfClientCompanies.get(clientId-9701).listOfEmployees.size())).clientEmployeeId;
                }
                listOfOrders.add(new Order(dateTime, preferredServeTime, isTakeaway, clientId, 1, reservationSeats,
                        listOfProductsOrdered, companysEmployeeId, addADiscountForClientPerson, date));
                System.out.println("xd1");
            }
            startDateOfRestaurant = startDateOfRestaurant.plusDays(1);
        }
    }
}
