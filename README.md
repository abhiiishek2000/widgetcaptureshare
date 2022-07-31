
# WidgetCaptureShare

A flutter package that provides you to capture any widget to image. The features is:
1. Preview image
2. Save image locally
3. share image

## Installation 

1. Add the latest version of package to your pubspec.yaml (and run`dart pub get`):
```yaml
dependencies:
  widget_capture_share: ^0.0.3
```
2. Import the package and use it in your Flutter App.
```dart
import 'package:widget_capture_share/process.dart';
```

## Example

```dart
// definig global key of widget
 GlobalKey? key1; 
 
  WidgetCapture(
        builder: (key) {
          key1 = key;
          return const Sample1Screen();
        }),
//function
Future<bool> shareImage(GlobalKey? key,String filename) async{
      await WidgetCaptureShare.capture(key!,saveToDevice: true,albumName: "Test",openFilePreview: false,fileName: filename,isShare: true);
        return true;

  }

//calling function
shareImage(key!, "Invitation card");
```

