import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker Demo',
      home: const MyHomePage(title: 'Image Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _pickedImage;
  String? _savedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final String storedPath = await _saveImageToAppFolder(image);

    setState(() {
      _pickedImage = image;
      _savedImagePath = storedPath;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved image to: $storedPath'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String> _saveImageToAppFolder(XFile image) async {
    final Directory targetDirectory = await _appFolderDirectory();
    await targetDirectory.create(recursive: true);

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final String destinationPath = path.join(targetDirectory.path, fileName);

    final File savedFile = await File(image.path).copy(destinationPath);
    return savedFile.path;
  }

  Future<Directory> _appFolderDirectory() async {
    const String appFolderName = 'imagepick';

    if (Platform.isAndroid) {
      final List<Directory>? downloadDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (downloadDirs != null && downloadDirs.isNotEmpty) {
        return Directory(path.join(downloadDirs.first.path, appFolderName));
      }

      final List<Directory>? externalDirs = await getExternalStorageDirectories(type: StorageDirectory.pictures);
      if (externalDirs != null && externalDirs.isNotEmpty) {
        return Directory(path.join(externalDirs.first.path, appFolderName));
      }

      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return Directory(path.join(externalDir.path, appFolderName));
      }
    }

    final Directory docsDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(docsDir.path, appFolderName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_pickedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_pickedImage!.path),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                if (_savedImagePath != null) ...[
                  SelectableText(
                    'Saved to: $_savedImagePath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                ],
              ] else ...[
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Text(
                      'No image selected',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickImage,
                label: const Text('Pick Image from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
