import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ウィジェットの名前を GirlfriendWidget とします
class GirlfriendWidget extends StatefulWidget {
  const GirlfriendWidget({super.key});

  @override
  State<GirlfriendWidget> createState() => _GirlfriendWidgetState();
}

class _GirlfriendWidgetState extends State<GirlfriendWidget> {
  final TextEditingController _controller = TextEditingController();

  int _totalSavings = 0;
  String _girlfriendMessage = "今日からよろしくね！";
  String _girlfriendImagePath = "assets/images/normal.png";
  bool _isLoading = false;

  // ★あなたのPCのIPアドレス
  final String _serverUrl = 'http://192.168.11.44:5000/girlfriend_reaction';

  Future<void> _saveMoney() async {
    final int amount = int.tryParse(_controller.text) ?? 0;
    
    setState(() { _isLoading = true; _girlfriendMessage = "えーっと・・・"; });

    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'savings_amount': amount}),
      ).timeout(const Duration(seconds: 10));

      String newReaction;
      String newEmotion;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        newReaction = data['reaction'];
        newEmotion = data['emotion'];
      } else {
        newReaction = "ごめんね、今ちょっと考えごと…。";
        newEmotion = "neutral";
      }

      setState(() {
        _totalSavings += amount;
        _girlfriendMessage = newReaction;
        _girlfriendImagePath = _getImagePathForEmotion(newEmotion);
      });
    } catch (e) {
      setState(() {
        _girlfriendMessage = "電波が悪いみたい…。後で話そ？";
        _girlfriendImagePath = _getImagePathForEmotion("neutral");
      });
    } finally {
      setState(() { _isLoading = false; });
      _controller.clear();
    }
  }
  
  String _getImagePathForEmotion(String emotion) {
    switch (emotion) {
      case 'very_happy': return 'assets/images/very_happy.png';
      case 'happy': return 'assets/images/happy.png';
      case 'curious': return 'assets/images/curious.png';
      default: return 'assets/images/normal.png';
    }
  }

  // ここがウィジェットの本体。Scaffoldは含まない
  @override
  Widget build(BuildContext context) {
    // Columnで機能全体を縦に並べる
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '合計貯金額: $_totalSavings円',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Image.asset(_girlfriendImagePath, height: 250, gaplessPlayback: true),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(12)),
          child: Text(_girlfriendMessage, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: const InputDecoration(labelText: '貯金額を入力', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _saveMoney,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('貯金する！'),
              ),
      ],
    );
  }
}