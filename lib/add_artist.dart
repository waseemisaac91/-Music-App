import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddArtistPage extends StatefulWidget {
  const AddArtistPage({Key? key}) : super(key: key);

  @override
  State<AddArtistPage> createState() => _AddArtistPageState();
}

class _AddArtistPageState extends State<AddArtistPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String?_selectedGender;
 // final List<String> _genders = ['Male', 'Female'];

  void addArtist() async {

        try {
          
          String url="https://fluttermusicapp.000webhostapp.com/api/insertArtist.php";
          var res=await http.post(Uri.parse(url),body: {
            "firstName":_firstNameController.text,
            "lastName":_lastNameController.text,
            "gender":_selectedGender,
            "country":_countryController.text

          });
          
         // var response=jsonDecode(res.body);
          if(res.statusCode==200 || res.statusCode==201) {

          print("Artist Added!");
          _formKey.currentState!.reset();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added Artist successful')));
        }
        else
        {
        print("Artist Faild!");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added Artist Not Successfully')));
        }
        }
      catch (error) {
        // Handle other errors (e.g., user input issues)
        print("Add Artist failed: $error");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added Artist failed')));
      } 
      }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Artist'), // Replace with your app title
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration:  InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist\'s first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _lastNameController,
                decoration:  InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist\'s last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              Row(
  children: <Widget>[
    Radio<String>(
      value: 'Male',
      groupValue: _selectedGender,
      onChanged: (value) {
        setState(() => _selectedGender = value);
      },
    ),
    const Text('Male'),
    Radio<String>(
      value: 'Female',
      groupValue: _selectedGender,
      onChanged: (value) {
        setState(() => _selectedGender = value);
      },
    ),
    const Text('Female'),
  ],
),
Text(
  _selectedGender == null ? 'Please select artist\'s gender' : '',
  style: TextStyle(color: Colors.red),
),
              // DropdownButtonFormField<String>(
              //   value: _selectedGender,
              //   hint: const Text('Select Gender'),
              //   items: _genders.map((gender) => DropdownMenuItem<String>(
              //     value: gender,
              //     child: Text(gender),
              //   )).toList(),
              //   onChanged: (value) => setState(() => _selectedGender = value),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please select artist\'s gender';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _countryController,
                decoration:  InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist\'s country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: ()=> addArtist(),
                child: const Text('Add Artist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
