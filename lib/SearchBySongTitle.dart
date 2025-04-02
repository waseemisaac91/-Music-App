import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


// Define the DebounceBloc events and states
class SearchBySongTitle extends StatefulWidget {
  const SearchBySongTitle({Key? key}) : super(key: key);

  @override
  State<SearchBySongTitle> createState() => _SearchSongState();
}

class _SearchSongState extends State<SearchBySongTitle> {
  List<Map<String, dynamic>> songs = [];
  TextEditingController searchController = TextEditingController();

 @override
void initState() {
  super.initState();

  // Add a delay of 3 seconds before fetching songs
  Future.delayed(const Duration(seconds: 1), () {
    _fetchSongs("");
  });
}
  Future<void> _fetchSongs(String term) async {
    try {
      String url = "https://fluttermusicapp.000webhostapp.com/api/SearchSong.php?title=$term";
      var res = await http.get(Uri.parse(url));
      var response = jsonDecode(res.body);

      if (response is List) {
        setState(() {
          songs = List<Map<String, dynamic>>.from(response);
        });
      } else {
        print('API returned unexpected data format.');
      }
    } catch (error) {
      print('Error fetching Songs: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Search'),
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search Songs...',
            ),
            onChanged: (value) {
              _fetchSongs(value);
            },
          ),
          Expanded(
            child: songs.isNotEmpty
                ? ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return ListTile(
                        title: Text(song['title']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongFullDetailsScreen(id:int.parse(song['id'])),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('No Songs found')),
          ),
        ],
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

