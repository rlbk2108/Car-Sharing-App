class Car {
  int? id;
  String model;
  String type;
  String color;
  String image;
  int mileage;
  int costPerDay;
  bool? isRented;


  Car({
      this.id,
      required this.model,
      required this.type,
      required this.image,
      required this.color,
      required this.costPerDay,
      required this.mileage});

  factory Car.fromJson(Map<dynamic, dynamic> json) {
    return Car(
      id: json['id'],
      model: json['model'],
      type: json['type'],
      image: json['image'],
      color: json['color'],
      costPerDay: json['cost_per_day'],
      mileage: json['mileage'],
    );
  }

  Map<dynamic, dynamic> toJson() => {
    'id': id,
    'model' : model,
    'type': type,
    'image': image,
    'color': color,
    'cost_per_day': costPerDay,
    'mileage': mileage,
  };
}