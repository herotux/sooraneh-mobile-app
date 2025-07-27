import 'dart:convert';
import 'package:http/http.dart' as http;

dynamic parseJsonResponse(http.Response response) {
  final decodedBody = utf8.decode(response.bodyBytes);
  return json.decode(decodedBody);
}