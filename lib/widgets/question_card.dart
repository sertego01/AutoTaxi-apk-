import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final bool answered;
  final Function(String) onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.answered,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = {
      'opcion1': question.opcion1,
      'opcion2': question.opcion2,
      'opcion3': question.opcion3,
      'opcion4': question.opcion4,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                // Widget Center añadido aquí
                child: Text(
                  question.pregunta,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Doble garantía de centrado
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...options.entries.map((entry) {
            final optionKey = entry.key;
            final optionText = entry.value;

            Color borderColor = Colors.grey;
            Color? iconColor;
            IconData? icon;

            if (answered) {
              if (optionKey == question.respuestaCorrecta) {
                borderColor = Colors.green;
                iconColor = Colors.green;
                icon = Icons.check;
              } else if (optionKey == selectedAnswer) {
                borderColor = Colors.red;
                iconColor = Colors.red;
                icon = Icons.close;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      answered ? null : () => onAnswerSelected(optionKey),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            optionText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      if (icon != null)
                        Icon(
                          icon,
                          color: iconColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
