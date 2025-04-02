import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AddSongPage extends StatefulWidget {
  const AddSongPage({Key? key}) : super(key: key);

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _artistIdController = TextEditingController();


List _artists = []; // List to store artist data
  String? _selectedArtist; // Selected artist ID (or name, depending on your database design)

  @override
  void initState() {
    super.initState();
    _getArtists(); // Fetch artist data on initialization
  }

  Future<void> _getArtists() async {
    try {
      _artists = await getallArtist();
      setState(() {
        // Update UI based on data availability
        if (_artists.isEmpty) {
          print('No artists found in the database.'); // Optional logging
        }
      });
    } catch (error) {
      // Handle errors appropriately (e.g., show a snackbar or error message)
      print('Error fetching artists: $error');
    }
  }
  Future <dynamic> getallArtist() async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/allartists.php";
    var res = await http.get(Uri.parse(url));
    //var artists = jsonDecode(res.body);
    var artists = jsonDecode(res.body);
   // Cast to List<dynamic> initially
    print(artists);
    return artists;
  } catch (error) {
    print('Error decoding artist data: $error');
    // Handle the error appropriately (e.g., return an empty list)
    return []; // Example: return an empty list on error
  }
}


  void addSong() async {
       try {
         int id = int.parse(_selectedArtist!); // Parse _selectedArtist to int
    String url = "https://fluttermusicapp.000webhostapp.com/api/addsong.php";
    var res = await http.post(Uri.parse(url), body: {
      "title": _titleController.text,
      "type": _typeController.text,
      "price": _priceController.text,
      "artistId": id.toString(), // Convert id back to String for sending in the request
    });
          
         // var response=jsonDecode(res.body);
          if(res.statusCode==200 || res.statusCode==201) {

          print("Song Added!");
          _formKey.currentState!.reset();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added Song successful')));
        }
        else
        {
        print("Song Faild!");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added Song Not Successfully')));
        }
        }
      catch (error) {
        // Handle other errors (e.g., user input issues)
        print("Add Song failed: $error");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added Song failed')));
      } 
      }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Add Song'), // Replace with your app title
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
                controller: _titleController,
                decoration:  InputDecoration(
                  labelText: 'Song Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter song title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _typeController,
                decoration:  InputDecoration(
                  labelText: 'Song Type (e.g., Pop, Rock)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter song type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration:  InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter song price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedArtist,
                hint: const Text('Select Artist'),
                items: _artists.isEmpty
                    ? [const DropdownMenuItem(child: Text('Loading...'))]
                    : _artists.map((artist) {
                  final String artistName = artist['firstName'] + ' ' + artist['lastName'];
                  return DropdownMenuItem<String>(
                    value: artist['id'].toString(),
                    child: Text(artistName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedArtist = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select artist';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () =>addSong(),
                child: const Text('Add Song'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
