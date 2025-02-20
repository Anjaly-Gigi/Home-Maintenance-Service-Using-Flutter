import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviceprovider/components/form_validation.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/addskills.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Myregister extends StatefulWidget {
  const Myregister({super.key});

  @override
  State<Myregister> createState() => _MyregisterState();
}

class _MyregisterState extends State<Myregister> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  String? selectedDistrict;
  List<Map<String, dynamic>> districtList = [];
  List<Map<String, dynamic>> placeList = [];
  File? _image;
  String? selectedPlace;

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      print("Fetched districts: $response");
      setState(() {
        districtList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchPlaces(String districtid) async {
    try {
      final response = await supabase
          .from('tbl_place')
          .select()
          .eq('district_id', districtid);
      print("Fetched places: $response");
      setState(() {
        placeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> signup() async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final User? user = response.user;

      if (user == null) {
        print('Sign up error: $user');
      } else {
        final String userId = user.id;

        // Step 2: Upload profile photo (if selected)
        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(_image!, userId);
        }

        // Step 3: Insert user details into `tbl_user`
        await supabase.from('tbl_sp').insert({
          'id': userId,
          'sp_name': _nameController.text,
          'sp_email': _emailController.text,
          'sp_photo': photoUrl,
          'sp_password': _passwordController.text,
          'sp_address': _addressController.text,
          'place_id': selectedPlace,
        });
        print('User created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created successfully')),
        );
      }
    } catch (e) {
      print('Sign up failed: $e');
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final fileName = 'sp_$userId';

      await supabase.storage.from('sp_images').upload(fileName, image);

      // Get public URL of the uploaded image
      final imageUrl =
          supabase.storage.from('sp_images').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 143, 143),
      appBar: AppBar(
        title: const Text("Create Account",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: const Color.fromARGB(255, 0, 128, 128),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 188, 143, 143)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Service Provider Information",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 128, 128)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Profile Image Picker with spacing
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey[800])
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 30), // Added space between image and fields

                    _buildTextField(_nameController, 'Name', Icons.person,
                        FormValidation.validateName),
                    _buildTextField(_addressController, 'Address', Icons.home,
                        FormValidation.validateAddress),
                    _buildTextField(_emailController, 'Email', Icons.email,
                        FormValidation.validateEmail),
                    _buildTextField(_phoneController, 'Phone Number',
                        Icons.phone, FormValidation.validateContact),

                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      value: districtList.any(
                              (district) => district['id'] == selectedDistrict)
                          ? selectedDistrict
                          : null,
                      items: districtList.map((district) {
                        return DropdownMenuItem(
                          child: Text(district['district_name']),
                          value: district['id'],
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value.toString();
                          fetchPlaces(selectedDistrict!);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select District',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            value: placeList.any(
                                    (place) => place['id'] == selectedPlace)
                                ? selectedPlace
                                : null,
                            items: placeList.map((place) {
                              return DropdownMenuItem(
                                child: Text(place['place_name']),
                                value: place['id'],
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPlace = value.toString();
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select Place',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    _buildTextField(_passwordController, 'Password', Icons.lock,
                        FormValidation.validatePassword,
                        obscureText: true),
                    _buildTextField(
                        _confirmPasswordController,
                        'Confirm Password',
                        Icons.lock_outline,
                        (value) => FormValidation.validateConfirmPassword(
                            value, _passwordController.text),
                        obscureText: true),

                    const Divider(),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 128, 128),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        // if (_formKey.currentState!.validate()) {
                          print("Registration Successful");
                          signup();
                        // }
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(230, 255, 252, 197),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String? Function(String?)? validator,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 0, 128, 128)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
