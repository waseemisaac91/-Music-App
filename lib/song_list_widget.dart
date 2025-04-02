import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SongListWidget extends StatefulWidget {
  final bool showList; 

  const SongListWidget({Key? key, required this.showList}) : super(key: key);

  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongListWidget> {
  List<Map<String, dynamic>> songs = []; // Store fetched songs

  @override
  void initState() {
    super.initState();
    _fetchSongs(); // Fetch songs on initialization
  }

Future<List<Map<String, dynamic>>> _fetchSongs() async {
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
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs List'), // Replace with your app title
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
  future: _fetchSongs(), // Replace with your function to fetch songs
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error fetching songs data'));
    } else if (snapshot.hasData) {
      List<Map<String, dynamic>> songs = snapshot.data!;
      return songs.isEmpty
          ? const Center(child: Text('No Songs found'))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                // Update the following section to display song information
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongFullDetailsScreen(id: int.parse(song['id'])),
                    ),
                  ),
                  child: Card(
                    // Update card design as needed
                    color: Colors.grey[200],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Update this section to display song details
                          Row(
                            children: [
                              const Icon(Icons.music_note),
                              const SizedBox(width: 10.0),
                              Text(
                                song['title'], // Replace with appropriate key for song title
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SongFullDetailsScreen(id: int.parse(song['id'])),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
    } else {
      return const Center(child: Text('No data available'));
 }
      },
    ),
  );
  }
}

 class SongFullDetailsScreen extends StatelessWidget {
  final int id;

  const SongFullDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Info'), // Replace with your app title
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        child: SizedBox(
          width: double.maxFinite, // Occupy entire width of the page
          height: MediaQuery.of(context).size.height * 0.3, // Set height to 30% of screen
          child: Card(
            color: Colors.grey[200], // Similar background color as ArtistDetailsScreen
            elevation: 5, // Similar elevation as ArtistDetailsScreen
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getSongsDetailsById(id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<Map<String, dynamic>> songList = snapshot.data!;
                    final Map<String, dynamic> song = songList.isNotEmpty ? songList[0] : {};
                    return FutureBuilder<String>(
                      future: getArtistNameById(int.parse(song['artistId'])),
                      builder: (context, artistSnapshot) {
                        if (artistSnapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Title:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    song['title'] ?? 'Unknown Title',
                                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Type:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    song['type'] ?? 'Unknown Type',
                                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Price:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    song['price']?.toString() ?? 'Unknown Price', // Ensure it's converted to string
                                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Artist Name:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    artistSnapshot.data ?? 'Unknown Artist',
                                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else if (artistSnapshot.hasError) {
                          return Text('Error fetching artist name');
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error fetching song details');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}



    Future<List<Map<String, dynamic>>> getSongsDetailsById(int id) async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/allsongs.php?id=$id"; // Include the 'id' parameter in the URL
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

  Future<String> getArtistNameById(int id) async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/allartists.php?id=$id";
    var res = await http.get(Uri.parse(url));
    var response = jsonDecode(res.body);

    if (response.containsKey('artistName')) {
      return response['artistName'];
    } else {
      return 'Unknown Artist';
    }
  } catch (e) {
    print('Error fetching artist name: $e');
    return 'Unknown Artist';
  }
}





