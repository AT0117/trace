import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/design_system.dart';
import '../api_service.dart';
import '../models.dart';

class InvestigationScreen extends StatefulWidget {
  const InvestigationScreen({super.key});

  @override
  State<InvestigationScreen> createState() => _InvestigationScreenState();
}

class _InvestigationScreenState extends State<InvestigationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // Context panel state
  List<dynamic> _latestCitations = [];
  List<dynamic> _latestTimeline = [];

  static const List<String> _roles = [
    'CEO / Founder',
    'Engineering Lead',
    'Product Manager',
    'Designer',
    'Intern / New Joiner',
    'External Stakeholder',
  ];
  String _selectedRole = 'CEO / Founder';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStr = prefs.getString('chat_history');
    if (historyStr != null && historyStr.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(historyStr);
        setState(() {
          _messages = jsonList.map((j) => ChatMessage.fromJson(j as Map<String, dynamic>)).toList();
        });
        _scrollToBottom();
      } catch (e) {
        debugPrint("Failed to load chat history: $e");
      }
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _messages.map((m) => m.toJson()).toList();
    await prefs.setString('chat_history', jsonEncode(jsonList));
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    final response = await ApiService.fetchAIResponse(text, _selectedRole);

    setState(() {
      _isTyping = false;
      _latestCitations = response['citations'] ?? [];
      _latestTimeline = response['timeline_events'] ?? [];
      _messages.add(
        ChatMessage(
          text: response['answer_text'] ?? "No answer provided.",
          isUser: false,
          timelineEvents: _latestTimeline,
          citations: _latestCitations,
        ),
      );
    });
    _saveHistory();
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

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'CEO / Founder':
        return Icons.business;
      case 'Engineering Lead':
        return Icons.code;
      case 'Product Manager':
        return Icons.dashboard;
      case 'Designer':
        return Icons.palette;
      case 'Intern / New Joiner':
        return Icons.school;
      case 'External Stakeholder':
        return Icons.handshake;
      default:
        return Icons.person;
    }
  }

  IconData _getPlatformIcon(String? platform) {
    final p = platform?.toLowerCase() ?? '';
    if (p.contains('discord') || p.contains('slack')) return Icons.forum;
    if (p.contains('email') || p.contains('gmail')) return Icons.mail;
    if (p.contains('meeting') || p.contains('voice')) return Icons.headset_mic;
    return Icons.source;
  }

  bool _hasValidDocument(dynamic docName) {
    if (docName == null) return false;
    final str = docName.toString().trim().toLowerCase();
    if (str.isEmpty || str == 'null' || str == 'none' || str == 'n/a') return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      
      appBar: _buildAppBar(),
      body: isWide ? _buildSplitLayout() : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      
      elevation: 0,
      title: const ThemedText(
        'Investigation',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF), size: 20),
              dropdownColor: const Color(0xFF111827),
              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13, fontWeight: FontWeight.w600),
              items: _roles.map((role) => DropdownMenuItem(
                value: role,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getRoleIcon(role), size: 16, color: const Color(0xFF00E5FF)),
                    const SizedBox(width: 8),
                    Text(role),
                  ],
                ),
              )).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
          ),
        ),
      ],
    );
  }

  // ===== SPLIT LAYOUT FOR WEB =====
  Widget _buildSplitLayout() {
    return Row(
      children: [
        // Chat panel (left)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(child: _buildChatList()),
              _buildInputArea(),
            ],
          ),
        ),
        // Divider
        Container(
          width: 1,
          color: Colors.white.withValues(alpha: 0.06),
        ),
        // Context panel (right)
        Expanded(
          flex: 2,
          child: _buildContextPanel(),
        ),
      ],
    );
  }

  // ===== MOBILE LAYOUT =====
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(child: _buildChatList()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF00E5FF),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Analyzing organizational memory...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final msg = _messages[index];
        return msg.isUser ? _buildUserBubble(msg) : _buildAIBubble(msg);
      },
    );
  }

  Widget _buildUserBubble(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildAIBubble(ChatMessage msg) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 40),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.psychology, size: 14, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(width: 10),
                Text(
                  'TRACE AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedRole,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF00E5FF)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            MarkdownBody(
              data: msg.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 15, height: 1.6, color: Theme.of(context).colorScheme.onSurface),
                h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                listBullet: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                strong: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                code: TextStyle(backgroundColor: Colors.white.withValues(alpha: 0.05), fontFamily: 'monospace', color: const Color(0xFF00E5FF)),
                codeblockDecoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // On mobile — show inline citations
            if (!isWide && msg.citations != null && msg.citations!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInlineCitations(msg.citations!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineCitations(List<dynamic> citations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOURCES',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...citations.map((c) => _buildCitationChip(c)),
      ],
    );
  }

  Widget _buildCitationChip(dynamic citation) {
    final platform = citation['platform']?.toString() ?? 'Unknown';
    final author = citation['author']?.toString() ?? 'Unknown Sender';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getPlatformIcon(platform), size: 14, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$platform — $author'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E5FF),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${citation['snippet']}"',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== CONTEXT PANEL (RIGHT SIDE ON WEB) =====
  Widget _buildContextPanel() {
    return Container(
      color: const Color(0xFF0D1117),
      child: Column(
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.source, color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 8),
                Text(
                  'CONTEXT PANEL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _latestCitations.isEmpty && _latestTimeline.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                        const SizedBox(height: 16),
                        Text(
                          'Ask a question to see\nsources and context here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_latestCitations.isNotEmpty) ...[
                        Text(
                          'SOURCES (${_latestCitations.length})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._latestCitations.map((c) => _buildDetailedCitation(c)),
                      ],
                      if (_latestTimeline.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'DECISION TIMELINE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._latestTimeline.asMap().entries.map((entry) {
                          return _buildTimelineTile(
                            entry.value,
                            isFirst: entry.key == 0,
                            isLast: entry.key == _latestTimeline.length - 1,
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCitation(dynamic citation) {
    final platform = citation['platform']?.toString() ?? 'Unknown';
    final author = citation['author']?.toString() ?? 'Unknown Sender';
    final docName = citation['document_name'];
    final showDoc = _hasValidDocument(docName);

    return SolidCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getPlatformIcon(platform), size: 14, color: const Color(0xFF00E5FF)),
              const SizedBox(width: 8),
              Text(
                '$platform — $author'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E5FF),
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                citation['timestamp']?.toString() ?? '',
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3)),
              ),
            ],
          ),
          if (showDoc) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, size: 12, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(
                  docName.toString(),
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '"${citation['snippet']}"',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.4,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(dynamic event, {required bool isFirst, required bool isLast}) {
    final timestamp = event['timestamp']?.toString() ?? event['date']?.toString() ?? '';

    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: const IndicatorStyle(width: 14, color: Color(0xFF00E5FF)),
      beforeLineStyle: LineStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), thickness: 1),
      endChild: Padding(
        padding: const EdgeInsets.only(left: 14, bottom: 20, top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timestamp,
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event['title']?.toString() ?? 'Event',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              event['description']?.toString() ?? '',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Ask about any decision, person, or event...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.2), size: 20),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.arrow_upward_rounded, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
