import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/question.dart';
import 'test_screen.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Question> _allQuestions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/preguntas.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> preguntasJson = jsonMap['preguntas'];
      setState(() {
        _allQuestions = preguntasJson.map((e) => Question.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando preguntas: $e';
        _loading = false;
      });
    }
  }

  void _startTest(String mode) {
    List<Question> selectedQuestions;
    String testType = mode;
    
    if (mode == 'normativa') {
      selectedQuestions = _allQuestions.where((q) => q.tipo == 'normativa').toList();
    } else if (mode == 'callejero') {
      selectedQuestions = _allQuestions.where((q) => q.tipo == 'callejero').toList();
    } else {
      List<Question> normativa = _allQuestions.where((q) => q.tipo == 'normativa').toList();
      List<Question> callejero = _allQuestions.where((q) => q.tipo == 'callejero').toList();
      normativa.shuffle();
      callejero.shuffle();
      selectedQuestions = normativa.take(15).toList() + callejero.take(15).toList();
    }
    
    selectedQuestions.shuffle();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          questions: selectedQuestions,
          testType: testType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Cargando preguntas...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AutoTaxi Gijón',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Normativa
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _startTest('normativa'),
                  child: const Text(
                    'Preguntas Normativa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Botón Callejero
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _startTest('callejero'),
                  child: const Text(
                    'Preguntas Callejero',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Botón Examen
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _startTest('examen'),
                  child: const Text(
                    'Modo Examen Completo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Texto informativo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Selecciona un modo de prueba para comenzar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}