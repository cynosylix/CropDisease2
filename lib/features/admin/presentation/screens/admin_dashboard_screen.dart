import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/analysis_repository.dart';
import 'admin_user_detail_screen.dart';

/// Admin dashboard: list all users. Tap to see that user's analyses.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: surfaceGradient),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: topPadding),
              decoration: BoxDecoration(gradient: gradient),
              child: AppBar(
                title: Text(
                  'Admin – Users',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                              const SizedBox(height: 16),
                              Text(_error!, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_outline_rounded, size: 64, color: theme.colorScheme.outline),
                                  const SizedBox(height: 16),
                                  Text('No users yet', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final u = _users[index];
                                final name = u['name'] as String? ?? '';
                                final email = u['email'] as String? ?? '';
                                final key = u['key'] as String? ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Material(
                                    color: theme.colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(16),
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
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 24),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name.isNotEmpty ? name : 'No name',
                                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                                  ),
                                                  if (email.isNotEmpty)
                                                    Text(
                                                      email,
                                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                                          ],
                                        ),
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
    );
  }
}
