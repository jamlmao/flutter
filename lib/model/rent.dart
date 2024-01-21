class RentCar {
  int? id;
  int? user_id;
  int? car_id;
  String? status;
  DateTime? pickup_date;
  String? payment_status;
  double?amount;
  int?days;

  RentCar({this.id, this.user_id, this.car_id, this.status, this.pickup_date, this.payment_status,this.amount, this.days});

  factory RentCar.fromJson(Map<String, dynamic> json) {
    return RentCar(
      id: json['rented_cars']['id'],
      user_id: json['rented_cars']['user_id'],
      car_id: json['rented_cars']['car_id'],
      status: json['rented_cars']['status'],
      pickup_date: json['rented_cars']['pickup_date'],
      payment_status: json['rented_cars']['payment_status'],
      amount: json['rented_cars']['amount'],
      days: json['rented_cars']['days'],
    );
  }
}
