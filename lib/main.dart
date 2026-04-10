import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'models.dart';
import 'api_service.dart';

void main() {
  runApp(const TraceApp());
}

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trace Memory Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          surface: Color(0xFF1D2236),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const InvestigationDashboard(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1D2236),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.white54,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Investigate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchAnalytics();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }

    final score = _data?['health_score'] ?? 0;
    final status = _data?['status'] ?? 'Unknown';
    final timeline = _data?['macro_timeline'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Organizational Health',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1D2236),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          backgroundColor: Colors.white10,
                          color: score > 70
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          strokeWidth: 8,
                        ),
                      ),
                      Text(
                        '$score%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Documentation Health',
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Based on cross-platform data extraction.',
                          style: TextStyle(fontSize: 12, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'MACRO DECISION TIMELINE',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (timeline.isEmpty)
              const Text(
                "No decisions logged yet.",
                style: TextStyle(color: Colors.white38),
              )
            else
              ...timeline
                  .map(
                    (event) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00E5FF),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                event['date']?.toString() ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event['source']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event['decision']?.toString() ?? '',
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Authorized by: ${event['author']?.toString() ?? 'Unknown'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }
}

class InvestigationDashboard extends StatefulWidget {
  const InvestigationDashboard({super.key});

  @override
  State<InvestigationDashboard> createState() => _InvestigationDashboardState();
}

class _InvestigationDashboardState extends State<InvestigationDashboard> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    final response = await ApiService.fetchAIResponse(text);

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(
          text: response['answer_text'] ?? "No answer provided.",
          isUser: false,
          timelineEvents: response['timeline_events'],
          citations: response['citations'],
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trace Investigation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1D2236),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                  );
                }
                final msg = _messages[index];
                return msg.isUser ? _buildUserBubble(msg) : _buildAIBubble(msg);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildUserBubble(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 50),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Text(
          msg.text,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAIBubble(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, right: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.text, style: const TextStyle(fontSize: 16, height: 1.5)),
            if (msg.citations != null && msg.citations!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "SOURCES",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ...msg.citations!.map((c) => _buildCitationCard(c)).toList(),
            ],
            if (msg.timelineEvents != null &&
                msg.timelineEvents!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "DECISION TIMELINE",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...msg.timelineEvents!.asMap().entries.map((entry) {
                return _buildTimelineTile(
                  entry.value,
                  isFirst: entry.key == 0,
                  isLast: entry.key == msg.timelineEvents!.length - 1,
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String? platform) {
    final p = platform?.toLowerCase() ?? '';
    if (p.contains('discord') || p.contains('slack')) return Icons.forum;
    if (p.contains('email') || p.contains('gmail')) return Icons.mail;
    if (p.contains('meeting') || p.contains('voice')) return Icons.headset_mic;
    return Icons.source;
  }

  // --- BULLETPROOF DOCUMENT CHECKER ---
  bool _hasValidDocument(dynamic docName) {
    if (docName == null) return false;
    final str = docName.toString().trim().toLowerCase();
    if (str.isEmpty || str == 'null' || str == 'none' || str == 'n/a')
      return false;
    return true;
  }

  Widget _buildCitationCard(dynamic citation) {
    final platform =
        citation['platform']?.toString().toUpperCase() ?? 'UNKNOWN SOURCE';
    final timestamp = citation['timestamp']?.toString() ?? '';
    final docName = citation['document_name'];
    final showDocument = _hasValidDocument(docName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPlatformIcon(citation['platform']?.toString()),
                color: const Color(0xFF00E5FF),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                platform,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E5FF),
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              if (timestamp.isNotEmpty)
                Text(
                  timestamp,
                  style: const TextStyle(fontSize: 10, color: Colors.white54),
                ),
            ],
          ),
          if (showDocument) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.redAccent,
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    docName.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.format_quote, color: Colors.white24, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"${citation['snippet']}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(
    dynamic event, {
    required bool isFirst,
    required bool isLast,
  }) {
    final timestamp =
        event['timestamp']?.toString() ?? event['date']?.toString() ?? '';
    final platform = event['source_platform']?.toString().toUpperCase() ?? '';
    final docName = event['document_name'];
    final showDocument = _hasValidDocument(docName);

    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: const IndicatorStyle(width: 16, color: Color(0xFF00E5FF)),
      beforeLineStyle: const LineStyle(color: Colors.white24, thickness: 2),
      endChild: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  timestamp,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (platform.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Text("•", style: TextStyle(color: Colors.white24)),
                  const SizedBox(width: 8),
                  Icon(
                    _getPlatformIcon(event['source_platform']?.toString()),
                    color: Colors.white54,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    platform,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              event['title']?.toString() ?? 'Event',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              event['description']?.toString() ?? '',
              style: const TextStyle(color: Colors.white70, height: 1.3),
            ),
            if (showDocument) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.attach_file,
                    color: Colors.white38,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Ref: $docName",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask about a decision...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _sendMessage,
              backgroundColor: Theme.of(context).colorScheme.primary,
              mini: true,
              child: const Icon(Icons.send, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
