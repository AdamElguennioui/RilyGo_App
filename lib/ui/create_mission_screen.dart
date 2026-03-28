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
  bool isExpress = false;

  @override
  void dispose() {
    categoryController.dispose();
    addressController.dispose();
    timeSlotController.dispose();
    noteController.dispose();
    super.dispose();
  }

  double _previewBasePrice(String category) {
    switch (category.trim().toLowerCase()) {
      case 'document':
        return 20;
      case 'petit colis':
        return 30;
      default:
        return 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = categoryController.text.trim();
    final basePrice = _previewBasePrice(category);
    final totalPrice = isExpress ? basePrice + 15 : basePrice;

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
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                hintText: 'Ex: document, petit colis...',
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
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Option express'),
              subtitle: const Text('+15 MAD'),
              value: isExpress,
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        isExpress = value;
                      });
                    },
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _priceRow('Prix de base', '${basePrice.toStringAsFixed(0)} MAD'),
                    const SizedBox(height: 8),
                    _priceRow('Express', isExpress ? '+15 MAD' : '0 MAD'),
                    const Divider(height: 24),
                    _priceRow(
                      'Total',
                      '${totalPrice.toStringAsFixed(0)} MAD',
                      isBold: true,
                    ),
                  ],
                ),
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

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
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
        isExpress: isExpress,
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
}