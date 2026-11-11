import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/campus_data.dart';

/// Override the source to demonstrate empty, pending and failed requests.
/// No network, Firebase initialization or credentials are required.
final campusSourceProvider = Provider<Future<CampusData> Function()>(
  (ref) =>
      () async => sampleCampus,
);
final campusDataProvider = FutureProvider.autoDispose<CampusData>(
  (ref) => ref.watch(campusSourceProvider)(),
  retry: (count, error) => null,
);
