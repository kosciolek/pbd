import java.sql.*;
import java.time.LocalDate;
import java.time.Month;
import java.util.LinkedList;

public class JavaConnect2SQL {
    public static void main(String[] args) {

        String url = "url serwera";
        String user = "user";
        String password = "password";

        MakingData data = new MakingData();

        data.makeListOfClients();
        data.makeListOfClientCompanies();
        data.makeListOfClientEmployees();
        data.makeListOfClientPeople();
        data.makeListOfProducts1();
        data.makeListOfProducts2();



        LocalDate startDateOfRestaurant = LocalDate.of( 2018 , Month.MAY , 24);
        LocalDate startDatePlus3Years = LocalDate.of( 2021 , Month.MAY , 24);

        int orderId = 1;
        try{
            Connection connection = DriverManager.getConnection(url, user, password);
            Statement statement = connection.createStatement();
            for(Clients element : data.listOfClients){

                String sql = "INSERT INTO client DEFAULT VALUES";

                statement.executeUpdate(sql);

                System.out.println("connected to sql server");
            }
            for(ClientPerson element : data.listOfClientPeople){

                String sql = "INSERT INTO client_person (id, first_name, second_name, phone_number)" +
                        " VALUES (" + element.id + "," + "'" + element.firstName + "'" + "," + "'" + element.secondName +"'"+ "," + "'" + element.phoneNumber + "'" + ")";

                statement.executeUpdate(sql);

                System.out.println("connected to sql server");
            }
            for(ClientCompany element : data.listOfClientCompanies){

                String sql = "INSERT INTO client_company (id, name, phone_number, nip)" +
                        " VALUES (" + element.id + "," + "'" + element.name + "'" + "," + "'" + element.phoneNumber +"'"+ "," + "'" + element.nip + "'" + ")";

                statement.executeUpdate(sql);

                System.out.println("connected to sql server");
            }
            for(ClientEmployee element : data.listOfClientEmployees){

                String sql = "INSERT INTO client_employee (company_id, first_name, second_name, phone_number)" +
                        " VALUES (" + element.companyId + "," + "'" + element.firstName + "'" + "," + "'" + element.secondName +"'"+ "," + "'" + element.phoneNumber + "'" + ")";

                statement.executeUpdate(sql);

                System.out.println("connected to sql server");
            }
            for(BasicDishes element : data.listOfProducts1){

                String sql = "INSERT INTO product (name, default_price, tax_percent)" +
                        " VALUES (" + "'" + element.name + "'" + "," + element.defaultPrice + "," + element.tax + ")";

                statement.executeUpdate(sql);

                System.out.println("connected to sql server");
            }
            for(SeaFoodDishes element : data.listOfProducts2){

                String sql = "INSERT INTO product (name, default_price, tax_percent)" +
                        " VALUES (" + "'" + element.name + "'" + "," + element.defaultPrice + "," + element.tax + ")";

                statement.executeUpdate(sql);

                System.out.println("connected to sql server");
            }
            while(startDateOfRestaurant.isBefore(startDatePlus3Years)){
                LinkedList<ProductAvailability> listOfProductAvailability = data.makeListOfProductsAvailability1(startDateOfRestaurant, data.listOfProducts1);
                startDateOfRestaurant = startDateOfRestaurant.plusDays(14);
                for(ProductAvailability element : listOfProductAvailability){

                    String sql = "INSERT INTO product_availability (product_id, price, date)" +
                            " VALUES (" +  + element.productId  + "," + element.price + "," + "'" + element.date + "'" + ")";

                    statement.executeUpdate(sql);

                    System.out.println("connected to sql server");
                }
            }

            startDateOfRestaurant = LocalDate.of(2018 , Month.MAY , 24);

            while(startDateOfRestaurant.isBefore(startDatePlus3Years)){
                LinkedList<ProductAvailability> listOfProductAvailability = data.makeListOfProductsAvailability2(startDateOfRestaurant, data.listOfProducts2);
                startDateOfRestaurant = startDateOfRestaurant.plusDays(14);
                for(ProductAvailability element : listOfProductAvailability){

                    String sql = "INSERT INTO product_availability (product_id, price, date)" +
                            " VALUES (" +  + element.productId  + "," + element.price + "," + "'" + element.date + "'" + ")";

                    statement.executeUpdate(sql);

                    System.out.println("connected to sql server");
                }
            }

            data.makeListOfOrders();

            for(Order element : data.listOfOrders){

                String sql = "INSERT INTO dbo.[order] (placed_at, preferred_serve_time, isTakeaway, accepted, order_owner_id)" +
                        " VALUES (" + "'" + element.dateTime + "'" + "," + "'" + element.preferredServeTime + "'" + "," + element.isTakeaway + "," +
                        element.accepted + "," + element.orderOwnerId + ")";

                statement.executeUpdate(sql);

                for(int i = 0; i<element.productsIds.size(); i++){
                    sql = "INSERT INTO order_product (order_id, product_id)" +
                            " VALUES (" + orderId + ',' + element.productsIds.get(i) + ")";
                    System.out.println("dodawanie do order_product");
                    statement.executeUpdate(sql);
                }

                if(element.companysEmployeeId != 0){
                    sql = "INSERT INTO order_associated_employee (employee_id, order_id)" +
                            " VALUES (" + element.companysEmployeeId + ',' + orderId + ")";
                    statement.executeUpdate(sql);
                }
                if(element.reservationSeats != 0){
                    sql = "INSERT INTO reservation (order_id, seats)" +
                            " VALUES (" + orderId + ',' + element.reservationSeats + ")";
                    statement.executeUpdate(sql);
                }
                if(element.addADiscountForClientPerson){
                    sql = "INSERT INTO discount (date_start, client_person_id)" +
                            " VALUES (" + "'" +  element.date + "'" + ',' + element.orderOwnerId + ")";
                    System.out.println("dodawanie discount");
                    statement.executeUpdate(sql);
                }
                orderId++;
                System.out.println("xd2");
            }
            connection.close();

        }catch (SQLException e){
            System.out.println("oops, error: ");
            e.printStackTrace();
        }


    }
}
