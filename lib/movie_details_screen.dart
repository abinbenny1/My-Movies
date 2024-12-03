import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  MovieDetailsScreen({required this.movieId});

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('movies').doc(widget.movieId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Movie Details'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Movie Details'),
            ),
            body: Center(child: Text('No movie details available.')),
          );
        }

        final movie = snapshot.data!.data() as Map<String, dynamic>?;

        if (movie == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Movie Details'),
            ),
            body: Center(child: Text('No movie details available.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(movie['title'] ?? 'Movie Details'),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Title
                  Center(
                    child: Text(
                      movie['title'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Movie Information
                  _buildMovieInfo(movie),
                  SizedBox(height: 10),
                  // Movie Synopsis
                  _buildMovieSynopsis(movie),
                  SizedBox(height: 20),
                  // Cast Information
                  if (movie.containsKey('cast')) _buildCast(movie),
                  SizedBox(height: 20),
                  // Reviews Section
                  _buildReviews(),
                  SizedBox(height: 20),
                  // Buttons for Actions
                  _buildActionButtons(movie),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovieInfo(Map<String, dynamic> movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Release Date: ${movie['releaseDate']}'),
        Text('Duration: ${movie['duration']} mins'),
        Text('Genre: ${movie['genre']}'),
      ],
    );
  }

  Widget _buildMovieSynopsis(Map<String, dynamic> movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synopsis:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          movie['synopsis'],
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildCast(Map<String, dynamic> movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        for (var actor in movie['cast'])
          Text(
            '- $actor',
            style: TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  Widget _buildReviews() {
    return Text(
      'Reviews and Ratings:',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> movie) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            _firestore.collection('favorites').add({'movieId': widget.movieId});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Added to Favorites!'),
            ));
          },
          child: Text('Add to Favorites'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.orangeAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            TextEditingController titleController =
            TextEditingController(text: movie['title']);
            TextEditingController synopsisController =
            TextEditingController(text: movie['synopsis']);
            TextEditingController castController =
            TextEditingController(text: movie['cast']?.join(', '));
            TextEditingController durationController =
            TextEditingController(text: movie['duration'].toString());
            TextEditingController genreController =
            TextEditingController(text: movie['genre']);
            TextEditingController releaseDateController =
            TextEditingController(text: movie['releaseDate']);

            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Update Movie'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(titleController, 'Title'),
                        _buildTextField(synopsisController, 'Synopsis'),
                        _buildTextField(castController, 'Cast (comma separated)'),
                        _buildTextField(durationController, 'Duration (in mins)'),
                        _buildTextField(genreController, 'Genre'),
                        _buildTextField(releaseDateController, 'Release Date'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        List<String> castList = castController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList();
                        await _firestore.collection('movies').doc(widget.movieId).update({
                          'title': titleController.text,
                          'synopsis': synopsisController.text,
                          'cast': castList,
                          'duration': int.tryParse(durationController.text) ?? 0,
                          'genre': genreController.text,
                          'releaseDate': releaseDateController.text,
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Movie updated!'),
                        ));
                      },
                      child: Text('Update'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Update'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.lightGreen[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {

            await _firestore.collection('movies').doc(widget.movieId).delete();


            final favoritesSnapshot = await _firestore.collection('favorites')
                .where('movieId', isEqualTo: widget.movieId)
                .get();

            for (var favorite in favoritesSnapshot.docs) {
              await favorite.reference.delete(); // Delete each favorite entry
            }

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Movie deleted!'),
            ));
          },
          child: Text('Delete'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
