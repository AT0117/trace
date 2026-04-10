import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../widgets/design_system.dart';
import '../api_service.dart';

class TemporalExplorerScreen extends StatefulWidget {
  const TemporalExplorerScreen({super.key});

  @override
  State<TemporalExplorerScreen> createState() => _TemporalExplorerScreenState();
}

class _TemporalExplorerScreenState extends State<TemporalExplorerScreen> {
  List<dynamic> _fullTimeline = [];
  bool _isLoading = true;
  double _sliderValue = 1.0; // 0.0 (oldest) to 1.0 (newest)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchTimeline();
    
    // Sort oldest to newest purely for the slider logic
    final tl = (data['timeline'] as List?) ?? [];
    setState(() {
      _fullTimeline = tl;
      _isLoading = false;
    });
  }

  List<dynamic> _getFilteredEvents() {
    if (_fullTimeline.isEmpty) return [];
    
    // Reverse the list from API to get [oldest -> newest] for temporal mapping
    // But since the API returns chronologically, it might already be oldest->newest.
    // Let's assume it's oldest first based on our LLM prompt.
    final total = _fullTimeline.length;
    // Slider value determines how many items to show from the start.
    // If slider = 0.0, show only the first event
    // If slider = 1.0, show all events up to the current
    final countToShow = ((_sliderValue * (total - 1)).round() + 1).clamp(1, total);
    
    return _fullTimeline.sublist(0, countToShow).reversed.toList(); // Reverse to show newest at top
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF080B16),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
      );
    }

    final filteredEvents = _getFilteredEvents();
    
    return Scaffold(
      
      appBar: AppBar(
        
        elevation: 0,
        title: const ThemedText('Temporal Explorer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Scrub Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PAST', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    Text('PRESENT', style: TextStyle(color: const Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF00E5FF),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    thumbColor: const Color(0xFF7C4DFF),
                    overlayColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _sliderValue,
                    onChanged: (val) {
                      setState(() => _sliderValue = val);
                    },
                  ),
                ),
                Text(
                  'Showing ${filteredEvents.length} over time',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(child: Text("No temporal data available.", style: TextStyle(color: Colors.white.withValues(alpha: 0.5))))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      // Determine if it's newly revealed
                      final isNew = index == 0 && _sliderValue > 0.0;
                      
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: isNew ? 600 : 200),
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
                        child: _buildEventTile(
                          event,
                          isFirst: index == 0,
                          isLast: index == filteredEvents.length - 1,
                          isNewest: isNew,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(dynamic event, {required bool isFirst, required bool isLast, required bool isNewest}) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: isNewest ? 20 : 12,
        color: isNewest ? const Color(0xFF00E5FF) : Colors.white.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(4),
      ),
      beforeLineStyle: LineStyle(color: Colors.white.withValues(alpha: 0.1), thickness: 2),
      endChild: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 24, top: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNewest ? const Color(0xFF00E5FF).withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNewest ? const Color(0xFF00E5FF).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  event['date']?.toString() ?? '',
                  style: TextStyle(
                    color: isNewest ? const Color(0xFF00E5FF) : Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event['platform']?.toString().toUpperCase() ?? 'SYSTEM',
                    style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event['title']?.toString() ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              event['description']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6), height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Color(0xFF7C4DFF)),
                const SizedBox(width: 6),
                Text(
                  event['author']?.toString() ?? 'Unknown',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7C4DFF), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
