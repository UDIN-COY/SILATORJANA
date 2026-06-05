import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

class ChatViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ChatMessage> messages = [];
  bool isTyping = false;

  void initChat() {
    if (messages.isEmpty) {
      messages.add(ChatMessage("Halo! Saya Jana, asisten AI Si-LATORJANA. Ada yang bisa saya bantu hari ini?", false));
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    messages.add(ChatMessage(trimmed, true));
    isTyping = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/chat', body: {'message': trimmed});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        messages.add(ChatMessage(data['reply'] ?? 'Maaf, saya tidak mengerti.', false));
      } else {
        messages.add(ChatMessage("Error: Gagal terhubung ke Jana AI.", false));
      }
    } catch (e) {
      messages.add(ChatMessage("Error jaringan: $e", false));
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }
}
