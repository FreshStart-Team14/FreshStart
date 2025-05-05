import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  
  final String _apiKey = '';

  Future<void> _sendMessage() async {
    final String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isLoading = true;
    });
    _controller.clear();

    final String response = await _fetchChatGPTResponse(userMessage);

    setState(() {
      _messages.add({'role': 'assistant', 'content': response});
      _isLoading = false;
    });
  }

  Future<String> _fetchChatGPTResponse(String prompt) async {
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';
    bool isTurkish(String text) {
  final turkishChars = RegExp(r'[çÇğĞıİöÖşŞüÜ]');
  return turkishChars.hasMatch(text);
}
final isInputTurkish = isTurkish(prompt);
final fallbackMessage = isInputTurkish
    ? 'Ben, sigarayı bırakma sürecinizde size destek olmak için buradayım. Haydi bu yolculuğa odaklanalım.'
    : "I'm here to support you in quitting smoking. Let's stay focused on that journey together.";

final systemMessage = {
  "role": "system",
  "content": """
Sen, sigarayı bırakmaya çalışan kullanıcılara yardımcı olan destekleyici bir yapay zekasın.
Yalnızca sigara bağımlılığı, bırakma süreci, istekle başa çıkma, motivasyon, yoksunluk belirtileri ve zihinsel destek ile ilgili soruları yanıtla.

Eğer kullanıcı sana başka bir konuda (örneğin hava durumu, yemek tarifleri, haberler, teknoloji vb.) bir şey sorarsa, şu mesajla yanıt ver:
"Sigarayı bırakma sürecinde size destek olmak için buradayım. Hadi bu yolculuğa odaklanalım."

Kullanıcının Türkçe yazdığını unutma. Lütfen her yanıtını Türkçe olarak ver.
"""
};


    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
  'model': 'gpt-3.5-turbo',
  'messages': [
    systemMessage,
    ..._messages,
    {'role': 'user', 'content': prompt},
  ],
  "max_tokens": 200,
  "temperature": 0.3,
}),

    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'].trim();
    } else {
      return 'Error: Unable to fetch response. Status code: ${response.statusCode}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Community Chat',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.blue),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey[100]!,
                          Colors.grey[100]!.withOpacity(0.8),
                          Colors.grey[100]!.withOpacity(0.6),
                          Colors.grey[100]!.withOpacity(0.4),
                        ],
                        stops: const [0.0, 0.2, 0.4, 0.6],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: 0.1,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              size: 120,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Community',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Messages
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thinking...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final message = _messages[index];
                    final isUser = message['role'] == 'user';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue[100],
                              child: Icon(
                                Icons.eco_rounded,
                                size: 20,
                                color: Colors.blue[900],
                              ),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                message['content']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isUser ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
