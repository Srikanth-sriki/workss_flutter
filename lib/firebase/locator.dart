import 'package:get_it/get_it.dart';

import 'events.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  if (!locator.isRegistered<AnalyticsService>()) {
    locator.registerLazySingleton(() => AnalyticsService());
  }
}
