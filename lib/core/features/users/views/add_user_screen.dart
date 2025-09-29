import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/users/services/users_services.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/utils/validations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/role.dart';
import '../../../models/user.dart';
import '../../../widgets/imagePicker.dart';
import 'password_validator.dart';

class AddUserScreen extends StatefulWidget {
  final User? user; // Pour la modification
  final bool isEditing;
  final String _accessToken;

  const AddUserScreen({
    super.key,
    this.user,
    this.isEditing = false,
    required String accessToken,
  }) : _accessToken = accessToken;

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _bioController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _confirmPasswordController;
  final _expertiseController = TextEditingController(text: '');
  final _availabilityController = TextEditingController(text: '');

  File? _selectedImage;
  Role? _roleSelected;
  List<Role> _rolesList = [];
  List<TextEditingController> _formationControllers = [];

  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _isLoading = false;
  bool _isLoadingRoles = false;
  bool _emailValid = true;
  bool? _emailCheckResult;
  bool _emailChecking = false;
  bool _phoneValid = true;
  bool? _phoneCheckResult;
  bool _phoneChecking = false;
  bool _obscurePassword = true;
  bool _obscureOldPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isVerified = true;
  bool _isActive = true;
  Map<String, bool> _passwordCriteria = {};

  User? _currentUser;
  String _selectedCountryCode = '+237';
  String _selectedCountryIso = 'cm';
  String? _phoneError;

  // Variables de profil
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadCurrentUser();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _checkEmail();
      }
    });
    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus) {
        _checkPhone();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailFocus.dispose();
    _emailController.dispose();
    _phoneFocus.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _oldPasswordController.dispose();
    _confirmPasswordController.dispose();
    _expertiseController.dispose();
    _availabilityController.dispose();
    for (var ct in _formationControllers) {
      ct.dispose();
    }
    super.dispose();
  }

  void _initializeData() {
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _passwordController = TextEditingController();
    _bioController = TextEditingController(text: widget.user?.bio ?? '');
    _oldPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Téléphone
    if (widget.user?.phone != null && widget.user!.phone!.isNotEmpty) {
      _parseAndSetPhoneNumber(widget.user!.phone);
    }

    // TechnicianProfile
    if (widget.user?.technicianProfile != null) {
      var techProfile = widget.user!.technicianProfile;

      _expertiseController.text = techProfile?.expertise ?? '';
      _availabilityController.text = techProfile?.availability ?? '';

      if (techProfile?.certifications != null &&
          techProfile!.certifications.isNotEmpty) {
        for (var formation in techProfile.certifications) {
          _formationControllers.add(TextEditingController(text: formation));
        }
      }
    }

    _isVerified = widget.user?.isVerified ?? true;
    _isActive = widget.user?.isActive ?? true;
  }

  void _parseAndSetPhoneNumber(String phone) {
    if (phone.startsWith('+')) {
      final parts = phone.split('_');
      if (parts.isNotEmpty) {
        _selectedCountryCode = parts[0];
        _phoneController.text = parts.length > 1
            ? parts[1]
            : phone.substring(_selectedCountryCode.length);
      } else {
        _phoneController.text = phone;
      }
    } else {
      _phoneController.text = phone.contains("_") ? phone.split('_')[1] : phone;
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(userData));
        _isAdmin = _currentUser?.isCompanyAdmin == true;
      });
    }
    await _loadRoles();
  }

  Future<void> _loadRoles() async {
    if (!mounted) return;

    setState(() => _isLoadingRoles = true);
    try {
      var roles = await UserService().fetchRoles();

      var filteredRoles = roles
          .where((role) => role.name.toLowerCase() != 'admin')
          .toList();

      if (mounted) {
        setState(() {
          _rolesList = filteredRoles;
          if (widget.user != null) {
            try {
              _roleSelected = _rolesList.firstWhere(
                (role) =>
                    role.id == widget.user!.role.id ||
                    role.name == widget.user!.role.name,
                orElse: () => _rolesList.first,
              );
            } catch (e) {
              _roleSelected = _rolesList.isNotEmpty ? _rolesList.first : null;
            }
          } else {
            _roleSelected = _rolesList.isNotEmpty ? _rolesList.first : null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des rôles')),
        );
        _rolesList = [
          new Role(
            name: 'technicien',
            companyId: _currentUser?.companyId ?? "",
          ),
          new Role(
            name: 'receptionniste',
            companyId: _currentUser?.companyId ?? "",
          ),
        ];
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoles = false);
      }
    }
  }

  Future<bool> _checkEmail() async {
    if (_emailCheckResult == true) {
      return true;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _emailCheckResult = null);
      return true;
    }
    setState(() => _emailChecking = true);
    try {
      final exists = await UserService().checkEmailExists(
        _emailController.text,
      );
      if (widget.isEditing && widget.user?.email == _emailController.text) {
        setState(() {
          _emailValid = true;
          _emailCheckResult = true;
        });
      } else {
        setState(() {
          _emailValid = !exists;
          _emailCheckResult = !exists;
        });
      }
    } catch (e) {
      setState(() {
        _emailValid = false;
        _emailCheckResult = false;
      });
    } finally {
      setState(() => _emailChecking = false);
    }
    return _emailValid;
  }

  Future<bool> _checkPhone() async {
    if (_phoneCheckResult == true) {
      return true;
    }
    if (_phoneController.text.isEmpty) {
      setState(() => _phoneCheckResult = null);
      return false;
    }

    setState(() => _phoneChecking = true);
    try {
      final exists = await UserService().checkPhoneExists(
        "${_selectedCountryCode}_${_phoneController.text}",
      );
      if (widget.isEditing &&
          widget.user?.phone ==
              "${_selectedCountryCode}_${_phoneController.text}") {
        setState(() {
          _phoneValid = true;
          _phoneCheckResult = true;
        });
      } else {
        setState(() {
          _phoneValid = !exists;
          _phoneCheckResult = !exists;
        });
      }
    } catch (e) {
      setState(() {
        _phoneValid = false;
        _phoneCheckResult = false;
      });
    } finally {
      setState(() => _phoneChecking = false);
    }
    return _phoneValid;
  }

  void _updatePasswordCriteria(String password) {
    setState(() {
      _passwordCriteria = PasswordValidator.validate(password);
    });
  }

  void _addFormationField() {
    setState(() {
      _formationControllers.add(TextEditingController());
    });
  }

  void _removeFormationField(int index) {
    setState(() {
      _formationControllers.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_emailValid || !_phoneValid) return;

    if (await _checkEmail() == false) return;
    if (await _checkPhone() == false) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      final currentUserData = prefs.getString('user_data');
      final userId = currentUserData != null
          ? User.fromJson(jsonDecode(currentUserData)).id
          : '';

      // Modifier le format du téléphone avant envoi
      final fullPhone = "${_selectedCountryCode}_${_phoneController.text}";

      final user = User(
        id: widget.user?.id ?? '',
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        phone: fullPhone,
        bio: _bioController.text.trim(),
        role: _roleSelected!,
        managerId: userId,
        companyId: companyId,
        isCompanyAdmin: false,
        isVerified: _isVerified,
        isActive: _isActive,
        technicianProfile: _roleSelected?.name.toLowerCase() == 'technicien'
            ? TechnicianProfile(
                userId: widget.user?.id ?? '',
                expertise: _expertiseController.text.trim(),
                availability: _availabilityController.text.trim(),
                certifications: _formationControllers
                    .map((c) => c.text.trim())
                    .where((t) => t.isNotEmpty)
                    .toList(),
              )
            : null,
      );

      FormData formData = FormData.fromMap(
        await user.toUserJson(
          _selectedImage,
          widget.isEditing ? null : _passwordController.text,
          oldPassword: widget.isEditing && _passwordController.text.isNotEmpty
              ? _oldPasswordController.text
              : null,
        ),
      );

      User newUser;

      if (!widget.isEditing) {
        // création d'un utilisateur
        newUser = await UserService().createUser(formData);
      } else if (!_isAdmin || widget.user!.id == user.id) {
        // update profile
        // un user peut également changer son mot de passe, son email,
        // sa biographie (bio) et sa photo de profil

        FormData formDataProfil = FormData();
        if (_emailController.text.trim().isNotEmpty &&
            _emailController.text != widget.user?.email) {
          formDataProfil.fields.add(
            MapEntry("email", jsonEncode(_emailController.text.trim())),
          );
        }
        if (_bioController.text.trim().isNotEmpty &&
            _bioController.text != widget.user?.bio) {
          formDataProfil.fields.add(
            MapEntry("bio", jsonEncode(_bioController.text.trim())),
          );
        }
        if (_passwordController.text.isNotEmpty &&
            _oldPasswordController.text.isNotEmpty) {
          formDataProfil.fields.add(
            MapEntry(
              "currentPassword",
              jsonEncode(_oldPasswordController.text),
            ),
          );
          formDataProfil.fields.add(
            MapEntry("newPassword", jsonEncode(_passwordController.text)),
          );
        }

        if (_selectedImage != null) {
          formDataProfil.files.add(
            MapEntry(
              "logo",
              await MultipartFile.fromFile(
                _selectedImage!.path,
                filename: _selectedImage!.path.split('/').last,
              ),
            ),
          );
        }

        newUser = await UserService().updateUserProfile(
          userId,
          formData,
          false,
        );
      } else {
        // modification complète d'un utilisateur
        if (_isAdmin) {
          newUser = await UserService().updateUser(user.id, formData);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utilisateur ${ /* newUser.name */ ''} ${widget.isEditing ? 'modifié' : 'créé'} avec succès',
            ),
          ),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer le succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Echec de l\'opération: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPhoneInput() {
    return Row(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: CountryCodePicker(
                initialSelection: 'CM',
                favorite: ['CM', 'TD', 'CE'],
                onChanged: (country) {
                  setState(() {
                    _selectedCountryCode = country.dialCode!;
                    _selectedCountryIso = country.code!.toLowerCase();
                    if (_phoneError != null) _phoneError = null;
                  });
                },
                dialogBackgroundColor: Colors.transparent,
                boxDecoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      // color: Colors.black.withOpacity(0.1),
                      blurRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            if (!_phoneValid) ...[SizedBox(height: 20)],
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: (phone) => setState(() {
              _phoneValid = validatePhone(phone, _selectedCountryIso);
              _phoneCheckResult = null;
            }),
            onEditingComplete: _checkPhone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: _phoneChecking
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _phoneValid ? Icons.check_circle : Icons.error,
                      color: _phoneValid ? Colors.green : Colors.red,
                    ),
              errorText: _phoneValid ? null : 'Invalide ou déjà utilisé',
            ),
            validator: (value) {
              if (value!.isEmpty) return 'Champ requis';
              if (!validatePhone(_phoneController.text, _selectedCountryCode)) {
                return 'Téléphone invalide';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.responsiveValue(
              context,
              mobile: 20,
              tablet: 40,
              desktop: MediaQuery.of(context).size.width * 0.15,
            ),
            vertical: 14,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(appColors),
                const SizedBox(height: 14),

                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 700 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        _buildProfileImage(
                          appColors,
                          context,
                          widget._accessToken,
                        ),
                        const SizedBox(height: 16),

                        _buildPersonalInfoSection(context),
                        const SizedBox(height: 14),

                        _buildAccountSettingsSection(context),
                        const SizedBox(height: 14),

                        if (_roleSelected?.name.toLowerCase() == 'technicien')
                          _buildFormationsSection(context),

                        const SizedBox(height: 24),
                        _buildSubmitButton(appColors, context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppAdaptiveColors appColors) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        Text(
          widget.isEditing
              ? 'Modifier l\'utilisateur'
              : 'Ajouter un utilisateur',
          style: AppStyles.titleLarge(context),
        ),
      ],
    );
  }

  Widget _buildProfileImage(
    AppAdaptiveColors appColors,
    BuildContext context,
    String accessToken,
  ) {
    debugPrint("logo=${widget.user?.logo}");
    return GestureDetector(
      onTap: _selectImageSource,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: appColors.primary.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : (widget.user?.logo != null
                        ? CachedNetworkImage(
                            imageUrl: widget.user!.logo!,
                            fit: BoxFit.cover,
                            httpHeaders: {
                              'Authorization': 'Bearer $accessToken',
                            },
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.person),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: appColors.primary,
                          )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.edit, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              "Informations personnelles",
              Icons.person,
              context,
            ),
            const SizedBox(height: 20),

            _buildTextFieldWithValidation(
              controller: _nameController,
              label: "Nom complet",
              validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              context: context,
            ),
            const SizedBox(height: 16),

            _buildEmailField(context),
            const SizedBox(height: 16),

            _buildPhoneInput(),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Biographie/Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => value == null
                  ? null
                  : (value.trim().length <= 500
                        ? null
                        : "Ne doit pas dépasser 500 caractères"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Paramètres du compte", Icons.settings, context),
            const SizedBox(height: 20),

            if (!widget.isEditing) _buildPasswordField(context),
            if (widget.isEditing) _buildPasswordUpdateSection(context),

            const SizedBox(height: 16),
            _buildRoleDropdown(context),
            const SizedBox(height: 20),

            Row(
              children: [
                _buildToggleSwitch(
                  value: _isVerified,
                  onChanged: (value) => setState(() => _isVerified = value),
                  label: "Vérifié",
                  icon: Icons.verified,
                ),
                const SizedBox(width: 20),
                _buildToggleSwitch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  label: "Actif",
                  icon: Icons.power_settings_new,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormationsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _availabilityController,
              decoration: InputDecoration(
                label: Text("Disponibilité"),
                helperText: "Ex: Lundi-Vendredi 8h-17h, Week-end sur demande",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _expertiseController,
              decoration: InputDecoration(
                label: Text("Expertise"),
                helperText: "Domaines d'expertise",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Formations", Icons.school, context),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: _addFormationField,
                ),
              ],
            ),
            const SizedBox(height: 16),

            ..._formationControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: "Formation ${index + 1}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeFormationField(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (_formationControllers.isEmpty)
              const Text(
                "Aucune formation ajoutée. Cliquez sur + pour ajouter.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      // key: _emailFieldKey,
      focusNode: _emailFocus,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (email) => setState(() {
        _emailValid = validateEmail(email);
        if (email.isNotEmpty) {
          _emailCheckResult = null;
        }
      }),
      onEditingComplete: _checkEmail,
      decoration: InputDecoration(
        labelText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: _emailChecking
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _emailValid ? Icons.check_circle : Icons.error,
                color: _emailValid ? Colors.green : Colors.red,
              ),
        errorText: _emailValid ? null : 'Email invalide ou déjà utilisé',
      ),
      validator: (value) {
        // if (value!.isEmpty) return 'Champ requis';
        if (value!.isNotEmpty && !validateEmail(value)) return 'Email invalide';
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: _updatePasswordCriteria,
          decoration: InputDecoration(
            labelText: "Mot de passe",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: widget.isEditing
              ? null
              : (value) {
                  if (value!.isEmpty) return 'Champ requis';
                  if (value.length < 6) return '6 caractères minimum';
                  return null;
                },
        ),
        const SizedBox(height: 8),
        PasswordCriteriaWidget(criteria: _passwordCriteria),
      ],
    );
  }

  Widget _buildPasswordUpdateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Modifier le mot de passe", style: AppStyles.titleMedium(context)),
        const SizedBox(height: 12),

        TextFormField(
          controller: _oldPasswordController,
          obscureText: _obscureOldPassword,
          decoration: InputDecoration(
            labelText: "Ancien mot de passe",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureOldPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _obscureOldPassword = !_obscureOldPassword),
            ),
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: _updatePasswordCriteria,
          decoration: InputDecoration(
            labelText: "Nouveau mot de passe",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PasswordCriteriaWidget(criteria: _passwordCriteria),

        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: "Confirmer le mot de passe",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
          validator: (value) {
            if (_passwordController.text.isNotEmpty &&
                value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: value ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildRoleDropdown(BuildContext context) {
    return _isLoadingRoles
        ? const Center(child: CircularProgressIndicator())
        : DropdownButtonFormField<Role>(
            value: _roleSelected,
            decoration: InputDecoration(
              labelText: "Rôle",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _rolesList.map((Role role) {
              return DropdownMenuItem<Role>(
                value: role,
                child: Text(role.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (widget.isEditing && _currentUser?.id == widget.user?.id)
                ? null // L'admin ne peut pas modifier son propre rôle
                : (Role? newValue) {
                    setState(() {
                      _roleSelected = newValue;
                    });
                  },
          );
  }

  Widget _buildSubmitButton(AppAdaptiveColors appColors, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isEditing ? Icons.save : Icons.person_add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEditing
                        ? "Modifier l'utilisateur"
                        : "Ajouter l'utilisateur",
                    style: AppStyles.buttonText(
                      context,
                    ).copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppStyles.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithValidation({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    required BuildContext context,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _selectImageSource() async {
    final source = await showImageSourceDialog(context);
    if (source == null) return;

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }
}
