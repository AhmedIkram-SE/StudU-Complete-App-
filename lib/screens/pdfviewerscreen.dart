import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatefulWidget {
  final File? file;
  final bool condition;
  final String? url;

  const PdfViewerScreen({
    super.key,
    this.file,
    this.url,
    required this.condition,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PDFDocument? document;
  List<Map<String, dynamic>> toplinks = [];
  bool isLoading = false; // Loading state for fetching links

  void initiliasePDF() async {
    if (widget.condition == false) {
      document = await PDFDocument.fromURL(widget.url!);
      setState(() {});
    } else {
      document = await PDFDocument.fromFile(widget.file!);
      setState(() {});
    }
  }

  Future<void> fetchTopLinksFromText(String pdfUrl) async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

      final response = await http.post(
        Uri.parse("https://hippo-neutral-commonly.ngrok-free.app/process-url/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": pdfUrl}),
      );

      if (response.statusCode == 200) {
        print("DATA GOT");
        final data = jsonDecode(response.body);
        setState(() {
          print("Within the state");
          toplinks = List<Map<String, dynamic>>.from(data['ranked_results'].map(
            (item) => {
              'title': item['title'] ?? 'No Title',
              'snippet': item['snippet'] ?? 'No Snippet',
              'url': item['url'] ?? "No URL",
            },
          ));
          print("TOPLINKS:  ${toplinks}");
        });
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching top links from text: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  void initState() {
    initiliasePDF();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: isLoading
            ? PreferredSize(
                preferredSize: Size.fromHeight(6.0),
                child: LinearProgressIndicator(
                  color: Colors.black87,
                ),
              )
            : null,
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.white,
        elevation: 4,
        title: Text(
          "FILE",
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              icon: const Icon(Icons.info_sharp),
              onPressed: () async {
                if (toplinks.isEmpty) {
                  await fetchTopLinksFromText(widget.url!);
                }

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      height: MediaQuery.of(context).size.height *
                          0.5, // Adjustable height
                      padding: const EdgeInsets.all(10),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : toplinks.isEmpty
                              ? Center(
                                  child: Text(
                                  "No links available!",
                                  style: GoogleFonts.rajdhani(
                                    textStyle: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ))
                              : ListView.builder(
                                  itemCount: toplinks.length,
                                  itemBuilder: (context, index) {
                                    final link = toplinks[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 7),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 1),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                      elevation: 5,
                                      surfaceTintColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 7, 10, 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              link['title'] ?? 'Unknown Title',
                                              style: GoogleFonts.rajdhani(
                                                textStyle:
                                                    TextStyle(fontSize: 17),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.description),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      link['snippet'] ??
                                                          'Unknown Snippet',
                                                      overflow:
                                                          TextOverflow.visible,
                                                      style:
                                                          GoogleFonts.rajdhani(
                                                        textStyle: TextStyle(
                                                            fontSize: 15),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 222, 222, 222),
                                                      ),
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 5.0,
                                                          spreadRadius: 0,
                                                          offset:
                                                              Offset(-5, -5),
                                                          color: Color.fromARGB(
                                                              255,
                                                              242,
                                                              241,
                                                              241),
                                                          inset: true,
                                                        ),
                                                        BoxShadow(
                                                          blurRadius: 5.0,
                                                          spreadRadius: 0,
                                                          offset: Offset(5, 5),
                                                          color: Color.fromARGB(
                                                              255,
                                                              242,
                                                              241,
                                                              241),
                                                          inset: true,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(Icons.public),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        final url =
                                                            link['url'] ?? '';
                                                        if (url.isNotEmpty) {
                                                          final uri =
                                                              Uri.parse(url);
                                                          if (await canLaunchUrl(
                                                              uri)) {
                                                            await launchUrl(
                                                              uri,
                                                              mode: LaunchMode
                                                                  .externalApplication, // Opens in an external browser
                                                            );
                                                          } else {
                                                            // Handle error if URL cannot be launched
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Could not open the URL')),
                                                            );
                                                          }
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        link['url'] ??
                                                            'Unknown Url',
                                                        style: GoogleFonts.rajdhani(
                                                            textStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        15),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.blue
                                                                    .shade700,
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      body: document != null
          ? PDFViewer(document: document!)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
