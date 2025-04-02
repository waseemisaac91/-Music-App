
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key?key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true; // Add a state variable for password visibility


  // Function to handle the registration process
  Future<void> _handleRegistration() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
          try {
          
          String url="https://fluttermusicapp.000webhostapp.com/api/registerCustomer.php";
          var res=await http.post(Uri.parse(url),body: {
            "username":_usernameController.text,
            "password":_passwordController.text,
            "firstName":_firstNameController.text,
            "lastName":_lastNameController.text,
            "email":_emailController.text,
            "address":_addressController.text,

          });
          
         // var response=jsonDecode(res.body);
          if(res.statusCode==200 || res.statusCode==201) {

          print("Customer Added!");
          _formKey.currentState!.reset();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added Customer successful')));
        }
        else
        {
        print("Customer Faild!");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added Customer Not Successfully')));
        }
        }
      catch (error) {
        print("Add Customer failed: $error");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added Customer failed')));
      } 
       finally {
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }




// ... rest of your code using escaped values


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Registration Page'),
          backgroundColor: Colors.grey,// Replace with your app title
    ),
    body: SingleChildScrollView(
    padding: const EdgeInsets.all(24.0),
    child: Form(
    key: _formKey,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    // App logo or image (optional)
    const FlutterLogo(size: 100.0),

    const SizedBox(height: 24.0),

    // Text fields for registration form
    TextFormField(
    controller: _usernameController,
    decoration:  InputDecoration(
    labelText: 'Username',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your username';
    }
    return null;
    },
    ),

      const SizedBox(height: 10.0),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword, // Apply password visibility
            decoration: InputDecoration(
              labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      10.0), // Rounded corners
                ),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
          ),
      const SizedBox(height: 10.0),
          TextFormField(
            controller: _firstNameController,
            decoration:  InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
      const SizedBox(height: 10.0),
          TextFormField(
            controller: _lastNameController,
            decoration:   InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
      const SizedBox(height: 10.0),
          TextFormField(
            controller: _emailController,
            decoration:  InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              // Add email validation logic here (e.g., using a regular expression)
              return null;
            },
          ),
      const SizedBox(height: 10.0),

          TextFormField(
            controller: _addressController,
            decoration:  InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
      const SizedBox(height: 20.0),
  
     SizedBox(
  height: 56.0, 
     child:  ElevatedButton(
        onPressed: _isLoading ? null : _handleRegistration,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Register'),
      ),
     )
    ],
    ),
    ),
    ),
    );
  }
}
