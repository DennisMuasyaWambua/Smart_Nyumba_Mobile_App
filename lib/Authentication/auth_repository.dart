class AuthRepository{
  Future<void> login() async{
      print("attempting to login");
      await Future.delayed(Duration(seconds: 3));
      print("logged in");
  }
}