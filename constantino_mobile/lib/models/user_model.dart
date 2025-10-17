enum LoginType {
  mongodb,
  firebase,
}

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? token;
  final String? firstName;
  final String? lastName;
  final String? age;
  final String? contactNumber;
  final String? address;
  final String? type;
  final LoginType loginType;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.firstName,
    this.lastName,
    this.age,
    this.contactNumber,
    this.address,
    this.type,
    this.loginType = LoginType.mongodb,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'viewer',
      token: json['token'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      contactNumber: json['contactNumber'],
      address: json['address'],
      type: json['type'],
      loginType: json['loginType'] == 'firebase' 
          ? LoginType.firebase 
          : LoginType.mongodb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (token != null) 'token': token,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (age != null) 'age': age,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (address != null) 'address': address,
      if (type != null) 'type': type,
      'loginType': loginType == LoginType.firebase ? 'firebase' : 'mongodb',
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
    String? firstName,
    String? lastName,
    String? age,
    String? contactNumber,
    String? address,
    String? type,
    LoginType? loginType,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      type: type ?? this.type,
      loginType: loginType ?? this.loginType,
    );
  }
}

