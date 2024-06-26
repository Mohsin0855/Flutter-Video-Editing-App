
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'editScreen.dart';
//-------------------//
//Pickup Video Screen//
//-------------------//
class VideoEditorExample extends StatefulWidget {
  const VideoEditorExample({super.key});

  @override
  State<VideoEditorExample> createState() => _VideoEditorExampleState();
}

class _VideoEditorExampleState extends State<VideoEditorExample> {
  final ImagePicker _picker = ImagePicker();

  void _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   allowMultiple: true,
    //   dialogTitle: 'select file',
    //   type: FileType.custom,
    //   allowedExtensions: ['jpeg','jpg','mp3','mp4','gif','png']
    // );


    if (mounted && file != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => EditScreen(file: File(file.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      //appBar: AppBar(title: const Text("Video Picker"),backgroundColor: Colors.grey[900],),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Click on the button to select video",
              style: TextStyle(color: Colors.white,fontSize: 18),),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.grey[900]
              ),
              onPressed: _pickVideo,
              child: const Text("Pick Video From Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}