class LoginState {
  bool loading;
  String error;
  bool loggedIn;

  LoginState._internal({this.loading = false, this.error, this.loggedIn = false});

  factory LoginState.initial() => LoginState._internal();
  factory LoginState.loading() => LoginState._internal(loading: true);
  factory LoginState.error(String error) => LoginState._internal(error: error);
  factory LoginState.success() => LoginState._internal(loggedIn: true);
  
}