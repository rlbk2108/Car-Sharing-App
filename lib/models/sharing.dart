class Share {
  final int? id;
  final int client;
  final Map<String, dynamic>? fullClient;
  final Map<dynamic, dynamic> fullCar;
  final int car;
  final String dateOfIssue;
  final String dateOfReturn;
  final int numberOfDays;
  final int? finalPayment;


  Share({
        this.id,
        required this.client,
        required this.car,
        this.fullClient,
        required this.fullCar,
        required this.dateOfIssue,
        required this.dateOfReturn,
        required this.numberOfDays,
        this.finalPayment});

  factory Share.fromJson(Map<String, dynamic> json) {
    return Share(
      id: json['id'],
      client: json['client']['id'],
      car: json['car']['id'],
      fullClient: json['client'],
      fullCar: json['car'],
      dateOfIssue: json['date_of_issue'],
      dateOfReturn: json['date_of_return'],
      numberOfDays: json['number_of_days'],
      finalPayment: json['final_payment'],
    );
  }

  Map<dynamic, dynamic> toJson() => {
    'id': id,
    'car' : car,
    'client': client,
    'fullClient': fullClient,
    'fullCar': fullCar,
    'date_of_issue': dateOfIssue,
    'date_of_return': dateOfReturn,
    'number_of_days': numberOfDays,
    'final_payment': finalPayment,
  };
}