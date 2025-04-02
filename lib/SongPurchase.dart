import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musicapp_flutter/User.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';




class SongPurchasePage extends StatefulWidget {
   final String? currentUser;
   

  const SongPurchasePage({Key? key, required this.currentUser});

  @override
  _SongPurchasePageState createState() => _SongPurchasePageState();
}

class _SongPurchasePageState extends State<SongPurchasePage> {
  List<Map<String, dynamic>> songs = [];
  double totalPrice=0.0;

  List<String> selectedSongs=[];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  // Fetch songs data when the widget initializes
  }

  Future<void> _fetchSongs() async {
    final fetchedSongs = await _fetchSongsFromApi();
    setState(() {
      songs = fetchedSongs;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchSongsFromApi() async {
    // Function to fetch songs data from the API
    try {
      String url = "https://fluttermusicapp.000webhostapp.com/api/allsongs.php";
      var res = await http.get(Uri.parse(url));
      var response = jsonDecode(res.body);

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        print('API returned unexpected data format.');
        return [];
      }
    } catch (error) {
      print('Error fetching Songs: $error');
      return [];
    }
  }

  Future<void> updatePrice(Map<String, dynamic> song) async {
  double songPrice = await _getPrice(int.parse(song['id']));
  if (selectedSongs.contains(song['title'])) {
    selectedSongs.remove(song['title']);
    totalPrice -= songPrice;
  } else {
    selectedSongs.add(song['title']);
    totalPrice += songPrice;
  }
}

Future<double> _getPrice(int songId) async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/songPrice.php?id=$songId";
    var res = await http.get(Uri.parse(url));
    var response = jsonDecode(res.body);

    if (response.containsKey('error')) {
      print('Error: ${response['error']}');
      return 0.0; // Return a default price of 0.0 in case of an error
    } else {
      return double.tryParse(response['price'].toString()) ?? 0.0; // Return the parsed price as a double
    }
  } catch (error) {
    print('Error fetching song price: $error');
    return 0.0; // Return a default price of 0.0 in case of an error
  }
}


  @override
Widget build(BuildContext context) {
 final String currentUser = ModalRoute.of(context)!.settings.arguments  as String;

  return Scaffold(
    appBar: AppBar(title: Text('Song Details')),
    body: SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20.0,
        columns: [
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Action')),
        ],
        rows: songs.map((song) {
          return DataRow(
            cells: [
              DataCell(Text(song['title'].toString())),
              DataCell(Text(song['type'].toString())),
              DataCell(Text(song['price'].toString())),
              DataCell(IconButton(
                icon: Icon(
                  selectedSongs.contains(song['title']) ? Icons.check_circle : Icons.add_circle_outline,
                ),
             onPressed: () async {
  await updatePrice(song);
  setState(() {
    // Update the UI if necessary after updating the price
  });    }

              )),
            ],
          );
        }).toList(),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {

   int customerId= await _getCustomerID(currentUser) ?? 0;

       // Navigate to credit card entry page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditCardPage(currentUser:customerId,
              selectedSongs: selectedSongs,
              totalPrice: totalPrice,
            ),
          ),
        );
      },
      child: Icon(Icons.credit_card),
    ),
  );
}

Future<int> _getCustomerID(String username) async {
  String url = "https://fluttermusicapp.000webhostapp.com/api/getCustomerID.php?username=$username";
  print(username);
  
  try {
    var res = await http.get(Uri.parse(url));
    
    if (res.statusCode == 200) {
      var jsonRes = jsonDecode(res.body);

      if (jsonRes is List) {
        if (jsonRes.isNotEmpty) {
          return jsonRes[0]['id'] as int ?? 0;
        } else {
          print('Error: Customer not found');
          return 0;
        }
      } else {
        print('Error: Invalid response format');
        return 0;
      }
    } else {
      print('Error: Failed to fetch data, status code ${res.statusCode}');
      return 0;
    }
  } catch (error) {
    print('Error fetching customer ID: $error');
    return 0; 
  }
}
}

class CreditCardPage extends StatelessWidget {
  final List<String> selectedSongs;
  final double totalPrice;
  final int currentUser;
  

  CreditCardPage({required this.selectedSongs, required this.totalPrice,required this.currentUser});
 TextEditingController _creditCardController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {

      void showConfirmationDialog(int invoiceId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Confirmation'),
        content: Text('You have successfully purchased the selected songs! With invoice ID: $invoiceId '),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

    DateTime now = DateTime.now();
String formattedDate = DateFormat('yyyy-MM-dd').format(now);
String formattedTime = DateFormat.Hms().format(now);
String formattedDateTimeString = '$formattedDate $formattedTime';
DateTime formattedDateTime = DateTime.parse(formattedDateTimeString);
String creditCardNumber = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Credit Card Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selected Songs:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(selectedSongs.join(', ')),
            SizedBox(height: 10),
            Text(
              'Total Price: \$ $totalPrice',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            
       TextFormField(
  controller: _creditCardController,
  decoration: InputDecoration(
    labelText: 'Credit Card Number',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
  maxLength: 16, // Maximum character length allowed
  keyboardType: TextInputType.number, // Set the keyboard type to numeric
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allow only numeric input
  ],
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your credit card number';
    } else if (value.length < 12 || value.length > 16) {
      return 'Credit card number should be between 12 and 16 numbers';
    }
    return null;
  },
), 
ElevatedButton(
  onPressed: () async {
    if (_creditCardController.text.isEmpty) {
      // Display error message if credit card number is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid credit card number.')),
      );
    } else {
       int iid= await saveInvoice(currentUser, formattedDateTime, totalPrice, _creditCardController.text);
      
     await saveOrder(iid, selectedSongs);
       showConfirmationDialog(iid); 
      // Navigation or further actions after saving invoice and order
    }
  },
              child: Text('Submit'),
            ),
          ],
          
        ),
      ),
    );

  }
}


Future<int> saveInvoice(int customerId, DateTime date, double total, String creditCard) async {
  try {
    String url = "http://fluttermusicapp.000webhostapp.com/api/addInvoice.php";
    
    var res = await http.post(Uri.parse(url), body: {
      "customerId": customerId.toString(),
      "date": date.toIso8601String(),
      "total": total.toString(),
      "creditCard": creditCard,
    });

    if (res.statusCode == 200 || res.statusCode == 201) {
        var response = jsonDecode(res.body);
        print(response);
        
            int id = response['lastId'];
            return id;
        }
    else {
      print('Error: Failed to save invoice, status code ${res.statusCode}');
      return 0;
    }
   
  } catch (error) {
    print("Add Invoice failed: $error");
    return 0;
  }
}

Future<void> saveOrder(int invoiceId, List<String> selectedSongs) async {
  for (String songTitle in selectedSongs) {
    int songId = await getSongId(songTitle);
    
    if (songId != 0) {
     await saveSongOrder(songId, invoiceId);
     
    } else {
      print('Skipping order saving for $songTitle due to missing Song ID');
     
    }
  }
}
  // Function to get the Song_id based on songTitle (You need to implement this part)
 Future<int> getSongId(String songTitle) async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/getsongId.php?title=$songTitle";
    var res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      var response = jsonDecode(res.body);

      if (response.containsKey('id')) {
        return int.parse(response['id'].toString());
      } else {
        print('Song ID not found for $songTitle');
        return 0;
      }
    } else {
      print('Failed to fetch Song ID. HTTP Error: ${res.statusCode}');
      return 0;
    }
  } catch (error) {
    print('Error fetching Song ID: $error');
    return 0;
  }
}



  // Function to save Song_id and Invoice_id into the 'order' table
  Future<void> saveSongOrder(int songId, int invoiceId) async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/addOrder.php?songId=$songId&invoiceId=$invoiceId";
    
    var res = await http.post(Uri.parse(url), body: {
      "songId": songId.toString(),
      "invoiceId": invoiceId.toString(),
    });
    
    if (res.statusCode == 200 || res.statusCode == 201) {
      var response = jsonDecode(res.body);
       int id = response['lastId'];
           

      print("Add Order Successfully!");
    
    } else {
      print("Order Failed!");
    
    }
  } catch (error) {
    print("Add Order failed: $error");

  }
  
  print('Saving Song_id: $songId to Invoice_id: $invoiceId');
 
}
