import 'package:flutter/material.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

bool validateEmail(String email) {
  final emailRegex = RegExp(
    r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );
  return emailRegex.hasMatch(email);
}

bool validatePhone(String phone, String selectedCountryCode) {
  final regex = _phoneRegex[selectedCountryCode.toLowerCase()];
  return regex != null && regex.hasMatch(phone);
}

final List<String> countries = ['CM', 'GA', 'TD', 'CE', 'NG', 'GQ', 'CG'];

// Expressions régulières par pays
final Map<String, RegExp> _phoneRegex = {
  'cm': RegExp(
    r'^[2367]\d{8}$',
  ), // Cameroun: 9 chiffres commençant par 2,3,6 ou 7
  'ga': RegExp(r'^\d{8}$'), // Gabon: 8 chiffres
  'td': RegExp(r'^\d{8}$'), // Tchad: 8 chiffres
  'cf': RegExp(r'^\d{8}$'), // Centrafrique: 8 chiffres
  'ng': RegExp(r'^[789]\d{9}$'), // Nigeria: 10 chiffres commençant par 7,8 ou 9
  'gq': RegExp(r'^\d{9}$'), // Guinée équatoriale: 9 chiffres
  'co': RegExp(r'^\d{10}$'), // Congo: 10 chiffres
};

String getPhoneFormatHint(String code, BuildContext context) {
  // 'CM', 'GA', 'TD', 'CE', 'NG', 'GQ', 'CG'
  switch (code.toLowerCase()) {
    case 'cm':
      return AppLocalizations.of(context).phoneFormatCM;
    case 'ga':
      return AppLocalizations.of(context).phoneFormatGA;
    case 'td':
      return AppLocalizations.of(context).phoneFormatTD;
    case 'ce':
      return AppLocalizations.of(context).phoneFormatCF;
    case 'ng':
      return AppLocalizations.of(context).phoneFormatNG;
    case 'gq':
      return AppLocalizations.of(context).phoneFormatGQ;
    case 'cg':
      return AppLocalizations.of(context).phoneFormatCO;
    default:
      return AppLocalizations.of(context).phoneFormatDefault;
  }
}
