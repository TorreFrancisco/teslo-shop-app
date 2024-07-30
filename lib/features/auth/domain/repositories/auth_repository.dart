import '../entities/user.dart';

//Repositorio termina teniendo en la implementacion la definicion del datasource que utilizamos para autenticarlos
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String fullName);
  Future<User> checkAuthStatus(String token); //Persona autenticada? si/no
}
