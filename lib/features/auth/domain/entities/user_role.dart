/// Roles del sistema, con los valores EXACTOS del enum `rol_usuario` del
/// backend (ver BACKEND_CONTRACT.md §2.2). Los valores de la API son verbatim.
enum UserRole {
  administradorGlobal('Administrador_Global'),
  operadorAseguradora('Operador_Aseguradora'),
  ajustador('Ajustador'),
  operadorTaller('Operador_Taller'),
  cliente('Cliente');

  const UserRole(this.apiValue);

  /// Valor tal cual lo envía/espera el backend.
  final String apiValue;

  /// Convierte el string del JWT/respuesta a un [UserRole].
  /// Si el valor es desconocido, se asume [UserRole.cliente] (el rol de menor
  /// privilegio dentro de la app móvil).
  static UserRole fromApi(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.apiValue == value,
      orElse: () => UserRole.cliente,
    );
  }

  bool get isCliente => this == UserRole.cliente;
  bool get isAjustador => this == UserRole.ajustador;

  /// Etiqueta legible para mostrar al usuario.
  String get label {
    return switch (this) {
      UserRole.administradorGlobal => 'Administrador',
      UserRole.operadorAseguradora => 'Aseguradora',
      UserRole.ajustador => 'Ajustador',
      UserRole.operadorTaller => 'Taller',
      UserRole.cliente => 'Cliente',
    };
  }
}
