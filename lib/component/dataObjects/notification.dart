// Data struct
class AppPushInfo {
  AppPushInfo(
      {this.id = '',
      this.thumbnails = '',
      this.userid = '',
      this.postDatetime = '',
      this.type = '',
      this.content = ''});
  final String id;
  final String thumbnails;
  final String userid;
  final String postDatetime;
  final String type; //case for button would show
  final String content;

  AppPushInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        thumbnails = json['thumbnails'],
        userid = json['userid'],
        postDatetime = json['postDatetime'],
        type = json['type'],
        content = json['content'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'thumbnails': thumbnails,
        'userid': userid,
        'postDatetime': postDatetime,
        'type': type,
        'content': content
      };

  static List<String> types = [
    'Know more', //push post
    'Say congrats',
    'Following',
    'Follow',
    'Approve Request',
    'ContentOnly'
  ];

  bool typeWillShowButtonAction() {
    if (typeIndex() != types.indexOf(types.last)) {
      return true;
    }
    return false;
  }

  int typeIndex() {
    return types.indexOf(type);
  }
}
