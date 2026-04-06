import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/admin/admin_repository.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.15),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: StreamBuilder<List<AdminUser>>(
                  stream: AdminRepository.streamAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    var users = snapshot.data ?? [];

                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      users = users.where((user) {
                        return user.username.toLowerCase().contains(query) ||
                            user.email.toLowerCase().contains(query) ||
                            user.uid.toLowerCase().contains(query);
                      }).toList();
                    }

                    if (users.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildUserList(context, users);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWebLayout =
        Responsive.width(context) >= Responsive.tabletWebBreakpoint;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isWebLayout ? 24 : 16,
        16,
        isWebLayout ? 24 : 16,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administration',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Gestion des utilisateurs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showCreateUserDialog(context),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearching
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        onTap: () => setState(() => _isSearching = true),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, email ou ID...',
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerSkeleton(height: 100, borderRadius: 20),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off_rounded
                : Icons.people_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun utilisateur trouve'
                : 'Aucun utilisateur',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<AdminUser> users) {
    final isWebLayout =
        Responsive.width(context) >= Responsive.tabletWebBreakpoint;
    final padding = isWebLayout ? 24.0 : 16.0;

    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return AnimatedFadeSlide(
          delay: Duration(milliseconds: 30 * index),
          child: _UserCard(
            user: users[index],
            onTap: () => _showUserDetailSheet(context, users[index]),
            onSuspend: () => _toggleUserSuspension(context, users[index]),
          ),
        );
      },
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateUserDialog(),
    );
  }

  Future<void> _toggleUserSuspension(
    BuildContext context,
    AdminUser user,
  ) async {
    final suspend = !user.isSuspended;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          suspend ? 'Suspendre l\'utilisateur' : 'Reactiver l\'utilisateur',
        ),
        content: Text(
          suspend
              ? 'Voulez-vous suspendre "${user.username}" ?\n\n'
                    'Il n\'aura plus acces aux tests et aux ressources.'
              : 'Voulez-vous reactiver "${user.username}" ?\n\n'
                    'Il retrouvera l\'acces a tous les tests et ressources.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(suspend ? 'Suspendre' : 'Reactiver'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        if (suspend) {
          await AdminRepository.suspendUser(user.uid);
        } else {
          await AdminRepository.reactivateUser(user.uid);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                suspend
                    ? 'Utilisateur suspendu avec succes'
                    : 'Utilisateur reactive avec succes',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showUserDetailSheet(BuildContext context, AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDetailSheet(user: user),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;
  final VoidCallback onSuspend;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatar(context),
                const SizedBox(width: 14),
                Expanded(child: _buildUserInfo(context)),
                _buildStatusAndSubscription(context),
                const SizedBox(width: 12),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAdmin = user.isAdmin;
    final isSuspended = user.isSuspended;

    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: isSuspended
              ? cs.errorContainer.withValues(alpha: 0.5)
              : cs.primaryContainer.withValues(alpha: 0.5),
          child: Text(
            user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isSuspended ? cs.onErrorContainer : cs.onPrimaryContainer,
            ),
          ),
        ),
        if (isAdmin)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: Icon(Icons.star_rounded, size: 12, color: cs.onPrimary),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isAdmin) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.65),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${user.uid.substring(0, 8)}...',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.45),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndSubscription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _StatusBadge(status: user.status),
        const SizedBox(height: 6),
        _SubscriptionBadge(
          subscription: user.subscription,
          daysRemaining: user.daysRemaining,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'Details',
        ),
        IconButton(
          onPressed: onSuspend,
          icon: Icon(
            user.isSuspended
                ? Icons.play_arrow_rounded
                : Icons.pause_circle_outline_rounded,
            color: user.isSuspended
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
          tooltip: user.isSuspended ? 'Reactiver' : 'Suspendre',
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final UserStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bgColor;
    Color textColor;

    switch (status) {
      case UserStatus.active:
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade700;
        break;
      case UserStatus.expired:
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange.shade700;
        break;
      case UserStatus.suspended:
        bgColor = cs.errorContainer.withValues(alpha: 0.5);
        textColor = cs.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SubscriptionBadge extends StatelessWidget {
  final SubscriptionPlan subscription;
  final int? daysRemaining;

  const _SubscriptionBadge({required this.subscription, this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (subscription == SubscriptionPlan.none) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Aucun',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final daysText = daysRemaining != null
        ? '$daysRemaining jours'
        : subscription.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        daysText,
        style: TextStyle(
          color: cs.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  SubscriptionPlan _selectedSubscription = SubscriptionPlan.none;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_add_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          const Text('Nouvel utilisateur'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Minimum 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Abonnement',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SubscriptionPlan.values.map((plan) {
                    final isSelected = _selectedSubscription == plan;
                    return ChoiceChip(
                      label: Text(plan.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedSubscription = plan);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _createUser,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Creer'),
        ),
      ],
    );
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AdminRepository.createUser(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        subscription: _selectedSubscription,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur cree avec succes'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _UserDetailSheet extends StatefulWidget {
  final AdminUser user;

  const _UserDetailSheet({required this.user});

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  late AdminUser _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWebLayout =
        Responsive.width(context) >= Responsive.tabletWebBreakpoint;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWebLayout ? 28 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildStats(context),
                  const SizedBox(height: 24),
                  _buildSubscriptionSection(context),
                  const SizedBox(height: 24),
                  _buildActions(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: cs.primaryContainer.withValues(alpha: 0.5),
          child: Text(
            _user.username.isNotEmpty ? _user.username[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _user.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (_user.isAdmin) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _user.email,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              _StatusBadge(status: _user.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.fingerprint_rounded, 'ID', _user.uid),
          _buildInfoRow(
            Icons.calendar_month_rounded,
            'Cree le',
            _formatDate(_user.createdAt),
          ),
          _buildInfoRow(
            Icons.login_rounded,
            'Derniere connexion',
            _user.lastLoginAt != null
                ? _formatDate(_user.lastLoginAt!)
                : 'Jamais',
          ),
          _buildInfoRow(
            Icons.checklist_rounded,
            'Tentatives',
            _user.attemptsCount?.toString() ?? '0',
          ),
          _buildInfoRow(
            Icons.emoji_events_rounded,
            'Meilleur score',
            _user.bestScore != null ? '${_user.bestScore} / 699' : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primaryContainer.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership_rounded, color: cs.primary),
              const SizedBox(width: 10),
              Text(
                'Abonnement',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_user.subscription == SubscriptionPlan.none)
            Text(
              'Aucun abonnement actif',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plan',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
                ),
                Text(
                  _user.subscription.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jours restants',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
                ),
                Text(
                  '${_user.daysRemaining ?? 0} jours',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expire le',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
                ),
                Text(
                  _user.subscriptionEndDate != null
                      ? _formatDate(_user.subscriptionEndDate!)
                      : '-',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Modifier l\'abonnement',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SubscriptionPlan.values.map((plan) {
              final isSelected = _user.subscription == plan;
              return ChoiceChip(
                label: Text(plan.label),
                selected: isSelected,
                onSelected: _isLoading
                    ? null
                    : (selected) async {
                        if (selected && _user.subscription != plan) {
                          await _updateSubscription(plan);
                        }
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_user.isSuspended)
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _toggleSuspension(false),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Reactiver l\'utilisateur'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _toggleSuspension(true),
            icon: const Icon(Icons.pause_rounded),
            label: const Text('Suspendre l\'utilisateur'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
      ],
    );
  }

  Future<void> _updateSubscription(SubscriptionPlan plan) async {
    setState(() => _isLoading = true);
    try {
      await AdminRepository.updateUserSubscription(
        uid: _user.uid,
        subscription: plan,
      );
      final updatedUser = await AdminRepository.getUser(_user.uid);
      if (mounted && updatedUser != null) {
        setState(() => _user = updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleSuspension(bool suspend) async {
    setState(() => _isLoading = true);
    try {
      if (suspend) {
        await AdminRepository.suspendUser(_user.uid);
      } else {
        await AdminRepository.reactivateUser(_user.uid);
      }
      final updatedUser = await AdminRepository.getUser(_user.uid);
      if (mounted && updatedUser != null) {
        setState(() => _user = updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
