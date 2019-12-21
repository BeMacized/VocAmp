import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class DioUtils {
  static Dio createCaching({
    Duration maxAge = const Duration(minutes: 2),
    Duration maxStale = const Duration(minutes: 60),
  }) {
    assert(maxAge <= maxStale);
    return Dio()
      ..interceptors.add(
        DioCacheManager(
          CacheConfig(
            defaultMaxAge: maxAge,
            defaultMaxStale: maxStale,
          ),
        ).interceptor,
      );
  }
}
