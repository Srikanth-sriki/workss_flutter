import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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

  var status = await Permission.phone.status;
  if (!status.isGranted) {
    status = await Permission.phone.request();
    if (!status.isGranted) {
      throw 'Phone call permission not granted';
    }
  }

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    launch("tel:$phoneUri");
  }
}

Future<void> launchEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'Packetss10@gmail.com',
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    launch("mailto:Packetss10@gmail.com");
    throw 'Could not launch $emailUri';
  }
}


Future<void> shareJobDetails({
  required String jobTitle,
  required String experience,
  required String location,
}) async {
  final String jobDetails = '''🚀 Discover amazing job opportunities with Works! 🚀

Check out this job:
📌 **Job Title:** $jobTitle
🏢 **Experience:** $experience
🌍 **Location:** $location

With Works, easily find jobs, connect with employers, and apply in a few clicks. 

Explore more exciting job opportunities with Works!

Download Works now and take the next step in your career:
👉 https://play.google.com/store/apps/details?id=com.workss.works_app 👈''';

  final ByteData bytes = await rootBundle.load('assets/images/home/share-banner.png');
  final Uint8List list = bytes.buffer.asUint8List();

  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/share-banner.png').create();
  file.writeAsBytesSync(list);

  // Share the job details with the image
  await Share.shareXFiles(
    [XFile(file.path)],
    text: jobDetails,
  );
}



Future<void> shareAppWithFriend() async {
  const String appPromotionMessage = '''🚀 Discover Your Next Job Opportunity with Works! 🚀

Works makes job hunting easy and efficient:
🌟 Find jobs that match your skills and experience
👥 Connect directly with employers
📲 Apply with just a few clicks

Don’t miss out on your dream job. Download Works now and take control of your career path!

👉 Download Works here: https://play.google.com/store/apps/details?id=com.workss.works_app 👈
''';

  // Load an image from assets
  final ByteData bytes = await rootBundle.load('assets/images/home/share-banner.png');
  final Uint8List imageBytes = bytes.buffer.asUint8List();

  // Save the image as a temporary file to share
  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/share-banner.png').create();
  file.writeAsBytesSync(imageBytes);

  // Share the app promotion message along with the image
  await Share.shareXFiles(
    [XFile(file.path)],
    text: appPromotionMessage,
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

void openMap(double latitude, double longitude) async {
  String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  if (await canLaunch(googleUrl)) {
    await launch(googleUrl);
  } else {
    throw 'Could not open the map.';
  }
}