import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class SearchArtistName extends StatefulWidget {
  const SearchArtistName({Key? key});

  @override
  State<SearchArtistName> createState() => _SearchArtistState();
}

class _SearchArtistState extends State<SearchArtistName> {
  List<Map<String, dynamic>> _artists = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      _fetchArtists("");
    });
  }

  Future<void> _fetchArtists(String term) async {
    try {
      String url = "https://fluttermusicapp.000webhostapp.com/api/SearchArtist.php?firstName=$term&lastName=$term";
      var res = await http.get(Uri.parse(url));
      var response = jsonDecode(res.body);

      if (response is List) {
        setState(() {
          _artists = List<Map<String, dynamic>>.from(response);
        });
      } else {
        print('API returned unexpected data format.');
      }
    } catch (error) {
      print('Error fetching artists: $error');
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist List'),
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search Artists...',
            ),
            onChanged: (value) {
              _fetchArtists(value);
            },
          ),
          Expanded(
            child: _artists.isNotEmpty
                ? ListView.builder(
                    itemCount: _artists.length,
                    itemBuilder: (context, index) {
                      final artist = _artists[index];
                      return ListTile(
                         title: Text(artist['firstName']+' '+artist['lastName']),
                        onTap: () {
                         
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistDetailsScreen(artistId: int.parse(artist['id'])),
                             ),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('No Artists found')),
          ),
        ],
      ),
    );
  }
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
        child: Card(
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
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
     floatingActionButton: FloatingActionButton(
  onPressed: () async {
    List<String> artistSongs = await getArtistSongs(artistId);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: artistSongs.map((song) {
              return ListTile(
                title: Text(
                  song != null ? song : 'Unknown Title',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  },
  child: const Icon(Icons.music_note),
  tooltip: 'View All Songs',
),
    );
  }
}
Future<List<String>> getArtistSongs(int artistId) async {
  try {
    String url = "https://fluttermusicapp.000webhostapp.com/api/artistSongs.php?artistId=$artistId";
    print(url);

    var res = await http.get(Uri.parse(url));
    
    if (res.statusCode == 200) {
      var response = jsonDecode(res.body);
      print('API Response: $response');
      
      if (response is List) {
        List<String> titles = [];
        for (var song in response) {
          if (song is String) {
            titles.add(song);
          }
        }
        
        return titles.isNotEmpty ? titles : ['No valid songs found for this artist'];
      } else {
        return ['No valid songs found for this artist'];
      }
    }

    return ['No valid songs found for this artist'];
      
  } catch (error) {
    print('Error fetching Artist Songs: $error');
    return ['Error fetching data from the API'];
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



