// ignore_for_file: use_build_context_synchronously, use_super_parameters

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _changeProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    final url = await _uploadImageToCloudinary(File(pickedFile.path));
    if (url != null) {
      final user = FirebaseAuth.instance.currentUser;
      await user?.updatePhotoURL(url);
      await user?.reload();
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!')),
      );
    } else {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dvahksa4n';
    const uploadPreset = 'avatar';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      return data['secure_url'];
    }
    return null;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoURL = user?.photoURL;
    final email = user?.email ?? 'No email';
  

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                          backgroundColor: Colors.grey.shade300,
                          child: photoURL == null
                              ? const Icon(Icons.person, size: 40, color: Colors.white)
                              : null,
                        ),
                        if (_isUploading)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Colors.black45,
                              child: Center(child: CircularProgressIndicator(color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(email, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _isUploading ? null : _changeProfilePhoto,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Change Picture"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text("help",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
              ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text("about us" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            side: const BorderSide(color: Colors.deepPurple),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Sign Out"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
