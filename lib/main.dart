import 'package:flutter/material.dart';
import 'package:musicapp_flutter/add_artist.dart'; // Replace with your AddArtistPage path
import 'package:musicapp_flutter/add_song.dart'; // Replace with your AddSongPage path
import 'package:musicapp_flutter/login_page.dart';
import 'package:musicapp_flutter/register.dart';
import 'package:musicapp_flutter/song_list_widget.dart';
import 'package:musicapp_flutter/SongPurchase.dart';
import 'package:musicapp_flutter/Artist_list_widget.dart';
import 'package:musicapp_flutter/SearchBySongTitle.dart';
import 'package:musicapp_flutter/SearchByArtistName.dart';
import 'package:musicapp_flutter/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Add an enum for user roles (admin, customer)

  void main() async {

  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key,}) : super(key: key);


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // Call the function to fetch songs on initialization
  }

  // Stores the currently logged-in user (optional)
  String? currentUser;
void _handleLogout(BuildContext context) {
  setState(() {
    currentUser = null;
  });

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
        ),
      ),


    initialRoute: currentUser == null ? '/login' : '/home', // Set initial route based on login status
    routes: {
    '/login': (context) => LoginPage(),//onLogin: _handleLogin), // Login route with callback
     '/register': (context) => const RegistrationPage(),
    '/home': (context)   => MyHomePage(title: 'Music App Home Page',currentUser: currentUser),
     '/add-artist': (context) => const AddArtistPage(), // Admin-restricted route
     '/add-song': (context) => const AddSongPage(),
     '/SongListWidget': (context) =>  SongListWidget(showList: true,),
     '/artistListWidget': (context) =>  artistListWidget(showList: true),
      '/SearchBySongTitle': (context) =>  SearchBySongTitle(),
      '/SearchArtistName': (context) =>  SearchArtistName(),
      '/SongPurchasePage': (context) =>  SongPurchasePage(currentUser:currentUser),
    },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final String? currentUser;

  const MyHomePage( {Key? key, required this.title,required this.currentUser}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Scaffold(
   appBar: AppBar(
  title:  Text(title), // Replace with your app title
  backgroundColor: Theme.of(context).primaryColor, // Set app bar color

  actions: [
    // Conditionally show logout button if logged in
    Builder(
      builder: (context) {
        return IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            final _myAppState = context.findAncestorStateOfType<_MyAppState>();
            if (_myAppState != null) {
              _myAppState._handleLogout(context);
            }
          },
        );
      },
    ),
  ],
),
    
   body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children:[
          // Show sections only if logged in
          if (currentUser != null) ...[
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/SongListWidget'),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.music_note),
                    const SizedBox(height: 25, width: double.maxFinite),
                    Text('Songs List'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/artistListWidget'),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(height: 25, width: double.maxFinite),
                    Text('Artists List'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/SearchBySongTitle'),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.find_in_page),
                    const SizedBox(height: 25, width: double.maxFinite),
                    Text('Search By Song Title '),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/SearchArtistName'),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.find_in_page_sharp),
                    const SizedBox(height: 25, width: double.maxFinite),
                    Text('Search By Artist Name'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/SongPurchasePage',arguments:currentUser),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.find_in_page_sharp),
                    const SizedBox(height: 25, width: double.maxFinite),
                    Text('Song Purchase '),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            // Add Artist section - Conditionally show for admin
            if (currentUser=='admin') ...[
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/add-artist'),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.add),
                      const SizedBox(height: 25, width: double.maxFinite),
                      Text('Add Artist'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/add-song'),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.add),
                      const SizedBox(height: 25, width: double.maxFinite),
                      Text('Add Song'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    ),
   ),
  );
}
}




