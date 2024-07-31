import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';
import 'package:weather_app/app/data/weather.dart';

late Isar isar;
late Settings settings;
late LocationCache locationCache;
final ValueNotifier<Future<bool>> isOnline = ValueNotifier(InternetConnection().hasInternetAccess);

bool amoledTheme = false;
bool materialColor = false;
bool roundDegree = false;
Locale locale = const Locale('en', 'US');
int timeRange = 1;
String timeStart = '09:00';
String timeEnd = '21:00';
String widgetBackgroundColor = '';
String widgetTextColor = '';

final List appLanguages = [
  {'name': 'English', 'locale': const Locale('en', 'US')}
];

const String appGroupId = 'DARK NIGHT';
const String androidWidgetName = 'OreoWidget';