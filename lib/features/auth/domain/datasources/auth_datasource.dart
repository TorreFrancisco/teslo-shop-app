import '../entities/user.dart';

abstract class AuthDataSource {
  Future<User> login(
      String email,
      String
          password); //Recibir datos del login (CON MANEJO DE ERRORES PERSONALIZADOS EN AUTH_REPOSITORY.DART)
  Future<User> register(
      String email,
      String password,
      String
          fullName); //Recibir datos del register (CON MANEJO DE ERRORES PERSONALIZADOS EN AUTH_REPOSITORY.DART)
  Future<User> checkAuthStatus(
      String
          token); //Persona autenticada?(ESTO SE MANEJA EN INFRAESTRUCTURE AUTH_DATASOURCE.DART Y AUTH_REPOSITORY.DART) si/no
}
