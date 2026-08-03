import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

void configureWebCredentials(Dio dio) {
  final adapter = dio.httpClientAdapter;
  if (adapter is BrowserHttpClientAdapter) {
    adapter.withCredentials = true;
  }
}
