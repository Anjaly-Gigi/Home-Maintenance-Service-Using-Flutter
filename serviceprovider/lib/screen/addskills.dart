import 'package:flutter/material.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/loginpage.dart';

class Addskills extends StatefulWidget {
  const Addskills({super.key});

  @override
  _AddskillsState createState() => _AddskillsState();
}

class _AddskillsState extends State<Addskills> {
  List<Map<String, dynamic>> skillList = [];


  Future<void> fetchSkills() async {
    try {
      final response = await supabase.from('tbl_skills').select();
      setState(() {
        skillList =  List<Map<String, dynamic>>.from(response);
        // response;
      });
      // Navigator.push(context, MaterialPageRoute(builder:(context) => Mylogin(),));
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSkills();
  }

  List<int> selectedSkills = [];

  void toggleSkill(int id) {
    setState(() {
      if (selectedSkills.contains(id)) {
        selectedSkills.remove(id);
      } else {
        selectedSkills.add(id);
      }
    });
  }

  Future<void> addSkill() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      for (int skillId in selectedSkills) {
        await supabase.from('tbl_spskills').insert([
          {'id': uid, 'id': skillId}
        ]);
      }
    } catch (e) {
      print("Error: $e");
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Text(" List of Skills"),
            Wrap(
                  spacing: 10, // Horizontal spacing
                  runSpacing: 10, // Vertical spacing
                  children: skillList.map((skill) {
                    final isSelected = selectedSkills.contains(skill['id']);
                    return ChoiceChip(
                      label: Text(skill['name']!),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color.fromARGB(255, 3, 3, 3) : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      selected: isSelected,
                      selectedColor: const Color.fromARGB(255, 250, 248, 248), // Background color when selected
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Default background color
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected ? Color.fromARGB(255, 51, 31, 199) : Colors.grey.shade400,
                        ),
                      ),
                      onSelected: (_) => toggleSkill(skill['id']!),
                    );
                  }).toList(),
                ),
                ElevatedButton(onPressed: () {
                  addSkill();
                }, child: Text("Submit Skills"))
          ],
        ),        
      ),
    );
  }
}