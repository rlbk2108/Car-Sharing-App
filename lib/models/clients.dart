class Client {
  final int id;
  final String username;
  final String email;
  final int balance;


  Client({required this.id,
          required this.username,
          required this.balance,
          required this.email,
  });

  factory Client.fromJson(Map<dynamic, dynamic> json) {
    return Client(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      balance: json['balance'],
    );
  }

  Map<dynamic, dynamic> toJson() => {
    'id': id,
    'initials' : username,
    'email': email,
    'balance': balance,
  };

}