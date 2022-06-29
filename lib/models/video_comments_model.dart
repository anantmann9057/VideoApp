class VideoCommentsModel {
  bool? status;
  String? message;
  List<Data>? data;

  VideoCommentsModel({this.status, this.message, this.data});

  VideoCommentsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? comment;
  int? userId;
  String? avatar;
  String? name;
  int? commentLikeCounter;

  Data(
      {this.id,
      this.comment,
      this.userId,
      this.avatar,
      this.name,
      this.commentLikeCounter});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    userId = json['user_id'];
    avatar = json['avatar'];
    name = json['name'];
    commentLikeCounter = json['comment_like_counter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['user_id'] = this.userId;
    data['avatar'] = this.avatar;
    data['name'] = this.name;
    data['comment_like_counter'] = this.commentLikeCounter;
    return data;
  }
}

