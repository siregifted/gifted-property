import 'package:flutter/foundation.dart';

const bool sampleDataRequested = bool.fromEnvironment(
  'USE_SAMPLE_PROPERTIES',
  defaultValue: false,
);

const bool sampleDataEnabled = kDebugMode && sampleDataRequested;

bool shouldEnableSampleData({
  required bool isDebugMode,
  required bool requested,
}) => isDebugMode && requested;
