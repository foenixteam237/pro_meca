import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/users/services/users_services.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/role.dart';
import '../../../models/user.dart';
import '../../../widgets/imagePicker.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  File? _selectedImage;

  Role? _roleSelected;
  List<Role> _rolesList = [];

  bool _isLoading = false;
  bool _isLoadingRoles = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _loadRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoadingRoles = true);
    try {

      var roles = await UserService().fetchRoles();
      // Remplacez par votre appel API réel
      await Future.delayed(const Duration(seconds: 1)); // Simulation chargement
      setState(() {
        _rolesList = roles;
        _roleSelected = _rolesList.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des rôles: $e')),
      );
    } finally {
      setState(() => _isLoadingRoles = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    var current = (await SharedPreferences.getInstance()).getString('user_data');
    var companyId = (await SharedPreferences.getInstance()).getString('companyId');
    final String userId = User.fromJson(jsonDecode(current!)).id;

    setState(() => _isLoading = true);
    try {
      final user = User(
        email: _emailController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        bio: "",
        role: _roleSelected!, id: '', managerId: userId, companyId: companyId, isCompanyAdmin: _roleSelected?.id == 1, createdAt: '', updatedAt: '',
      );

      FormData formData = FormData.fromMap(
        await user.toUserJson(_selectedImage, _passwordController.text),
      );
      var newUser = await UserService().createUser(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur ${newUser.name} créé avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.responsiveValue(
              context,
              mobile: 20,
              tablet: 40,
              desktop: MediaQuery.of(context).size.width * 0.2,
            ),
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: appColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 600 : double.infinity,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildProfileImage(appColors, context),
                          const SizedBox(height: 24),

                          _buildSectionTitle("Informations personnelles", context),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _nameController,
                            label: "Nom complet",
                            validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                            context: context,
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _emailController,
                            label: "Email",
                            validator: (value) =>
                            !value!.contains('@') ? 'Email invalide' : null,
                            context: context,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _phoneController,
                            label: "Numéro de téléphone",
                            validator: (value) =>
                            value!.length < 9 ? 'Téléphone invalide' : null,
                            context: context,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _passwordController,
                            label: "Mot de passe",
                            obscureText: true,
                            validator: (value) =>
                            value!.length < 6 ? '6 caractères minimum' : null,
                            context: context,
                          ),
                          const SizedBox(height: 16),

                          const Divider(height: 20, color: Colors.grey),

                          _buildSectionTitle("Rôle", context),
                          const SizedBox(height: 12),
                          _buildRoleDropdown(context),
                          const SizedBox(height: 16),

                          const Divider(height: 20, color: Colors.grey),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle("Formations", context),
                              IconButton(
                                icon: Icon(Icons.add_circle,
                                    color: appColors.primary,
                                    size: isDesktop ? 32 : 28),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isLoading ? null : _submitForm,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                "Ajouter l'utilisateur",
                                style: AppStyles.buttonText(context),
                              ),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 40 : 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
// Dans n'importe quel widget
  Future<void> _selectImageSource() async {
    final source = await showImageSourceDialog(context);
    if (source == null) return;

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Widget _buildProfileImage(AppAdaptiveColors appColors, BuildContext context) {
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
                color: appColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              )
                  : Image.network(
                'https://i.imgur.com/Iy8Z6kO.jpg',
                fit: BoxFit.cover,
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 60,
                  color: appColors.primary,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: appColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit, size: 20, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppStyles.titleMedium(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    required BuildContext context,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final isDesktop = Responsive.isDesktop(context);
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelStyle: AppStyles.titleMedium(context).copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey
        ),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: appColors.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16,
          vertical: isDesktop ? 20 : 16,
        ),
        filled: true,
      ),
    );
  }

  Widget _buildRoleDropdown(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return _isLoadingRoles
        ? const CircularProgressIndicator()
        : Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 18,
      ),
      child:DropdownButtonFormField<Role>(
        isExpanded: true,
        padding: const EdgeInsets.all(10),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        value: _roleSelected,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.grey.shade600,
        ),
        items: _rolesList.map((Role role) {
          return DropdownMenuItem<Role>(
            value: role,
            child: Text(
              role.name.toUpperCase(),
              style: AppStyles.bodyMedium(context),
            ),
          );
        }).toList(),
        onChanged: (Role? newValue) {
          setState(() {
            _roleSelected = newValue;
          });
        },
        style: AppStyles.titleMedium(context).copyWith(
          fontSize: Responsive.responsiveValue(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
      ),
    );
  }
}