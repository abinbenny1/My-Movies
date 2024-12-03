import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'movie_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isError = false;


  void _reloadData() {
    setState(() {
      _isError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          // Add a button to manually refresh the data
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _reloadData,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('favorites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }
          final favorites = snapshot.data?.docs ?? [];
          if (favorites.isEmpty) {
            return Center(child: Text('No favorite movies added yet.'));
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {

              final favorite = favorites[index].data() as Map<String, dynamic>?;


              if (favorite == null || favorite['movieId'] == null) {
                return Center(child: Text('Invalid favorite data.'));
              }

              final movieId = favorite['movieId'];
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('movies').doc(movieId).get(),
                builder: (context, movieSnapshot) {
                  if (movieSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!movieSnapshot.hasData || movieSnapshot.data?.data() == null) {
                    return Center(child: Text('Error loading movie data.'));
                  }

                  final movie = movieSnapshot.data?.data() as Map<String, dynamic>?;

                  // Check if movie data is valid
                  if (movie == null || movie['title'] == null || movie['genre'] == null) {
                    return Center(child: Text('Invalid movie data.'));
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        movie['title'] ?? 'No title available',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        movie['genre'] ?? 'No genre available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward, color: Colors.deepPurple),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(movieId: movieId),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
