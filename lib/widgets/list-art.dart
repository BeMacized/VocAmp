import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voc_amp/utils/gradient-utils.dart';

class ListArt extends StatefulWidget {
  final String imageUrl;
  final double size;
  final Color gradientColor;
  final Color textColor;
  final List<String> text;

  ListArt({
    this.imageUrl,
    this.size,
    Color gradientColor,
    Color textColor,
    List<String> text,
  })  : this.gradientColor = gradientColor ?? Colors.white,
        this.textColor = textColor ?? Colors.black.withOpacity(0.8),
        this.text = text ?? [];

  @override
  _ListArtState createState() => _ListArtState();
}

class _ListArtState extends State<ListArt> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            _buildBackgroundImage(),
            _buildGradientOverlay(),
            _buildTextOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextOverlay() {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.text
                .map((line) => AutoSizeText(
                      line,
                      maxLines: 1,
                      minFontSize: 1,
                      stepGranularity: 0.1,
                      style: GoogleFonts.montserrat(
                        fontSize: constraints.maxWidth,
                        fontWeight: FontWeight.bold,
                        textStyle: TextStyle(
                          color: widget.textColor,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      );
    });
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1,
            center: Alignment(-1, 1),
            colors: GradientUtils.curved(
              [
                widget.gradientColor,
                widget.gradientColor.withOpacity(0),
              ],
              curve: Curves.easeOutQuint.flipped,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          color: widget.gradientColor,
          child: CachedNetworkImage(
            useOldImageOnUrlChange: true,
            imageUrl: widget.imageUrl,
            imageBuilder: (BuildContext context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: min(widget.size ?? constraints.maxWidth, 64),
                height: min(widget.size ?? constraints.maxHeight, 64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(widget.textColor),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      }),
    );
  }
}
