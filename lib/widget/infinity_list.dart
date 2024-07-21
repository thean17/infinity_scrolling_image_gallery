import 'dart:async';

import 'package:flutter/material.dart';

class InfinityList extends StatefulWidget {
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final bool loading;
  final Function() load;
  final double triggerLoadThreshold;

  const InfinityList(
      {super.key,
      required this.itemCount,
      required this.itemBuilder,
      required this.load,
      required this.triggerLoadThreshold,
      this.loading = false});

  @override
  State<InfinityList> createState() => _InfinityListState();
}

class _InfinityListState extends State<InfinityList> {
  final _controller = ScrollController();

  bool _debounce = false;

  @override
  void initState() {
    super.initState();

    _registerScrollListener();
  }

  void _registerScrollListener() {
    _controller.addListener(() {
      var nextPageTrigger =
          widget.triggerLoadThreshold * _controller.position.maxScrollExtent;

      if (_controller.position.pixels > nextPageTrigger &&
          !widget.loading &&
          !_debounce) {
        widget.load();

        _debounceScrollHandler();
      }
    });
  }

  void _debounceScrollHandler() {
    _debounce = true;
    setState(() {});

    Timer(const Duration(milliseconds: 250), () {
      _debounce = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: _controller,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: widget.loading
              ? const LinearProgressIndicator(
                  backgroundColor: Colors.black,
                )
              : const SizedBox.shrink(),
        )
      ],
    );
  }
}
