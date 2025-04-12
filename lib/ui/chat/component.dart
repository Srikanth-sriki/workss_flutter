import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/helper_function.dart';
import 'dart:math' as math;
import '../../global_helper/reuse_widget.dart';

Widget chartSearchCards({
  required String image,
  required String name,
  required VoidCallback onTapCard,
  required String message,
  required String date,
  required String count,
  required bool isGroup,
}) {
  return TouchRippleEffect(
    borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
    rippleColor: Colors.white60,
    child: InkWell(
      onTap: onTapCard,
      splashColor: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig.blockHeight * 1,
        ),
        padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
          color: COLORS.primaryOne.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(image.isNotEmpty)...[
                  Container(
                    width: SizeConfig.blockWidth * 14,
                    height: SizeConfig.blockWidth * 14,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(SizeConfig.blockWidth * 2))),
                  ),

                ]
                else...[
                  Container(
                    width: SizeConfig.blockWidth * 14,
                    height: SizeConfig.blockWidth * 14,
                    decoration: BoxDecoration(
                      color: COLORS.neutralDarkTwo,
                      borderRadius: BorderRadius.circular(SizeConfig.blockWidth*3)
                    ),
                    child: Icon(isGroup?Icons.people:Icons.person,color: COLORS.neutralDark,size: SizeConfig.blockWidth*7,),
                  )
                ]
               ,
                SizedBox(width: SizeConfig.blockWidth * 3),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: SizeConfig.blockWidth * 40,
                      child: Text(
                        capitalizeEachWord(name),
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 3.3,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // textAlign: TextAlign.end,
                      ),
                    ),
                    if(message.isNotEmpty)...[
                      SizedBox(
                        width: SizeConfig.blockWidth * 40,
                        child: Text(
                          capitalizeFirstLetter(message),
                          style: TextStyle(
                            color: COLORS.neutralDarkOne,
                            fontSize: SizeConfig.blockWidth * 3,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // textAlign: TextAlign.end,
                        ),
                      )
                    ],
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 2.8,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // textAlign: TextAlign.end,
                ),
                SizedBox(height: SizeConfig.blockHeight),
                if(count !='0' )...[
                  Container(
                    alignment: Alignment.center,
                    width: SizeConfig.blockWidth * 4,
                    height: SizeConfig.blockWidth * 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          SizeConfig.blockWidth * 4,
                        ),
                        color: COLORS.accent),
                    child: Text(
                      count,
                      style: TextStyle(
                        color: COLORS.white,
                        fontSize: SizeConfig.blockWidth * 2.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),

                      // textAlign: TextAlign.end,
                    ),
                  )
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class DynamicBottomSheet extends StatelessWidget {
  final String header;
  final List<BottomSheetItem> items;

  const DynamicBottomSheet({
    Key? key,
    required this.header,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: COLORS.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.blockWidth * 5),
              topRight: Radius.circular(SizeConfig.blockWidth * 5))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: SizeConfig.blockHeight),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 5,
                vertical: SizeConfig.blockHeight),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  header.tr(),
                  style: TextStyle(
                    color: COLORS.primaryTwo,
                    fontSize: SizeConfig.blockWidth * 4.25,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: COLORS.neutralDark,
                    size: SizeConfig.blockWidth * 6.5,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(
            color: COLORS.neutralDarkTwo,
          ),
          ...items.map((item) => GestureDetector(
                onTap: item.onTap,
                child: Container(
                  width: double.infinity,
                  color: COLORS.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 6,
                      vertical: SizeConfig.blockHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 3.9,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(height: SizeConfig.blockHeight),
                      const Divider(
                        color: COLORS.neutralDarkTwo,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class BottomSheetItem {
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  BottomSheetItem({
    required this.title,
    required this.onTap,
    this.trailing,
  });
}

void showDynamicBottomSheet(
    BuildContext context, String header, List<BottomSheetItem> items) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DynamicBottomSheet(header: header, items: items),
  );
}

Widget createGroupInviteCard({
  required String image,
  required String name,
  required bool added,
  required VoidCallback onTapCard,
  required String disc,
  required bool checkSelected
}) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockWidth * 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: SizeConfig.blockWidth * 12,
                    height: SizeConfig.blockWidth * 12,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: COLORS.primary,
                          width: SizeConfig.blockWidth * 0.3,
                        ),
                        image: DecorationImage(
                            image: NetworkImage(
                              image
                                  .isEmpty
                                  ? 'https://via.placeholder.com/150'
                                  : image,
                            ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.all(
                            Radius.circular(
                                SizeConfig.blockWidth * 3))),
                  ),
                  SizedBox(width: SizeConfig.blockWidth * 2),
                  SizedBox(
                    width: SizeConfig.blockWidth * 30,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: COLORS.neutralDark,
                            fontSize: SizeConfig.blockWidth * 3.5,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // textAlign: TextAlign.end,
                        ),
                        Text(
                          disc,
                          style: TextStyle(
                            color: COLORS.neutralDarkOne,
                            fontSize: SizeConfig.blockWidth * 3,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if(!checkSelected)...[
                customIconButton(
                    text: added ? 'Request Sent' : 'Invite',
                    onPressed: onTapCard,
                    width: SizeConfig.blockWidth * 32,
                    height: SizeConfig.blockHeight * 6.25,
                    backgroundColor: added ? COLORS.neutralDarkTwo : COLORS.primary,
                    textColor: added ? COLORS.neutralDark : COLORS.white,
                    showIcon: false)
              ]
            ],
          ),
          SizedBox(
            height: SizeConfig.blockHeight * 1.5,
          ),
          Divider(
            color: COLORS.neutralDarkTwo,
            height: SizeConfig.blockHeight * 4,
          )
        ],
      ),
    ),
  );
}

Widget chartMemberCardViewSearchCards(
    {required String image,
    required String name,
    required VoidCallback onTapCard,
      required bool admin,
    required String message}) {
  return TouchRippleEffect(
    borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
    rippleColor: Colors.white60,
    child: InkWell(
      onTap: onTapCard,
      splashColor: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig.blockHeight * 1,
        ),
        padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
          color: COLORS.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: SizeConfig.blockWidth * 12,
                    height: SizeConfig.blockWidth * 12,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: COLORS.primary,
                          width: SizeConfig.blockWidth * 0.3,
                        ),
                        image: DecorationImage(
                            image: NetworkImage(
                              image
                                  .isEmpty
                                  ? 'https://via.placeholder.com/150'
                                  : image,
                            ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.all(
                            Radius.circular(
                                SizeConfig.blockWidth * 3))),
                  ),
                  SizedBox(width: SizeConfig.blockWidth * 3),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: SizeConfig.blockWidth * 50,
                        child: Text(
                          name,
                          style: TextStyle(
                            color: COLORS.neutralDark,
                            fontSize: SizeConfig.blockWidth * 3.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // textAlign: TextAlign.end,
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.blockWidth * 50,
                        child: Text(
                          message,
                          style: TextStyle(
                            color: COLORS.neutralDarkOne,
                            fontSize: SizeConfig.blockWidth * 3,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
                ),
                if(admin)...[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight*0.6,horizontal: SizeConfig.blockWidth*3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 1.5),
                      color: COLORS.semanticTwo.withOpacity(0.15),
                    ),
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 2,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  )
                ]

              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// class MessageBubbleClipper extends CustomClipper<Path> {
//   final bool isSentByMe;
//
//   MessageBubbleClipper({required this.isSentByMe});
//
//   @override
//   Path getClip(Size size) {
//     final Path path = Path();
//
//     if (isSentByMe) {
//       // Sent message (right-side notch + rounded corners)
//       path.moveTo(10, 0);
//       path.lineTo(size.width - 20, 0);
//       path.quadraticBezierTo(size.width, 0, size.width, 20); // Top-right radius
//       path.lineTo(size.width, size.height - 10);
//       path.quadraticBezierTo(size.width, size.height, size.width - 10, size.height); // Bottom-right radius
//       path.lineTo(20, size.height);
//       path.lineTo(10, size.height + 10); // Notch
//       path.lineTo(10, size.height);
//       path.quadraticBezierTo(0, size.height, 0, size.height - 10); // Bottom-left (no radius)
//       path.lineTo(0, 20);
//       path.quadraticBezierTo(0, 0, 10, 0); // Top-left radius
//       path.close();
//     } else {
//       // Received message (left-side notch + rounded corners)
//       path.moveTo(size.width - 10, 0);
//       path.lineTo(20, 0);
//       path.quadraticBezierTo(0, 0, 0, 20); // Top-left radius
//       path.lineTo(0, size.height - 10);
//       path.quadraticBezierTo(0, size.height, 10, size.height); // Bottom-left radius
//       path.lineTo(size.width - 20, size.height);
//       path.lineTo(size.width - 10, size.height + 10); // Notch
//       path.lineTo(size.width - 10, size.height);
//       path.quadraticBezierTo(size.width, size.height, size.width, size.height - 10); // Bottom-right (no radius)
//       path.lineTo(size.width, 20);
//       path.quadraticBezierTo(size.width, 0, size.width - 10, 0); // Top-right radius
//       path.close();
//     }
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }

class MessageBubbleClipper extends CustomClipper<Path> {
  final bool isSentByMe;

  MessageBubbleClipper({required this.isSentByMe});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double radius = 12.0; // Corner radius
    const double notchWidth = 10.0; // Width of the notch
    const double notchHeight = 12.0; // Height of the notch

    if (isSentByMe) {
      path.moveTo(radius, 0); // Top-left corner
      path.lineTo(size.width - radius, 0); // Top edge
      path.quadraticBezierTo(
          size.width, 0, size.width, radius); // Top-right corner
      path.lineTo(size.width, size.height - radius - notchHeight); // Right edge
      path.quadraticBezierTo(size.width, size.height - notchHeight,
          size.width - radius, size.height - notchHeight); // Bottom-right curve

      // Add Notch
      path.lineTo(size.width - notchWidth, size.height - notchHeight);
      path.lineTo(size.width - notchWidth / 2, size.height); // Notch tip
      path.lineTo(size.width - 2 * notchWidth, size.height - notchHeight);

      path.lineTo(radius, size.height - notchHeight); // Bottom edge
      path.quadraticBezierTo(0, size.height - notchHeight, 0,
          size.height - radius - notchHeight); // Bottom-left curve
      path.lineTo(0, radius); // Left edge
      path.quadraticBezierTo(0, 0, radius, 0); // Top-
    } else {
      // Received message (left side notch)
      path.moveTo(10, 10);
      path.lineTo(size.width, 10);
      path.quadraticBezierTo(size.width, 10, size.width, 20);
      path.lineTo(size.width, size.height - 10);
      path.quadraticBezierTo(
          size.width, size.height, size.width - 10, size.height);
      path.lineTo(10, size.height);
      path.lineTo(0, size.height + 10); // Notch
      path.lineTo(0, size.height);
      path.quadraticBezierTo(0, size.height, 10, size.height - 10);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => true;
}

class ChatMessageWidget extends StatelessWidget {
  final bool isSentByMe;
  final String message;
  final String time;
  final bool isRead;

  const ChatMessageWidget({
    Key? key,
    required this.isSentByMe,
    required this.message,
    required this.time,
    this.isRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isSentByMe ? 50 : 10,
          10,
          isSentByMe ? 10 : 50,
          10,
        ),
        child: ClipPath(
          clipper: MessageBubbleClipper(isSentByMe: isSentByMe),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: isSentByMe ? Colors.blue[100] : Colors.grey[300],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (isSentByMe)
                      Icon(
                        isRead ? Icons.done_all : Icons.check,
                        size: 16,
                        color: isRead ? Colors.blue : Colors.grey,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// class ChatMessageWidget extends StatelessWidget {
//   final bool isSentByMe;
//   final String? message;
//   final String? imageUrl;
//   final String? audioWave;
//   final String time;
//   final bool isRead;
//
//   const ChatMessageWidget({
//     Key? key,
//     required this.isSentByMe,
//     this.message,
//     this.imageUrl,
//     this.audioWave,
//     required this.time,
//     this.isRead = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.fromLTRB(
//           isSentByMe ? 50 : 10, 10, isSentByMe ? 10 : 50, 10,
//         ),
//         child: ClipPath(
//           clipper: MessageBubbleClipper(isSentByMe: isSentByMe),
//           child: Container(
//             color: isSentByMe ? Colors.blue[100] : Colors.grey[300],
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // IMAGE
//                 if (imageUrl != null)
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(color: Colors.white, width: 2),
//                       ),
//                     ),
//                     child: Image.network(
//                       imageUrl!,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//
//                 // AUDIO WAVE
//                 if (audioWave != null)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Icon(Icons.play_circle, size: 32, color: Colors.black54),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             audioWave!,
//                             style: TextStyle(fontSize: 14, color: Colors.blue),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // MESSAGE TEXT
//                 if (message != null)
//                   Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Text(
//                       message!,
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ),
//
//                 // TIME AND STATUS
//                 Padding(
//                   padding: const EdgeInsets.only(right: 8, bottom: 8),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         time,
//                         style:
//                         const TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                       if (isSentByMe)
//                         Icon(
//                           isRead ? Icons.done_all : Icons.check,
//                           size: 16,
//                           color: isRead ? Colors.blue : Colors.grey,
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class Triangle extends CustomPainter {
  final Color bgColor;

  Triangle(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SendMessage extends StatelessWidget {
  final bool isSeenByMe;
  final String message;
  final String time;
  final bool isRead;
  final bool imageShow;
  final bool textShow;
  final bool audioShow;
  final Widget? audioWidget;
  final String imageUrl;
  const SendMessage(
      {required super.key,
      required this.message,
      required this.isSeenByMe,
      required this.time,
      required this.imageShow,
      required this.textShow,
      required this.audioShow,
      this.audioWidget,
      this.isRead = false,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: SizeConfig.blockWidth * 70,
          ),
          child: IntrinsicWidth(
            child: Container(
              padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
              decoration: BoxDecoration(
                color: COLORS.neutralDarkTwo.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeConfig.blockWidth * 2),
                  bottomLeft: Radius.circular(SizeConfig.blockWidth * 2),
                  topRight: Radius.circular(SizeConfig.blockWidth * 2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (textShow) ...[
                    Text(
                      message,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 3.25,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      softWrap: true,
                    )
                  ],
                  if (imageShow) ...[
                    GestureDetector(
                      onTap: () => _showImageDialog(context, imageUrl),
                      child: Container(
                        width: SizeConfig.blockWidth * 40,
                        height: SizeConfig.blockWidth * 40,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                  imageUrl,
                                ),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.all(
                                Radius.circular(SizeConfig.blockWidth * 3))),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockHeight,
                    )
                  ],
                  if (audioShow && audioWidget != null) ...[audioWidget!],
                  SizedBox(
                    width: SizeConfig.blockWidth * 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          time.toUpperCase(),
                          style: TextStyle(
                            color: COLORS.neutralDarkOne,
                            fontSize: SizeConfig.blockWidth * 2.6,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                        SizedBox(
                          width: SizeConfig.blockWidth * 1.5,
                        ),
                        Image.asset(
                          isSeenByMe
                              ? 'assets/images/chat/read_done.png'
                              : 'assets/images/chat/read.png',
                          width: SizeConfig.blockWidth * 3,
                          height: SizeConfig.blockWidth * 3,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationX(math.pi),
          child: CustomPaint(
            painter: Triangle(COLORS.neutralDarkTwo.withOpacity(0.9)),
          ),
        ),
        // CustomPaint(painter: Triangle(Colors.grey[300]!),),
      ],
    ));

    return Padding(
      padding: EdgeInsets.only(right: SizeConfig.blockWidth*5, left: SizeConfig.blockWidth*20, top: SizeConfig.blockWidth*1.5, bottom: SizeConfig.blockWidth*1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: SizeConfig.blockHeight*4),
          messageTextGroup,
        ],
      ),
    );
  }
}

// class ReceivedMessage extends StatelessWidget {
//   final bool isSeenByMe;
//   final String message;
//   final String time;
//   final String sendName;
//   final bool imageShow;
//   final bool textShow;
//   final bool audioShow;
//   final Widget? audioWidget;
//   final String imageUrl;
//   const ReceivedMessage({
//     super.key,
//     required this.message,
//     required this.isSeenByMe,
//     required this.time,
//     required this.sendName,
//     required this.imageShow,
//     required this.textShow,
//     required this.audioShow,
//     required this.imageUrl,
//     this.audioWidget,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final messageTextGroup = Flexible(
//         child: Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.rotationX(math.pi),
//           child: CustomPaint(
//             painter: Triangle(COLORS.primaryOne.withOpacity(0.5),),
//           ),
//         ),
//         Flexible(
//           child: Container(
//             padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
//             decoration: BoxDecoration(
//               color: COLORS.primaryOne.withOpacity(0.5),
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(SizeConfig.blockWidth * 3),
//                   topLeft: Radius.circular(SizeConfig.blockWidth * 3),
//                   bottomRight: Radius.circular(SizeConfig.blockWidth * 3),
//                 ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (textShow) ...[
//                   Text(
//                     message,
//                     style: TextStyle(
//                       color: COLORS.neutralDark,
//                       fontSize: SizeConfig.blockWidth * 3.25,
//                       fontWeight: FontWeight.w400,
//                       fontFamily: "Poppins",
//                     ),softWrap: true,
//                   )
//                 ],
//                 if (imageShow) ...[
//                   GestureDetector(
//                     onTap: () => _showImageDialog(context, imageUrl),
//                     child: Container(
//                       width: SizeConfig.blockWidth * 40,
//                       height: SizeConfig.blockWidth * 40,
//                       decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image: NetworkImage(imageUrl), fit: BoxFit.cover),
//                           borderRadius: BorderRadius.all(
//                               Radius.circular(SizeConfig.blockWidth * 3))),
//                     ),
//                   ),
//                   SizedBox(
//                     height: SizeConfig.blockHeight,
//                   )
//                 ],
//                 if (audioShow && audioWidget != null) ...[audioWidget!],
//                 Row(
//
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         capitalizeFirstLetter(sendName),
//                         style: TextStyle(
//                           color: COLORS.neutralDarkOne,
//                           fontSize: SizeConfig.blockWidth * 3,
//                           fontWeight: FontWeight.w400,
//                           fontFamily: "Poppins",
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     SizedBox(width: SizeConfig.blockWidth * 2), // Space between name and time
//                     Text(
//                       time.toUpperCase(),
//                       style: TextStyle(
//                         color: COLORS.neutralDarkOne,
//                         fontSize: SizeConfig.blockWidth * 3,
//                         fontWeight: FontWeight.w400,
//                         fontFamily: "Poppins",
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ));
//
//     return Padding(
//       padding: EdgeInsets.only(right: SizeConfig.blockWidth*20, left: SizeConfig.blockWidth*5, top: SizeConfig.blockWidth*1.5, bottom: SizeConfig.blockWidth*1.5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           SizedBox(height: SizeConfig.blockHeight * 10),
//           messageTextGroup,
//         ],
//       ),
//     );
//   }
// }




class ReceivedMessage extends StatelessWidget {
  final bool isSeenByMe;
  final String message;
  final String time;
  final String sendName;
  final bool imageShow;
  final bool textShow;
  final bool audioShow;
  final Widget? audioWidget;
  final String imageUrl;

  const ReceivedMessage({
    super.key,
    required this.message,
    required this.isSeenByMe,
    required this.time,
    required this.sendName,
    required this.imageShow,
    required this.textShow,
    required this.audioShow,
    required this.imageUrl,
    this.audioWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: SizeConfig.blockWidth * 20,
        left: SizeConfig.blockWidth * 5,
        top: SizeConfig.blockWidth * 1.5,
        bottom: SizeConfig.blockWidth * 1.5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationX(math.pi),
            child: CustomPaint(
              painter: Triangle(COLORS.primaryOne.withOpacity(0.5)),
            ),
          ),


          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: SizeConfig.blockWidth * 70,
            ),
            child: IntrinsicWidth(
              child: Container(
                padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                decoration: BoxDecoration(
                  color: COLORS.primaryOne.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(SizeConfig.blockWidth * 2),
                    topLeft: Radius.circular(SizeConfig.blockWidth * 2),
                    bottomRight: Radius.circular(SizeConfig.blockWidth * 2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message Text
                    if (textShow)
                      Padding(
                        padding:  EdgeInsets.only(bottom:SizeConfig.blockHeight * 0.2),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: COLORS.neutralDark,
                            fontSize: SizeConfig.blockWidth * 3.25,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                          softWrap: true,
                        ),
                      ),


                    if (imageShow)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: GestureDetector(
                          onTap: () => _showImageDialog(context, imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
                            child: Image.network(
                              imageUrl,
                              width: SizeConfig.blockWidth * 40,
                              height: SizeConfig.blockWidth * 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),


                    if (audioShow && audioWidget != null)
                      Padding(
                        padding:  EdgeInsets.only(bottom: SizeConfig.blockHeight * 0.2),
                        child: audioWidget!,
                      ),


                    Padding(
                      padding: EdgeInsets.only(top: SizeConfig.blockWidth * 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              capitalizeFirstLetter(sendName),
                              style: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 2.6,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: SizeConfig.blockWidth*4),
                          Text(
                            time.toUpperCase(),
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 2.6,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


void _showImageDialog(BuildContext context, String imageUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "ImageDialog",
    transitionDuration: const Duration(milliseconds: 100),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: COLORS.white,
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.white, // Background color
                ),
                minScale: PhotoViewComputedScale.contained,
                // maxScale: PhotoViewComputedScale.covered * 2.0, // Zoom settings
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close,
                      color: COLORS.neutralDark,
                      size: SizeConfig.blockWidth * 6.5),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



Widget BlockedChartCards({
  required String image,
  required String name,
  required VoidCallback onPressed,
  required bool isGroup,
}) {
  return Container(
    margin: EdgeInsets.symmetric(
      vertical: SizeConfig.blockHeight * 1,
    ),
    padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
      color: COLORS.primaryOne.withOpacity(0.1),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(image.isNotEmpty)...[
              Container(
                width: SizeConfig.blockWidth * 14,
                height: SizeConfig.blockWidth * 14,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(SizeConfig.blockWidth * 2))),
              ),

            ]
            else...[
              Container(
                width: SizeConfig.blockWidth * 14,
                height: SizeConfig.blockWidth * 14,
                decoration: BoxDecoration(
                    color: COLORS.neutralDarkTwo,
                    borderRadius: BorderRadius.circular(SizeConfig.blockWidth*3)
                ),
                child: Icon(isGroup?Icons.people:Icons.person,color: COLORS.neutralDark,size: SizeConfig.blockWidth*7,),
              )
            ]
            ,
            SizedBox(width: SizeConfig.blockWidth * 3),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: SizeConfig.blockWidth * 30,
                  child: Text(
                    capitalizeEachWord(name),
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.3,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
        customIconButton(
            text: 'UNBLOCK',
            onPressed: onPressed,
            width: SizeConfig.blockWidth * 25,
            height: SizeConfig.blockHeight * 6.25,
            backgroundColor: COLORS.primary,
            textColor: COLORS.white,
            showIcon: false)
      ],
    ),
  );
}
