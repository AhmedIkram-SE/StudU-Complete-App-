import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Panels extends StatefulWidget {
  const Panels(
      {super.key,
      required this.heading,
      required this.icon,
      required this.image});

  final IconData icon;
  final String heading;
  final String image;

  @override
  State<Panels> createState() => _Panels();
}

class _Panels extends State<Panels> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 15,
      surfaceTintColor: Colors.grey,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            alignment: const AlignmentDirectional(0, 0),
            opacity: 0.5,
            image: AssetImage(widget.image),
          ),
          border: const Border.symmetric(
            horizontal: BorderSide.none,
            vertical: BorderSide.none,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        padding: const EdgeInsets.all(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.heading,
              style: GoogleFonts.rajdhani(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(widget.icon),
          ],
        ),
      ),
    );
  }
}
