import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/design_system.dart';
import '../api_service.dart';

class CommandCenter extends StatefulWidget {
  const CommandCenter({super.key});

  @override
  State<CommandCenter> createState() => _CommandCenterState();
}

class _CommandCenterState extends State<CommandCenter>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _analyticsData;
  Map<String, dynamic>? _pulseData;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiService.fetchAnalytics(),
      ApiService.fetchPulse(),
    ]);
    setState(() {
      _analyticsData = results[0];
      _pulseData = results[1];
      _isLoading = false;
    });
    _fadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                color: const Color(0xFF00E5FF),
                backgroundColor: const Color(0xFF111827),
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 32 : 16,
                        vertical: 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHealthSection(),
                          const SizedBox(height: 20),
                          _buildQuickStats(),
                          const SizedBox(height: 24),
                          _buildContributorSection(),
                          const SizedBox(height: 24),
                          _buildRecentActivity(),
                          const SizedBox(height: 24),
                          _buildPlatformDistribution(),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      elevation: 0,
      toolbarHeight: 70,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ThemedText(
            'Command Center',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const PulsingDot(color: Color(0xFF4CAF50), size: 6),
              const SizedBox(width: 8),
              Text(
                'All systems operational',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Catch Up',
          icon: const Icon(Icons.auto_awesome, color: Color(0xFFE91E63)),
          onPressed: _showCatchUpSheet,
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E5FF)),
          onPressed: _loadData,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHealthSection() {
    final score = _analyticsData?['health_score'] ?? 0;
    final status = _analyticsData?['status']?.toString() ?? 'Unknown';
    final healthColor = score > 70
        ? const Color(0xFF4CAF50)
        : score > 40
            ? const Color(0xFFFF9800)
            : const Color(0xFFf44336);

    return SolidCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: score / 100),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        color: healthColor,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedCounter(
                      value: score is int ? score : (score as num).toInt(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'HEALTH',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization Pulse',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: healthColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        score > 70 ? Icons.trending_up : Icons.trending_down,
                        color: healthColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        score > 70
                            ? 'Strong alignment'
                            : score > 40
                                ? 'Needs attention'
                                : 'Critical',
                        style: TextStyle(
                          fontSize: 12,
                          color: healthColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalMemories = _pulseData?['total_memories'] ?? 0;
    final contributors = (_pulseData?['contributors'] as List?)?.length ?? 0;
    final platforms = (_pulseData?['platforms'] as List?)?.length ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final cards = [
          _QuickStatData(Icons.memory, 'Memories', '$totalMemories', const Color(0xFF00E5FF)),
          _QuickStatData(Icons.people_alt, 'Contributors', '$contributors', const Color(0xFF7C4DFF)),
          _QuickStatData(Icons.hub, 'Platforms', '$platforms', const Color(0xFFFF9800)),
          _QuickStatData(Icons.psychology, 'AI Queries', 'Live', const Color(0xFF4CAF50)),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final item = cards[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 600 + (index * 150)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: StatCard(
                icon: item.icon,
                label: item.label,
                value: item.value,
                accentColor: item.color,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContributorSection() {
    final contributors = _pulseData?['contributors'] as List? ?? [];
    if (contributors.isEmpty) {
      return SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Contributor Activity', Icons.bar_chart),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No contributor data yet. Ingest some messages first.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      );
    }

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Contributor Activity', Icons.bar_chart),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxContribution(contributors) * 1.3,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1D2236),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final name = contributors[groupIndex]['name'] ?? '';
                      return BarTooltipItem(
                        '$name\n${rod.toY.toInt()} contributions',
                        const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= contributors.length) return const SizedBox();
                        final name = (contributors[idx]['name'] ?? '').toString();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            name.length > 8 ? '${name.substring(0, 8)}..' : name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(contributors.length, (i) {
                  final count = (contributors[i]['count'] ?? 0) as num;
                  final colors = [
                    const Color(0xFF00E5FF),
                    const Color(0xFF7C4DFF),
                    const Color(0xFFFF9800),
                    const Color(0xFF4CAF50),
                    const Color(0xFFE91E63),
                  ];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            colors[i % colors.length].withValues(alpha: 0.6),
                            colors[i % colors.length],
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxContribution(List contributors) {
    double max = 0;
    for (final c in contributors) {
      final count = (c['count'] ?? 0) as num;
      if (count > max) max = count.toDouble();
    }
    return max == 0 ? 10 : max;
  }

  Widget _buildRecentActivity() {
    final timeline = _analyticsData?['macro_timeline'] as List? ?? [];

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Recent Decisions', Icons.history),
          const SizedBox(height: 16),
          if (timeline.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.inbox, color: Colors.white.withValues(alpha: 0.2), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No decisions logged yet',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...timeline.take(5).toList().asMap().entries.map((entry) {
              final event = entry.value;
              final index = entry.key;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['decision']?.toString() ?? 'Decision',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person_outline,
                                    size: 12, color: Colors.white.withValues(alpha: 0.4)),
                                const SizedBox(width: 4),
                                Text(
                                  event['author']?.toString() ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.calendar_today,
                                    size: 11, color: Colors.white.withValues(alpha: 0.3)),
                                const SizedBox(width: 4),
                                Text(
                                  event['date']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event['source']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7C4DFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlatformDistribution() {
    final rawPlatformData = _pulseData?['platform_distribution'];
    final platformData = (rawPlatformData is Map) ? rawPlatformData : {};
    if (platformData.isEmpty) return const SizedBox();

    final total = platformData.values.fold<num>(0, (sum, val) => sum + (val as num));
    if (total == 0) return const SizedBox();

    final colors = [
      const Color(0xFF00E5FF),
      const Color(0xFF7C4DFF),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
      const Color(0xFFE91E63),
    ];

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Platform Distribution', Icons.hub),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 35,
                      sections: platformData.entries.toList().asMap().entries.map((e) {
                        final idx = e.key;
                        final entry = e.value;
                        final value = (entry.value as num).toDouble();
                        return PieChartSectionData(
                          value: value,
                          color: colors[idx % colors.length],
                          radius: 40,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: platformData.entries.toList().asMap().entries.map((e) {
                      final idx = e.key;
                      final entry = e.value;
                      final percentage = ((entry.value as num) / total * 100).toInt();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[idx % colors.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  void _showCatchUpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CatchUpSheet(),
    );
  }
}

class CatchUpSheet extends StatefulWidget {
  const CatchUpSheet({super.key});

  @override
  State<CatchUpSheet> createState() => _CatchUpSheetState();
}

class _CatchUpSheetState extends State<CatchUpSheet> {
  bool _isLoading = true;
  List<dynamic> _cards = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCatchUp();
  }

  Future<void> _loadCatchUp() async {
    final data = await ApiService.fetchCatchUp(7);
    if (mounted) {
      setState(() {
        _cards = data['cards'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFE91E63)),
                SizedBox(width: 12),
                Text('While You Were Away', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
                : _cards.isEmpty
                    ? Center(child: Text('Nothing to report.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))))
                    : Center(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! < -100) _nextCard();
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: ScaleTransition(scale: animation, child: child),
                              );
                            },
                            child: _buildCard(_cards[_currentIndex], key: ValueKey(_currentIndex)),
                          ),
                        ),
                      ),
          ),
          if (!_isLoading && _cards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_currentIndex + 1} of ${_cards.length}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
                  ElevatedButton(
                    onPressed: _nextCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(_currentIndex == _cards.length - 1 ? 'DONE' : 'NEXT', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(dynamic card, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: const Color(0xFFE91E63).withValues(alpha: 0.1), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              card['category']?.toString().toUpperCase() ?? 'UPDATE',
              style: const TextStyle(color: Color(0xFFE91E63), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            card['title']?.toString() ?? '',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            card['content']?.toString() ?? '',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}


class _QuickStatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _QuickStatData(this.icon, this.label, this.value, this.color);
}
