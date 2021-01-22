library side_header_list_view;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/**
 *  SideHeaderListView for Flutter
 *
 *  Copyright (c) 2017 Rene Floor
 *
 *  Released under BSD License.
 */

typedef bool HasSameHeader(int a, int b);

class SideHeaderListView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder headerBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;
  final HasSameHeader hasSameHeader;
  final double itemExtent;

  SideHeaderListView({
    Key key,
    this.itemCount,
    @required this.itemExtent,
    @required this.headerBuilder,
    @required this.itemBuilder,
    @required this.hasSameHeader,
    this.padding,
  }) : super(key: key);

  @override
  _SideHeaderListViewState createState() => _SideHeaderListViewState();
}

class _SideHeaderListViewState extends State<SideHeaderListView> {
  int currentPosition = 0;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Reposition side view each time the main list view is scrolled
    _controller.addListener(_reposition);
    // In case the initial offset is not 0, we reposition the side view to the
    // correct offset after first build
    // TODO: this produces a flickering effect -- we should try to position it
    // correctly before the first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _reposition());
  }

  @override
  void dispose() {
    _controller?.removeListener(_reposition);
    super.dispose();
  }

  void _reposition() {
    setState(() =>
        currentPosition = (_controller.offset / widget.itemExtent).floor());
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Positioned(
            child: Opacity(
              opacity: _shouldShowHeader(currentPosition) ? 0.0 : 1.0,
              child: widget.headerBuilder(
                  context, currentPosition >= 0 ? currentPosition : 0),
            ),
            top: 0.0 + (widget.padding?.top ?? 0),
            left: 0.0 + (widget.padding?.left ?? 0),
          ),
          ListView.builder(
            padding: widget.padding,
            itemCount: widget.itemCount,
            itemExtent: widget.itemExtent,
            controller: _controller,
            itemBuilder: (BuildContext context, int index) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  child: Opacity(
                    opacity: _shouldShowHeader(index) ? 1.0 : 0.0,
                    child: widget.headerBuilder(context, index),
                  ),
                ),
                Expanded(child: widget.itemBuilder(context, index))
              ],
            ),
          ),
        ],
      );

  bool _shouldShowHeader(int position) =>
      (position < 0) ||
      (position == 0 && currentPosition < 0) ||
      (position != 0 &&
          position != currentPosition &&
          !widget.hasSameHeader(position, position - 1)) ||
      (position != widget.itemCount - 1 &&
          !widget.hasSameHeader(position, position + 1) &&
          position == currentPosition);
}
