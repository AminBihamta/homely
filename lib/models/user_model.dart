/// apparently this is uneeded if using firebase auth
/// but am still keeping it here just in case (:
class UserModel {
  String email;
  String password;

  UserModel({required this.email, required this.password});
}

// // Hardcoded users list (temporary, in-memory)
// List<UserModel> users = [
//   UserModel(email: 'alice@email.com', password: 'alice123'),
//   UserModel(email: 'bob@email.com', password: 'bob456'),
//   UserModel(email: 'charlie@email.com', password: 'charlie789'),
//   UserModel(email: 'abcd@email.com', password: 'abcd1234'),
// ];

// // Login function
// bool login(String email, String password) {
//   return users.any((user) => user.email == email && user.password == password);
// }

// // Register function
// bool register(String email, String password) {
//   if (users.any((user) => user.email == email)) {
//     return false; // Email already exists
//   }
//   users.add(UserModel(email: email, password: password));
//   return true;
// }

// // Forgot password function
// bool resetPassword(String email, String newPassword) {
//   for (var user in users) {
//     if (user.email == email) {
//       user.password = newPassword;
//       return true;
//     }
//   }
//   return false; // Email not found
// }
