class Car {
  int? id;
  String? model;
  String? image;
  String? brand;
  double? price;
  String? status;
  int? pickup_counter;
  Car({this.id, this.model, this.image, this.brand, this.price, this.status , this.pickup_counter});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['car']['id'],
      model: json['car']['model'],
      image: json['car']['image'],
      brand: json['car']['brand'],
      price: json['car']['price'],
      status: json['car']['status'],
      pickup_counter: json['car']['pickup_counter'],
    );
  }
}
