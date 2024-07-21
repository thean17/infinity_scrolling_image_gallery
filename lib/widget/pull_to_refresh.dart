import 'dart:math';

import 'package:flutter/material.dart';

class PullToRefresh extends StatefulWidget {
  final Widget child;

  final double triggerThreshold;

  final Function onRefresh;

  final bool disabled;

  const PullToRefresh(
      {super.key,
      required this.child,
      required this.triggerThreshold,
      required this.onRefresh,
      required this.disabled});

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh> {
  double _overscrollAmount = 0.0;

  double _getOverscrollPercentage() {
    return _overscrollAmount / widget.triggerThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (_overscrollAmount > 0 && notification.scrollDelta != null) {
          if (notification.scrollDelta! > 0) {
            _overscrollAmount =
                max(0, _overscrollAmount - notification.scrollDelta!);
            setState(() {});
          }
        }
        return true;
      },
      child: NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            if (_overscrollAmount > widget.triggerThreshold) {
              widget.onRefresh();
            }

            _overscrollAmount = 0;
            setState(() {});

            return true;
          },
          child: NotificationListener<OverscrollNotification>(
            onNotification: (notification) {
              if (widget.disabled) {
                return true;
              }

              if (notification.overscroll < 0) {
                _overscrollAmount += -notification.overscroll;
                setState(() {});
              }

              return true;
            },
            child: Stack(
              children: [
                widget.child,
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  top: min(-48 + _getOverscrollPercentage() * 100, 100),
                  left: 0,
                  right: 0,
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[50],
                          ),
                          child: AnimatedRotation(
                              duration: const Duration(milliseconds: 50),
                              turns: _getOverscrollPercentage() * pi * 0.2,
                              child: const Icon(Icons.refresh_rounded)))),
                ),
              ],
            ),
          )),
    );
  }
}
