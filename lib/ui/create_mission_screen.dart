import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/mission_service.dart';

class CreateMissionScreen extends StatefulWidget {
  const CreateMissionScreen({super.key});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final MissionService missionService = MissionService();

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController timeSlotController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool isSubmitting = false;

  @override
  void dispose() {
    categoryController.dispose();
    addressController.dispose();
    timeSlotController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _submitMission() async {
    final category = categoryController.text.trim();
    final address = addressController.text.trim();
    final timeSlot = timeSlotController.text.trim();
    final note = noteController.text.trim();

    if (category.isEmpty ||
        address.isEmpty ||
        timeSlot.isEmpty ||
        note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de remplir tous les champs.'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final Mission mission = await missionService.createMission(
        category: category,
        address: address,
        timeSlot: timeSlot,
        note: note,
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/missionStatus',
        arguments: mission,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une mission'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeSlotController,
              decoration: const InputDecoration(
                labelText: 'Créneau',
                hintText: 'Ex: Aujourd’hui 14:00 - 16:00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitMission,
                child: Text(isSubmitting ? 'Création...' : 'Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}