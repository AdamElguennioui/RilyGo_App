import 'package:flutter/material.dart';
import '../services/mission_service.dart';
import '../services/connectivity_service.dart';
import 'theme/app_theme.dart';
import 'widgets/rily_widgets.dart';

class CreateMissionScreen extends StatefulWidget {
  const CreateMissionScreen({super.key});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final MissionService _missionService = MissionService();
  final ConnectivityService _connectivity = ConnectivityService();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _timeSlotController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _category = 'Document';
  bool _isExpress = false;
  bool _isSubmitting = false;

  static const List<String> _categories = [
    'Document',
    'Petit colis',
    'Grand colis',
  ];

  static const Map<String, String> _categoryEmojis = {
    'Document': '📄',
    'Petit colis': '📦',
    'Grand colis': '🚚',
  };

  @override
  void dispose() {
    _addressController.dispose();
    _timeSlotController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _basePrice {
    switch (_category.toLowerCase()) {
      case 'document':
        return 20;
      case 'petit colis':
        return 30;
      default:
        return 40;
    }
  }

  double get _totalPrice => _isExpress ? _basePrice + 15 : _basePrice;

  Future<void> _submit() async {
    final address = _addressController.text.trim();
    final timeSlot = _timeSlotController.text.trim();
    final note = _noteController.text.trim();

    if (address.isEmpty || timeSlot.isEmpty) {
      showErrorSnack(context, 'Adresse et créneau sont obligatoires.');
      return;
    }

    if (!_connectivity.isConnected) {
      showErrorSnack(
          context, 'Pas de connexion. Vérifie ton réseau et réessaie.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final mission = await _missionService.createMission(
        category: _category,
        address: address,
        timeSlot: timeSlot,
        note: note.isEmpty ? '' : note,
        isExpress: _isExpress,
      );

      if (!mounted) return;

      showSuccessSnack(context, 'Mission créée !');
      Navigator.pushReplacementNamed(
        context,
        '/missionStatus',
        arguments: mission,
      );
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle mission'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Catégorie ──
                  const SectionHeader('CATÉGORIE'),
                  const SizedBox(height: 14),
                  Row(
                    children: _categories.map((cat) {
                      final selected = cat == _category;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? RilyColors.accentDim
                                    : RilyColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? RilyColors.accent
                                      : RilyColors.surfaceBorder,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _categoryEmojis[cat] ?? '📦',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: selected
                                          ? RilyColors.accent
                                          : RilyColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ── Adresse ──
                  const SectionHeader('DÉTAILS'),
                  const SizedBox(height: 14),
                  RilyTextField(
                    controller: _addressController,
                    label: 'Adresse de livraison',
                    hint: 'Ex: 12 rue Mohammed V, Casablanca',
                  ),
                  const SizedBox(height: 14),
                  RilyTextField(
                    controller: _timeSlotController,
                    label: 'Créneau',
                    hint: 'Ex: Aujourd\'hui 14h–16h',
                  ),
                  const SizedBox(height: 14),
                  RilyTextField(
                    controller: _noteController,
                    label: 'Note (optionnel)',
                    hint: 'Instructions particulières...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // ── Option express ──
                  const SectionHeader('OPTIONS'),
                  const SizedBox(height: 14),
                  RilyCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: RilyColors.expressDim,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                              child: Text('⚡',
                                  style: TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Mode Express',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: RilyColors.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Priorité + majoration +15 MAD',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: RilyColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isExpress,
                          onChanged: _isSubmitting
                              ? null
                              : (v) => setState(() => _isExpress = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Récap prix ──
                  const SectionHeader('TARIF'),
                  const SizedBox(height: 14),
                  RilyCard(
                    borderColor: RilyColors.accent.withOpacity(0.2),
                    child: Column(
                      children: [
                        PriceRow(
                            'Prix de base',
                            '${_basePrice.toStringAsFixed(0)} MAD'),
                        if (_isExpress)
                          const PriceRow('Express', '+15 MAD',
                              valueColor: RilyColors.express),
                        const Divider(height: 20),
                        PriceRow(
                          'Total',
                          '${_totalPrice.toStringAsFixed(0)} MAD',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bouton sticky en bas ──
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: RilyColors.bg,
              border: const Border(
                  top: BorderSide(color: RilyColors.surfaceBorder)),
            ),
            child: RilyButton(
              label: 'Créer la mission',
              loadingLabel: 'Création en cours...',
              isLoading: _isSubmitting,
              icon: Icons.rocket_launch_rounded,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}