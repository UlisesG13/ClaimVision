class SseEvent {
  final String entity;
  final String action;
  final String? siniestroId;
  final String? aseguradoraId;
  final String? targetUserId;
  final String? targetAseguradoraId;
  final String? targetRole;
  final Map<String, dynamic>? data;

  const SseEvent({
    required this.entity,
    required this.action,
    this.siniestroId,
    this.aseguradoraId,
    this.targetUserId,
    this.targetAseguradoraId,
    this.targetRole,
    this.data,
  });

  factory SseEvent.fromJson(Map<String, dynamic> json) {
    return SseEvent(
      entity: json['entity'] as String? ?? '',
      action: json['action'] as String? ?? '',
      siniestroId: json['siniestro_id'] as String?,
      aseguradoraId: json['aseguradora_id'] as String?,
      targetUserId: json['target_user_id'] as String?,
      targetAseguradoraId: json['target_aseguradora_id'] as String?,
      targetRole: json['target_role'] as String?,
      data: json,
    );
  }

  bool get isSiniestro => entity == 'siniestro';
  bool get isCotizacion => entity == 'cotizacion';
  bool get isPeritaje => entity == 'peritaje';
  bool get isImagen => entity == 'siniestro_imagen';
  bool get isCliente => entity == 'cliente';
  bool get isAjustador => entity == 'ajustador';
  bool get isVehiculo => entity == 'vehiculo';
  bool get isTaller => entity == 'taller';

  bool get esStatusChange =>
      action == 'STATUS_CHANGE' || action == 'UPDATE';
}
