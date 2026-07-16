enum SecurityIssue {
  developerOptions,
  adbEnabled,
  appDebuggable,
  mockLocation,
  emulator,
}

sealed class SecurityStatus {
  const SecurityStatus();
}

class SecurityLoading extends SecurityStatus {
  const SecurityLoading();
}

class SecurityOk extends SecurityStatus {
  const SecurityOk();
}

class SecurityCompromised extends SecurityStatus {
  const SecurityCompromised(this.issues);
  final List<SecurityIssue> issues;
}
