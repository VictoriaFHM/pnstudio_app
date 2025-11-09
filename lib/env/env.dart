import 'env_dev.dart';
import 'env_prod.dart';

class Env {
  static const bool isProd = bool.fromEnvironment('dart.vm.product');
  static String get baseUrl => isProd ? EnvProd.baseUrl : EnvDev.baseUrl;
}
