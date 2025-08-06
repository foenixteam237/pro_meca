import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/features/users/services/users_services.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/providers/theme_provider.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/editable_textField.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final BuildContext con;
  final User? member; // Si fourni, on édite un membre, sinon self

  const ProfileScreen({super.key, required this.con, this.member});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  User? _originalUser;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _hasChanged = false;
  String? _errorMessage;
  late String _accessToken;

  // Contrôleurs pour chaque champ éditable
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late String accessToken;
  @override
  void initState() {
    super.initState();
    _initProfile();
  }
// Ajoutez ces variables à votre état
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

// Ajoutez ces méthodes
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
        await _uploadProfileImage();
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() => _selectedImage = File(photo.path));
        await _uploadProfileImage();
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final userId = widget.member?.id ?? _user!.id;
      final updatedUser = await UserService().uploadUserProfileImage(
        userId: userId,
        imageFile: _selectedImage!,
      );

      if (updatedUser != null) {
        setState(() {
          _user = updatedUser;
          _originalUser = updatedUser;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Photo de profil mise à jour',
                style: AppStyles.titleMedium(context).copyWith(color: AppColors.primary),
              ),
            ),
            backgroundColor: AppColors.customBackground(context),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur upload image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }
  Future<void> _initProfile() async {
    _accessToken = (await SharedPreferences.getInstance()).getString('accessToken') ?? '';
    if (widget.member != null) {
      // L'admin édite un membre
      _user = widget.member;
      _originalUser = widget.member;
      _initControllers();
      setState(() => _isLoading = false);
    } else {
      _fetchUser();
    }
  }

  void _initControllers() {
    _nameCtrl = TextEditingController(text: _user?.name ?? "");
    _bioCtrl = TextEditingController(text: _user?.bio ?? "");
    _phoneCtrl = TextEditingController(text: _user?.phone ?? "");
    _emailCtrl = TextEditingController(text: _user?.email ?? "");
    // On "écoute" le changement pour activer le bouton de sauvegarde
    _nameCtrl.addListener(_onChanged);
    _bioCtrl.addListener(_onChanged);
    _phoneCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    // Active le bouton si un champ a changé par rapport à l'original
    setState(() {
      _hasChanged = (_nameCtrl.text != (_originalUser?.name ?? "")) ||
          (_bioCtrl.text != (_originalUser?.bio ?? "")) ||
          (_phoneCtrl.text != (_originalUser?.phone ?? "") || (_emailCtrl.text != (_originalUser?.email ?? "")));
    });
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await ApiDioService().getSavedUser();
      _user = User.fromUserJson(user!.toJson());
      _originalUser = User.fromUserJson(user.toJson());
      _initControllers();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données utilisateur';
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(widget.con, '/login');
  }

  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);
    try {
      // Prépare un map des champs modifiés
      final updatedFields = <String, dynamic>{};
      if (_nameCtrl.text != _originalUser?.name) updatedFields['name'] = _nameCtrl.text;
      if (_bioCtrl.text != _originalUser?.bio) updatedFields['bio'] = _bioCtrl.text;
      if (_phoneCtrl.text != _originalUser?.phone) updatedFields['phone'] = _phoneCtrl.text;
      if (_emailCtrl.text != _originalUser?.email) updatedFields['email'] = _emailCtrl.text;

      if (updatedFields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune modification détectée')),
        );
        setState(() => _isUpdating = false);
        return;
      }

      // Détermine l'ID de l'utilisateur à mettre à jour
      final userId = widget.member?.id ?? _user!.id;

      // Appel API
      final updatedUser = await UserService().updateUserProfile(userId, updatedFields, _user!.isCompanyAdmin);
      await _refreshUserData(updatedUser);
      // Vérifie que la réponse est valide
      setState(() {
        _originalUser = updatedUser;
        _hasChanged = false;
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Center(child: Text('Profil mis à jour avec succès', style: AppStyles.titleMedium(context).copyWith(color: AppColors.primary,))),
           backgroundColor: AppColors.customBackground(context),
         ),
      );
        } catch (e) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
      debugPrint('Erreur update profile: $e');
    }
  }
  Future<void> _refreshUserData([User? updatedUser]) async {
    try {
      if (widget.member == null) {
        // Cas où l'utilisateur modifie son propre profil
        final freshUser = await ApiDioService().getSavedUser();
        setState(() {
          _user = User.fromUserJson(freshUser!.toJson());
          _originalUser = User.fromUserJson(freshUser.toJson());
          _initControllers(); // Réinitialise les contrôleurs avec les nouvelles valeurs
          _isUpdating = false;
          _hasChanged = false;
        });
      } else if (updatedUser != null) {
        // Cas où un admin modifie un membre
        setState(() {
          _user = updatedUser;
          _originalUser = updatedUser;
          _initControllers();
          _isUpdating = false;
          _hasChanged = false;
        });
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      debugPrint('Erreur rafraîchissement: $e');
    }
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }
  Widget _buildBackButton(bool isAdmin){

    final appColors = Provider.of<AppAdaptiveColors>(context);
    if(isAdmin){
      return IconButton(
        icon: Icon(Icons.arrow_back, color: appColors.primary),
        onPressed: () => Navigator.pop(context),
      );
    }
    return SizedBox(height: 0,);
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.text;
    final isCompanyAdmin = _user?.isCompanyAdmin ?? false;
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackButton(widget.member !=null),
            // Section profil
            _buildProfileHeader(context, l10n, _user),
            const SizedBox(height: 10),
            // Informations utilisateur
            _buildUserInfoSection(context, l10n, textColor, _user, isCompanyAdmin),
            const SizedBox(height: 24),
            // Bouton de mise à jour
            if (isCompanyAdmin || widget.member == null)
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
                  onPressed: _hasChanged && !_isUpdating ? _updateProfile : null,
                  child: _isUpdating
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                    l10n.updateProfile,
                    style: AppStyles.buttonText(context),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Bouton de déconnexion (seulement pour "moi")
            if (widget.member == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alert,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await ApiDioService().logoutUser();
                    _navigateToHome();
                  },
                  child: Text(
                    l10n.logout,
                    style: AppStyles.buttonText(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context,
      AppLocalizations l10n,
      User? user,
      ) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Center(
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 8),
          Text(
            user?.name ?? "",
            style: AppStyles.titleLarge(context).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?.role.name ?? l10n.technicianRole,
            style: AppStyles.bodyMedium(context).copyWith(color: appColors.primary),
          ),
        ],
      ),
    );
  }
  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
          _selectImageSource();
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: _buildImageContent(_user!.logo ?? ""),
            ),
          ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit, size: 20, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Future<void> _selectImageSource() async {
    if (_selectedImage != null) {
      return; // Ne pas demander à nouveau si une image est déjà sélectionnée
    }
    final action = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
          child: Text(
            'Choisir une source d\'image',
            style: AppStyles.titleMedium(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Caméra'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galerie'),
          ),
        ],
      ),
    );
    if (action != null) {
      action == ImageSource.camera ? await _takePhoto() : await _pickImage();
    }
  }
  Widget _buildImageContent(String img) {
    if (_isUploadingImage) {
      return Center(child: CircularProgressIndicator());
    } else if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_user?.logo != null && _user!.logo!.isNotEmpty && widget.member != null) {
      return CachedNetworkImage(
        imageUrl:  _user!.logo!,
        fit: BoxFit.cover,
        httpHeaders:{'Authorization': 'Bearer $_accessToken'},
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.person),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: ApiDioService().apiUrl+img,
        fit: BoxFit.cover,
        httpHeaders:{'Authorization': 'Bearer $_accessToken'},
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.person),
      );
    }
  }
  Widget _buildUserInfoSection(
      BuildContext context,
      AppLocalizations l10n,
      Color textColor,
      User? user,
      bool isCompanyAdmin,
      ) {
    final isEditable = true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(l10n.nameLabel, _nameCtrl, isEditable),
          const Divider(height: 24, color: Colors.black12),
          _buildInfoRow(l10n.biographyLabel, _bioCtrl, isEditable, hint: "Pas de bio disponible"),
          const Divider(height: 24, color: Colors.black12),
          _buildInfoRow(l10n.phoneNumberLabel, _phoneCtrl, isEditable),
          const Divider(height: 24, color: Colors.black12),
          _buildInfoRow(l10n.authEmail, _emailCtrl, isEditable),
          if (user?.isCompanyAdmin ?? false || isCompanyAdmin ) ...[
            const Divider(height: 24, color: Colors.black12),
            _buildStaticInfoRow(l10n.lastLogin, user?.lastLogin ?? "Aucune certification"),
          ],
          const Divider(height: 24, color: Colors.black12),
          _buildStaticInfoRow(l10n.roleLabel, user?.role.name ?? l10n.technicianRole),
          if (user?.isCompanyAdmin ?? false) ...[
            const Divider(height: 24, color: Colors.black12),
            _buildStaticInfoRow(l10n.permissionsLabel, l10n.permissionsDetails),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller, bool editable, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodySmall(context).copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 4),
        EditableTextField(
          controller: controller,
          enabled: editable,
          hintText: hint,
        ),
      ],
    );
  }

  Widget _buildStaticInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodySmall(context).copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.bodyMedium(context)),
      ],
    );
  }
}