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
    public LinkedList<Double> productsPrices;
    public int companysEmployeeId;
    public boolean addADiscount1ForClientPerson = false;
    public double costOfOrder;
    public boolean addADiscount2ForClientPerson = false;
    public boolean isValid = true;

    public Order(String dateTime, String preferredServeTime, int isTakeaway, int orderOwnerId, int accepted, int reservationSeats,
                 LinkedList<Integer> productsIds, int companysEmployeeId, boolean addADiscount1ForClientPerson, boolean addADiscount2ForClientPerson, String date, double costOfOrder,
                 boolean isValid, LinkedList<Double> productsPrices){
        this.dateTime = dateTime;
        this.preferredServeTime = preferredServeTime;
        this.isTakeaway = isTakeaway;
        this.orderOwnerId = orderOwnerId;
        this.accepted = accepted;
        this.reservationSeats = reservationSeats;
        this.productsIds = productsIds;
        this.companysEmployeeId = companysEmployeeId;
        this.addADiscount1ForClientPerson = addADiscount1ForClientPerson;
        this.addADiscount2ForClientPerson = addADiscount2ForClientPerson;
        this.date = date;
        this.costOfOrder = costOfOrder;
        this.isValid = isValid;
        this.productsPrices = productsPrices;

    }

}
