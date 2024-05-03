import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WidgetCaptureShare {
  static Future capture(GlobalKey key,
      {String fileName = 'WidgetCaptureShare',
      bool openFilePreview = true,
      bool saveToDevice = false,
      bool isShare = false,
      String? albumName,
      String? shareText,
      double? pixelRatio,
      bool returnImageUint8List = false}) async {
    try {
      pixelRatio ??= ui.window.devicePixelRatio;

      /// finding the widget in the current context by the key.
      var repaintBoundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      /// With the repaintBoundary we got from the context, we start the createImageProcess
      await _createImageProcess(
          albumName: albumName,
          fileName: fileName,
          saveToDevice: saveToDevice,
          returnImageUint8List: returnImageUint8List,
          openFilePreview: openFilePreview,
          isShare: isShare,
          repaintBoundary: repaintBoundary,
          shareText: shareText,
          pixelRatio: pixelRatio);
    } catch (e) {
      /// if the above process is failed, the error is printed.
      print(e);
    }
  }

  /// create image process
  static Future _createImageProcess(
      {saveToDevice,
      albumName,
      fileName,
      isShare,
      returnImageUint8List,
      openFilePreview,
      repaintBoundary,
      shareText,
      pixelRatio}) async {
    /// the boundary is converted to Image.
    final ui.Image image =
        await repaintBoundary.toImage(pixelRatio: pixelRatio);

    /// The raw image is converted to byte data.
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    /// The byteData is converted to uInt8List image memory Image.
    final u8Image = byteData!.buffer.asUint8List();

    if (saveToDevice) {
      _saveImageToDevice(albumName, fileName);
    }

    /// If the returnImageUint8List is true, return the image as uInt8List
    if (returnImageUint8List) {
      return u8Image;
    }

    /// if the openFilePreview is true, open the image in openFile
    if (openFilePreview) {
      await _openImagePreview(u8Image, fileName);
    }
    if (isShare) {
      await _share(u8Image, fileName, shareText ?? '');
    }
  }

  static Future _openImagePreview(Uint8List u8Image, String imageName) async {
    /// getting the temp directory of the app.
    String dir = (await getApplicationDocumentsDirectory()).path;

    /// Saving the file with the file name in temp directory.
    File file = File('$dir/$imageName.png');

    /// the image file is created
    await file.writeAsBytes(u8Image);

    /// The image file is opened.
    await OpenFile.open(
      '$dir/$imageName.png',
    );

    return file;
  }

  static Future _share(
      Uint8List u8Image, String imageName, String shareText) async {
    /// getting the temp directory of the app.
    String dir = (await getApplicationDocumentsDirectory()).path;

    /// Saving the file with the file name in temp directory.
    File file = File('$dir/$imageName.png');

    /// the image file is created
    await file.writeAsBytes(u8Image);

    /// share image
    await Share.shareXFiles([XFile(file.path)], text: shareText);
  }

  /// To save the images locally
  static void _saveImageToDevice(String? album, String imageName) async {
    /// getting the temp directory of the app.
    String dir = (await getApplicationDocumentsDirectory()).path;

    /// Saving the file with the file name in temp directory.
    File file = File('$dir/$imageName.png');

    /// The image is saved with the file path and to the album if defined,
    /// if the album is null, it saves to the all pictures.
    await GallerySaver.saveImage(file.path, albumName: album);
  }
}
