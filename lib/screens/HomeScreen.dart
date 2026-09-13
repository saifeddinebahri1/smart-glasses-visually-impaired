// ignore_for_file: use_build_context_synchronously, deprecated_member_use, use_super_parameters, depend_on_referenced_packages, unused_import, prefer_final_fields, unused_field, unused_element

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'live_stream_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isUploading = false;
  String? _photoUrl;
  String _userName = 'Welcome';
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final places = [
    {'title': 'LIVE STREAMING', 'image': 'assets/survillance.jpeg', 'subtitle': 'Camera Access'},
    {'title': 'GPS TRACKING', 'image': 'assets/GPS.jpg', 'subtitle': 'Real-time Location'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
    _pageController = PageController(viewportFraction: 0.8);
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % places.length;
        _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPhoto() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    String email = user?.email ?? 'user';
    String username = email.split('@').first; // e.g., saifbahri123

    // Remove digits
    String cleaned = username.replaceAll(RegExp(r'[0-9]'), '');

    // Try to split into first and last name (simple heuristic)
    String finalName = cleaned;
    if (cleaned.length > 5) {
      final middle = (cleaned.length / 2).floor();
      finalName =
          '${cleaned.substring(0, middle)} ${cleaned.substring(middle)}';
    }

    // Capitalize each part
    finalName = finalName
        .split(' ')
        .map((e) =>
            e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '')
        .join(' ');

    setState(() {
      _photoUrl = user?.photoURL;
      _userName = 'Welcome $finalName';
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage = _photoUrl != null && _photoUrl!.isNotEmpty
        ? NetworkImage(_photoUrl!)
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _userName,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 22,
                backgroundImage: avatarImage,
                backgroundColor: Colors.white,
                child: avatarImage == null ? const Icon(Icons.person, color: Colors.grey) : null,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 153, 112, 235), Color.fromARGB(255, 7, 7, 7), Color.fromARGB(255, 2, 101, 177)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 110),
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  final imageWidget = Image.asset(place['image']!, fit: BoxFit.cover, height: 280, width: double.infinity);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(20), child: imageWidget),
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(place['subtitle']!, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FeatureButton(
                      icon: Icons.videocam,
                      label: 'Live Stream',
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LiveStreamScreen(
                              cameraName: 'PC Camera',
                              videoFeedUrl: 'http://192.168.1.14:5000/video_feed',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _FeatureButton(
                      icon: Icons.location_on,
                      label: 'GPS Location',
                      color: Colors.tealAccent,
                      onTap: () => Navigator.pushNamed(context, '/gps'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color.withOpacity(0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 10),
                Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
