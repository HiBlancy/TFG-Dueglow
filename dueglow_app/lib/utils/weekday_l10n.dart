import '../l10n/app_localizations.dart';

const weekdayKeys = <String>[
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

String weekdayShortLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'monday':
      return l10n.dayMondayShort;
    case 'tuesday':
      return l10n.dayTuesdayShort;
    case 'wednesday':
      return l10n.dayWednesdayShort;
    case 'thursday':
      return l10n.dayThursdayShort;
    case 'friday':
      return l10n.dayFridayShort;
    case 'saturday':
      return l10n.daySaturdayShort;
    case 'sunday':
      return l10n.daySundayShort;
    default:
      return key;
  }
}

String weekdayLongLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'monday':
      return l10n.dayMonday;
    case 'tuesday':
      return l10n.dayTuesday;
    case 'wednesday':
      return l10n.dayWednesday;
    case 'thursday':
      return l10n.dayThursday;
    case 'friday':
      return l10n.dayFriday;
    case 'saturday':
      return l10n.daySaturday;
    case 'sunday':
      return l10n.daySunday;
    default:
      return key;
  }
}
