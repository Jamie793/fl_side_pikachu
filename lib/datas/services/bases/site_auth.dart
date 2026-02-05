abstract class SiteAuth {
  
  Future<bool> login();

  bool isLogin();

  bool logout();

  Future<bool> handleLogin(dynamic res);
  
}
