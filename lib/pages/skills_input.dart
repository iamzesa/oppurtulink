import 'package:flutter/material.dart';

class SkillsInput extends StatefulWidget {
  final List<String> skillsList;
  final List<String> selectedSkills;

  const SkillsInput({
    required this.skillsList,
    required this.selectedSkills,
  });

  @override
  _SkillsInputState createState() => _SkillsInputState();
}

class _SkillsInputState extends State<SkillsInput> {
  late TextEditingController _searchController;
  List<String> filteredSkills = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    filteredSkills = widget.skillsList;
  }

  void _filterSkills(String query) {
    print("Filtering skills for: $query"); // Print the query
    setState(() {
      if (query.isEmpty) {
        filteredSkills = widget.skillsList;
      } else {
        filteredSkills = widget.skillsList
            .where((skill) => skill.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      print(
          "Filtered Skills Length: ${filteredSkills.length}"); // Print the length of filtered skills
      print("Filtered Skills: $filteredSkills"); // Print the filtered skills
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Filtered Skills Length: ${filteredSkills.length}"); // Add this line

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: TextField(
            controller: _searchController,
            onChanged: _filterSkills,
            decoration: InputDecoration(
              labelText: 'Search Skills',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: widget.selectedSkills.map((skill) {
            return InputChip(
              label: Text(skill),
              onDeleted: () {
                setState(() {
                  widget.selectedSkills.remove(skill);
                });
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: filteredSkills.map((skill) {
            return ActionChip(
              label: Text(skill),
              onPressed: () {
                setState(() {
                  widget.selectedSkills.add(skill);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
