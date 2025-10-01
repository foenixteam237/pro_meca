import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/users/services/users_services.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user.dart';
import '../../../widgets/build_image.dart';
import '../widgets/UserListShimmer.dart';
import 'add_user_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<User> users = [];
  List<User> filteredUsers = [];
  bool _isLoading = false;
  String _accessToken = '';
  String? _selectedRole;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _initData();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(userData));
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchUsers();
    _filterUsers();
  }

  Future<void> _initData() async {
    await _getToken();
    await _fetchUsers();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken') ?? '';
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        final nameMatch = user.name.toLowerCase().contains(query);
        final roleMatch =
            _selectedRole == null || user.role.name == _selectedRole;
        return nameMatch && roleMatch;
      }).toList();
    });
  }

  Future<void> _fetchUsers() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      users = await UserService().getAllUsers();
      filteredUsers = List.from(users);
    } catch (e) {
      debugPrint("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des utilisateurs')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRoleFilter(BuildContext context) {
    final roles = users.map((u) => u.role.name).toSet().toList();
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('Aucun filtre'),
                onTap: () {
                  setState(() {
                    _selectedRole = null;
                    _filterUsers();
                  });
                  Navigator.pop(context);
                },
              ),
              ...roles.map(
                (role) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(role),
                  selected: role == _selectedRole,
                  onTap: () {
                    setState(() {
                      _selectedRole = role;
                      _filterUsers();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserActions(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  _editUser(user);
                },
              ),
              if (!user.isCompanyAdmin)
                ListTile(
                  leading: Icon(
                    user.isActive ? Icons.pause_circle : Icons.play_arrow,
                    color: user.isActive ? Colors.orange : Colors.green,
                  ),
                  title: Text(user.isActive ? 'Désactiver' : 'Activer'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleUserStatus(user);
                  },
                ),
              if (_currentUser != null && user.id != _currentUser!.id)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(user);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUserScreen(
          user: user,
          isEditing: true,
          accessToken: _accessToken,
        ),
      ),
    );

    if (result == true && mounted) {
      await _handleRefresh();
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      final success = await UserService().toggleUserStatus(
        user.id,
        !user.isActive,
      );
      if (success) {
        await _handleRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utilisateur ${user.isActive ? 'désactivé' : 'activé'} avec succès',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur de changement de statut utilisateur: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text("Voulez-vous supprimer ${user.name} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteUser(user);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    try {
      final success = await UserService().deleteUser(user.id);
      if (success) {
        await _handleRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} supprimé avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur suppression: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: appColors.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.responsiveValue(
                context,
                mobile: height * 0.025,
                tablet: height * 0.02,
                desktop: height * 0.03,
              ),
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Champ de recherche
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => _filterUsers(),
                          decoration: InputDecoration(
                            hintText: 'Nom utilisateur',
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.search,
                              color: appColors.primary,
                            ),
                            hintStyle: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Responsive.responsiveValue(
                    context,
                    mobile: height * 0.01,
                    tablet: height * 0.02,
                    desktop: height * 0.03,
                  ),
                ),
                // 🧾 Titre + Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Liste des utilisateurs',
                      style: AppStyles.titleMedium(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showRoleFilter(context),
                          icon: Icon(
                            Icons.filter_list,
                            color: appColors.primary,
                          ),
                          tooltip: "Filtrer par rôle",
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddUserScreen(accessToken: _accessToken),
                              ),
                            ).then((value) {
                              if (value == true) {
                                _handleRefresh();
                              }
                            });
                          },
                          icon: Icon(
                            Icons.add_circle,
                            color: appColors.primary,
                          ),
                          tooltip: "Ajouter un utilisateur",
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: Responsive.responsiveValue(
                    context,
                    mobile: height * 0.001,
                    tablet: height * 0.01,
                    desktop: height * 0.03,
                  ),
                ),
                // 👤 Liste des utilisateurs
                Expanded(
                  child: _isLoading
                      ? const UserListShimmer()
                      : filteredUsers.isEmpty
                      ? const Center(child: Text('Aucun utilisateur trouvé.'))
                      : ListView.separated(
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, __) => Divider(
                            color: Colors.grey.withValues(alpha: 0.4),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final phoneNumber = user.phone.contains('_')
                                ? user.phone.split('_').last
                                : user.phone;

                            return Dismissible(
                              key: ValueKey('${user.id}-$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Confirmation"),
                                    content: Text(
                                      "Voulez-vous supprimer ${user.name} ?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text("Annuler"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text(
                                          "Supprimer",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) => _deleteUser(user),
                              child: Container(
                                // Couleur de fond pour les utilisateurs inactifs
                                color: user.isActive
                                    ? null
                                    : Colors.red.withOpacity(0.1),
                                child: ListTile(
                                  leading: Stack(
                                    children: [
                                      buildImage(
                                        user.logo,
                                        context,
                                        _accessToken,
                                      ),
                                      // Badge rouge sur l'avatar pour les utilisateurs inactifs
                                      if (!user.isActive)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.block,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.name,
                                          style: AppStyles.bodyMedium(context)
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: user.isActive
                                                    ? appColors.customText(
                                                        context,
                                                      )
                                                    : Colors
                                                          .grey, // Texte grisé si inactif
                                              ),
                                        ),
                                      ),
                                      // Indicateur visuel "Inactif"
                                      if (!user.isActive)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            "INACTIF",
                                            style: AppStyles.bodySmall(context)
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.role.name.toUpperCase(),
                                        style: AppStyles.bodySmall(context)
                                            .copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w100,
                                              color: !user.isActive
                                                  ? Colors.grey
                                                  : null,
                                            ),
                                      ),
                                      if (phoneNumber.isNotEmpty)
                                        Text(
                                          phoneNumber,
                                          style: AppStyles.bodySmall(context)
                                              .copyWith(
                                                fontSize: 10,
                                                color: !user.isActive
                                                    ? Colors.grey
                                                    : null,
                                              ),
                                        ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                  onTap: () => _showUserActions(context, user),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: user.isActive
                                          ? Theme.of(context).primaryColor
                                          : Colors
                                                .grey, // Icône grisée si inactif
                                    ),
                                    onPressed: () =>
                                        _showUserActions(context, user),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
