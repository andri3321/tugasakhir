import 'dart:io'; // Untuk menggunakan File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasakhir/database/database.dart';
import 'package:tugasakhir/screens/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

Future<void> _checkAndRequestPermission() async {
  final cameraStatus = await Permission.camera.status;
  final galleryStatus = await Permission.photos.status;

  if (!cameraStatus.isGranted) {
    await Permission.camera.request();
  }
  if (!galleryStatus.isGranted) {
    await Permission.photos.request();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  String? _profileImage;
  bool _isLoading = true; // Menambahkan indikator loading

  // Fungsi untuk memuat data pengguna dari database
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      if (email != null) {
        final dbHelper = DatabaseHelper.instance;
        final user = await dbHelper.getUser(email);

        if (user != null) {
          setState(() {
            _name = user['name'];
            _email = user['email'];
            _profileImage = user['profileImage'];
            _isLoading = false; // Selesai loading
          });
        } else {
          print('User not found in database for email: $email');
          setState(() {
            _isLoading = false; // Selesai loading meski user tidak ditemukan
          });
        }
      } else {
        print('Email not found in SharedPreferences');
        setState(() {
          _isLoading = false; // Selesai loading meski email tidak ditemukan
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false; // Selesai loading meski terjadi error
      });
    }
  }

  // Fungsi untuk logout dan kembali ke halaman login
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Hapus status login
    await prefs.remove('email'); // Hapus email pengguna
    // Jangan hapus semua data SharedPreferences!

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Fungsi untuk memilih gambar dari kamera atau galeri
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    await _checkAndRequestPermission(); // Memastikan izin telah diberikan

    // Menampilkan dialog untuk memilih kamera atau galeri
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context); // Tutup dialog
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera, // Ambil gambar dari kamera
                  imageQuality: 50, // Mengatur kualitas gambar
                );
                _handlePickedImage(image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context); // Tutup dialog
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery, // Ambil gambar dari galeri
                  imageQuality: 50, // Mengatur kualitas gambar
                );
                _handlePickedImage(image);
              },
            ),
          ],
        );
      },
    );
  }

  void _handlePickedImage(XFile? image) {
    if (image != null) {
      setState(() {
        _profileImage = image.path; // Simpan path gambar ke variabel
      });

      // Simpan ke database jika gambar valid
      _updateProfileImage(image.path);
    } else {
      // Jika gambar tidak dipilih, beri feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  // Fungsi untuk menyimpan gambar profil yang dipilih ke database
  Future<void> _updateProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final email =
        prefs.getString('email'); // Ambil email dari SharedPreferences

    if (email != null) {
      final dbHelper = DatabaseHelper.instance;

      // Update gambar profil di database
      final result = await dbHelper.updateUserProfileImage(email, imagePath);

      if (result > 0) {
        // Jika pembaruan berhasil
        print('Profile image updated in database: $imagePath');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      } else {
        // Jika pembaruan gagal
        print('Failed to update profile image in database');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile image')),
        );
      }
    } else {
      print('No email found in SharedPreferences');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Memuat data pengguna ketika halaman pertama kali dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Menunggu data dimuat
            : Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage, // Memilih foto profil
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: _profileImage != null &&
                              File(_profileImage!).existsSync()
                          ? FileImage(
                              File(_profileImage!)) // Menampilkan gambar profil
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider, // Gambar default
                      child: _profileImage == null ||
                              !File(_profileImage!).existsSync()
                          ? const Icon(Icons.camera_alt,
                              color: Colors.white) // Ikon kamera
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Menampilkan Nama Pengguna yang diambil dari database
                  Text(
                    _name ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Menampilkan Email Pengguna yang diambil dari database
                  Text(
                    _email ?? 'Email tidak tersedia',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.security,
                    title: 'Security',
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    isLogout: true,
                  ),
                ],
              ),
      ),
    );
  }

  // Fungsi untuk membuat item menu profil
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    bool isLogout = false,
    Function? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      trailing:
          isLogout ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        if (onTap != null) {
          onTap(); // Jika onTap ada, panggil onTap (untuk edit profile)
        } else {
          if (isLogout) {
            _logout(); // Jika logout dipilih, lakukan logout
          }
        }
      },
    );
  }
}
