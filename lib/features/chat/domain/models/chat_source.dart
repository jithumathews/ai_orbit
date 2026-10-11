class ChatSource {
  final String title;
  final String url;
  final String domain;
  final String snippet;
  final String? publishedDate;

  const ChatSource({
    required this.title,
    required this.url,
    required this.domain,
    required this.snippet,
    this.publishedDate,
  });

  factory ChatSource.fromJson(Map<String, dynamic> json) {
    return ChatSource(
      title: json['title'] as String? ?? 'Web Source',
      url: json['url'] as String? ?? '',
      domain: json['domain'] as String? ?? 'web',
      snippet: json['snippet'] as String? ?? '',
      publishedDate: json['published_date'] as String? ?? json['publishedDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'domain': domain,
    'snippet': snippet,
    if (publishedDate != null) 'published_date': publishedDate,
  };
}
