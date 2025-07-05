import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.headers['User-Agent'] =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  return dio;
});

final hiveProvider = Provider<HiveInterface>((ref) => Hive);
