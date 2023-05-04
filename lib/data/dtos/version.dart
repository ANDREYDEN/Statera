class Version {
  final int major;
  final int minor;
  final int patch;

  Version({
    required this.major,
    required this.minor,
    required this.patch,
  });

  factory Version.fromString(String versionString) {
    final parts = versionString.split('.');
    return Version(
      major: int.parse(parts[0]),
      minor: int.parse(parts[1]),
      patch: int.parse(parts[2]),
    );
  }

  @override
  String toString() {
    return '$major.$minor.$patch';
  }

  bool operator >(Version other) {
    if (major > other.major) {
      return true;
    }

    if (major == other.major && minor > other.minor) {
      return true;
    }

    if (major == other.major && minor == other.minor && patch > other.patch) {
      return true;
    }

    return false;
  }

  bool operator <(Version other) {
    if (major < other.major) {
      return true;
    }

    if (major == other.major && minor < other.minor) {
      return true;
    }

    if (major == other.major && minor == other.minor && patch < other.patch) {
      return true;
    }

    return false;
  }
}