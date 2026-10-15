// Encodes a PNG frame sequence (with frames.json manifest of {file, ms})
// into an optimised animated GIF: one global palette, and every frame after
// the first only stores the rectangle that changed since the previous one.
//
// Usage: dart run bin/encode_gif.dart <frames_dir> <out.gif>
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final dir = args[0];
  final out = args[1];
  final manifest =
      (jsonDecode(File('$dir/frames.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();

  final frames = [
    for (final f in manifest)
      img
          .decodePng(File('$dir/${f['file']}').readAsBytesSync())!
          .convert(numChannels: 3),
  ];
  final w = frames.first.width, h = frames.first.height;

  // Global palette from a montage of sampled frames.
  final samples = [for (var i = 0; i < frames.length; i += 6) frames[i]];
  final montage = img.Image(width: w, height: h * samples.length);
  for (var i = 0; i < samples.length; i++) {
    img.compositeImage(montage, samples[i], dstY: i * h);
  }
  final quant =
      img.NeuralQuantizer(montage, numberOfColors: 256, samplingFactor: 3);
  final palette = Uint8List(256 * 3);
  for (var i = 0; i < 256; i++) {
    palette[i * 3] = quant.palette.getRed(i).toInt();
    palette[i * 3 + 1] = quant.palette.getGreen(i).toInt();
    palette[i * 3 + 2] = quant.palette.getBlue(i).toInt();
  }
  final cache = <int, int>{};
  int indexOf(int r, int g, int b) => cache.putIfAbsent(
      (r << 16) | (g << 8) | b, () => quant.getColorIndexRgb(r, g, b));

  final bytes = BytesBuilder();
  void u16(int v) => bytes.add([v & 0xff, (v >> 8) & 0xff]);
  bytes.add(ascii.encode('GIF89a'));
  u16(w);
  u16(h);
  bytes.add([0xF7, 0, 0]); // global color table, 8 bits
  bytes.add(palette);
  // Loop forever.
  bytes.add([0x21, 0xFF, 0x0B]);
  bytes.add(ascii.encode('NETSCAPE2.0'));
  bytes.add([3, 1, 0, 0, 0]);

  img.Image? prev;
  final rects = <List<int>>[];
  final frameOf = <int>[];
  final delays = <int>[];
  for (var f = 0; f < frames.length; f++) {
    final cur = frames[f];
    final ms = manifest[f]['ms'] as int;
    List<int>? rect;
    if (prev == null) {
      rect = [0, 0, w, h];
    } else {
      var x0 = w, y0 = h, x1 = -1, y1 = -1;
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final a = cur.getPixel(x, y), b = prev.getPixel(x, y);
          if (a.r != b.r || a.g != b.g || a.b != b.b) {
            if (x < x0) x0 = x;
            if (x > x1) x1 = x;
            if (y < y0) y0 = y;
            if (y > y1) y1 = y;
          }
        }
      }
      if (x1 >= 0) rect = [x0, y0, x1 - x0 + 1, y1 - y0 + 1];
    }
    if (rect == null) {
      delays[delays.length - 1] += ms;
      continue;
    }
    rects.add(rect);
    frameOf.add(f);
    delays.add(ms);
    prev = cur;
  }

  // Second pass: write the frames that changed, with merged delays.
  for (var r = 0; r < rects.length; r++) {
    final cur = frames[frameOf[r]];
    final rect = rects[r];
    final delay = (delays[r] / 10).round();
    bytes.add([0x21, 0xF9, 4, 0x04]); // GCE, disposal: do not dispose
    u16(delay);
    bytes.add([0, 0]);
    bytes.add([0x2C]);
    u16(rect[0]);
    u16(rect[1]);
    u16(rect[2]);
    u16(rect[3]);
    bytes.add([0]);
    final indices = Uint8List(rect[2] * rect[3]);
    var i = 0;
    for (var y = rect[1]; y < rect[1] + rect[3]; y++) {
      for (var x = rect[0]; x < rect[0] + rect[2]; x++) {
        final p = cur.getPixel(x, y);
        indices[i++] = indexOf(p.r.toInt(), p.g.toInt(), p.b.toInt());
      }
    }
    bytes.add([8]);
    final data = _lzw(indices, 8);
    for (var o = 0; o < data.length; o += 255) {
      final end = (o + 255 < data.length) ? o + 255 : data.length;
      bytes.add([end - o]);
      bytes.add(data.sublist(o, end));
    }
    bytes.add([0]);
  }
  bytes.add([0x3B]);
  final result = bytes.toBytes();
  File(out).writeAsBytesSync(result);
  stdout.writeln('Wrote $out (${(result.length / 1024).toStringAsFixed(0)} KB, '
      '${rects.length} frames, ${w}x$h)');
}

/// GIF LZW encoder (port of omggif's GifWriterOutputLZWCodeStream).
Uint8List _lzw(Uint8List index, int minCodeSize) {
  final out = BytesBuilder();
  final clearCode = 1 << minCodeSize;
  final eoiCode = clearCode + 1;
  var nextCode = eoiCode + 1;
  var curCodeSize = minCodeSize + 1;
  var curShift = 0;
  var cur = 0;

  void emit(int c) {
    cur |= c << curShift;
    curShift += curCodeSize;
    while (curShift >= 8) {
      out.addByte(cur & 0xff);
      cur >>= 8;
      curShift -= 8;
    }
  }

  var table = <int, int>{};
  emit(clearCode);
  var ibCode = index[0];
  for (var i = 1; i < index.length; i++) {
    final k = index[i];
    final key = (ibCode << 8) | k;
    final code = table[key];
    if (code == null) {
      emit(ibCode);
      if (nextCode == 4096) {
        emit(clearCode);
        nextCode = eoiCode + 1;
        curCodeSize = minCodeSize + 1;
        table = <int, int>{};
      } else {
        if (nextCode >= (1 << curCodeSize)) curCodeSize++;
        table[key] = nextCode++;
      }
      ibCode = k;
    } else {
      ibCode = code;
    }
  }
  emit(ibCode);
  emit(eoiCode);
  if (curShift > 0) out.addByte(cur & 0xff);
  return out.toBytes();
}
