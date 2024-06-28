// ignore_for_file: public_member_api_docs, sort_constructors_first
class Notes {
  String title;
  String content;
  DateTime createdAt;
  Notes({
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
