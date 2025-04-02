import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class artistListWidget extends StatefulWidget {
  final bool showList; // Flag for toggling between list and grid view (optional)

  const artistListWidget({Key? key, required this.showList}) : super(key: key);

  @override
  _ArtistListState createState() => _ArtistListState();
}

class _ArtistListState extends State<artistListWidget> {


List<Map<String,dynamic>>  _artists =[];
 // Store fetched artists
  @override
  void initState() {
    super.initState();
    _fetchArtists(); // Fetch artists on initialization
  }

// Fetch artists and store them in the _artists list
Future<List<Map<String, dynamic>>> _fetchArtists() async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/allartists.php";
    var res = await http.get(Uri.parse(url));
    var response = jsonDecode(res.body);

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      print('API returned unexpected data format.');
      return [];
    }
  } catch (error) {
    print('Error fetching artists: $error');
    return [];
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Artist List'),
      backgroundColor: Theme.of(context).primaryColor,
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchArtists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching artists data'));
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> artists = snapshot.data!;

          return artists.isEmpty
              ? Center(child: Text('No Artists found'))
              : Scrollbar(
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(), // Enable scrolling
                    shrinkWrap: true,
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistDetailsScreen(artistId: artist['id']),
                          ),
                        ),
                        child: Card(
                          color: Colors.grey,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(color: Colors.lightBlue, width: 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      '${artist['firstName']} ${artist['lastName']}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArtistDetailsScreen(artistId: int.parse(artist['id'])),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    ),
  );
}


  deleteArtist(artist) {}
}


  Future<String> getArtistNameById(int id) async {

    try {
  
    String url = "https://fluttermusicapp.000webhostapp.com/api/allartists.php?id=$id";
    var res = await http.get(Uri.parse(url));
    var response = jsonDecode(res.body);

    if (response is List && response.isNotEmpty) {
      String artistFirstName = response[0]['firstName'];
      String artistLastName = response[0]['lastName'];
      
      return '$artistFirstName +' '+$artistLastName';
    } else {
      return 'Unknown Artist';
    }
  } catch (error) {
    print('Error fetching artist details: $error');
    return 'Unknown Artist';
  }
  }


class ArtistDetailsScreen extends StatelessWidget {
  final int artistId;

  const ArtistDetailsScreen({Key? key, required this.artistId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Info'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.grey,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.black87, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getArtistDetailsById(artistId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final artist = snapshot.data!.isNotEmpty ? snapshot.data!.first : {};
                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ListTile(
                            title: Text('First Name:'),
                            subtitle: Text(artist['firstName'] ?? 'Unknown'),
                          ),
                          ListTile(
                            title: Text('Last Name:'),
                            subtitle: Text(artist['lastName'] ?? 'Unknown'),
                          ),
                          ListTile(
                            title: Text('Gender:'),
                            subtitle: Text(artist['gender'] ?? 'Unknown'),
                          ),
                          ListTile(
                            title: Text('Country:'),
                            subtitle: Text(artist['country'] ?? 'Unknown'),
                          ),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }

}

  Future <List<Map<String, dynamic>>> getArtistDetailsById(int id) async {
    try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/artists.php?id=$id"; // Include the 'id' parameter in the URL
    print(url);
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


