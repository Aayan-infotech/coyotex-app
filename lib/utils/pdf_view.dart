import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Add this import

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = true;
  String? _filePath;
  String? _errorMessage;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? _pages = 0;
  int? _currentPage = 0;
  UniqueKey _pdfKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _downloadAndSavePDF();
  }

  Future<void> _downloadAndSavePDF() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(
            "${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf");
        await file.writeAsBytes(response.bodyBytes, flush: true);
        setState(() {
          _filePath = file.path;
          _pdfKey = UniqueKey();
        });
      } else {
        setState(() =>
            _errorMessage = "Failed to download PDF: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // New function to open PDF in browser
  Future<void> _openInBrowser() async {
    try {
      final url = widget.pdfUrl;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        setState(() {
          _errorMessage = "Could not open the URL.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _openInBrowser, // Updated to use the new function
            tooltip: 'Download in Browser', // Updated tooltip
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
                ? Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                : PDFView(
                    key: _pdfKey,
                    filePath: _filePath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: true,
                    defaultPage: _currentPage!,
                    fitPolicy: FitPolicy.BOTH,
                    onRender: (pages) => setState(() => _pages = pages),
                    onViewCreated: (PDFViewController pdfViewController) {
                      _controller.complete(pdfViewController);
                    },
                    onPageChanged: (int? page, int? total) {
                      setState(() => _currentPage = page);
                    },
                    onError: (error) {
                      setState(() => _errorMessage = "PDF Error: $error");
                    },
                    onPageError: (page, error) {
                      setState(
                          () => _errorMessage = "Page $page Error: $error");
                    },
                  ),
      ),
    );
  }
}
