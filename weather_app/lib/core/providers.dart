import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final hiveProvider = Provider<HiveInterface>((ref) => Hive);
