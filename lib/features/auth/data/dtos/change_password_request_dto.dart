class ChangePasswordRequestDto {
  const ChangePasswordRequestDto({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => {
        'old_password': oldPassword,
        'new_password': newPassword,
      };
}
