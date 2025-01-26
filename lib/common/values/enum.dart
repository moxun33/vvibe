//url检测的结果状态
enum UrlSniffResStatus { failed, success, timeout }

enum UpdatStatus {
  available,
  availableWithChangelog,
  checking,
  upToDate,
  error,
  idle,
  downloading,
  readyToInstall,
  dismissed,
}
