import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? grayscaleImage;
  File? selectedImage;

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> makeGrayscale() async {
    if (selectedImage == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.107:4000/convert'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', selectedImage!.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      setState(() {
        grayscaleImage = bytes;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrayscalePage(grayscaleImage: bytes),
        ),
      );
    } else {
      print('Failed to convert image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Grayscale Converter",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 70),
            Container(
              width: 370,
              height: 370,
              color: Colors.grey[300],
              child: selectedImage != null
                  ? Image.file(selectedImage!, fit: BoxFit.cover)
                  : Center(child: Text("No image selected")),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text("Upload Image", style: TextStyle(fontSize: 16)),
              onPressed: pickImage,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                minimumSize: MaterialStateProperty.all<Size>(Size(370, 50)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              child: Text("Make Grayscale", style: TextStyle(fontSize: 16)),
              onPressed: makeGrayscale,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                minimumSize: MaterialStateProperty.all<Size>(Size(370, 50)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GrayscalePage extends StatelessWidget {
  final Uint8List grayscaleImage;

  GrayscalePage({required this.grayscaleImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(grayscaleImage, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                Directory? directory;
                if (Platform.isAndroid) {
                  directory = Directory('/storage/emulated/0/Download');
                } else {
                  directory = await getApplicationDocumentsDirectory();
                }
                final filePath = '${directory.path}/grayscale_image.png';
                final file = File(filePath);
                await file.writeAsBytes(grayscaleImage);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Image saved to $filePath')),
                );
              },
              child: Text("Download", style: TextStyle(fontSize: 16)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 1, 4, 99),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 255, 255, 255),
                ),
                minimumSize: MaterialStateProperty.all<Size>(Size(370, 50)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
