class CommentLikeResponseModel {
  bool? status;
  Data? data;
  String? message;
  bool? error;

  CommentLikeResponseModel({this.status, this.data, this.message, this.error});

  CommentLikeResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    return data;
  }
}

class Data {
  int? likes;

  Data({this.likes});

  Data.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['likes'] = this.likes;
    return data;
  }
}

