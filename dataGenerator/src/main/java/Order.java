import java.util.LinkedList;


public class Order {
    public String dateTime;
    public String preferredServeTime;
    public String date;
    public int isTakeaway;
    public int orderOwnerId;
    public int accepted;
    public int reservationSeats;
    public LinkedList<Integer> productsIds;
    public int companysEmployeeId;
    public boolean addADiscountForClientPerson = false;

    public Order(String dateTime, String preferredServeTime, int isTakeaway, int orderOwnerId, int accepted, int reservationSeats, LinkedList<Integer> productsIds, int companysEmployeeId, boolean addADiscountForClientPerson, String date){
        this.dateTime = dateTime;
        this.preferredServeTime = preferredServeTime;
        this.isTakeaway = isTakeaway;
        this.orderOwnerId = orderOwnerId;
        this.accepted = accepted;
        this.reservationSeats = reservationSeats;
        this.productsIds = productsIds;
        this.companysEmployeeId = companysEmployeeId;
        this.addADiscountForClientPerson = addADiscountForClientPerson;
        this.date = date;
    }

}
