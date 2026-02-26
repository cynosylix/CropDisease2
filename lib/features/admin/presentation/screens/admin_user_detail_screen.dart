import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/analysis_repository.dart';

/// Shows one user's analysis history: image, label, confidence, date.
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
      return '${dt.day}/${dt.month}/${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
                              'Loading analyses...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline_rounded, size: 56, color: theme.colorScheme.error),
                                  const SizedBox(height: 20),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: _load,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _analyses.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.analytics_outlined,
                                          size: 64,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'No analyses yet',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'This user has not analyzed any image.',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : CustomScrollView(
                                slivers: [
                                  // User info card
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        horizontalPadding + padding.left,
                                        20,
                                        horizontalPadding + padding.right,
                                        8,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                if (widget.userEmail.isNotEmpty)
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.mail_outline_rounded,
                                                        size: 18,
                                                        color: theme.colorScheme.onSurfaceVariant,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Flexible(
                                                        child: Text(
                                                          widget.userEmail,
                                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                            color: theme.colorScheme.onSurfaceVariant,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                const SizedBox(height: 16),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.analytics_rounded,
                                                        size: 22,
                                                        color: theme.colorScheme.primary,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        '${_analyses.length} ${_analyses.length == 1 ? 'analysis' : 'analyses'}',
                                                        style: theme.textTheme.titleMedium?.copyWith(
                                                          fontWeight: FontWeight.w700,
                                                          color: theme.colorScheme.onPrimaryContainer,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 22),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.history_rounded,
                                                size: 22,
                                                color: theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Analysis history',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Analysis list
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(
                                      horizontalPadding + padding.left,
                                      0,
                                      horizontalPadding + padding.right,
                                      padding.bottom + 28,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final a = _analyses[index];
                                          final label = a['label'] as String? ?? '—';
                                          final confidence = (a['confidence'] as num?)?.toDouble() ?? 0.0;
                                          final timestamp = a['timestamp'] as String?;
                                          final imageUrl = a['imageUrl'] as String?;
                                          final imageBase64 = a['imageBase64'] as String?;
                                          final isHealthy = label.toLowerCase().contains('healthy');
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 14),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.surface,
                                                borderRadius: BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: (isHealthy
                                                          ? theme.colorScheme.primary
                                                          : theme.colorScheme.tertiary)
                                                      .withValues(alpha: 0.25),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(18),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Thumbnail
                                                    if (imageUrl != null && imageUrl.isNotEmpty)
                                                      Image.network(
                                                        imageUrl,
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, Object? err, StackTrace? st) => _placeholderThumb(theme),
                                                      )
                                                    else if (imageBase64 != null && imageBase64.isNotEmpty)
                                                      Image.memory(
                                                        base64Decode(imageBase64),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, Object? err, StackTrace? st) => _placeholderThumb(theme),
                                                      )
                                                    else
                                                      _placeholderThumb(theme),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(18),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets.all(8),
                                                                  decoration: BoxDecoration(
                                                                    color: (isHealthy
                                                                            ? theme.colorScheme.primary
                                                                            : theme.colorScheme.tertiary)
                                                                        .withValues(alpha: 0.15),
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                  child: Icon(
                                                                    isHealthy
                                                                        ? Icons.check_circle_rounded
                                                                        : Icons.warning_amber_rounded,
                                                                    size: 24,
                                                                    color: isHealthy
                                                                        ? theme.colorScheme.primary
                                                                        : theme.colorScheme.tertiary,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 12),
                                                                Expanded(
                                                                  child: Text(
                                                                    label,
                                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                                      fontWeight: FontWeight.w700,
                                                                      color: theme.colorScheme.onSurface,
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 12),
                                                            Text(
                                                              _formatTimestamp(timestamp),
                                                              style: theme.textTheme.bodySmall?.copyWith(
                                                                color: theme.colorScheme.onSurfaceVariant,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Confidence: ',
                                                                  style: theme.textTheme.labelMedium?.copyWith(
                                                                    color: theme.colorScheme.onSurfaceVariant,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 10,
                                                                    vertical: 4,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color: (isHealthy
                                                                            ? theme.colorScheme.primary
                                                                            : theme.colorScheme.tertiary)
                                                                        .withValues(alpha: 0.2),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Text(
                                                                    '${(confidence * 100).toStringAsFixed(1)}%',
                                                                    style: theme.textTheme.labelLarge?.copyWith(
                                                                      fontWeight: FontWeight.w700,
                                                                      color: isHealthy
                                                                          ? theme.colorScheme.primary
                                                                          : theme.colorScheme.tertiary,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: _analyses.length,
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

  Widget _placeholderThumb(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 36,
        color: theme.colorScheme.outline,
      ),
    );
  }
}
