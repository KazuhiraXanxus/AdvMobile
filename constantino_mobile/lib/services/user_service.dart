import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserService {
  static const String _baseUrl = host;
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // Register user
  static Future<User> registerUser({
    required String firstName,
    required String lastName,
    required String age,
    required String gender,
    required String contactNumber,
    required String email,
    required String username,
    required String password,
    required String address,
    String type = 'viewer',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'gender': gender,
        'contactNumber': contactNumber,
        'email': email,
        'username': username,
        'password': password,
        'address': address,
        'type': type,
        'isActive': true,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      
      // Create user object from response
      final user = User(
        id: data['_id'] ?? data['id'] ?? '',
        name: '$firstName $lastName',
        email: email,
        role: type,
        token: null, // No token returned on registration
      );
      
      return user;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Login user
  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Backend returns user data directly, not nested in 'user' field
      final user = User(
        id: data['id'] ?? '',
        name: '${data['firstName']} ${data['lastName']}',
        email: email, // Use the email from login
        role: data['type'] ?? 'viewer',
        token: data['token'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        age: data['age'],
        contactNumber: data['contactNumber'],
        address: data['address'],
        type: data['type'],
        loginType: LoginType.mongodb, // Set login type to MongoDB
      );
      
      // Save to SharedPreferences
      await _saveUser(user);

      return user;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Save user to SharedPreferences
  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    if (user.token != null) {
      await prefs.setString('token', user.token!);
    }
  }

  // Get saved user
  static Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Get user data based on login type
  static Future<Map<String, dynamic>?> getUserData() async {
    final user = await getSavedUser();
    if (user == null) return null;

    if (user.loginType == LoginType.firebase) {
      // Return Firebase user data
      final userService = UserService();
      final firebaseUser = userService.currentUser;
      
      if (firebaseUser != null) {
        return {
          'id': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'User',
          'email': firebaseUser.email ?? '',
          'role': 'user',
          'loginType': 'firebase',
          'firstName': 'N/A',
          'lastName': 'N/A',
          'age': 'N/A',
          'contactNumber': 'N/A',
          'address': 'N/A',
          'type': 'user',
        };
      }
    } else {
      // Return MongoDB user data
      return {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'loginType': 'mongodb',
        'firstName': user.firstName ?? 'N/A',
        'lastName': user.lastName ?? 'N/A',
        'age': user.age ?? 'N/A',
        'contactNumber': user.contactNumber ?? 'N/A',
        'address': user.address ?? 'N/A',
        'type': user.type ?? 'N/A',
      };
    }
    
    return null;
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getSavedUser();
    return user != null;
  }

  // ==================== FIREBASE AUTH METHODS ====================
  
  // Get current Firebase user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Stream for auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Save Firebase user to SharedPreferences
    if (userCredential.user != null) {
      final user = User(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'User',
        email: userCredential.user!.email ?? '',
        role: 'user',
        loginType: LoginType.firebase,
      );
      await _saveUser(user);
    }
    
    return userCredential;
  }

  // Create account with email and password
  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // Also clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
  }

  // Update username/display name
  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }

  // Delete account (requires reauthentication)
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    firebase_auth.AuthCredential credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await _firebaseAuth.signOut();
  }

  // Reset password from current password
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    firebase_auth.AuthCredential credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

