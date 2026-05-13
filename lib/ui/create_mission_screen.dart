import 'package:flutter/material.dart';
import '../models/service_category.dart';
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
  final MissionService _ms = MissionService();
  final ConnectivityService _conn = ConnectivityService();

  // ── Wizard state ──────────────────────────────────────────────────────────
  int _step = 0; // 0: category  1: details  2: options

  // Step 0
  ServiceCategory? _selectedCategory;

  // Step 1
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  // Step 2
  bool _isPrioritaire = false;
  final _noteCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-select category if passed from service grid
    final arg =
        ModalRoute.of(context)?.settings.arguments as ServiceCategory?;
    if (arg != null && _selectedCategory == null) {
      _selectedCategory = arg;
      // Skip category step if already selected
      if (_step == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _step = 1);
        });
      }
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Pricing ───────────────────────────────────────────────────────────────

  double get _basePrice {
    switch (_selectedCategory?.id) {
      case 'personal':
        return 149;
      case 'mobility':
        return 199;
      case 'business':
        return 299;
      case 'immigration':
        return 249;
      case 'queue':
        return 99;
      case 'notary':
        return 199;
      default:
        return 149;
    }
  }

  double get _totalPrice => _isPrioritaire ? _basePrice + 50 : _basePrice;

  // ── Navigation ────────────────────────────────────────────────────────────

  void _next() {
    if (_step == 0) {
      if (_selectedCategory == null) {
        showErrorSnack(context, 'Veuillez sélectionner un type de démarche.');
        return;
      }
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      if (_descCtrl.text.trim().isEmpty) {
        showErrorSnack(context, 'Veuillez décrire votre démarche.');
        return;
      }
      if (_locationCtrl.text.trim().isEmpty) {
        showErrorSnack(context, 'Veuillez préciser le lieu de la démarche.');
        return;
      }
      if (_dateCtrl.text.trim().isEmpty) {
        showErrorSnack(context, 'Veuillez indiquer la date souhaitée.');
        return;
      }
      setState(() => _step = 2);
      return;
    }
    // step 2 → submit
    _submit();
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    if (!_conn.isConnected) {
      showErrorSnack(context, 'Connexion requise. Vérifiez votre réseau.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final desc = _descCtrl.text.trim();
      final note = _noteCtrl.text.trim();
      final combined = note.isEmpty ? desc : '$desc\n\n$note';

      final mission = await _ms.createMission(
        category: _selectedCategory!.title,
        address: _locationCtrl.text.trim(),
        timeSlot: _dateCtrl.text.trim(),
        note: combined,
        isExpress: _isPrioritaire,
      );
      if (!mounted) return;
      showSuccessSnack(context, 'Dossier soumis avec succès.');
      Navigator.pushReplacementNamed(
          context, '/missionStatus',
          arguments: mission);
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  static const _stepTitles = [
    'Type de démarche',
    'Détails du dossier',
    'Options & tarif',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: _back,
        ),
        title: Text(_stepTitles[_step]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: RilyColors.surfaceBorder,
            color: RilyColors.accent,
            minHeight: 3,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStep(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildStepCategory();
      case 1:
        return _buildStepDetails();
      case 2:
        return _buildStepOptions();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 0 : category ─────────────────────────────────────────────────────

  Widget _buildStepCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quel type de démarche\nsouhaitez-vous déléguer ?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: RilyColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sélectionnez la catégorie correspondant\nà votre besoin.',
          style: TextStyle(
              fontSize: 14, color: RilyColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        ...kServiceCategories.map((cat) {
          final selected = _selectedCategory?.id == cat.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? cat.accentColor.withValues(alpha: 0.08)
                      : RilyColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        selected ? cat.accentColor : RilyColors.surfaceBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cat.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(cat.emoji,
                              style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? cat.accentColor
                                  : RilyColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat.subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: RilyColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right_rounded,
                      color:
                          selected ? cat.accentColor : RilyColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Step 1 : details ──────────────────────────────────────────────────────

  Widget _buildStepDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryChip(category: _selectedCategory!),
        const SizedBox(height: 24),
        const Text(
          'Décrivez votre démarche',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: RilyColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Plus vous êtes précis, mieux notre expert\npourra prendre en charge votre dossier.',
          style: TextStyle(
              fontSize: 14, color: RilyColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        RilyTextField(
          controller: _descCtrl,
          label: 'Description de la démarche',
          hint:
              'Ex : Renouvellement de titre de séjour suite à un changement d\'adresse...',
          maxLines: 4,
        ),
        const SizedBox(height: 14),
        RilyTextField(
          controller: _locationCtrl,
          label: 'Lieu de la démarche',
          hint: 'Ex : Préfecture de Casablanca, Consulat de France...',
        ),
        const SizedBox(height: 14),
        RilyTextField(
          controller: _dateCtrl,
          label: 'Date / créneau souhaité',
          hint: 'Ex : Cette semaine, avant le 20 mars, de préférence matin...',
        ),
        const SizedBox(height: 20),
        const AlertBanner(
          type: AlertType.info,
          message:
              'Vos informations sont strictement confidentielles et uniquement partagées avec l\'expert assigné à votre dossier.',
        ),
      ],
    );
  }

  // ── Step 2 : options & pricing ────────────────────────────────────────────

  Widget _buildStepOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryChip(category: _selectedCategory!),
        const SizedBox(height: 24),
        const Text(
          'Options & tarification',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: RilyColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),

        // Urgency
        const SectionHeader("NIVEAU D'URGENCE"),
        const SizedBox(height: 12),
        _UrgencyOption(
          title: 'Standard',
          subtitle: 'Prise en charge sous 48h ouvrées',
          detail: 'Tarif de base',
          isSelected: !_isPrioritaire,
          onTap: () => setState(() => _isPrioritaire = false),
        ),
        const SizedBox(height: 10),
        _UrgencyOption(
          title: 'Prioritaire',
          subtitle: 'Expert dédié — traitement sous 24h',
          detail: '+50 MAD',
          isSelected: _isPrioritaire,
          onTap: () => setState(() => _isPrioritaire = true),
          highlighted: true,
        ),

        const SizedBox(height: 24),

        // Notes
        const SectionHeader('INSTRUCTIONS PARTICULIÈRES'),
        const SizedBox(height: 12),
        RilyTextField(
          controller: _noteCtrl,
          label: 'Notes complémentaires (optionnel)',
          hint:
              'Documents spécifiques à apporter, accès, contact sur place...',
          maxLines: 3,
        ),

        const SizedBox(height: 24),

        // Price recap
        const SectionHeader('RÉCAPITULATIF TARIFAIRE'),
        const SizedBox(height: 12),
        RilyCard(
          borderColor: RilyColors.accent.withValues(alpha: 0.2),
          child: Column(
            children: [
              PriceRow(
                'Prestation — ${_selectedCategory!.title}',
                '${_basePrice.toStringAsFixed(0)} MAD',
              ),
              if (_isPrioritaire)
                const PriceRow(
                  'Supplément prioritaire',
                  '+50 MAD',
                  valueColor: RilyColors.express,
                ),
              const Divider(height: 20),
              PriceRow(
                'Total estimé',
                '${_totalPrice.toStringAsFixed(0)} MAD',
                isTotal: true,
              ),
              const SizedBox(height: 10),
              const Text(
                'Règlement confirmé après validation du dossier par notre équipe.',
                style: TextStyle(
                    fontSize: 11, color: RilyColors.textMuted, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Security note
        const AlertBanner(
          type: AlertType.success,
          message:
              'Vos documents sont traités par des experts vérifiés, sous accord de confidentialité.',
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isLastStep = _step == 2;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: RilyColors.bg,
        border: Border(top: BorderSide(color: RilyColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _back,
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: RilyButton(
              label: isLastStep ? 'Soumettre le dossier' : 'Continuer',
              loadingLabel: 'Soumission en cours...',
              isLoading: _isSubmitting,
              icon: isLastStep
                  ? Icons.send_rounded
                  : Icons.arrow_forward_rounded,
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Category chip (shown on steps 1 & 2)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final ServiceCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: category.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: category.accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            category.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: category.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Urgency option row
// ─────────────────────────────────────────────────────────────────────────────

class _UrgencyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String detail;
  final bool isSelected;
  final bool highlighted;
  final VoidCallback onTap;

  const _UrgencyOption({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.isSelected,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? RilyColors.express : RilyColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : RilyColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : RilyColors.surfaceBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : RilyColors.textMuted,
                  width: isSelected ? 0 : 1.5,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : RilyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: RilyColors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              detail,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: highlighted
                    ? RilyColors.express
                    : RilyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
