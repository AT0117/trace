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

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timelineEvents': timelineEvents,
    'citations': citations,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timelineEvents: json['timelineEvents'] as List<dynamic>?,
      citations: json['citations'] as List<dynamic>?,
    );
  }
}
