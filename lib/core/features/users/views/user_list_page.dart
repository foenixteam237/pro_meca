import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/profil/user_profile_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _initData();
  }
  Future<void> _handleRefresh() async {
    await _fetchUsers(); // Recharge les données
    _filterUsers(); // Réapplique les filtres
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
        final roleMatch = _selectedRole == null || user.role.name == _selectedRole;
        return nameMatch && roleMatch;
      }).toList();
    });
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      users = await UserService().getAllUsers();
      filteredUsers = List.from(users);
    } catch (e) {
      print("Erreur: $e");
    } finally {
      setState(() => _isLoading = false);
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
              ...roles.map((role) => ListTile(
                leading: Icon(Icons.person),
                title: Text(role),
                selected: role == _selectedRole,
                onTap: () {
                  setState(() {
                    _selectedRole = role;
                    _filterUsers();
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
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
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.responsiveValue(context,
                    mobile: height * 0.025,
                    tablet: height * 0.02,
                    desktop: height * 0.03),
                vertical: 12),
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
                            suffixIcon: Icon(Icons.search, color: appColors.primary),
                            hintStyle: TextStyle(
                                color: Theme.of(context).hintColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.responsiveValue(context, mobile: height * 0.01, tablet: height * 0.02, desktop: height * 0.03)),
                // 🧾 Titre + Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Liste des utilisateurs', style: AppStyles.titleMedium(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showRoleFilter(context);
                          },
                          icon:  Icon(Icons.filter_list, color: appColors.primary),
                          tooltip: "Filtrer par rôle",
                        ),
                        IconButton(
                          onPressed: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddUserScreen()),
                            );
                          },
                          icon:  Icon(Icons.add_circle, color: appColors.primary),
                          tooltip: "Ajouter un utilisateur",
                        ),
                     ]
                    )
                   ]
                ),
                SizedBox(height: Responsive.responsiveValue(context, mobile: height * 0.001, tablet: height * 0.01, desktop: height * 0.03)),
                // 👤 Liste des utilisateurs ou shimmer
                Expanded(
                  child: _isLoading
                      ? const UserListShimmer()
                      : filteredUsers.isEmpty
                      ? const Center(child: Text('Aucun utilisateur trouvé.'))
                      : ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) =>  Divider(color: Colors.grey.withOpacity(0.4), height: 1),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];

                      return Dismissible(
                        key: ValueKey(user.id), // ⚠️ assure-toi que User a un id unique
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Confirmation"),
                              content: Text("Voulez-vous supprimer ${user.name} ?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text("Annuler"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          try {
                            bool delete = await UserService().deleteUser(user.id);
                            if (delete) {
                              setState(() {
                                users.removeWhere((u) => u.id == user.id);
                                filteredUsers.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur suppression: ${user.id}")),
                              );
                            }else{

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur de suppression ${user.name}")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Erreur suppression: $e")),
                            );
                          }
                        },
                        child: ListTile(
                          leading: buildImage(user.logo, context, _accessToken),
                          title: Text(
                            user.name,
                            style: AppStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: appColors.customText(context),
                            ),
                          ),
                          subtitle: Text(
                            user.role.name.toUpperCase(),
                            style: AppStyles.bodySmall(context).copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen(con: context, member: user)),
                            );
                          },
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

