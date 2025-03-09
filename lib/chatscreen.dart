import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'functions.dart';

class ChatScreen extends StatefulWidget {
  final bool sending;

  const ChatScreen({this.sending = false, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String imagePath = "";
  bool isLoading = false;
  bool sent = false;
  Uint8List? byte = null;

  @override
  void initState() {
    super.initState();
    imagePath = imageFinal;

    byte = imageBytes;
    if (widget.sending) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (kIsWeb) {
          _callApiWeb();
        } else {
          _callApi();
        }
      });
    }
  }

  Future<void> _callApiWeb() async {
    await apiCallWeb(byte!);
    setState(() {
      sent = true;
    });
  }

  Future<void> _callApi() async {
    await apiCall(imagePath);
    setState(() {
      sent = true;
    });
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      await imagePickerWeb();
      if (imageBytes != null) {
        setState(() {
          byte = imageBytes;
          message = "";
          sent = false;
        });
        await _callApiWeb();
      }
    } else {
      await imagePicker(changeState);
      if (imageFinal.isNotEmpty) {
        setState(() {
          imagePath = imageFinal;
          message="";
          sent = false;
        });

        await _callApi();
      }
    }
  }

  void changeState() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  "PicScan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  "Powered by OPR",
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            physics: ScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.bottomRight,
                        child:
                            imagePath.isEmpty && imageBytes==null
                                ? SizedBox.shrink()
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  // Rounded corners
                                  child: kIsWeb
                                      ? Image.memory(
                                    imageBytes!,
                                    width: screenWidth * 0.6,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.file(
                                    File(imagePath),
                                    width: screenWidth * 0.6,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                      ),
                      SizedBox(height: 5),
                      Visibility(
                        visible: imagePath.isNotEmpty,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.isNotEmpty ? "Sent" : "Sending",
                              style: TextStyle(fontSize: 10),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              message.isNotEmpty
                                  ? Icons.done_all_rounded
                                  : Icons.schedule_rounded,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: message.isNotEmpty,
                  child: Container(
                    margin: EdgeInsets.only(right: 50, left: 10, top: 0),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(4),
                      ),
                      color: Colors.lightBlueAccent[200],
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(height: 120),
              ],
            ),
          ),
          floatingActionButton: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: pickImage,
                    style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(70, 70)),
                      shape: WidgetStatePropertyAll(CircleBorder()),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(70, 70)),
                      shape: WidgetStatePropertyAll(CircleBorder()),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.7),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
