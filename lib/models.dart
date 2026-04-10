class ChatMessage {
  final String text;
  final bool isUser;
  final List<dynamic>? timelineEvents;
  final List<dynamic>? citations;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.timelineEvents,
    this.citations,
  });
}
