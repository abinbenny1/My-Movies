import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDataPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _posterUrlController = TextEditingController();
  final TextEditingController _castController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie Data', style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    icon: Icons.movie,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the movie title' : null,
                  ),
                  _buildTextField(
                    controller: _releaseDateController,
                    label: 'Release Date',
                    icon: Icons.date_range,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the release date' : null,
                  ),
                  _buildTextField(
                    controller: _durationController,
                    label: 'Duration (mins)',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the movie duration' : null,
                  ),
                  _buildTextField(
                    controller: _genreController,
                    label: 'Genre',
                    icon: Icons.category,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the movie genre' : null,
                  ),
                  _buildTextField(
                    controller: _synopsisController,
                    label: 'Synopsis',
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a brief synopsis' : null,
                  ),
                  _buildTextField(
                    controller: _posterUrlController,
                    label: 'Poster URL',
                    icon: Icons.link,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the poster URL' : null,
                  ),
                  _buildTextField(
                    controller: _castController,
                    label: 'Cast (comma-separated)',
                    icon: Icons.people,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the cast names' : null,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), backgroundColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.purple,
                        elevation: 10,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addMovieToFirestore(context);
                        }
                      },
                      child: const Text(
                        'Save Movie',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.purple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _addMovieToFirestore(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      await _firestore.collection('movies').add({
        'title': _titleController.text,
        'releaseDate': _releaseDateController.text,
        'duration': int.parse(_durationController.text),
        'genre': _genreController.text,
        'synopsis': _synopsisController.text,
        'posterUrl': _posterUrlController.text,
        'cast': _castController.text.split(',').map((e) => e.trim()).toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add movie: Please insert valid data')),
      );
    }
  }
}
