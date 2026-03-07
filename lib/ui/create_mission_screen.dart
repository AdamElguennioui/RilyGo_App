import 'package:flutter/material.dart';
import '../services/mission_service.dart';

class CreateMissionScreen extends StatefulWidget {
  @override
  _CreateMissionScreenState createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final missionService = MissionService();
  final categoryController = TextEditingController();
  final addressController = TextEditingController();
  final noteController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer une mission")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: categoryController, decoration: InputDecoration(labelText: "Catégorie")),
            TextField(controller: addressController, decoration: InputDecoration(labelText: "Adresse")),
            TextField(controller: noteController, decoration: InputDecoration(labelText: "Note")),
            ElevatedButton(
              onPressed: () {
                selectedDate = DateTime.now();
                final mission = missionService.createMission(
                  categoryController.text,
                  addressController.text,
                  selectedDate!,
                  noteController.text,
                );
                Navigator.pushNamed(context, "/missionStatus", arguments: mission);
              },
              child: Text("Créer"),
            )
          ],
        ),
      ),
    );
  }
}
