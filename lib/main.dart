import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_drawer_flutter/lib/painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Drawer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _imageFile = File('');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(50, 50),
        child: AppBar(
          backgroundColor: Colors.blue,
          actions: [Icon(Icons.ac_unit)],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            var imagePicker = ImagePicker();
            final filePicked =
                await imagePicker.pickImage(source: ImageSource.camera);

            if (filePicked == null) {
              return;
            }

            var basNameWithExtension = path.basename(filePicked.path);

            final tempDirectory = await getTemporaryDirectory();
            var file = await moveFile(File(filePicked.path),
                tempDirectory.path + "/" + basNameWithExtension);

            print(file);

            setState(() {
              _imageFile = File(file.path ?? '');
            });
            openImageEdit();
          },
          child: Text("Open Editor"),
        ),
      ),
    );
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      return await sourceFile.rename(newPath);
    } catch (e) {
      final newFile = await sourceFile.copy(newPath);
      return newFile;
    }
  }

  Future<void> openImageEdit() async {
    final result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Painter(
        imageFile: _imageFile,
        onBackTap: () => Navigator.pop(context),
      );
    }));
    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.memory(result),
            ),
          ),
        ),
      );
    }
  }
}
