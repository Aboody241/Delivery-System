class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneCode;
  final String phoneNumber;
  final String birthday;
  final String address;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneCode,
    required this.phoneNumber,
    required this.birthday,
    required this.address,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    String pCode = '';
    String pNum = '';
    
    final rawPhone = data['phone'] ?? '';
    if (rawPhone.startsWith('+')) {
      final parts = rawPhone.substring(1).split(' ');
      if (parts.length > 1) {
        pCode = parts[0];
        pNum = parts.sublist(1).join(' ');
      } else {
        pCode = '';
        pNum = rawPhone;
      }
    } else if (rawPhone.contains('countryCode:')) {
      final countryCodeMatch = RegExp(r'countryCode:\s*([0-9]+)').firstMatch(rawPhone);
      final nsnMatch = RegExp(r'nsn:\s*([0-9]+)').firstMatch(rawPhone);
      if (countryCodeMatch != null && nsnMatch != null) {
        pCode = countryCodeMatch.group(1) ?? '';
        pNum = nsnMatch.group(1) ?? '';
      } else {
        pCode = '';
        pNum = rawPhone;
      }
    } else {
      pCode = '';
      pNum = rawPhone;
    }

    return UserModel(
      uid: uid,
      name: data['nem'] ?? data['name'] ?? 'User',
      email: data['email'] ?? '',
      phoneCode: pCode,
      phoneNumber: pNum,
      birthday: data['birthday'] ?? '',
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    final phoneStr = phoneCode.isNotEmpty
        ? '+${phoneCode.replaceAll('+', '')} $phoneNumber'
        : phoneNumber;

    return {
      'nem': name,
      'email': email,
      'phone': phoneStr,
      'birthday': birthday,
      'address': address,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneCode,
    String? phoneNumber,
    String? birthday,
    String? address,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneCode: phoneCode ?? this.phoneCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
    );
  }
}
