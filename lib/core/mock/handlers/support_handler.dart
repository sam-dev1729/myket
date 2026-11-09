import 'package:dio/dio.dart';

import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for the Goftino support chat endpoint.
class SupportHandler extends MockHandler {
  @override
  bool matches(String method, String path) {
    return method == 'GET' && path == '/goftino/start/chat';
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 80));

    final storage = MockStorage.instance..ensureSeeded();
    return mockSuccess({'chat_link_view': storage.goftinoChatUrl});
  }
}
