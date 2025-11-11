class AppMessage {
  int dbId;
  final String id;

  // MessageTypeのindexを保存
  final int type;

  final String text;
  final String time;

  AppMessage(
      {this.dbId = 0,
      required this.id,
      required this.type,
      required this.text,
      required this.time});

  MessageType get messageType => MessageType.values[type];

  // JSONに変換するファクトリコンストラクタ
  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: json['id'],
      // fromJsonではStringからenumに変換し、そのindexを保存
      type: MessageType.values.byName(json['type']).index,
      text: json['text'],
      time: json['time'],
    );
  }

  // オブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // toJsonではindexからenumのname(String)に変換
      'type': MessageType.values[type].name,
      'text': text,
      'time': time,
    };
  }
}

enum MessageType {
  girlfriend,
  user,
}
