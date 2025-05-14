import '../models/user_model.dart';

class AuthService {
  static List<UserModel> get _users => users;
  static UserModel? _loggedInUser;

  static UserModel? get currentUser => _loggedInUser;

  static bool signUp(String email, String password) {
    final existingUser = _users.any((user) => user.email == email);
    if (existingUser) return false;
    _users.add(UserModel(email: email, password: password));
    return true;
  }

  static bool signIn(String email, String password) {
    final user = _users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => UserModel(email: '', password: ''),
    );
    if (user.email.isEmpty) return false;
    _loggedInUser = user;
    return true;
  }

  static bool resetPassword(String email) {
    final exists = _users.any((user) => user.email == email);
    return exists;
  }

  static void signOut() {
    _loggedInUser = null;
  }
}
