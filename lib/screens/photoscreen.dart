import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({
    super.key,
    required this.condition,
    this.selectedImage,
    this.address,
  });
  final bool condition;
  final File? selectedImage;
  final String? address;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 251, 233, 1),
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Color.fromRGBO(255, 251, 233, 1),
        surfaceTintColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 206, 202, 202),
        ),
        elevation: 4,
        title: const Text("View Photo"),
      ),
      body: Center(
        child: CircleAvatar(
          backgroundImage: widget.condition
              ? FileImage(widget.selectedImage!) as ImageProvider
              : NetworkImage(widget.address!),
          radius: 150,
        ),
      ),
    );
  }
}
