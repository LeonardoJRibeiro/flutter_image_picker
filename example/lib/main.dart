import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_picker/flutter_image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final controller = FlutterImagePickerController(
    required: true,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Image Picker'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 220,
              child: FlutterImagePicker(
                controller: controller,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                controller.validate();
              },
              child: Text('Validar'),
            ),
            SizedBox(
              height: 30,
            ),
            ValueListenableBuilder<Uint8List?>(
              valueListenable: controller.imagePickedBytesNotifier,
              builder: (context, imageBytes, _) {
                return Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    image: imageBytes is Uint8List
                        ? DecorationImage(
                            image: MemoryImage(imageBytes),
                          )
                        : null,
                    color: imageBytes == null ? Theme.of(context).primaryColor : null,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
