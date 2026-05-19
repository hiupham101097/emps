import 'dart:convert';

class DataValue {
  late String? title;
  late String? body;
  late String value;

  DataValue(this.value, {this.title, this.body});

  factory DataValue.fromJson(Map<String, dynamic> json) {
    var title = "";
    var body = "";

    if (json.containsKey("title") == true) {
      title = json["title"];
    }

    if (json.containsKey("body") == true) {
      body = json["body"];
    }

    if (json.containsKey("data") == false) {
      return DataValue("", title: title, body: body);
    }

    var jsonData = jsonDecode(json['data']);

    if (jsonData.containsKey("id") == false) {
      return DataValue("", title: title, body: body);
    }

    return DataValue(jsonData["id"], title: title, body: body);
  }
}
