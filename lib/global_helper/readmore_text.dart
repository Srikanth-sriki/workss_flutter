import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/colors.dart';

import '../components/size_config.dart';

class ReadMoreText extends StatefulWidget {
  final String text;
  final int trimLength;

  const ReadMoreText({
    Key? key,
    required this.text,
    this.trimLength = 120,  // Default trim length
  }) : super(key: key);

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final displayText = isExpanded ? text : (text.length > widget.trimLength ? '${text.substring(0, widget.trimLength)}...' : text);

    return RichText(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: COLORS.neutralDark,
          fontSize: SizeConfig.blockWidth * 3.9,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
        ),
        children: [
          if (text.length > widget.trimLength)
            TextSpan(
              text: isExpanded ? ' Read less' : ' Read more',
              style: TextStyle(
                color: COLORS.accent,
                fontSize: SizeConfig.blockWidth * 3.9,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
            ),
        ],
      ),
    );
  }
}
