// ignore_for_file: library_private_types_in_public_api, avoid_print, use_super_parameters, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

extension Uint8ListExtension on Uint8List {
  int indexOfList(Uint8List list, [int start = 0]) {
    if (list.isEmpty) return start;
    if (start < 0 || start >= length) return -1;
    for (int i = start; i <= length - list.length; i++) {
      bool found = true;
      for (int j = 0; j < list.length; j++) {
        if (this[i + j] != list[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }
}

class LiveStreamScreen extends StatefulWidget {
  final String cameraName;
  final String videoFeedUrl;

  const LiveStreamScreen({
    Key? key,
    required this.cameraName,
    required this.videoFeedUrl,
  }) : super(key: key);

  @override
  _LiveStreamScreenState createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> with WidgetsBindingObserver {
  Uint8List? _imageBytes;
  final String boundary = '--frame';
  Uint8List _buffer = Uint8List(0);
  http.Client? _httpClient;
  StreamSubscription<List<int>>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startStreaming();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.of(context).orientation;
    _updateSystemUI(orientation);
  }

  void _updateSystemUI(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _startStreaming() async {
    _httpClient = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(widget.videoFeedUrl));
      final streamedResponse = await _httpClient!.send(request);

      if (streamedResponse.statusCode == 200) {
        _streamSubscription = streamedResponse.stream.listen(
          (chunk) {
            _buffer = Uint8List.fromList([..._buffer, ...chunk]);
            _processBuffer();
          },
          onError: (error) => print('Stream error: $error'),
          onDone: () => print('Stream finished.'),
        );
      } else {
        print('Failed to connect to the video feed: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  void _processBuffer() {
    while (true) {
      final boundaryBytes = utf8.encode('\r\n$boundary\r\n');
      final contentTypeHeaderBytes = utf8.encode('Content-Type: image/jpeg\r\n\r\n');

      final startIndex = _buffer.indexOfList(boundaryBytes);
      if (startIndex == -1) break;

      final contentTypeIndex = _buffer.indexOfList(contentTypeHeaderBytes, startIndex + boundaryBytes.length);
      if (contentTypeIndex == -1) break;

      final imageDataStartIndex = contentTypeIndex + contentTypeHeaderBytes.length;
      final nextBoundaryIndex = _buffer.indexOfList(boundaryBytes, imageDataStartIndex);
      if (nextBoundaryIndex == -1) break;

      final frameBytes = _buffer.sublist(imageDataStartIndex, nextBoundaryIndex);
      if (mounted) {
        setState(() {
          _imageBytes = Uint8List.fromList(frameBytes);
        });
      }

      _buffer = _buffer.sublist(nextBoundaryIndex);
    }

    if (_buffer.length > 1024 * 1024 * 5) {
      _buffer = Uint8List(0); // prevent memory overflow
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _httpClient?.close();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
appBar: isLandscape
    ? null
    : AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Live Stream - ${widget.cameraName}',
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 2, 27),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 66, 61, 81),
              Color.fromARGB(255, 66, 61, 81)

            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.memory(
                          _imageBytes!,
                          gaplessPlayback: true,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 30),
                          Text(
                            'Connecting to camera feed...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
              ),
            ),
            if (!isLandscape && _imageBytes != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text('Exit Streaming', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 20, 2, 27),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
