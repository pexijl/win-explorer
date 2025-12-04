import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that distinguishes single-tap and double-tap while keeping
/// the single-tap response fast (by using a short delay + cancellation)
///
/// Behavior:
/// - When the user taps once, the [onTap] callback is scheduled to run
///   after [doubleTapDelay] duration.
/// - If a double-tap occurs before that delay, the scheduled single-tap
///   callback is canceled and [onDoubleTap] is invoked instead.
class DoubleTapAwareDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  /// The delay to wait before firing the single tap callback. This should be
  /// slightly longer than the ripple / UI response you want, but shorter than
  /// the platform double-tap recognition threshold if you want snappier UI.
  final Duration doubleTapDelay;

  /// If true, call [onTap] immediately on the first down event and cancel
  /// it if a double tap occurs. This makes UI feel instant, but if [onTap] is
  /// an expensive action (e.g., navigation) you might prefer to use delayed
  /// single-tap via [doubleTapDelay].
  final bool performTapOnDown;

  const DoubleTapAwareDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.doubleTapDelay = const Duration(milliseconds: 250),
    this.performTapOnDown = false,
  });

  @override
  State<DoubleTapAwareDetector> createState() => _DoubleTapAwareDetectorState();
}

class _DoubleTapAwareDetectorState extends State<DoubleTapAwareDetector> {
  Timer? _tapTimer;



  void _scheduleSingleTap() {
    _tapTimer?.cancel();
    _tapTimer = Timer(widget.doubleTapDelay, () {
      // After the delay, treat it as a single tap
      widget.onTap?.call();
      _tapTimer = null;
    });
  }

  void _cancelSingleTap() {
    _tapTimer?.cancel();
    _tapTimer = null;
  }

  @override
  void dispose() {
    _cancelSingleTap();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        if (widget.performTapOnDown) {
          // Immediate single-tap semantics
          widget.onTap?.call();
        } else {
          // Schedule a single-tap; it will be canceled if a double-tap occurs
          _scheduleSingleTap();
        }
      },
      onTapCancel: () {
        // If gesture was canceled (drag, long press), cancel single-tap
        _cancelSingleTap();
      },
      onDoubleTap: () {
        // Double-tap cancels single-tap and triggers double-tap handler
        _cancelSingleTap();
        widget.onDoubleTap?.call();
      },
      child: widget.child,
    );
  }
}
