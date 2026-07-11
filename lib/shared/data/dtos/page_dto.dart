class PageDto<T> {
  const PageDto({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> data;
  final int total;
  final int page;
  final int pageSize;

  factory PageDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final dataList = (json['data'] as List<dynamic>?)
            ?.map((e) => fromItem(e as Map<String, dynamic>))
            .toList() ??
        [];
    return PageDto(
      data: dataList,
      total: (json['total'] as num?)?.toInt() ?? dataList.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? dataList.length,
    );
  }
}
