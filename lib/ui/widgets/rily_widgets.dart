import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../models/mission.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  RilyCard — carte surface standard
// ─────────────────────────────────────────────────────────────────────────────

class RilyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const RilyCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RilyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? RilyColors.surfaceBorder,
          width: 1,
        ),
      ),
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            )
          : Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  StatusBadge — badge coloré pour statut mission
// ─────────────────────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final MissionStatus status;
  final bool small;

  const StatusBadge(this.status, {super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '${status.emoji}  ${status.label}',
        style: TextStyle(
          color: color,
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ExpressBadge
// ─────────────────────────────────────────────────────────────────────────────

class ExpressBadge extends StatelessWidget {
  const ExpressBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: RilyColors.expressDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RilyColors.express.withOpacity(0.3)),
      ),
      child: const Text(
        '⚡ Express',
        style: TextStyle(
          color: RilyColors.express,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RilyButton — bouton primaire avec état loading
// ─────────────────────────────────────────────────────────────────────────────

class RilyButton extends StatelessWidget {
  final String label;
  final String? loadingLabel;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  const RilyButton({
    super.key,
    required this.label,
    this.loadingLabel,
    this.isLoading = false,
    this.isEnabled = true,
    this.onPressed,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? RilyColors.accent;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? bg : RilyColors.surfaceElevated,
          foregroundColor: isEnabled ? Colors.white : RilyColors.textMuted,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isEnabled ? Colors.white : RilyColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loadingLabel ?? label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RilyTextField — champ texte thémé
// ─────────────────────────────────────────────────────────────────────────────

class RilyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const RilyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: RilyColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ConnectivityBanner — bandeau offline en haut d'écran
// ─────────────────────────────────────────────────────────────────────────────

class ConnectivityBanner extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onRetry;

  const ConnectivityBanner({
    super.key,
    required this.isOffline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: RilyColors.error.withOpacity(0.12),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: RilyColors.error, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pas de connexion — les données peuvent ne pas être à jour',
              style: TextStyle(
                  color: RilyColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: RilyColors.error,
              ),
              child: const Text('Réessayer',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AlertBanner — message succès / erreur / info inline
// ─────────────────────────────────────────────────────────────────────────────

class AlertBanner extends StatelessWidget {
  final String message;
  final AlertType type;
  final IconData? icon;

  const AlertBanner({
    super.key,
    required this.message,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      AlertType.success => RilyColors.success,
      AlertType.error => RilyColors.error,
      AlertType.warning => RilyColors.warning,
      AlertType.info => RilyColors.info,
    };
    final defaultIcon = switch (type) {
      AlertType.success => Icons.check_circle_outline_rounded,
      AlertType.error => Icons.error_outline_rounded,
      AlertType.warning => Icons.warning_amber_rounded,
      AlertType.info => Icons.info_outline_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AlertType { success, error, warning, info }

// ─────────────────────────────────────────────────────────────────────────────
//  SectionHeader — titre de section avec ligne
// ─────────────────────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: RilyColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(height: 1)),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  StarRating — widget étoiles interactif
// ─────────────────────────────────────────────────────────────────────────────

class StarRating extends StatelessWidget {
  final int selected;
  final void Function(int)? onSelect; // null = lecture seule
  final double size;

  const StarRating({
    super.key,
    required this.selected,
    this.onSelect,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final score = i + 1;
        final filled = score <= selected;
        return GestureDetector(
          onTap: onSelect != null ? () => onSelect!(score) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? RilyColors.warning : RilyColors.textMuted,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PriceRow — ligne prix pour récap tarif
// ─────────────────────────────────────────────────────────────────────────────

class PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const PriceRow(this.label, this.value,
      {super.key, this.isTotal = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight:
                  isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal
                  ? RilyColors.textPrimary
                  : RilyColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight:
                  isTotal ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ??
                  (isTotal ? RilyColors.accent : RilyColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Snackbar helpers
// ─────────────────────────────────────────────────────────────────────────────

void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: RilyColors.success, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

void showErrorSnack(BuildContext context, Object error) {
  final msg =
      error is Exception ? error.toString().replaceFirst('Exception: ', '') : '$error';
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: RilyColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  EmptyState — état vide générique
// ─────────────────────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: RilyColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: RilyColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}