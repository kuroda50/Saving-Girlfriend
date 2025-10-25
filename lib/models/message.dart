class Message {
  final String id;
  final String type; // 'girlfriend' or 'user'
  final String text;
  final String time;

  Message(
      {required this.id,
      required this.type,
      required this.text,
      required this.time});

  // JSONに変換するファクトリコンストラクタ
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      type: json['type'],
      text: json['text'],
      time: json['time'],
    );
  }

  // オブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'text': text,
      'time': time,
    };
  }
}
