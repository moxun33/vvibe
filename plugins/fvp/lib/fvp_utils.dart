//播放状态
class FvpPlayState {
  static const notRunning = 0;
  static const stopped = notRunning;
  static const running = 1;
  static const playing = running;

  /// start/resume to play
  static const paused = 2;
}

//媒体状态
class FvpMediaStatus {
  static const noMedia =
      0; // initial status, not invalid. // what if set an empty url and closed?
  static const unloaded =
      1; // unloaded // (TODO: or when a source(url) is set?)
  static const loading = 1 << 1; // opening and parsing the media
  static const loaded = 1 <<
      2; // media is loaded and parsed. player is stopped state. mediaInfo() is available now
  static const prepared = 1 <<
      8; // all tracks are buffered and ready to decode frames. tracks failed to open decoder are ignored
  static const stalled = 1 <<
      3; // insufficient buffering or other interruptions (timeout, user interrupt)
  static const buffering = 1 << 4; // when buffering starts
  static const buffered = 1 << 5; // when buffering ends
  static const end =
      1 << 6; // reached the end of the current media, no more data to read
  static const seeking = 1 << 7;
  static const invalid = 1 <<
      31; // failed to load media because of unsupport format or invalid media source
}
