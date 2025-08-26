import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pgiconnect/widgets/app_utils.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imageUrl;

  const ImagePreviewPage({super.key, required this.imageUrl});

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  bool _isDownloading = false;

  Future<void> _downloadImage(BuildContext context) async {
    setState(() => _isDownloading = true);

    try {
      // Download image bytes
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) {
        throw Exception("Failed with status ${response.statusCode}");
      }

      final fileName = "download_${DateTime.now().millisecondsSinceEpoch}.png";
      String savePath;

      if (Platform.isAndroid) {
        final dir = Directory("/storage/emulated/0/Download");
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        savePath = "${dir.path}/$fileName";
      } else if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        savePath = "${dir.path}/$fileName";
      } else {
        throw Exception("Unsupported platform");
      }

      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      AppUtils.showSingleDialogPopup(
          context, "image downloaded successfully!", "Ok", oneixtpopup, null);
    } catch (e) {
      AppUtils.showSingleDialogPopup(
          context, e.toString(), "Ok", oneixtpopup, null);
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void oneixtpopup() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _isDownloading
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () => _downloadImage(context),
                ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(widget.imageUrl),
        ),
      ),
    );
  }
}
