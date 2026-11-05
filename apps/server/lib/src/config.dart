import 'dart:io';

/// Cấu hình đọc từ biến môi trường (xem deploy/.env.example).
class ServerConfig {
  const ServerConfig({
    required this.port,
    required this.databaseUrl,
    required this.minClientVersion,
    required this.latestClientVersion,
    required this.latestClientUrl,
  });

  factory ServerConfig.fromEnvironment([Map<String, String>? env]) {
    final e = env ?? Platform.environment;
    return ServerConfig(
      port: int.parse(e['PORT'] ?? '8080'),
      databaseUrl: e['DATABASE_URL'],
      minClientVersion: AppVersion.parse(e['MIN_CLIENT_VERSION'] ?? '0.0.0'),
      latestClientVersion: AppVersion.parse(
        e['LATEST_CLIENT_VERSION'] ?? '0.1.0',
      ),
      latestClientUrl: e['LATEST_CLIENT_URL'] ?? '',
    );
  }

  final int port;

  /// `postgres://user:pass@host:5432/db`. `null` thì chạy không có DB (dev).
  final String? databaseUrl;

  /// App cũ hơn bản này nhận `CLIENT_TOO_OLD` (docs/tech/01 mục 6).
  final AppVersion minClientVersion;

  final AppVersion latestClientVersion;

  /// Link bộ cài đã ký trên R2.
  final String latestClientUrl;
}

/// Phiên bản app dạng `major.minor.patch` (bỏ qua phần `+build`).
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  factory AppVersion.parse(String value) {
    final core = value.split('+').first.trim();
    final parts = core.split('.');
    if (parts.length != 3) {
      throw FormatException('Phiên bản phải dạng x.y.z', value);
    }
    return AppVersion(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';
}
