class PaginatedResponseDto<T> {
  const PaginatedResponseDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<T> data;
  final int total;
  final int page;
  final int limit;

  factory PaginatedResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PaginatedResponseDto(
      data: (json['data'] as List<dynamic>)
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}
