# xp_dart example

A Flutter port of the [XP.css](https://botoxparty.github.io/XP.css/)
documentation page, built entirely with `xp_dart` widgets and without
`material.dart` or `cupertino.dart`.

## Run it

```bash
cd example
flutter pub get
flutter run -d macos   # or linux, windows, chrome
```

The repository only checks in the macOS runner. To run on another platform,
generate its runner first:

```bash
flutter create --platforms=linux,windows,web .
```

See [`lib/main.dart`](lib/main.dart) for the full source.
