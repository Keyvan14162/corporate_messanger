import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class ImgPage extends StatefulWidget {
  const ImgPage({required this.imgUrl, Key? key}) : super(key: key);
  final String imgUrl;

  @override
  State<ImgPage> createState() => _ImgPageState();
}

class _ImgPageState extends State<ImgPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              // splashColor: Colors.blue,
              splashRadius: 30,
              onPressed: () async {
                print(widget.imgUrl);
                await shareImage();
              },
              icon: const Icon(
                Icons.share,
              ),
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Hero(
          tag: widget.imgUrl,
          child: Center(
            child: PhotoView(
              imageProvider: NetworkImage(widget.imgUrl),
            ),
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
