import 'dart:convert';
import '../../domain/entities/kanji.dart';

class KanjiModel extends Kanji {
  const KanjiModel({
    required super.id,
    required super.character,
    required super.strokes,
    super.grade,
    super.freq,
    super.jlptOld,
    super.jlptNew,
    required super.meanings,
    required super.readingsOn,
    required super.readingsKun,
    super.wkLevel,
    super.wkMeanings,
    super.wkReadingsOn,
    super.wkReadingsKun,
    super.wkRadicals,
  });

  factory KanjiModel.fromJson(Map<String, dynamic> json) {
    return KanjiModel(
      id: json['id'],
      character: json['character'],
      strokes: json['strokes'],
      grade: json['grade'],
      freq: json['freq'],
      jlptOld: json['jlpt_old'],
      jlptNew: json['jlpt_new'],
      meanings: _decodeList(json['meanings']),
      readingsOn: _decodeList(json['readings_on']),
      readingsKun: _decodeList(json['readings_kun']),
      wkLevel: json['wk_level'],
      wkMeanings: json['wk_meanings'] != null
          ? _decodeList(json['wk_meanings'])
          : null,
      wkReadingsOn: json['wk_readings_on'] != null
          ? _decodeList(json['wk_readings_on'])
          : null,
      wkReadingsKun: json['wk_readings_kun'] != null
          ? _decodeList(json['wk_readings_kun'])
          : null,
      wkRadicals: json['wk_radicals'] != null
          ? _decodeList(json['wk_radicals'])
          : null,
    );
  }

  static List<String> _decodeList(dynamic data) {
    if (data == null) return [];
    if (data is String) {
      final decoded = json.decode(data);
      return List<String>.from(decoded.map((e) => e.toString()));
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'strokes': strokes,
      'grade': grade,
      'freq': freq,
      'jlpt_old': jlptOld,
      'jlpt_new': jlptNew,
      'meanings': json.encode(meanings),
      'readings_on': json.encode(readingsOn),
      'readings_kun': json.encode(readingsKun),
      'wk_level': wkLevel,
      'wk_meanings': wkMeanings != null ? json.encode(wkMeanings) : null,
      'wk_readings_on': wkReadingsOn != null ? json.encode(wkReadingsOn) : null,
      'wk_readings_kun': wkReadingsKun != null
          ? json.encode(wkReadingsKun)
          : null,
      'wk_radicals': wkRadicals != null ? json.encode(wkRadicals) : null,
    };
  }
}
