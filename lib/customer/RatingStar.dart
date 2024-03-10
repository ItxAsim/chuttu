import 'package:flutter/material.dart';

class RatingStar extends StatefulWidget {
  final int rating;
  final int value;
  final Function(int) onTap;

  const RatingStar({required this.rating, required this.value, required this.onTap});

  @override
  State<RatingStar> createState() => _RatingStarState();
}

class _RatingStarState extends State<RatingStar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IconButton(
        icon: Icon(
          // Use filled star for both exact and higher ratings
          widget.rating >= widget.value ? Icons.star : Icons.star_border,
          color: widget.rating >= widget.value ? Colors.yellow[700] : Colors.grey, // Color for selected and unselected stars
        ),
        onPressed: () => widget.onTap(widget.value),
      ),
    );
  }
}

