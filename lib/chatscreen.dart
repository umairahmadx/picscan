import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
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

  void api(Content c){
    message = "";
    try{
      Gemini.instance.streamChat([c]).listen((response) {
        setState(() {
          if(!sent) sent = true;
          message+=response.output!;
        });
      }).onDone(() {
        print(message);
      });

    } catch(e) {
      message = "Error $e";
    }
  }

  Future<void> _callApiWeb() async {
    Content c = await getContentWeb(byte!);
    api(c);

  }

  Future<void> _callApi() async {
    Content c = await getContent(imagePath);
    api(c);
  }

  Widget buildDescriptionWidget(String message) {
    final lines = message.split('\n');

    // Detects if a line is a list item based on common markdown patterns.
    // It looks for lines starting with one or more asterisks (*), a dash (-),
    // or a plus (+), followed by text and a colon (:).
    bool isListItem(String line) {
      final trimmed = line.trim();
      // Regex matches lines starting with *, +, or - followed by text and a colon.
      return RegExp(r'^((\*+)|-|\+)\s*[^:]+:\s*').hasMatch(trimmed);
    }

    // Extracts the label and description from a recognized list item line.
    Map<String, String> extractLabelAndDescription(String line) {
      final trimmed = line.trim();
      final colonIndex = trimmed.indexOf(':');

      if (colonIndex == -1) {
        // If no colon is found, treat the entire line as a description or unformatted text.
        return {'label': '', 'description': trimmed};
      }

      String labelPart = trimmed.substring(0, colonIndex);
      String description = trimmed.substring(colonIndex + 1).trim(); // This is the part immediately after the colon

      // Clean up the label: remove leading markdown (*, -, +) and any spaces.
      // Then remove all instances of '**' and '*' from the entire label.
      String label = labelPart.replaceAll(RegExp(r'^\s*(\*+|-|\+)\s*'), '').trim();
      label = label.replaceAll('**', '').replaceAll('*', '').trim();

      // Aggressively clean leading markdown/punctuation from the description.
      // This handles cases like `:** description` or `: description`
      description = description.replaceAll(RegExp(r'^\s*[:\-\*]+\s*'), '').trim();


      // Attempt to remove the redundant label from the beginning of the description.
      // This heuristic assumes the label might be duplicated at the start of the description.
      if (description.toLowerCase().startsWith(label.toLowerCase())) {
        description = description.substring(label.length).trim();
      }

      // Final trim for description
      description = description.trim();

      return {'label': label, 'description': description};
    }

    List<Widget> widgets = [];

    // --- Phase 1: Process initial paragraphs ---
    // Iterate through lines to find and add leading paragraphs until a list item is encountered.
    int i = 0;
    for (; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue; // Skip empty lines to avoid blank widgets

      if (isListItem(line)) break; // Stop processing paragraphs if a list item is found

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
    }


    // --- Phase 2: Process list items and subsequent non-list content ---
    // Continue iterating from where Phase 1 left off, handling both list items
    // and any paragraphs that might appear after the list.
    for (; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue; // Skip empty lines

      if (!isListItem(line)) {
        // If the line is not a recognized list item, treat it as a regular paragraph.
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        );
        continue; // Move to the next line
      }

      // If the line is a list item, extract its label and description.
      final extracted = extractLabelAndDescription(line);
      final label = extracted['label']!;
      final description = extracted['description']!;

      // Only add a RichText widget if either the label or description has content.
      if (label.isNotEmpty || description.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  // Conditionally add the bullet point and bold label if the label is not empty.
                  if (label.isNotEmpty)
                    TextSpan(
                      text: "• $label: ", // Formats as "• Label: "
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  // Always add the description, even if it's empty, to maintain consistent spacing.
                  TextSpan(
                    text: description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // --- Fallback: If no widgets were generated, display the original message ---
    // This handles cases where the message is empty or contains only unparseable content,
    // ensuring something is always displayed.
    if (widgets.isEmpty) {
      widgets.add(
        Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      );
    }

    // Return a Column containing all the generated widgets, aligned to the start.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard!'),
        duration: Duration(seconds: 2), // SnackBar stays for 2 seconds
      ),
    );
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
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
                        child: buildDescriptionWidget(message),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        iconSize: 20,
                        color: Colors.grey,
                        onPressed: () => _copyToClipboard(context),
                        tooltip: 'Copy response', // Provides a hint on long press
                      ),
                    ],
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
