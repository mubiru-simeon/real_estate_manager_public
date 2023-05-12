import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Abstract base class for text animations.
abstract class AnimatedText {
  /// Text for [Text] widget.
  final String text;

  /// [TextAlign] property for [Text] widget.
  ///
  /// By default it is set to [TextAlign.start]
  final TextAlign textAlign;

  /// [TextStyle] property for [Text] widget.
  final TextStyle textStyle;

  /// The Duration for the Animation Controller.
  ///
  /// This will set the total duration for the animated widget.
  /// For example, if you want the text animation to take 3 seconds,
  /// then you have to set [duration] to 3 seconds.
  final Duration duration;

  /// Same as [text] but as [Characters].
  ///
  /// Need to use character length, not String length, to propertly support
  /// Unicode and Emojis.
  final Characters textCharacters;

  AnimatedText({
    @required this.text,
    this.textAlign = TextAlign.start,
    this.textStyle,
    @required this.duration,
  }) : textCharacters = text.characters;

  /// Return the remaining Duration for the Animation (when applicable).
  Duration get remaining => null;

  /// Initialize the Animation.
  void initAnimation(AnimationController controller);

  /// Utility method to create a styled [Text] widget using the [textAlign] and
  /// [textStyle], but you can specify the [data].
  Widget textWidget(String data) => Text(
        data,
        textAlign: textAlign,
        style: textStyle,
      );

  /// Widget showing the complete text (when animation is complete or paused).
  /// By default, it shows a Text widget, but this may be overridden.
  Widget completeText(BuildContext context) => textWidget(text);

  /// Widget showing animated text, based on animation value(s).
  Widget animatedBuilder(BuildContext context, Widget child);
}

/// Base class for Animated Text widgets.
class AnimatedTextKit extends StatefulWidget {
  /// List of [AnimatedText] to display subsequently in the animation.
  final List<AnimatedText> animatedTexts;

  /// Define the [Duration] of the pause between texts
  ///
  /// By default it is set to 1000 milliseconds.
  final Duration pause;

  /// Should the animation ends up early and display full text if you tap on it?
  ///
  /// By default it is set to false.
  final bool displayFullTextOnTap;

  /// If on pause, should a tap remove the remaining pause time ?
  ///
  /// By default it is set to false.
  final bool stopPauseOnTap;

  /// Adds the onTap [VoidCallback] to the animated widget.
  final VoidCallback onTap;

  /// Adds the onFinished [VoidCallback] to the animated widget.
  ///
  /// This method will run only if [isRepeatingAnimation] is set to false.
  final VoidCallback onFinished;

  /// Adds the onNext callback to the animated widget.
  ///
  /// Will be called right before the next text, after the pause parameter
  final void Function(int, bool) onNext;

  /// Adds the onNextBeforePause callback to the animated widget.
  ///
  /// Will be called at the end of n-1 animation, before the pause parameter
  final void Function(int, bool) onNextBeforePause;

  /// Set if the animation should not repeat by changing the value of it to false.
  ///
  /// By default it is set to true.
  final bool isRepeatingAnimation;

  /// Sets if the animation should repeat forever. [isRepeatingAnimation] also
  /// needs to be set to true if you want to repeat forever.
  ///
  /// By default it is set to false, if set to true, [totalRepeatCount] is ignored.
  final bool repeatForever;

  /// Sets the number of times animation should repeat
  ///
  /// By default it is set to 3
  final int totalRepeatCount;

  const AnimatedTextKit({
    Key key,
    @required this.animatedTexts,
    this.pause = const Duration(milliseconds: 1000),
    this.displayFullTextOnTap = false,
    this.stopPauseOnTap = false,
    this.onTap,
    this.onNext,
    this.onNextBeforePause,
    this.onFinished,
    this.isRepeatingAnimation = true,
    this.totalRepeatCount = 3,
    this.repeatForever = false,
  })  : assert(animatedTexts.length > 0),
        assert(!isRepeatingAnimation || totalRepeatCount > 0 || repeatForever),
        assert(null == onFinished || !repeatForever),
        super(key: key);

  /// Creates the mutable state for this widget. See [StatefulWidget.createState].
  @override
  State<AnimatedTextKit> createState() => _AnimatedTextKitState();
}

class _AnimatedTextKitState extends State<AnimatedTextKit>
    with TickerProviderStateMixin {
  AnimationController _controller;

  AnimatedText _currentAnimatedText;

  int _currentRepeatCount = 0;

  int _index = 0;

  bool _isCurrentlyPausing = false;

  Timer _timer;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completeText = _currentAnimatedText.completeText(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: _isCurrentlyPausing || !_controller.isAnimating
          ? completeText
          : AnimatedBuilder(
              animation: _controller,
              builder: _currentAnimatedText.animatedBuilder,
              child: completeText,
            ),
    );
  }

  bool get _isLast => _index == widget.animatedTexts.length - 1;

  void _nextAnimation() {
    final isLast = _isLast;

    _isCurrentlyPausing = false;

    // Handling onNext callback
    widget.onNext?.call(_index, isLast);

    if (isLast) {
      if (widget.isRepeatingAnimation &&
          (widget.repeatForever ||
              _currentRepeatCount != (widget.totalRepeatCount - 1))) {
        _index = 0;
        if (!widget.repeatForever) {
          _currentRepeatCount++;
        }
      } else {
        widget.onFinished?.call();
        return;
      }
    } else {
      _index++;
    }

    if (mounted) setState(() {});

    _controller.dispose();

    // Re-initialize animation
    _initAnimation();
  }

  void _initAnimation() {
    _currentAnimatedText = widget.animatedTexts[_index];

    _controller = AnimationController(
      duration: _currentAnimatedText.duration,
      vsync: this,
    );

    _currentAnimatedText.initAnimation(_controller);

    _controller
      ..addStatusListener(_animationEndCallback)
      ..forward();
  }

  void _setPause() {
    final isLast = _isLast;

    _isCurrentlyPausing = true;
    if (mounted) setState(() {});

    // Handle onNextBeforePause callback
    widget.onNextBeforePause?.call(_index, isLast);
  }

  void _animationEndCallback(AnimationStatus state) {
    if (state == AnimationStatus.completed) {
      _setPause();
      assert(null == _timer || !_timer.isActive);
      _timer = Timer(widget.pause, _nextAnimation);
    }
  }

  void _onTap() {
    if (widget.displayFullTextOnTap) {
      if (_isCurrentlyPausing) {
        if (widget.stopPauseOnTap) {
          _timer?.cancel();
          _nextAnimation();
        }
      } else {
        final left =
            (_currentAnimatedText.remaining ?? _currentAnimatedText.duration)
                .inMilliseconds;

        _controller.stop();

        _setPause();

        assert(null == _timer || !_timer.isActive);
        _timer = Timer(
          Duration(
            milliseconds: max(
              widget.pause.inMilliseconds,
              left,
            ),
          ),
          _nextAnimation,
        );
      }
    }

    widget.onTap?.call();
  }
}



/// Animated Text that shows text shimmering between [colors].
///
/// ![Colorize example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/colorize.gif)
class ColorizeAnimatedText extends AnimatedText {
  /// The [Duration] of the delay between the apparition of each characters
  ///
  /// By default it is set to 200 milliseconds.
  final Duration speed;

  /// Set the colors for the gradient animation of the text.
  ///
  /// The [List] should contain at least two values of [Color] in it.
  final List<Color> colors;

  /// Specifies the [TextDirection] for animation direction.
  ///
  /// By default it is set to [TextDirection.ltr]
  final TextDirection textDirection;

  ColorizeAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    @required TextStyle textStyle,
    this.speed = const Duration(milliseconds: 200),
    @required this.colors,
    this.textDirection = TextDirection.ltr,
  })  : assert(null != textStyle.fontSize),
        assert(colors.length > 1),
        super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: speed * text.characters.length,
        );

  Animation<double> _colorShifter, _fadeIn, _fadeOut;
  // Copy of colors that may be reversed when RTL.
  List<Color> _colors;

  @override
  void initAnimation(AnimationController controller) {
    // Note: This calculation is the only reason why [textStyle] is required
    final tuning = (300.0 * colors.length) *
        (textStyle.fontSize / 24.0) *
        0.75 *
        (textCharacters.length / 15.0);

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
      ),
    );

    final colorShift = colors.length * tuning;
    final colorTween = textDirection == TextDirection.ltr
        ? Tween<double>(
            begin: 0.0,
            end: colorShift,
          )
        : Tween<double>(
            begin: colorShift,
            end: 0.0,
          );
    _colorShifter = colorTween.animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    // With RTL, colors need to be reversed to compensate for colorTween
    // counting down instead of up.
    _colors = textDirection == TextDirection.ltr
        ? colors
        : colors.reversed.toList(growable: false);
  }

  @override
  Widget completeText(BuildContext context) {
    final linearGradient = LinearGradient(colors: _colors).createShader(
      Rect.fromLTWH(0.0, 0.0, _colorShifter.value, 0.0),
    );

    return DefaultTextStyle.merge(
      style: textStyle,
      child: Text(
        text,
        style: TextStyle(foreground: Paint()..shader = linearGradient),
        textAlign: textAlign,
      ),
    );
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    return Opacity(
      opacity: _fadeIn.value != 1.0 ? _fadeIn.value : _fadeOut.value,
      child: completeText(context),
    );
  }
}

/// Animation that displays [text] elements, shimmering transition between [colors].
///
/// ![Colorize example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/colorize.gif)
@Deprecated('Use AnimatedTextKit with ColorizeAnimatedText instead.')
class ColorizeAnimatedTextKit extends AnimatedTextKit {
  ColorizeAnimatedTextKit({
    Key key,
    @required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
    @required TextStyle textStyle,
    @required List<Color> colors,
    Duration speed = const Duration(milliseconds: 200),
    Duration pause = const Duration(milliseconds: 1000),
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    int totalRepeatCount = 3,
    bool repeatForever = false,
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
  }) : super(
          key: key,
          animatedTexts: _animatedTexts(
            text,
            textAlign,
            textStyle,
            speed,
            colors,
            textDirection,
          ),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          totalRepeatCount: totalRepeatCount,
          repeatForever: repeatForever,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration speed,
    List<Color> colors,
    TextDirection textDirection,
  ) =>
      text
          .map((_) => ColorizeAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                speed: speed,
                colors: colors,
                textDirection: textDirection,
              ))
          .toList();
}


/// Animated Text that displays a [Text] element, fading it in and then out.
///
/// ![Fade example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/fade.gif)
class FadeAnimatedText extends AnimatedText {
  /// Marks ending of fade-in interval, default value = 0.5
  final double fadeInEnd;

  /// Marks the beginning of fade-out interval, default value = 0.8
  final double fadeOutBegin;
  FadeAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    Duration duration = const Duration(milliseconds: 2000),
    this.fadeInEnd = 0.5,
    this.fadeOutBegin = 0.8,
  })  : assert(fadeInEnd < fadeOutBegin,
            'The "fadeInEnd" argument must be less than "fadeOutBegin"'),
        super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: duration,
        );

   Animation<double> _fadeIn, _fadeOut;

  @override
  void initAnimation(AnimationController controller) {
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, fadeInEnd, curve: Curves.linear),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(fadeOutBegin, 1.0, curve: Curves.linear),
      ),
    );
  }

  @override
  Widget completeText(BuildContext context) => SizedBox.shrink();

  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    return Opacity(
      opacity: _fadeIn.value != 1.0 ? _fadeIn.value : _fadeOut.value,
      child: textWidget(text),
    );
  }
}

/// Animation that displays [text] elements, fading them in and then out.
///
/// ![Fade example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/fade.gif)
@Deprecated('Use AnimatedTextKit with FadeAnimatedText instead.')
class FadeAnimatedTextKit extends AnimatedTextKit {
  FadeAnimatedTextKit({
    Key key,
    @required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    Duration duration = const Duration(milliseconds: 2000),
    Duration pause = const Duration(milliseconds: 500),
    double fadeInEnd = 0.5,
    double fadeOutBegin = 0.8,
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    int totalRepeatCount = 3,
    bool repeatForever = false,
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
  }) : super(
          key: key,
          animatedTexts: _animatedTexts(
              text, textAlign, textStyle, duration, fadeInEnd, fadeOutBegin),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          totalRepeatCount: totalRepeatCount,
          repeatForever: repeatForever,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration duration,
    double fadeInEnd,
    double fadeOutBegin,
  ) =>
      text
          .map((_) => FadeAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                duration: duration,
                fadeInEnd: fadeInEnd,
                fadeOutBegin: fadeOutBegin,
              ))
          .toList();
}

/// Animated Text that displays a [Text] element, as a flickering glow text.
///
/// ![Flicker example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/flicker.gif)
class FlickerAnimatedText extends AnimatedText {
  /// Marks ending of flickering entry interval of text
  final double entryEnd;
  final Duration speed;

  FlickerAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    this.speed = const Duration(milliseconds: 1600),
    this.entryEnd = 0.5,
  }) : super(
          text: text,
          textStyle: textStyle,
          duration: speed,
        );

  Animation<double> _entry;

  @override
  void initAnimation(AnimationController controller) {
    _entry = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, entryEnd, curve: Curves.bounceIn),
      ),
    );
  }

  @override
  Widget completeText(BuildContext context) => SizedBox.shrink();

  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    return Opacity(
      opacity: _entry.value != 1.0 ? _entry.value : _entry.value,
      child: textWidget(text),
    );
  }
}

@Deprecated('Use AnimatedTextKit with FlickerAnimatedText instead.')
class FlickerAnimatedTextKit extends AnimatedTextKit {
  FlickerAnimatedTextKit({
    Key key,
    @required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    TextDirection textDirection = TextDirection.ltr,
    Duration speed = const Duration(milliseconds: 1600),
    double entryEnd = 0.5,
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    int totalRepeatCount = 3,
    bool repeatForever = false,
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
  }) : super(
          key: key,
          animatedTexts:
              _animatedTexts(text, textAlign, textStyle, speed, entryEnd),
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          totalRepeatCount: totalRepeatCount,
          repeatForever: repeatForever,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration speed,
    double entryEnd,
  ) =>
      text
          .map((_) => FlickerAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                speed: speed,
                entryEnd: entryEnd,
              ))
          .toList();
}


/// Animation that displays a [text] element, coloring it to look like sloshing
/// water is filling it up.
///
/// ![TextLiquidFill example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/text_liquid_fill.gif)
class TextLiquidFill extends StatefulWidget {
  /// Gives [TextStyle] to the text string.
  ///
  /// By default it is `TextStyle(fontSize: 140, fontWeight: FontWeight.bold)`
  final TextStyle textStyle;

  /// Gives [TextAlign] to the text string.
  ///
  /// By default it is [TextAlign.left].
  final TextAlign textAlign;

  /// Specifies the duration the text should fill with liquid.
  ///
  /// By default it is set to 6 seconds.
  final Duration loadDuration;

  /// Specifies the duration that one wave takes to pass the screen.
  ///
  /// By default it is set to 2 seconds.
  final Duration waveDuration;

  /// Specifies the height of the box around text
  ///
  /// By default it is set to 250
  final double boxHeight;

  /// Specifies the width of the box around text
  ///
  /// By default it is set to 400
  final double boxWidth;

  /// String which would be filled by liquid animation
  final String text;

  /// Specifies the backgroundColor of the box
  ///
  /// By default it is set to black color
  final Color boxBackgroundColor;

  /// Specifies the color of the wave
  ///
  /// By default it is set to blueAccent color
  final Color waveColor;

  /// Specifies the load limit: (0, 1.0].  This may be used to limit the liquid
  /// fill effect to less than 100%.
  ///
  /// By default, the animation will load to 1.0 (100%).
  final double loadUntil;

  TextLiquidFill({
    Key key,
    @required this.text,
    this.textStyle =
        const TextStyle(fontSize: 140, fontWeight: FontWeight.bold),
    this.textAlign = TextAlign.left,
    this.loadDuration = const Duration(seconds: 6),
    this.waveDuration = const Duration(seconds: 2),
    this.boxHeight = 250,
    this.boxWidth = 400,
    this.boxBackgroundColor = Colors.black,
    this.waveColor = Colors.blueAccent,
    this.loadUntil = 1.0,
  })  : assert(loadUntil > 0 && loadUntil <= 1.0),
        super(key: key);

  /// Creates the mutable state for this widget. See [StatefulWidget.createState].
  @override
  State<TextLiquidFill> createState() => _TextLiquidFillState();
}

class _TextLiquidFillState extends State<TextLiquidFill>
    with TickerProviderStateMixin {
  final _textKey = GlobalKey();

  AnimationController _waveController, _loadController;

  Animation<double> _loadValue;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: widget.waveDuration,
    );

    _loadController = AnimationController(
      vsync: this,
      duration: widget.loadDuration,
    );
    _loadValue = Tween<double>(
      begin: 0.0,
      end: widget.loadUntil,
    ).animate(_loadController);
    if (1.0 == widget.loadUntil) {
      _loadValue.addStatusListener((status) {
        if (AnimationStatus.completed == status) {
          // Stop the repeating wave when the load has completed to 100%
          _waveController.stop();
        }
      });
    }

    _waveController.repeat();
    _loadController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: widget.boxHeight,
          width: widget.boxWidth,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (BuildContext context, Widget child) {
              return CustomPaint(
                painter: _WavePainter(
                  textKey: _textKey,
                  waveValue: _waveController.value,
                  loadValue: _loadValue.value,
                  boxHeight: widget.boxHeight,
                  waveColor: widget.waveColor,
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: widget.boxHeight,
          width: widget.boxWidth,
          child: ShaderMask(
            blendMode: BlendMode.srcOut,
            shaderCallback: (bounds) => LinearGradient(
              colors: [widget.boxBackgroundColor],
              stops: [0.0],
            ).createShader(bounds),
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Text(
                  widget.text,
                  key: _textKey,
                  style: widget.textStyle,
                  textAlign: widget.textAlign,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  static const _pi2 = 2 * pi;
  final GlobalKey textKey;
  final double waveValue;
  final double loadValue;
  final double boxHeight;
  final Color waveColor;

  _WavePainter({
    @required this.textKey,
    @required this.waveValue,
    @required this.loadValue,
    @required this.boxHeight,
    @required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox textBox =
        textKey.currentContext.findRenderObject() as RenderBox;
    if (textBox == null) return;
    final textHeight = textBox.size.height;
    final baseHeight =
        (boxHeight / 2) + (textHeight / 2) - (loadValue * textHeight);

    final width = size.width;
    final height = size.height;
    final path = Path();
    path.moveTo(0.0, baseHeight);
    for (var i = 0.0; i < width; i++) {
      path.lineTo(i, baseHeight + sin(_pi2 * (i / width + waveValue)) * 8);
    }

    path.lineTo(width, height);
    path.lineTo(0.0, height);
    path.close();
    final wavePaint = Paint()..color = waveColor;
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


/// Animated Text that rotates a [Text] in and then out.
///
/// ![Rotate example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/rotate.gif)
class RotateAnimatedText extends AnimatedText {
  /// Transition height.
  ///
  /// By default it is set to [TextStyle.fontSize] * 10 / 3.
  final double transitionHeight;

  /// Adds [AlignmentGeometry] property to the text in the widget.
  ///
  /// By default it is set to [Alignment.center]
  final AlignmentGeometry alignment;

  /// Specifies the [TextDirection] for resolving alignment.
  ///
  /// By default it is set to [TextDirection.ltr]
  final TextDirection textDirection;

  /// Controls whether the text:
  /// * rotates in _and_ out (true), or
  /// * just rotates _in_ (false).
  ///
  /// Note that you may want to adjust the [duration] when mixing
  /// [RotateAnimatedText] instances with mixed [rotateOut] values.
  ///
  /// By default, it is set to true.
  final bool rotateOut;

  RotateAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    Duration duration = const Duration(milliseconds: 2000),
    this.transitionHeight,
    this.alignment = Alignment.center,
    this.textDirection = TextDirection.ltr,
    this.rotateOut = true,
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: duration,
        );

   Animation<double> _fadeIn, _fadeOut;
   Animation<Alignment> _slideIn, _slideOut;

  @override
  void initAnimation(AnimationController controller) {
    final direction = textDirection;

    final inIntervalEnd = rotateOut ? 0.4 : 1.0;

    _slideIn = AlignmentTween(
      begin: Alignment.topCenter.add(alignment).resolve(direction),
      end: Alignment.center.add(alignment).resolve(direction),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, inIntervalEnd, curve: Curves.linear),
      ),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, inIntervalEnd, curve: Curves.easeOut),
      ),
    );

    if (rotateOut) {
      _slideOut = AlignmentTween(
        begin: Alignment.center.add(alignment).resolve(direction),
        end: Alignment.bottomCenter.add(alignment).resolve(direction),
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.7, 1.0, curve: Curves.linear),
        ),
      );

      _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
        ),
      );
    }
  }

  @override
  Widget completeText(BuildContext context) =>
      rotateOut ? SizedBox.shrink() : super.completeText(context);

  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    final fontSize =
        textStyle?.fontSize ?? DefaultTextStyle.of(context).style.fontSize;

    return SizedBox(
      height: transitionHeight ?? (fontSize * 10 / 3),
      child: AlignTransition(
        alignment: _slideIn.value.y != 0.0 || !rotateOut ? _slideIn : _slideOut,
        child: Opacity(
          opacity: _fadeIn.value != 1.0 || !rotateOut
              ? _fadeIn.value
              : _fadeOut.value,
          child: textWidget(text),
        ),
      ),
    );
  }
}

/// Animation that displays [text] elements, rotating them in one at a time.
///
/// ![Rotate example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/rotate.gif)
@Deprecated('Use AnimatedTextKit with RotateAnimatedText instead.')
class RotateAnimatedTextKit extends AnimatedTextKit {
  RotateAnimatedTextKit({
    Key key,
   @ required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    double transitionHeight,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection textDirection = TextDirection.ltr,
    Duration duration = const Duration(milliseconds: 2000),
    Duration pause = const Duration(milliseconds: 500),
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    int totalRepeatCount = 3,
    bool repeatForever = false,
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
  }) : super(
          key: key,
          animatedTexts: _animatedTexts(
            text,
            textAlign,
            textStyle,
            duration,
            transitionHeight,
            alignment,
            textDirection,
          ),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          totalRepeatCount: totalRepeatCount,
          repeatForever: repeatForever,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration duration,
    double transitionHeight,
    AlignmentGeometry alignment,
    TextDirection textDirection,
  ) =>
      text
          .map((_) => RotateAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                duration: duration,
                transitionHeight: transitionHeight,
                alignment: alignment,
                textDirection: textDirection,
              ))
          .toList();
}


/// Animated Text that displays a [Text] element, scaling them up and then out.
///
/// ![Scale example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/scale.gif)
class ScaleAnimatedText extends AnimatedText {
  /// Set the scaling factor of the text for the animation.
  ///
  /// By default it is set to [double] value 0.5
  final double scalingFactor;

  ScaleAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    Duration duration = const Duration(milliseconds: 2000),
    this.scalingFactor = 0.5,
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: duration,
        );

   Animation<double> _fadeIn, _fadeOut, _scaleIn, _scaleOut;

  @override
  void initAnimation(AnimationController controller) {
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleIn = Tween<double>(begin: scalingFactor, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _scaleOut = Tween<double>(begin: 1.0, end: scalingFactor).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  Widget completeText(BuildContext context) => SizedBox.shrink();

  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    return ScaleTransition(
      scale: _scaleIn.value != 1.0 ? _scaleIn : _scaleOut,
      child: Opacity(
        opacity: _fadeIn.value != 1.0 ? _fadeIn.value : _fadeOut.value,
        child: textWidget(text),
      ),
    );
  }
}

/// Animation that displays [text] elements, scaling them up and then out, one at a time.
///
/// ![Scale example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/scale.gif)
@Deprecated('Use AnimatedTextKit with ScaleAnimatedText instead.')
class ScaleAnimatedTextKit extends AnimatedTextKit {
  ScaleAnimatedTextKit({
    Key key,
    @required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    double scalingFactor = 0.5,
    Duration duration = const Duration(milliseconds: 2000),
    Duration pause = const Duration(milliseconds: 500),
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    int totalRepeatCount = 3,
    bool repeatForever = false,
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
  }) : super(
          key: key,
          animatedTexts: _animatedTexts(
            text,
            textAlign,
            textStyle,
            duration,
            scalingFactor,
          ),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          totalRepeatCount: totalRepeatCount,
          repeatForever: repeatForever,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration duration,
    double scalingFactor,
  ) =>
      text
          .map((_) => ScaleAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                duration: duration,
                scalingFactor: scalingFactor,
              ))
          .toList();
}


/// Animated Text that displays a [Text] element as if it is being typed one
/// character at a time. Similar to [TyperAnimatedText], but shows a cursor.
///
/// ![Typewriter example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/typewriter.gif)
class TypewriterAnimatedText extends AnimatedText {
  // The text length is padded to cause extra cursor blinking after typing.
  static const extraLengthForBlinks = 8;

  /// The [Duration] of the delay between the apparition of each characters
  ///
  /// By default it is set to 30 milliseconds.
  final Duration speed;

  /// The [Curve] of the rate of change of animation over time.
  ///
  /// By default it is set to Curves.linear.
  final Curve curve;

  /// Cursor text. Defaults to underscore.
  final String cursor;

  TypewriterAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    this.speed = const Duration(milliseconds: 30),
    this.curve = Curves.linear,
    this.cursor = '_',
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: speed * (text.characters.length + extraLengthForBlinks),
        );

  Animation<double> _typewriterText;

  @override
  Duration get remaining =>
      speed *
      (textCharacters.length + extraLengthForBlinks - _typewriterText.value);

  @override
  void initAnimation(AnimationController controller) {
    _typewriterText = CurveTween(
      curve: curve,
    ).animate(controller);
  }

  @override
  Widget completeText(BuildContext context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(text: text),
            TextSpan(
              text: cursor,
              style: const TextStyle(color: Colors.transparent),
            )
          ],
          style: DefaultTextStyle.of(context).style.merge(textStyle),
        ),
        textAlign: textAlign,
      );

  /// Widget showing partial text
  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    /// Output of CurveTween is in the range [0, 1] for majority of the curves.
    /// It is converted to [0, textCharacters.length + extraLengthForBlinks].
    final textLen = textCharacters.length;
    final typewriterValue = (_typewriterText.value.clamp(0, 1) *
            (textCharacters.length + extraLengthForBlinks))
        .round();

    var showCursor = true;
    var visibleString = text;
    if (typewriterValue == 0) {
      visibleString = '';
      showCursor = false;
    } else if (typewriterValue > textLen) {
      showCursor = (typewriterValue - textLen) % 2 == 0;
    } else {
      visibleString = textCharacters.take(typewriterValue).toString();
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: visibleString),
          TextSpan(
            text: cursor,
            style:
                showCursor ? null : const TextStyle(color: Colors.transparent),
          )
        ],
        style: DefaultTextStyle.of(context).style.merge(textStyle),
      ),
      textAlign: textAlign,
    );
  }
}

/// Animation that displays [text] elements, as if they are being typed one
/// character at a time. Similar to [TyperAnimatedTextKit], but shows a cursor.
///
/// ![Typewriter example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/typewriter.gif)
@Deprecated('Use AnimatedTextKit with TypewriterAnimatedText instead.')
class TypewriterAnimatedTextKit extends AnimatedTextKit {
  TypewriterAnimatedTextKit({
    Key key,
    @required List<String> text,
    TextAlign textAlign = TextAlign.start,
    @required TextStyle textStyle,
    Duration speed = const Duration(milliseconds: 30),
    Duration pause = const Duration(milliseconds: 1000),
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    bool repeatForever = true,
    int totalRepeatCount = 3,
    Curve curve = Curves.linear,
  }) : super(
          key: key,
          animatedTexts:
              _animatedTexts(text, textAlign, textStyle, speed, curve),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          repeatForever: repeatForever,
          totalRepeatCount: totalRepeatCount,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration speed,
    Curve curve,
  ) =>
      text
          .map((_) => TypewriterAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                speed: speed,
                curve: curve,
              ))
          .toList();
}


/// Animated Text that displays a [Text] element with each character popping
/// like a stadium wave.
///
/// ![Wavy example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/wavy.gif)
class WavyAnimatedText extends AnimatedText {
  /// The [Duration] of the motion of each character
  ///
  /// By default it is set to 300 milliseconds.
  final Duration speed;

  WavyAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    this.speed = const Duration(milliseconds: 300),
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: speed * text.characters.length,
        );

  Animation<double> _waveAnim;

  @override
  void initAnimation(AnimationController controller) {
    _waveAnim = Tween<double>(begin: 0, end: textCharacters.length / 2 + 0.52)
        .animate(controller);
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _WTextPainter(
          progress: _waveAnim.value,
          text: text,
          textStyle: defaultTextStyle.merge(textStyle),
          scaleFactor: scaleFactor,
        ),
        child: Text(
          text,
          style: defaultTextStyle
              .merge(textStyle)
              .merge(TextStyle(color: Colors.transparent)),
          textScaleFactor: scaleFactor,
        ),
      ),
    );
  }
}

/// Animation that displays [text] elements, with each text animated with its
/// characters popping like a stadium wave.
///
/// ![Wavy example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/wavy.gif)
@Deprecated('Use AnimatedTextKit with WavyAnimatedText instead.')
class WavyAnimatedTextKit extends AnimatedTextKit {
  WavyAnimatedTextKit({
    Key key,
    @required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    Duration speed = const Duration(milliseconds: 300),
    Duration pause = const Duration(milliseconds: 1000),
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    int totalRepeatCount = 3,
    bool repeatForever = true,
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
  }) : super(
          key: key,
          animatedTexts: _animatedTexts(text, textAlign, textStyle, speed),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          totalRepeatCount: totalRepeatCount,
          repeatForever: repeatForever,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration speed,
  ) =>
      text
          .map((_) => WavyAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                speed: speed,
              ))
          .toList();
}

class _WTextPainter extends CustomPainter {
  _WTextPainter({
    @required this.progress,
    @required this.text,
    @required this.textStyle,
    @required this.scaleFactor,
  });

  final double progress, scaleFactor;
  final String text;
  // Private class to store text information
  final _textLayoutInfo = <_TextLayoutInfo>[];
  final TextStyle textStyle;
  @override
  void paint(Canvas canvas, Size size) {
    if (_textLayoutInfo.isEmpty) {
      // calculate the initial position of each char
      calculateLayoutInfo(text, _textLayoutInfo);
    }
    canvas.save();

    for (var textLayout in _textLayoutInfo) {
      // offset required to center the characters
      final centerOffset =
          Offset(size.width / 2, (size.height / 2 - textLayout.height / 2));

      if (textLayout.isMoving) {
        final p = math.min(progress * 2, 1.0);
        // drawing the char if the text is moving
        drawText(
            canvas,
            textLayout.text,
            Offset(
                  textLayout.offsetX,
                  (textLayout.offsetY -
                      (textLayout.offsetY - textLayout.riseHeight) * p),
                ) +
                centerOffset,
            textLayout);
      } else {
        // drawing the char if text is not moving
        drawText(
          canvas,
          textLayout.text,
          Offset(textLayout.offsetX, textLayout.offsetY) + centerOffset,
          textLayout,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WTextPainter oldDelegate) {
    if (oldDelegate.progress != progress) {
      // calulate layout of text and movement of moving chars
      calculateLayoutInfo(text, _textLayoutInfo);
      calculateMove();
      return true;
    }
    return false;
  }

  void calculateMove() {
    final height = _textLayoutInfo[0].height;
    final txtInMoInd = progress.floor();
    final percent = progress - txtInMoInd;
    final txtInMoOdd = (progress - .5).floor();
    final txtInMoEven = txtInMoInd * 2;

    // Calculating movement of the char at odd place
    if (txtInMoOdd < (text.length - 1) / 2 && !txtInMoOdd.isNegative) {
      _textLayoutInfo[txtInMoOdd + (txtInMoOdd + 1)].isMoving = true;
      // percent < .5 creates an phase difference between odd and even chars
      _textLayoutInfo[txtInMoOdd + (txtInMoOdd + 1)].riseHeight = progress < .5
          ? 0
          : -1.3 * height * math.sin((progress - .5) * math.pi).abs();
    }

    // Calculating movement of the char at even place
    if (txtInMoEven < text.length) {
      _textLayoutInfo[txtInMoEven].isMoving = true;
      _textLayoutInfo[txtInMoEven].riseHeight =
          -1.3 * height * math.sin(percent * math.pi);
    }
  }

  void drawText(Canvas canvas, String text, Offset offset,
      _TextLayoutInfo textLayoutInfo) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: scaleFactor,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textLayoutInfo.width / 2,
        offset.dy + (textLayoutInfo.height - textPainter.height) / 2,
      ),
    );
  }

  void calculateLayoutInfo(String text, List<_TextLayoutInfo> list) {
    list.clear();

    // creating a textPainter to get data about location and offset for chars
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textScaleFactor: scaleFactor,
    );

    textPainter.layout();
    for (var i = 0; i < text.length; i++) {
      var forCaret = textPainter.getOffsetForCaret(
        TextPosition(offset: i),
        Rect.zero,
      );
      var offsetX = forCaret.dx;
      if (i > 0 && offsetX == 0) {
        break;
      }

      // creating layout for each char
      final textLayoutInfo = _TextLayoutInfo(
        text: text[i],
        offsetX: offsetX,
        offsetY: forCaret.dy,
        width: textPainter.width,
        height: textPainter.height,
        baseline: textPainter
            .computeDistanceToActualBaseline(TextBaseline.ideographic),
      );

      list.add(textLayoutInfo);
    }
  }
}


/// Animated Text that displays a [Text] element as if it is being typed one
/// character at a time.
///
/// ![Typer example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/typer.gif)
class TyperAnimatedText extends AnimatedText {
  /// The [Duration] of the delay between the apparition of each characters
  ///
  /// By default it is set to 40 milliseconds.
  final Duration speed;

  /// The [Curve] of the rate of change of animation over time.
  ///
  /// By default it is set to Curves.linear.
  final Curve curve;

  TyperAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    this.speed = const Duration(milliseconds: 40),
    this.curve = Curves.linear,
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: speed * text.characters.length,
        );

   Animation<double> _typingText;

  @override
  Duration get remaining => speed * (textCharacters.length - _typingText.value);

  @override
  void initAnimation(AnimationController controller) {
    _typingText = CurveTween(
      curve: curve,
    ).animate(controller);
  }

  /// Widget showing partial text, up to [count] characters
  @override
  Widget animatedBuilder(BuildContext context, Widget child) {
    /// Output of CurveTween is in the range [0, 1] for majority of the curves.
    /// It is converted to [0, textCharacters.length].
    final count =
        (_typingText.value.clamp(0, 1) * textCharacters.length).round();

    assert(count <= textCharacters.length);
    return textWidget(textCharacters.take(count).toString());
  }
}

/// Animation that displays [text] elements, as if they are being typed one
/// character at a time.
///
/// ![Typer example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/typer.gif)
@Deprecated('Use AnimatedTextKit with TyperAnimatedText instead.')
class TyperAnimatedTextKit extends AnimatedTextKit {
  TyperAnimatedTextKit({
    Key key,
    @required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextStyle textStyle,
    Duration speed = const Duration(milliseconds: 40),
    Duration pause = const Duration(milliseconds: 1000),
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
    VoidCallback onTap,
    void Function(int, bool) onNext,
    void Function(int, bool) onNextBeforePause,
    VoidCallback onFinished,
    bool isRepeatingAnimation = true,
    bool repeatForever = true,
    int totalRepeatCount = 3,
    Curve curve = Curves.linear,
  }) : super(
          key: key,
          animatedTexts:
              _animatedTexts(text, textAlign, textStyle, speed, curve),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          repeatForever: repeatForever,
          totalRepeatCount: totalRepeatCount,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration speed,
    Curve curve,
  ) =>
      text
          .map((_) => TyperAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                speed: speed,
                curve: curve,
              ))
          .toList();
}

class _TextLayoutInfo {
  final String text;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  final double baseline;
  double riseHeight;
  bool isMoving = false;

  _TextLayoutInfo({
    @required this.text,
    @required this.offsetX,
    @required this.offsetY,
    @required this.width,
    @required this.height,
    @required this.baseline,
  });
}