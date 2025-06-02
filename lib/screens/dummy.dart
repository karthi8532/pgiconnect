import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageGrid extends StatefulWidget {
  const UploadImageGrid({super.key});

  @override
  _UploadImageGridState createState() => _UploadImageGridState();
}

class _UploadImageGridState extends State<UploadImageGrid> {
  final List<File> _images = [];
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> imageTiles = List.generate(_images.length, (index) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(_images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      );
    });

    if (_images.length < 5) {
      imageTiles.add(
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade400, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 30, color: Colors.grey),
                  Text("Upload", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Files", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
          physics: NeverScrollableScrollPhysics(),
          children: imageTiles,
        ),
      ],
    );
  }
}
