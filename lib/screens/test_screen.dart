import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/question_card.dart';

class TestScreen extends StatefulWidget {
  final List<Question> questions;
  final String testType;

  const TestScreen({
    super.key, 
    required this.questions,
    required this.testType,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentIndex = 0;
  bool _answered = false;
  String? _selectedAnswer;
  final Map<String, String> _userAnswers = {};

  bool get _showProgressIndicator {
    // Mostrar progreso solo si NO es modo examen
    return widget.testType != 'examen';
  }

  Map<String, dynamic> _calculateResults() {
    int normativaCorrect = 0;
    int callejeroCorrect = 0;
    int normativaTotal = 0;
    int callejeroTotal = 0;

    for (var question in widget.questions) {
      final userAnswer = _userAnswers[question.id.toString()];
      final isCorrect = userAnswer == question.respuestaCorrecta;

      if (question.tipo == 'normativa') {
        normativaTotal++;
        if (isCorrect) normativaCorrect++;
      } else if (question.tipo == 'callejero') {
        callejeroTotal++;
        if (isCorrect) callejeroCorrect++;
      }
    }

    final normativaPassed = normativaCorrect >= 9;
    final callejeroPassed = callejeroCorrect >= 9;
    final totalPassed = normativaPassed && callejeroPassed;

    return {
      'normativa': {
        'correct': normativaCorrect,
        'total': normativaTotal,
        'passed': normativaPassed,
      },
      'callejero': {
        'correct': callejeroCorrect,
        'total': callejeroTotal,
        'passed': callejeroPassed,
      },
      'totalPassed': totalPassed,
    };
  }

  void _showExamResults() {
    final results = _calculateResults();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          results['totalPassed'] ? '¡APROBADO!' : 'SUSPENDIDO',
          style: TextStyle(
            color: results['totalPassed'] ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultItem('Normativa', results['normativa']),
              const SizedBox(height: 16),
              _buildResultItem('Callejero', results['callejero']),
              const SizedBox(height: 20),
              Text(
                results['totalPassed']
                    ? 'Has aprobado el examen con éxito'
                    : 'Necesitas al menos 9 aciertos en cada categoría',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String title, Map<String, dynamic> data) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${data['correct']} de ${data['total']}',
          style: TextStyle(
            fontSize: 24,
            color: data['passed'] ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data['passed'] ? Icons.check : Icons.close,
              color: data['passed'] ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              data['passed'] ? 'APROBADO' : 'SUSPENSO',
              style: TextStyle(
                color: data['passed'] ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateCurrentPercentage() {
    final currentType = widget.questions[_currentIndex].tipo;
    final typeQuestions = widget.questions.where((q) => q.tipo == currentType).toList();
    
    if (typeQuestions.isEmpty) return '0% (0/0)';

    int correct = 0;
    int total = typeQuestions.length;

    for (var question in typeQuestions) {
      final answer = _userAnswers[question.id.toString()];
      if (answer != null && answer == question.respuestaCorrecta) {
        correct++;
      }
    }

    final percentage = (correct / total * 100).round();
    return '$percentage% ($correct/$total)';
  }

  Color _getPercentageColor() {
    final percentageStr = _calculateCurrentPercentage().split('%')[0];
    final percentage = int.tryParse(percentageStr) ?? 0;
    
    if (percentage >= 60) return Colors.green;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildProgressIndicator() {
    final currentType = widget.questions[_currentIndex].tipo;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Column(
              children: [
                Text(
                  currentType == 'normativa' ? 'NORMATIVA' : 'CALLEJERO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _calculateCurrentPercentage(),
                  style: TextStyle(
                    color: _getPercentageColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _answer(String selected) {
    if (_answered) return;

    _userAnswers[widget.questions[_currentIndex].id.toString()] = selected;
    
    setState(() {
      _selectedAnswer = selected;
      _answered = true;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_currentIndex + 1 >= widget.questions.length) {
        if (widget.testType == 'examen') {
          _showExamResults();
        } else {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedAnswer = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test completado')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver al menú principal'),
          ),
        ),
      );
    }

    final question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pregunta ${_currentIndex + 1} de ${widget.questions.length}'),
            if (widget.testType != 'examen')
              Text('Tipo: ${question.tipo == 'normativa' ? 'Normativa' : 'Callejero'}'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_showProgressIndicator) _buildProgressIndicator(),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuestionCard(
                question: question,
                selectedAnswer: _selectedAnswer,
                onAnswerSelected: _answer,
                answered: _answered,
              ),
            ),
          ),
        ],
      ),
    );
  }
}