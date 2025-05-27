class Question {
  final int id;
  final String opcion1;
  final String opcion2;
  final String opcion3;
  final String opcion4;
  final String pregunta;
  final String respuestaCorrecta;
  final String tipo;

  Question({
    required this.id,
    required this.opcion1,
    required this.opcion2,
    required this.opcion3,
    required this.opcion4,
    required this.pregunta,
    required this.respuestaCorrecta,
    required this.tipo,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      opcion1: json['opcion1'],
      opcion2: json['opcion2'],
      opcion3: json['opcion3'],
      opcion4: json['opcion4'],
      pregunta: json['pregunta'],
      respuestaCorrecta: json['respuesta_correcta'],
      tipo: json['tipo'],
    );
  }

  Map<String, String> toJson() {
    return {
      'opcion1': opcion1,
      'opcion2': opcion2,
      'opcion3': opcion3,
      'opcion4': opcion4,
    };
  }
}