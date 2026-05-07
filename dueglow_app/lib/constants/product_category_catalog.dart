import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ProductCategoryCatalog {
  static const List<CategorySection> sections = [
    CategorySection(
      id: 'facial',
      nameKey: 'sectionFacial',
      options: [
        CategoryOption(id: 'limpieza', nameKey: 'subLimpieza', icon: Icons.water_drop_outlined, legacyNames: ['Limpieza']),
        CategoryOption(id: 'serums', nameKey: 'subSerums', icon: Icons.science_outlined, legacyNames: ['Sérums']),
        CategoryOption(id: 'cremas', nameKey: 'subCremas', icon: Icons.spa_outlined, legacyNames: ['Hidratación', 'Cremas', 'Protección']),
        CategoryOption(id: 'contorno_ojos', nameKey: 'subContornoOjos', icon: Icons.remove_red_eye_outlined, legacyNames: ['Contorno de ojos']),
        CategoryOption(id: 'cuidado_labial', nameKey: 'subCacaoLabial', icon: Icons.healing_outlined, legacyNames: ['Cacao de labios', 'Bálsamo labial']),
        CategoryOption(id: 'tratamientos', nameKey: 'subTratamientos', icon: Icons.auto_fix_high_outlined, legacyNames: ['Tratamientos']),
      ],
    ),
    CategorySection(
      id: 'corporal',
      nameKey: 'sectionCorporal',
      options: [
        CategoryOption(id: 'gel', nameKey: 'subGel', icon: Icons.grain, legacyNames: ['Gel exfoliante', 'Gel']),
        CategoryOption(id: 'crema', nameKey: 'subCrema', icon: Icons.clean_hands_outlined, legacyNames: ['Crema', 'Solares corporales']),
        CategoryOption(id: 'manos', nameKey: 'subManos', icon: Icons.front_hand_outlined, legacyNames: ['Manos']),
        CategoryOption(id: 'desodorante', nameKey: 'subDesodorante', icon: Icons.air_outlined, legacyNames: ['Desodorante']),
      ],
    ),
    CategorySection(
      id: 'capilar',
      nameKey: 'sectionCapilar',
      options: [
        CategoryOption(id: 'champu', nameKey: 'subChampu', icon: Icons.wash_outlined, legacyNames: ['Champú']),
        CategoryOption(id: 'mascarilla', nameKey: 'subMascarilla', icon: Icons.face_retouching_natural, legacyNames: ['Mascarilla']),
        CategoryOption(id: 'acondicionador', nameKey: 'subAcondicionador', icon: Icons.water_outlined, legacyNames: ['Acondicionador']),
        CategoryOption(id: 'serum_capilar', nameKey: 'subSerumCapilar', icon: Icons.spa_outlined, legacyNames: ['Sérum capilar']),
      ],
    ),
    CategorySection(
      id: 'maquillaje',
      nameKey: 'sectionMaquillaje',
      options: [
        CategoryOption(id: 'rostro', nameKey: 'subRostro', icon: Icons.brush_outlined, legacyNames: ['Rostro']),
        CategoryOption(id: 'ojos', nameKey: 'subOjos', icon: Icons.remove_red_eye_outlined, legacyNames: ['Ojos']),
        CategoryOption(id: 'labios', nameKey: 'subLabios', icon: Icons.face_4_outlined, legacyNames: ['Labios']),
        CategoryOption(id: 'cejas', nameKey: 'subCejas', icon: Icons.auto_awesome_outlined, legacyNames: ['Cejas']),
      ],
    ),
    CategorySection(
      id: 'salud',
      nameKey: 'sectionMedicamentosSuplementos',
      options: [
        CategoryOption(id: 'medicamentos', nameKey: 'subMedicamentos', icon: Icons.medication_outlined),
        CategoryOption(id: 'suplementos', nameKey: 'subSuplementos', icon: Icons.vaccines_outlined),
      ],
    ),
    CategorySection(
      id: 'otros',
      nameKey: 'sectionOtros',
      options: [
        CategoryOption(id: 'unas', nameKey: 'subUnas', icon: Icons.back_hand_outlined, legacyNames: ['Uñas']),
        CategoryOption(id: 'fragancia', nameKey: 'subFragancia', icon: Icons.local_florist_outlined, legacyNames: ['Fragancia']),
        CategoryOption(id: 'higiene_intima', nameKey: 'subHigieneIntima', icon: Icons.sanitizer_outlined, legacyNames: ['Higiene íntima']),
        CategoryOption(id: 'otros', nameKey: 'subOtros', icon: Icons.inventory_2_outlined),
      ],
    ),
  ];

  static String scopedLabel(String sectionId, String subcategoryId) {
    return '$sectionId:$subcategoryId';
  }

  static bool matchesSubcategory({
    required List<String> categories,
    required String sectionId,
    required String subcategoryId,
  }) {
    final wantedScoped = _normalize(scopedLabel(sectionId, subcategoryId));
    final wantedSub = _normalize(subcategoryId);
    final option = getOption(sectionId, subcategoryId);
    final legacyScoped = option?.legacyNames
            .map((legacy) => _normalize('${sectionLabelFromId(sectionId)}:$legacy'))
            .toSet() ??
        <String>{};
    final legacySubs = option?.legacyNames.map(_normalize).toSet() ?? <String>{};

    for (final category in categories) {
      final normalized = _normalize(category);
      if (normalized == wantedScoped ||
          normalized == wantedSub ||
          legacyScoped.contains(normalized) ||
          legacySubs.contains(normalized)) {
        return true;
      }
    }
    return false;
  }

  static String prettyLabel(String rawCategory, AppLocalizations l10n) {
    if (!rawCategory.contains(':')) return rawCategory;
    final parts = rawCategory.split(':');
    if (parts.length != 2) return rawCategory;
    final section = getSection(parts.first);
    final option = getOption(parts.first, parts.last);
    if (section != null && option != null) {
      return '${section.localizedName(l10n)} > ${option.localizedName(l10n)}';
    }
    return '${parts.first} > ${parts.last}';
  }

  static CategorySection? getSection(String sectionId) {
    for (final section in sections) {
      if (section.id == sectionId) return section;
    }
    return null;
  }

  static CategoryOption? getOption(String sectionId, String subcategoryId) {
    final section = getSection(sectionId);
    if (section == null) return null;
    for (final option in section.options) {
      if (option.id == subcategoryId) return option;
    }
    return null;
  }

  static String sectionLabelFromId(String sectionId) {
    switch (sectionId) {
      case 'facial':
        return 'Facial';
      case 'corporal':
        return 'Corporal';
      case 'capilar':
        return 'Capilar';
      case 'maquillaje':
        return 'Maquillaje';
      case 'salud':
        return 'Medicamentos y suplementos';
      case 'otros':
        return 'Otros';
      default:
        return sectionId;
    }
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}

class CategorySection {
  final String id;
  final String nameKey;
  final List<CategoryOption> options;

  const CategorySection({
    required this.id,
    required this.nameKey,
    required this.options,
  });

  String localizedName(AppLocalizations l10n) => _labelForKey(l10n, nameKey);
}

class CategoryOption {
  final String id;
  final String nameKey;
  final IconData icon;
  final List<String> legacyNames;

  const CategoryOption({
    required this.id,
    required this.nameKey,
    required this.icon,
    this.legacyNames = const [],
  });

  String localizedName(AppLocalizations l10n) => _labelForKey(l10n, nameKey);
}

String _labelForKey(AppLocalizations l10n, String key) {
  switch (key) {
    case 'sectionFacial':
      return l10n.sectionFacial;
    case 'sectionCorporal':
      return l10n.sectionCorporal;
    case 'sectionCapilar':
      return l10n.sectionCapilar;
    case 'sectionMaquillaje':
      return l10n.sectionMaquillaje;
    case 'sectionMedicamentosSuplementos':
      return l10n.sectionMedicamentosSuplementos;
    case 'sectionOtros':
      return l10n.sectionOtros;
    case 'subLimpieza':
      return l10n.subLimpieza;
    case 'subSerums':
      return l10n.subSerums;
    case 'subCremas':
      return l10n.subCremas;
    case 'subContornoOjos':
      return l10n.subContornoOjos;
    case 'subTratamientos':
      return l10n.subTratamientos;
    case 'subProteccion':
      return l10n.subProteccion;
    case 'subGel':
      return l10n.subGel;
    case 'subCrema':
      return l10n.subCrema;
    case 'subManos':
      return l10n.subManos;
    case 'subDesodorante':
      return l10n.subDesodorante;
    case 'subChampu':
      return l10n.subChampu;
    case 'subMascarilla':
      return l10n.subMascarilla;
    case 'subAcondicionador':
      return l10n.subAcondicionador;
    case 'subSerumCapilar':
      return l10n.subSerumCapilar;
    case 'subRostro':
      return l10n.subRostro;
    case 'subOjos':
      return l10n.subOjos;
    case 'subLabios':
      return l10n.subLabios;
    case 'subCejas':
      return l10n.subCejas;
    case 'subMedicamentos':
      return l10n.subMedicamentos;
    case 'subSuplementos':
      return l10n.subSuplementos;
    case 'subUnas':
      return l10n.subUnas;
    case 'subFragancia':
      return l10n.subFragancia;
    case 'subCacaoLabial':
      return l10n.subCacaoLabial;
    case 'subHigieneIntima':
      return l10n.subHigieneIntima;
    case 'subSolaresCorporales':
      return l10n.subSolaresCorporales;
    case 'subOtros':
      return l10n.subOtros;
    default:
      return key;
  }
}
