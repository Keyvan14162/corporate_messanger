import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class ImgPage extends StatefulWidget {
  const ImgPage({required this.imgUrl, required this.sendDate, Key? key})
      : super(key: key);
  final String imgUrl;
  final String sendDate;

  @override
  State<ImgPage> createState() => _ImgPageState();
}

class _ImgPageState extends State<ImgPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          widget.sendDate,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              // splashColor: Colors.blue,
              splashRadius: 30,
              onPressed: () async {
                await shareImage();
              },
              icon: const Icon(
                Icons.share,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Hero(
        tag: widget.imgUrl,
        child: Center(
          child: PhotoView(
            imageProvider: NetworkImage(widget.imgUrl),
          ),
        ),
      ),
    );
  }

  shareImage() async {
    try {
      final url = Uri.parse(widget.imgUrl);
      final response = await http.get(url);
      final bytes = response.bodyBytes;

      final temp = await getTemporaryDirectory();
      final path = "${temp.path}/image.jpg";
      File(path).writeAsBytesSync(bytes);

      await Share.shareFiles([path], text: "textetetet");
    } catch (e) {
      print(e);
    }
  }
}
