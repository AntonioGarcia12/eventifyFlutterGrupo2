class Usuario {
  final int id;
  final String name;
  final String email;
  final String password;
  final String role;

  Usuario(this.name, this.email, this.password, this.role, {required this.id});
}
