import javax.xml.transform.Result;
import java.sql.*;
import java.time.LocalDate;
import java.time.Month;
import java.util.LinkedList;

public class JavaConnect2SQL {
    public static void main(String[] args) {

        String url = "jdbc:sqlserver://pbd.kosciolek.dev:1433;databaseName=p3";
        String user = "sa";
        String password = "SomePassword0)0)";

        MakingData data = new MakingData();

        data.makeListOfClients();
        data.makeListOfClientCompanies();
        data.makeListOfClientEmployees();
        data.makeListOfClientPeople();
        data.makeListOfProducts1();
        data.makeListOfProducts2();



        LocalDate startDateOfRestaurant = LocalDate.of( 2018 , Month.MAY , 24);
        LocalDate startDatePlus3Years = LocalDate.of( 2021 , Month.JUNE , 10);

        int orderId = 1;
        try{
            Connection connection = DriverManager.getConnection(url, user, password);
            Statement statement = connection.createStatement();

            for(Clients element : data.listOfClients){

                String sql = "INSERT INTO client DEFAULT VALUES";

                statement.execute(sql);

                System.out.println("connected to sql server");
            }
            for(ClientPerson element : data.listOfClientPeople){

                String sql = "INSERT INTO client_person (id, first_name, second_name, phone_number)" +
                        " VALUES (" + element.id + "," + "'" + element.firstName + "'" + "," + "'" + element.secondName +"'"+ "," + "'" + element.phoneNumber + "'" + ")";

                statement.execute(sql);

                System.out.println("connected to sql server");
            }
            for(ClientCompany element : data.listOfClientCompanies){

                String sql = "INSERT INTO client_company (id, name, phone_number, nip)" +
                        " VALUES (" + element.id + "," + "'" + element.name + "'" + "," + "'" + element.phoneNumber +"'"+ "," + "'" + element.nip + "'" + ")";

                statement.execute(sql);

                System.out.println("connected to sql server");
            }
            for(ClientEmployee element : data.listOfClientEmployees){

                String sql = "INSERT INTO client_employee (company_id, first_name, second_name, phone_number)" +
                        " VALUES (" + element.companyId + "," + "'" + element.firstName + "'" + "," + "'" + element.secondName +"'"+ "," + "'" + element.phoneNumber + "'" + ")";

                statement.execute(sql);

                System.out.println("connected to sql server");
            }
            int j = 1;
            for(BasicDishes element : data.listOfProducts1){

                String sql = "INSERT INTO product (id, tax_percent, isSeafood, description)" +
                        " VALUES (" + j + "," +  element.tax  + "," + 0 + "," + "'" +  element.name + "'" + ")";

                statement.execute(sql);

                System.out.println("connected to sql server");
                j++;
            }
            for(SeaFoodDishes element : data.listOfProducts2){

                String sql = "INSERT INTO product (id, tax_percent, isSeafood, description)" +
                        " VALUES ("+ j + "," + element.tax  + "," + 1 + "," + "'" + element.name + "'" + ")";

                statement.execute(sql);

                System.out.println("connected to sql server");
                j++;
            }
            while(startDateOfRestaurant.isBefore(startDatePlus3Years)){
                LinkedList<ProductAvailability> listOfProductAvailability = data.makeListOfProductsAvailability1(startDateOfRestaurant, data.listOfProducts1);
                startDateOfRestaurant = startDateOfRestaurant.plusDays(14);
                for(ProductAvailability element : listOfProductAvailability){

                    String sql = "INSERT INTO product_availability (product_id, price, date)" +
                            " VALUES ("  + element.productId  + "," + element.price + "," + "'" + element.date + "'" + ")";

                    statement.execute(sql);

                    System.out.println("connected to sql server");
                }
            }

            startDateOfRestaurant = LocalDate.of(2018 , Month.MAY , 24);

            while(startDateOfRestaurant.isBefore(startDatePlus3Years)){
                LinkedList<ProductAvailability> listOfProductAvailability = data.makeListOfProductsAvailability2(startDateOfRestaurant, data.listOfProducts2);
                startDateOfRestaurant = startDateOfRestaurant.plusDays(14);
                for(ProductAvailability element : listOfProductAvailability){

                    String sql = "INSERT INTO product_availability (product_id, price, date)" +
                            " VALUES (" + element.productId  + "," + element.price + "," + "'" + element.date + "'" + ")";

                    statement.execute(sql);

                    System.out.println("connected to sql server");
                }
            }

            startDateOfRestaurant = LocalDate.of(2018 , Month.MAY , 24);

            while(startDateOfRestaurant.isBefore(startDatePlus3Years)){
                String sql = "INSERT INTO seat_limit (day, seats)" +
                        " VALUES (" + "'" + startDateOfRestaurant + "'" + "," + 70 + ")";

                statement.execute(sql);

                System.out.println("connected to sql server");

                startDateOfRestaurant = startDateOfRestaurant.plusDays(1);
            }

            data.makeListOfOrders();

            for(Order element : data.listOfOrders){
                if(element.isValid){

                    String sql = "INSERT INTO dbo.[order] (preferred_serve_time, isTakeaway, order_owner_id, date_placed)" +
                            " VALUES (" + "'" + element.preferredServeTime + "'" + "," + element.isTakeaway + ","
                              + element.orderOwnerId + "," + "'" + element.dateTime + "'" + ")";

                    statement.execute(sql);

                    for(int i = 0; i<element.productsIds.size(); i++){
                        sql = "INSERT INTO order_product (order_id, product_id, effective_price)" +
                                " VALUES (" + orderId + "," + element.productsIds.get(i) + "," +  element.productsPrices.get(i) + ")";
                        statement.execute(sql);
                    }

                    if(element.companysEmployeeId != 0){
                        sql = "INSERT INTO order_associated_employee (employee_id, order_id)" +
                                " VALUES (" + element.companysEmployeeId + ',' + orderId + ")";
                        statement.execute(sql);
                    }
                    if(element.reservationSeats != 0){
                        sql = "INSERT INTO reservation (order_id, seats)" +
                                " VALUES (" + orderId + ',' + element.reservationSeats + ")";
                        statement.execute(sql);
                    }

                    if(element.addADiscount2ForClientPerson){
                        sql = "INSERT INTO discount (date_start, client_person_id)" +
                                " VALUES (" + "'" +  element.date + "'" + ',' + element.orderOwnerId + ")";
                        statement.execute(sql);
                    }
                    orderId++;

                }
            }
            connection.close();

        }catch (SQLException e){
            System.out.println("oops, error: ");
            e.printStackTrace();
        }


    }
}
