import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/analysis_repository.dart';

/// Shows one user's analysis history: date, label, confidence.
class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({
    super.key,
    required this.userKey,
    required this.userName,
    required this.userEmail,
  });

  final String userKey;
  final String userName;
  final String userEmail;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final _repo = AnalysisRepository();
  List<Map<String, dynamic>> _analyses = [];
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
      final list = await _repo.getAnalysesForUser(widget.userKey);
      if (mounted) {
        setState(() {
          _analyses = list;
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

  static String _formatTimestamp(String? ts) {
    if (ts == null || ts.isEmpty) return '—';
    try {
      final dt = DateTime.parse(ts);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
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
                  widget.userName.isNotEmpty ? widget.userName : 'User details',
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
            if (widget.userEmail.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                child: Text(
                  widget.userEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
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
                      : _analyses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.analytics_outlined, size: 64, color: theme.colorScheme.outline),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No analyses yet',
                                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This user has not analyzed any image.',
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              itemCount: _analyses.length,
                              itemBuilder: (context, index) {
                                final a = _analyses[index];
                                final label = a['label'] as String? ?? '—';
                                final confidence = (a['confidence'] as num?)?.toDouble() ?? 0.0;
                                final timestamp = a['timestamp'] as String?;
                                final isHealthy = label.toLowerCase().contains('healthy');
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: (isHealthy ? theme.colorScheme.primary : theme.colorScheme.tertiary).withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          isHealthy ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                                          size: 28,
                                          color: isHealthy ? theme.colorScheme.primary : theme.colorScheme.tertiary,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                label,
                                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatTimestamp(timestamp),
                                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Confidence: ',
                                                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                                  ),
                                                  Text(
                                                    '${(confidence * 100).toStringAsFixed(1)}%',
                                                    style: theme.textTheme.labelMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      color: isHealthy ? theme.colorScheme.primary : theme.colorScheme.tertiary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
