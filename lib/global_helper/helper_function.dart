import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:intl/intl.dart';

// String timeAgo(DateTime updatedAt) {
//   DateTime now = DateTime.now();
//   Duration difference = now.difference(updatedAt);
//
//   if (difference.inDays > 0) {
//     int days = difference.inDays;
//     return "${days}d ago";
//   } else if (difference.inHours > 0) {
//     int hours = difference.inHours;
//     int minutes = difference.inMinutes.remainder(60);
//     return "${hours}h ${minutes}m ago";
//   } else if (difference.inMinutes > 0) {
//     int minutes = difference.inMinutes;
//     int seconds = difference.inSeconds.remainder(60);
//     return "${minutes}m ${seconds}s ago";
//   } else {
//     int seconds = difference.inSeconds;
//     return "${seconds}s ago";
//   }
// }

String timeAgo(DateTime updatedAt) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(updatedAt);

  if (difference.inDays > 0) {
    int days = difference.inDays;
    return "${days}d ago";
  } else if (difference.inHours > 0) {
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    return "${hours}h ${minutes}m ago";
  } else if (difference.inMinutes > 0) {
    int minutes = difference.inMinutes;
    int seconds = difference.inSeconds.remainder(60);
    return "${minutes}m ago";
  } else {
    int seconds = difference.inSeconds;
    return "${seconds}s ago";
  }
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

String capitalizeEachWord(String input) {
  return input.split(' ').map((word) => capitalizeFirstLetter(word)).join(' ');
}


Future<void> makePhoneCall(String phoneNumber) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $phoneNumber';
  }
}

Future<void> shareJobDetails() async {
  final String jobDetails = 'Check out this job:\nJob Title: Developer\nCompany: XYZ Corp\nLocation: Remote\n\nDownload the app from the link: https://example.com/app';
  final ByteData bytes = await rootBundle.load('assets/images/login/intro1.png');
  final Uint8List list = bytes.buffer.asUint8List();
  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/banner.png').create();
  file.writeAsBytesSync(list);
  await Share.shareXFiles(
    [XFile(file.path)],
    text: jobDetails,
  );
}


Future<File?> compressImage(File file) async {
  final compressedImage = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 800,
    minHeight: 800,
    quality: 85, // Adjust the quality as per your requirement
  );

  if (compressedImage != null) {
    final tempDir = Directory.systemTemp;
    final targetPath = "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
    final compressedFile = File(targetPath).writeAsBytes(compressedImage);
    return compressedFile;
  }

  return null;
}


String formatPrice(String price) {
  try {
    int priceInt = int.parse(price);
    return '₹ ${NumberFormat('#,##,###').format(priceInt)}';
  } catch (e) {
    return 'Invalid price';
  }
}