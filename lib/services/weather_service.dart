import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

String get _apiBaseUrl {
  if (_configuredApiBaseUrl.isNotEmpty) {
    return _configuredApiBaseUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:8000';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000';
  }

  return 'http://localhost:8000';
}

class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WeatherData {
  const WeatherData({
    required this.temperatura,
    required this.vento,
    required this.latitude,
    required this.longitude,
    this.umidade,
    this.sensacaoTermica,
    this.ventoVelocidade,
    this.ventoDirecao,
    this.exposicaoSolarCodigo,
  });

  final double temperatura;
  final double? umidade;
  final double? sensacaoTermica;
  final double? ventoVelocidade;
  final double? ventoDirecao;
  final String vento;
  final String? exposicaoSolarCodigo;
  final double latitude;
  final double longitude;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final temperatura = _asDouble(json['temperatura']);
    if (temperatura == null) {
      throw const WeatherException('A API de clima nao retornou temperatura.');
    }
    return WeatherData(
      temperatura: temperatura,
      umidade: _asDouble(json['umidade']),
      sensacaoTermica: _asDouble(json['sensacao_termica']),
      ventoVelocidade: _asDouble(json['vento_velocidade']),
      ventoDirecao: _asDouble(json['vento_direcao']),
      vento: json['vento']?.toString() ?? 'Nao informado',
      exposicaoSolarCodigo: json['exposicao_solar_codigo']?.toString(),
      latitude: _asDouble(json['latitude']) ?? 0,
      longitude: _asDouble(json['longitude']) ?? 0,
    );
  }
}

class WeatherService {
  const WeatherService();

  Future<WeatherData> buscarClimaAtual() async {
    final position = await _buscarLocalizacaoAtual();
    final uri = Uri.parse('$_apiBaseUrl/weather/current').replace(
      queryParameters: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw WeatherException('Nao foi possivel buscar o clima. Codigo ${response.statusCode}.');
      }
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const WeatherException('Resposta de clima em formato invalido.');
      }
      return WeatherData.fromJson(data);
    } on http.ClientException {
      throw WeatherException(
        'Nao consegui conectar a API local em $_apiBaseUrl. '
        'Inicie o backend FastAPI antes de abrir esta tela.',
      );
    } on TimeoutException catch (error) {
      throw WeatherException('A consulta de clima demorou demais: $error');
    } on WeatherException {
      rethrow;
    } catch (error) {
      throw WeatherException('Erro ao buscar dados climaticos: $error');
    }
  }

  Future<Position> _buscarLocalizacaoAtual() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const WeatherException('Ative a localizacao do dispositivo para preencher o clima.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const WeatherException('Permita o acesso a localizacao para preencher o clima.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const WeatherException('A permissao de localizacao foi bloqueada nas configuracoes.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}