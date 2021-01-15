class UnavailableBean {
  String fromTime;
  String toTime;
  String orderId;
  int code;
  String status;

  UnavailableBean.fromJson(Map<String, dynamic> json) {
    fromTime = json["from_time"] as String;
    toTime = json["to_time"] as String;
    orderId = json["orderid"] as String;
    code = json["code"] as int;
    status = json["status"] as String;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["from_time"] = fromTime;
    data["to_time"] = toTime;
    data["orderid"] = orderId;
    data["code"] = code;
    data["status"] = status;
    return data;
  }
}
