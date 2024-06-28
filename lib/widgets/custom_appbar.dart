import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.leftIcon,
    this.leftAppBarTitle,
    this.rightAppBarTitle,
    required this.rightIcon,
    required this.leftOntap,
  });

  final IconData leftIcon;
  final String? leftAppBarTitle;
  final String? rightAppBarTitle;
  final IconData rightIcon;
  final Function leftOntap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              leftOntap();
            },
            child: Icon(
              leftIcon,
              size: 40,
            ),
          ),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                  text: leftAppBarTitle,
                  style: const TextStyle(
                    color: Color(0xff5693BF),
                    fontSize: 30,
                  ),
                ),
                TextSpan(
                    text: rightAppBarTitle,
                    style: const TextStyle(
                      fontSize: 30,
                    )),
              ],
            ),
          ),
          Icon(
            rightIcon,
            size: 40,
          ),
        ],
      ),
    );
  }
}
