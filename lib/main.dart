// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
//  FIRST ATTEMPT //
// ---------------- LOGIN PAGE ----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Debug print
      print("Login successful: ${userCredential.user?.email}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userEmail: email)),
      );
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}, ${e.message}");

      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'Email format is invalid.';
      } else if (e.code == 'user-disabled') {
        message = 'User account has been disabled.';
      } else {
        message = e.message ?? 'Login failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print("Other exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An unknown error occurred")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text("Welcome Back",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your email";
                      if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your password";
                      if (value.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Login", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Forgot password + signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage()));
                          },
                          child: const Text("Forgot Password?")),
                      TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const SignUpPage()));
                          },
                          child: const Text("Create Account")),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- SIGN UP PAGE ----------------
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print("SignUp successful: ${userCredential.user?.email}");

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')));
      Navigator.pop(context); // Back to login
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}, ${e.message}");

      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'Email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Email format is invalid.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are not enabled.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else {
        message = e.message ?? 'Signup failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print("Other exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("An unknown error occurred")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) => value!.isEmpty ? "Enter email" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      })),
              validator: (value) =>
                  value!.length < 6 ? "Password must be at least 6 chars" : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _signUp, child: const Text("Sign Up")),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------- FORGOT PASSWORD PAGE ----------------
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      print("Password reset email sent to ${_emailController.text}");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password reset email sent')));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}, ${e.message}");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    } catch (e) {
      print("Other exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An unknown error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Enter your email"),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _resetPassword, child: const Text("Reset")),
          )
        ]),
      ),
    );
  }
}

// ---------------- HOME PAGE ----------------
// ---------------- HOME PAGE ----------------
class HomePage extends StatelessWidget {
  final String userEmail;
  const HomePage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'title': 'Crop Advisory (AI)', 'icon': Icons.agriculture, 'page': CropAdvisorPage()},
      {'title': 'Soil Health & Fertilizer', 'icon': Icons.eco, 'page': SoilHealthPage()},
      {'title': 'Weather Alerts', 'icon': Icons.cloud, 'page': WeatherPage()},
      {'title': 'Pest & Disease Detection', 'icon': Icons.bug_report, 'page': PestDetectionPage()},
      {'title': 'Market Price Tracking', 'icon': Icons.shopping_cart, 'page': MarketPricePage()},
      {'title': 'Voice Support', 'icon': Icons.mic, 'page': VoiceSupportPage()},
      {'title': 'Feedback', 'icon': Icons.feedback, 'page': FeedbackPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Advisor"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $userEmail",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => feature['page']));
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(feature['icon'], size: 40, color: Colors.green),
                          const SizedBox(height: 10),
                          Text(
                            feature['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- DUMMY FEATURE PAGES ----------------
class CropAdvisorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("AI Crop Advisory")),
        body: const Center(child: Text("Multilingual AI crop advisory here")));
  }
}

class SoilHealthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Soil Health & Fertilizer")),
        body: const Center(child: Text("Soil health recommendations here")));
  }
}

class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Weather Alerts")),
        body: const Center(child: Text("Weather-based insights here")));
  }
}

class PestDetectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Pest & Disease Detection")),
        body: const Center(child: Text("Upload image for pest detection")));
  }
}

class MarketPricePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Market Price Tracking")),
        body: const Center(child: Text("Live crop market prices here")));
  }
}

class VoiceSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Voice Support")),
        body: const Center(child: Text("Voice assistant support here")));
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Feedback")),
        body: const Center(child: Text("Feedback & data collection here")));
  }
}
