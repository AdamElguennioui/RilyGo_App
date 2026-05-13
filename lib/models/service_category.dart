import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color accentColor;

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accentColor,
  });
}

const List<ServiceCategory> kServiceCategories = [
  ServiceCategory(
    id: 'personal',
    title: 'Administration personnelle',
    subtitle: 'CNI, passeport, permis de conduire',
    emoji: '🪪',
    accentColor: Color(0xFF00C896),
  ),
  ServiceCategory(
    id: 'mobility',
    title: 'Démarches mobilité',
    subtitle: 'Carte grise, ANTS, contrôle technique',
    emoji: '🚗',
    accentColor: Color(0xFF60A5FA),
  ),
  ServiceCategory(
    id: 'business',
    title: 'Formalités entreprise',
    subtitle: 'KBIS, dépôt légal, modifications RC',
    emoji: '🏢',
    accentColor: Color(0xFFF59E0B),
  ),
  ServiceCategory(
    id: 'immigration',
    title: 'Immigration & consulaire',
    subtitle: 'Visa, titre de séjour, apostille',
    emoji: '✈️',
    accentColor: Color(0xFFA78BFA),
  ),
  ServiceCategory(
    id: 'queue',
    title: "File d'attente",
    subtitle: 'Rendez-vous, représentation, attente',
    emoji: '⏳',
    accentColor: Color(0xFFFF7043),
  ),
  ServiceCategory(
    id: 'notary',
    title: 'Notariat & légalisation',
    subtitle: 'Légalisation, traduction certifiée',
    emoji: '⚖️',
    accentColor: Color(0xFF22C55E),
  ),
];

/// Map category title → emoji (includes legacy categories)
const kCategoryEmojis = <String, String>{
  'Administration personnelle': '🪪',
  'Démarches mobilité': '🚗',
  'Formalités entreprise': '🏢',
  'Immigration & consulaire': '✈️',
  "File d'attente": '⏳',
  'Notariat & légalisation': '⚖️',
  // legacy
  'Document': '📄',
  'Petit colis': '📦',
  'Grand colis': '🚚',
};
