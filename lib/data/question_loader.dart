import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionLoader {
  static Future<List<Question>> loadQuestions() async {
    final jsonString = await rootBundle.loadString('assets/preguntas.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => Question.fromJson(item)).toList();
  }
}
