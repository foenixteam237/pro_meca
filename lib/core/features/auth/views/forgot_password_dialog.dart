import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/features/auth/services/auth_services.dart';
import 'package:pro_meca/core/utils/extensions.dart';
import 'package:pro_meca/core/utils/q_toggle.dart';
import 'package:pro_meca/core/utils/validations.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

class ForgotPasswordDialog extends StatefulWidget {
  final String initialIdentifier;
  final bool isEmailMode;
  final String countryCode;
  final String countryIso;

  const ForgotPasswordDialog({
    super.key,
    required this.initialIdentifier,
    required this.isEmailMode,
    required this.countryCode,
    required this.countryIso,
  });

  @override
  ForgotPasswordDialogState createState() => ForgotPasswordDialogState();
}

class ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  final TextEditingController _adminPhoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _errorEmail;
  String? _errorUserPhone;
  String? _errorAdminPhone;
  String? _successMessage;
  String _countryCode = '+237';
  String _countryIso = 'cm';
  String _countryCodeAdmin = '+237';
  String _countryIsoAdmin = 'cm';

  @override
  void initState() {
    super.initState();
    _countryCode = widget.countryCode;
    _countryIso = widget.countryIso;
    _countryCodeAdmin = widget.countryCode;
    _countryIsoAdmin = widget.countryIso;

    if (widget.isEmailMode) {
      _newEmailController.text = widget.initialIdentifier;
    } else {
      _newPhoneController.text = widget.initialIdentifier;
    }
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _newPhoneController.dispose();
    _adminPhoneController.dispose();
    super.dispose();
  }

  bool _checkMail() {
    // Réinitialiser l'erreur
    setState(() {
      _errorEmail = null;
    });
    if (_newEmailController.text.isEmpty) {
      setState(() => _errorEmail = AppLocalizations.of(context).emailRequired);
      return false;
    } else if (!validateEmail(_newEmailController.text)) {
      setState(
        () => _errorEmail = AppLocalizations.of(context).errorsInvalidEmail,
      );
      return false;
    } else {
      return true;
    }
  }

  Map<String, String> _checkPhoneWithAdmin() {
    Map<String, String> map = {'phone': '', 'adminPhone': ''};
    bool isValid = true;

    setState(() {
      _errorUserPhone = null;
      _errorAdminPhone = null;
    });
    final userPhone = _newPhoneController.text.replaceAll(' ', '');
    if (userPhone.isEmpty) {
      setState(() {
        _errorUserPhone = AppLocalizations.of(context).phoneRequired;
        isValid = false;
      });
    } else if (!validatePhone(userPhone, _countryIso)) {
      setState(() {
        _errorUserPhone = AppLocalizations.of(context).invalidPhone;
        isValid = false;
      });
    }

    final adminPhone = _adminPhoneController.text.replaceAll(' ', '');
    if (adminPhone.isEmpty) {
      setState(() {
        _errorAdminPhone = AppLocalizations.of(context).phoneRequired;
        isValid = false;
      });
    } else if (!validatePhone(adminPhone, _countryIsoAdmin)) {
      setState(() {
        _errorAdminPhone = AppLocalizations.of(context).invalidPhone;
        isValid = false;
      });
    }

    Map<String, String> phones = {
      "phone": "${_countryCode}_$userPhone",
      "adminPhone": "${_countryCodeAdmin}_$adminPhone",
    };
    return isValid == false ? map : phones;
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (widget.isEmailMode) {
        // Mode email
        if (!_checkMail()) {
          throw (Exception(AppLocalizations.of(context).errorsInvalidEmail));
        }

        if (_codeAvailable) {
          _showVerificationCodeDialog(context);
        } else {
          await AuthServices().requestPasswordReset(
            email: _newEmailController.text.trim(),
          );
          setState(() {
            _successMessage = AppLocalizations.of(context).resetPasswordSent;
          });

          // Fermer le dialog après 2 secondes et ouvrir le dialog de vérification
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          // Navigator.of(context).pop();
          _showVerificationCodeDialog(context);
        }
      } else {
        // Mode téléphone - validation des deux numéros

        final selectedPhones = _checkPhoneWithAdmin();

        if (selectedPhones['phone']!.isEmpty ||
            selectedPhones['adminPhone']!.isEmpty) {
          throw Exception(AppLocalizations.of(context).bothPhonesRequired);
        }

        if (_codeAvailable) {
          if (!mounted) return;
          _showVerificationCodeDialog(context);
        } else {
          await AuthServices().requestPasswordReset(
            phone: selectedPhones['phone'],
            adminPhone: selectedPhones['adminPhone'],
          );

          setState(() {
            _successMessage = AppLocalizations.of(context).resetPasswordSent;
          });

          // Fermer le dialog après 2 secondes et ouvrir le dialog de vérification
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          // Navigator.of(context).pop();
          _showVerificationCodeDialog(context);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            e.toString().contains(
              AppLocalizations.of(context).bothPhonesRequired,
            )
            ? AppLocalizations.of(context).bothPhonesRequired
            : e.toString().contains(
                AppLocalizations.of(context).errorsInvalidEmail,
              )
            ? AppLocalizations.of(context).errorsInvalidEmail
            : e.toString().contains(
                AppLocalizations.of(context).eitherEmailOrPhonesRequired,
              )
            ? AppLocalizations.of(context).eitherEmailOrPhonesRequired
            : AppLocalizations.of(context).resetPasswordError;
      });
    } finally {
      setState(() => _isLoading = false);
      FocusScope.of(context).unfocus();
    }
  }

  void _showVerificationCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerificationCodeDialog(
        isEmailMode: widget.isEmailMode,
        email: !widget.isEmailMode ? null : _newEmailController.text.trim(),
        phone: widget.isEmailMode
            ? null
            : '${_countryCode}_${_newPhoneController.text.trim()}',
        adminPhone: widget.isEmailMode
            ? null
            : '${_countryCodeAdmin}_${_adminPhoneController.text.trim()}',
      ),
    );
  }

  bool _codeAvailable = false;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        l10n.authForgotPassword,
        style: theme.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEmailMode
                  ? l10n.resetPasswordEmailPrompt
                  : l10n.resetPasswordPhonePrompt,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Champ de l'utilisateur (email ou phone)
            if (widget.isEmailMode) ...[
              TextField(
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.authEmail,
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                onChanged: (value) {
                  if (_errorEmail != null) {
                    setState(() => _errorEmail = null);
                  }
                },
              ),
            ] else ...[
              Text(l10n.userPhoneNumber),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: CountryCodePicker(
                      countryFilter: countries,
                      showFlag: false,
                      initialSelection: widget.countryCode,
                      favorite: ['CM', 'TD', 'CE'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      searchDecoration: InputDecoration(
                        hintText: l10n.searchCountry,
                        border: OutlineInputBorder(),
                      ),
                      headerText: l10n.selectCountry,
                      textStyle: TextStyle(fontSize: 16, color: AppColors.text),
                      padding: EdgeInsets.zero,
                      onChanged: (country) {
                        setState(() {
                          _countryCode = country.dialCode!;
                          _countryIso = country.code!.toLowerCase();
                          if (_errorUserPhone != null) {
                            _errorUserPhone = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _newPhoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: getPhoneFormatHint(
                          _countryIso,
                          context,
                        ).replaceAll("Format: ", "").extractBefore('(ex:'),
                      ),
                      onChanged: (value) => setState(() {
                        if (_errorUserPhone != null) {
                          setState(() {
                            _errorUserPhone = null;
                            _errorMessage = null;
                          });
                        }
                      }),
                    ),
                  ),
                ],
              ),
              if (_errorUserPhone != null) ...[
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Text(
                    _errorUserPhone!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.alert.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
              // Champ supplémentaire pour le numéro d'admin en mode téléphone
              const SizedBox(height: 15),
              Text(l10n.adminPhoneNumber),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: CountryCodePicker(
                      countryFilter: countries,
                      showFlag: false,
                      initialSelection: widget.countryCode,
                      favorite: ['CM', 'TD', 'CE'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      searchDecoration: InputDecoration(
                        hintText: l10n.searchCountry,
                        border: OutlineInputBorder(),
                      ),
                      headerText: l10n.selectCountry,
                      textStyle: TextStyle(fontSize: 16, color: AppColors.text),
                      padding: EdgeInsets.zero,
                      onChanged: (country) {
                        setState(() {
                          _countryCodeAdmin = country.dialCode!;
                          _countryIsoAdmin = country.code!.toLowerCase();
                          if (_errorAdminPhone != null) {
                            _errorAdminPhone = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      controller: _adminPhoneController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: getPhoneFormatHint(
                          _countryIsoAdmin,
                          context,
                        ).replaceAll("Format: ", "").extractBefore('(ex:'),
                      ),
                      onChanged: (value) => setState(() {
                        if (_errorAdminPhone != null) {
                          setState(() {
                            _errorAdminPhone = null;
                            _errorMessage = null;
                          });
                        }
                      }),
                    ),
                  ),
                ],
              ),
              if (_errorAdminPhone != null) ...[
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),

                  child: Text(
                    _errorAdminPhone!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.alert.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ],

            // Messages d'état
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.alert,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else if (_successMessage != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "👍🏽${_successMessage!}",
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            SizedBox(height: 15),
            Center(
              child: QToggle(
                value: _codeAvailable,
                onChanged: (newValue) =>
                    setState(() => _codeAvailable = newValue),
                label: "Code disponible",
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _isLoading ? null : Navigator.of(context).pop(),
          child: Text(l10n.cancel, style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(l10n.submit, style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

class VerificationCodeDialog extends StatefulWidget {
  final bool isEmailMode;
  final String? email;
  final String? phone;
  final String? adminPhone;

  const VerificationCodeDialog({
    super.key,
    required this.isEmailMode,
    this.email,
    required this.phone,
    this.adminPhone,
  });

  @override
  _VerificationCodeDialogState createState() => _VerificationCodeDialogState();
}

class _VerificationCodeDialogState extends State<VerificationCodeDialog> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _codeIsCorrect = false;
  bool _obscurePassword = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_formatCode);
  }

  void _formatCode() {
    final text = _codeController.text;
    final cleanText = text.toUpperCase().replaceAll('-', '');

    if (cleanText.isEmpty) {
      return;
    }

    // Reconstruire le texte formaté
    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      if (i > 0 && i % 2 == 0 && i < 6) {
        formatted.write('-');
      }
      formatted.write(cleanText[i]);
    }

    // Mettre à jour sans déclencher de boucle infinie
    if (text != formatted.toString()) {
      _codeController.value = TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text;

    if (_codeController.text.replaceAll('-', '').length != 6) {
      setState(
        () => _errorMessage = AppLocalizations.of(
          context,
        ).verificationCodeInvalid,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Appel du service de vérification
      final responseData = await AuthServices().verifyResetCode(
        email: widget.email,
        code: code,
        phone: widget.phone,
        adminPhone: widget.adminPhone,
      );

      if (responseData['success'] == false) {
        setState(() {
          _errorMessage = responseData['message'];
        });
        return;
      }

      final data = responseData['data'];

      _userId = data['id'];
      _codeIsCorrect = true;

      // Si succès, mettre le TextField en couleur primary et afficher le champ pour le newPassword
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).verificationCodeSuccess),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      setState(
        () =>
            _errorMessage = AppLocalizations.of(context).verificationCodeFailed,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPass() async {
    final code = _codeController.text;
    final newPassword = _newPasswordController.text;

    // validations
    if (_codeController.text.replaceAll('-', '').length != 6) {
      setState(
        () => _errorMessage = AppLocalizations.of(
          context,
        ).verificationCodeInvalid,
      );
      return;
    }

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).passwordRequired),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthServices().resetPassword(
        code: code,
        newPassword: newPassword,
        id: _userId!,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).resetPasswordSucces),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      setState(
        () => _errorMessage = AppLocalizations.of(context).resetPasswordError,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        _codeIsCorrect ? l10n.newPassword : l10n.verificationCodeTitle,
        style: theme.textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _codeIsCorrect
                ? '${l10n.verificationCodeSuccess}✔️'
                : widget.isEmailMode
                ? l10n.verificationCodeSentEmail
                : l10n.verificationCodeSentAdminPhone,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: _codeIsCorrect ? AppColors.secondary : null,
            ),
          ),
          const SizedBox(height: 20),

          // Champ unique pour le code
          TextField(
            controller: _codeController,
            autofocus: !_codeIsCorrect,
            enabled: !_codeIsCorrect,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            maxLength: 8, // 6 caractères + 2 tirets
            style: theme.textTheme.headlineSmall?.copyWith(
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
              color: _codeIsCorrect ? AppColors.primary : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              counterText: '',
              hintText: 'XX-XX-XX',
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),

              suffixIcon: _codeController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _codeController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),

          if (_codeIsCorrect) ...[
            const SizedBox(height: 15),
            Text(l10n.newPassword),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              autofocus: _codeIsCorrect,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n.authPassword,
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    !_obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 15),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: AppColors.alert,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel, style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : _codeIsCorrect
              ? _resetPass
              : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _codeIsCorrect ? l10n.submit : l10n.verify,
                  style: TextStyle(fontSize: 14),
                ),
        ),
      ],
    );
  }
}
