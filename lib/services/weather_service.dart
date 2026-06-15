import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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
}

class WeatherService {
  const WeatherService();

  Future<WeatherData> buscarClimaAtual() async {
    // 1. Pega a localização atual do celular do atleta
    final position = await _buscarLocalizacaoAtual();
    
    // 2. Chama a API gratuita da Open-Meteo diretamente
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=${position.latitude}&'
      'longitude=${position.longitude}&'
      'current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,weather_code'
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      
      if (response.statusCode != 200) {
        throw WeatherException('Não foi possível buscar o clima. Código ${response.statusCode}.');
      }
      
      final data = jsonDecode(response.body);
      final current = data['current'];

      if (current == null) {
        throw const WeatherException('A API de clima não retornou os dados atuais.');
      }

      // 3. Monta o objeto com os dados recebidos do satélite
      return WeatherData(
        temperatura: _asDouble(current['temperature_2m']) ?? 0.0,
        umidade: _asDouble(current['relative_humidity_2m']),
        sensacaoTermica: _asDouble(current['apparent_temperature']),
        ventoVelocidade: _asDouble(current['wind_speed_10m']),
        ventoDirecao: _asDouble(current['wind_direction_10m']),
        vento: '${current['wind_speed_10m']} km/h',
        exposicaoSolarCodigo: current['weather_code']?.toString(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

    } on TimeoutException catch (error) {
      throw WeatherException('A consulta de clima demorou demais: $error');
    } on WeatherException {
      rethrow;
    } catch (error) {
      throw WeatherException('Erro ao buscar dados climáticos: $error');
    }
  }

  Future<Position> _buscarLocalizacaoAtual() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const WeatherException('Ative a localização do dispositivo para preencher o clima.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const WeatherException('Permita o acesso à localização para preencher o clima.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const WeatherException('A permissão de localização foi bloqueada nas configurações.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}

// Função auxiliar para garantir que os números venham certinhos
double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}