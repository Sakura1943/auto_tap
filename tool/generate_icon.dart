import 'dart:io';
import 'package:image/image.dart' as img;

const _sizes = {
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};

const _mipmapBase = 'android/app/src/main/res';

void main() {
  final src = File('assets/icon.png');
  if (!src.existsSync()) {
    print('请先把图标放到 assets/icon.png');
    return;
  }
  final image = img.decodePng(src.readAsBytesSync());
  if (image == null) {
    print('无法解码图标文件');
    return;
  }

  for (final e in _sizes.entries) {
    final resized = img.copyResize(image, width: e.value, height: e.value);
    final dir = Directory('$_mipmapBase/mipmap-${e.key}');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/ic_launcher.png').writeAsBytesSync(img.encodePng(resized));
  }

  print('已生成 ${_sizes.length} 个 DPI 尺寸的 mipmap 图标');
}
