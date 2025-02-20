import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageSkills extends StatefulWidget {
  const ManageSkills({super.key});

  @override
  State<ManageSkills> createState() => _ManageSkillsState();
}

class _ManageSkillsState extends State<ManageSkills> {
  final TextEditingController skills = TextEditingController();
  bool isLoading = true;
  List<Map<String, dynamic>> skillsList = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.from('tbl_skills').select();
      print("Fetched data: $response");
      setState(() {
        skillsList = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submit() async {
    try {
      await supabase.from('tbl_skills').insert([
        {'skill_name': skills.text}
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Inserted")),
      );

      print("Data Inserted");
      skills.clear();
      await fetchData();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_skills').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Deleted")),
      );
      print("Deleted");
      fetchData();
    } catch (e) {
      print("Error Deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
         width: 90, // Reduce this value
         height: 700, // Reduce this value
        decoration: BoxDecoration(
          color:  Color.fromARGB(255, 255, 250, 250),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: skills,
                        decoration: InputDecoration(
                          labelText: 'Skill Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.brown, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.brown, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                  ],
                ),
                
              ),
                                 ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown, // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Add Skill",
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              SizedBox(height: 20),

              Divider(
                thickness: 2,
                color: Colors.brown,
              ),
               SizedBox(height: 16),

              Text(
                "List of Skills",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.brown),
              ),
              SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: skillsList.length,                
                        itemBuilder: (context, index) {
                          final skill = skillsList[index];
                          return ListTile(
                            title: Text(skill['skill_name']),
                            // subtitle: Text(skill['id'].toString()),
                            trailing: IconButton(
                                onPressed: () {
                                  delete(skill['id']);
                                },
                                icon: Icon(Icons.delete_outline)),
                          );
                        },
                      ),
              ),
            ],
        ),
          ),
        ),
      );
    
  }
}


