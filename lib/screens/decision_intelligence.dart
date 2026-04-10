import 'package:flutter/material.dart';
import '../widgets/design_system.dart';
import '../api_service.dart';

class DecisionIntelligenceScreen extends StatefulWidget {
  const DecisionIntelligenceScreen({super.key});

  @override
  State<DecisionIntelligenceScreen> createState() => _DecisionIntelligenceScreenState();
}

class _DecisionIntelligenceScreenState extends State<DecisionIntelligenceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        
        elevation: 0,
        title: const ThemedText('Decision Intelligence', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00E5FF),
          labelColor: const Color(0xFF00E5FF),
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
          tabs: const [
            Tab(icon: Icon(Icons.radar), text: 'Conflict Radar'),
            Tab(icon: Icon(Icons.account_tree), text: 'Decision Drift'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ConflictRadarView(),
          DecisionDriftView(),
        ],
      ),
    );
  }
}

class ConflictRadarView extends StatefulWidget {
  const ConflictRadarView({super.key});

  @override
  State<ConflictRadarView> createState() => _ConflictRadarViewState();
}

class _ConflictRadarViewState extends State<ConflictRadarView> {
  List<dynamic> _conflicts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchConflicts();
    setState(() {
      _conflicts = data['conflicts'] ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)));
    }

    if (_conflicts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PulsingDot(color: Color(0xFF4CAF50), size: 16),
            const SizedBox(height: 20),
            Text('No operational conflicts detected.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conflicts.length,
        itemBuilder: (context, index) {
          final conflict = _conflicts[index];
          final severity = conflict['severity']?.toString().toLowerCase() ?? 'medium';
          final sColor = severity == 'high' ? const Color(0xFFf44336) : severity == 'low' ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

          return SolidCard(
            borderColor: sColor.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PulsingDot(color: sColor, size: 8),
                    const SizedBox(width: 8),
                    Text(
                      '${severity.toUpperCase()} CONFLICT',
                      style: TextStyle(color: sColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  conflict['topic']?.toString() ?? 'Topic',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  conflict['description']?.toString() ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Color(0xFF00E5FF), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          conflict['resolution_suggestion']?.toString() ?? 'No suggestion provided.',
                          style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DecisionDriftView extends StatefulWidget {
  const DecisionDriftView({super.key});

  @override
  State<DecisionDriftView> createState() => _DecisionDriftViewState();
}

class _DecisionDriftViewState extends State<DecisionDriftView> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _driftData = {'nodes': [], 'edges': []};
  bool _isLoading = false;

  void _analyzeDrift() async {
    final topic = _controller.text.trim();
    if (topic.isEmpty) return;

    setState(() => _isLoading = true);
    final data = await ApiService.fetchDecisionDrift(topic);
    setState(() {
      _driftData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF0D1117),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Enter decision topic (e.g., Q3 Pricing)...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _analyzeDrift(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _analyzeDrift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('TRACE DRIFT', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                      SizedBox(height: 16),
                      Text('Mapping decision flow...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
                    ],
                  ),
                )
              : _buildDriftGraph(),
        ),
      ],
    );
  }

  Widget _buildDriftGraph() {
    final nodes = _driftData['nodes'] as List? ?? [];
    if (nodes.isEmpty) {
      return Center(
        child: Text(
          'Enter a topic to map its evolution over time.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return Column(
          children: [
            SolidCard(
              borderColor: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.4), blurRadius: 8)],
                    ),
                    child: Center(
                      child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node['label']?.toString() ?? 'State',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                            const SizedBox(width: 4),
                            Text(
                              node['author']?.toString() ?? '',
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.source, size: 14, color: Colors.white.withValues(alpha: 0.3)),
                            const SizedBox(width: 4),
                            Text(
                              node['platform']?.toString() ?? '',
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (index < nodes.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 2, height: 30, color: const Color(0xFF7C4DFF).withValues(alpha: 0.3)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
