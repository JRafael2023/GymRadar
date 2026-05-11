import 'dart:typed_data';

class FFUploadedFile {
  const FFUploadedFile({
    this.name,
    this.bytes,
    this.height,
    this.width,
    this.blurHash,
  });

  final String? name;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final String? blurHash;

  @override
  String toString() =>
      'FFUploadedFile(name: $name, bytes: ${bytes?.length ?? 0} bytes)';

  @override
  bool operator ==(Object other) =>
      other is FFUploadedFile &&
      name == other.name &&
      bytes == other.bytes;

  @override
  int get hashCode => Object.hash(name, bytes);
}
