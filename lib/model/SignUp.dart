// ignore_for_file: file_names

class SignUp {
  String name;
  String mobile;
  String password;
  String id;

  SignUp(
      {this.name = '',
      required this.mobile,
      required this.password,
      required this.id});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['mobile'] = mobile;
    data['password'] = password;
    data['id'] = id;
    return data;
  }
}
