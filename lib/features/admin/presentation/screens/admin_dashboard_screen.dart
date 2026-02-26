import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/analysis_repository.dart';
import '../../../../services/auth_service.dart';
import 'admin_user_detail_screen.dart';

/// Admin dashboard: list all users. Tap to see that user's analyses.
/// Shown as home when admin logs in; has "Analyze" to open the app and "Log out".
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.authService,
    required this.onLogout,
    required this.getAnalyzeScreen,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final AuthService authService;
  final VoidCallback onLogout;
  final Widget Function() getAnalyzeScreen;
  final Locale currentLocale;
  final void Function(Locale) onLocaleChanged;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _repo = AnalysisRepository();
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _repo.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.primaryGradientDark : AppTheme.primaryGradientLight;
    final surfaceGradient = isDark ? AppTheme.surfaceGradientDark : AppTheme.surfaceGradientLight;
    final topPadding = MediaQuery.paddingOf(context).top;
    final padding = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width > 600 ? 32.0 : 20.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: surfaceGradient),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // —— App bar ——
              Container(
                padding: EdgeInsets.only(top: topPadding),
                decoration: BoxDecoration(
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppBar(
                  leading: IconButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(AppLocalizations.of(ctx).logout),
                          content: const Text('Do you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(AppLocalizations.of(ctx).logout),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && mounted) widget.onLogout();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Log out',
                  ),
                  title: Column(
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Manage users & view analyses',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      onPressed: _loading ? null : _load,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => widget.getAnalyzeScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.eco_rounded),
                      tooltip: 'Analyze',
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Loading users...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? _ErrorState(
                            message: _error!,
                            onRetry: _load,
                            theme: theme,
                          )
                        : _users.isEmpty
                            ? _EmptyState(theme: theme)
                            : CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        horizontalPadding + padding.left,
                                        24,
                                        horizontalPadding + padding.right,
                                        8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Stats card
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                                                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  child: Icon(
                                                    Icons.people_rounded,
                                                    size: 32,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Total users',
                                                      style: theme.textTheme.labelLarge?.copyWith(
                                                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${_users.length}',
                                                      style: theme.textTheme.headlineMedium?.copyWith(
                                                        fontWeight: FontWeight.w800,
                                                        color: theme.colorScheme.onPrimaryContainer,
                                                        letterSpacing: -0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_search_rounded,
                                                size: 22,
                                                color: theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'All users',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(
                                      horizontalPadding + padding.left,
                                      0,
                                      horizontalPadding + padding.right,
                                      padding.bottom + 24,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final u = _users[index];
                                          final name = u['name'] as String? ?? '';
                                          final email = u['email'] as String? ?? '';
                                          final key = u['key'] as String? ?? '';
                                          final initial = name.isNotEmpty
                                              ? name.trim().substring(0, 1).toUpperCase()
                                              : (email.isNotEmpty ? email.substring(0, 1).toUpperCase() : '?');
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 14),
                                            child: Material(
                                              color: theme.colorScheme.surface,
                                              borderRadius: BorderRadius.circular(18),
                                              elevation: 0,
                                              shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => AdminUserDetailScreen(
                                                        userKey: key,
                                                        userName: name,
                                                        userEmail: email,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(18),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(18),
                                                    border: Border.all(
                                                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 52,
                                                        height: 52,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                            colors: [
                                                              theme.colorScheme.primary.withValues(alpha: 0.25),
                                                              theme.colorScheme.secondary.withValues(alpha: 0.2),
                                                            ],
                                                          ),
                                                          borderRadius: BorderRadius.circular(14),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          initial,
                                                          style: theme.textTheme.titleLarge?.copyWith(
                                                            fontWeight: FontWeight.w800,
                                                            color: theme.colorScheme.primary,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 18),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              name.isNotEmpty ? name : 'No name',
                                                              style: theme.textTheme.titleMedium?.copyWith(
                                                                fontWeight: FontWeight.w700,
                                                                color: theme.colorScheme.onSurface,
                                                              ),
                                                            ),
                                                            if (email.isNotEmpty) ...[
                                                              const SizedBox(height: 4),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.mail_outline_rounded,
                                                                    size: 16,
                                                                    color: theme.colorScheme.onSurfaceVariant,
                                                                  ),
                                                                  const SizedBox(width: 6),
                                                                  Expanded(
                                                                    child: Text(
                                                                      email,
                                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                                        color: theme.colorScheme.onSurfaceVariant,
                                                                      ),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios_rounded,
                                                        size: 16,
                                                        color: theme.colorScheme.onSurfaceVariant,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: _users.length,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.theme,
  });

  final String message;
  final VoidCallback onRetry;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 72,
                color: theme.colorScheme.outline.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No users yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When users register in the app, they will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
