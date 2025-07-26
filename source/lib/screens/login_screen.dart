import 'package:flutter/material.dart';
import 'package:sooraneh_mobile/screens/home_screen.dart';
import 'package:sooraneh_mobile/services/api_service.dart';
import 'package:sooraneh_mobile/utils/jwt_storage.dart';
import 'package:sooraneh_mobile/utils/log_service.dart';



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  // تابع ارسال درخواست لاگین به API
  Future<bool> _login() async {
    final url = Uri.parse('https://freetux.pythonanywhere.com/api/auth/login/');
    final body = {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // چاپ برای دیباگ
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        if (token != null) {
          await JwtStorage.saveToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ورود')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'نام کاربری',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'نام کاربری الزامی است';
                  }
                  if (value.length > 150) {
                    return 'نام کاربری نباید بیشتر از 150 کاراکتر باشد';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'رمز عبور',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رمز عبور الزامی است';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _loading = true);
                          final success = await _login();
                          setState(() => _loading = false);

                          if (success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('نام کاربری یا رمز عبور اشتباه است'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'ورود',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('صفحه ثبت‌نام هنوز پیاده‌سازی نشده')),
                  );
                },
                child: Text('حساب کاربری ندارید؟ ثبت‌نام کنید'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _loading = false;
  bool _isAdmin = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await _apiService.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _passwordController.text,
      _isAdmin,
    );

    setState(() => _loading = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ثبت‌نام موفقیت‌آمیز بود!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ثبت‌نام. نام کاربری یا ایمیل تکراری است.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ثبت‌نام')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'نام کاربری'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'نام کاربری الزامی است';
                  if (value.length > 150) return 'حداکثر 150 کاراکتر';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'ایمیل'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'ایمیل الزامی است';
                  if (!value.contains('@')) return 'ایمیل نامعتبر است';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'نام'),
                validator: (value) => value?.isEmpty ?? true ? 'نام الزامی است' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'نام خانوادگی'),
                validator: (value) => value?.isEmpty ?? true ? 'نام خانوادگی الزامی است' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'رمز عبور'),
                validator: (value) => value?.isEmpty ?? true ? 'رمز عبور الزامی است' : null,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('مدیر سیستم'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),
              SizedBox(height: 24),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: Text('ثبت‌نام'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}