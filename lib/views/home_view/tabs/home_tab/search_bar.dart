import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/actions/search_actions.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key key,
    @required FocusNode searchFocusNode,
  })  : _searchFocusNode = searchFocusNode,
        super(key: key);

  final FocusNode _searchFocusNode;

  @override
  SearchBarState createState() {
    return SearchBarState();
  }
}

class SearchBarState extends State<SearchBar> with TickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;
  TextEditingController _searchEditingController;

  bool get isFocused => widget._searchFocusNode.hasFocus;
  Timer _searchDebounceTimer;
  String _lastSearch;

  @override
  void initState() {
    super.initState();
    // Animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    );
    _animation = Tween(begin: 1.0, end: 0.0).animate(curve);
    widget._searchFocusNode.addListener(_onFocusChange);
    // Text Editing
    _searchEditingController = TextEditingController();
    _searchEditingController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Focus Animation
    widget._searchFocusNode.removeListener(_onFocusChange);
    // Text Edit Controller
    _searchEditingController.removeListener(_onSearchChanged);
    _searchEditingController.dispose();
    _controller.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_searchDebounceTimer?.isActive ?? false) _searchDebounceTimer.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_lastSearch == _searchEditingController.text) return;
      _lastSearch = _searchEditingController.text;
      Application.store
          .dispatch(searchQueryAction(_searchEditingController.text));
    });
  }

  void _onFocusChange() {
    if (widget._searchFocusNode.hasFocus ||
        _searchEditingController.value.text.length > 0)
      _controller.forward();
    else
      _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) {
        return Padding(
          padding: EdgeInsets.only(
              top: _animation.value * MediaQuery.of(context).padding.top),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _animation.value * 12,
              vertical: _animation.value * 12,
            ),
            child: PhysicalModel(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(_animation.value * 8),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context)
                    .requestFocus(widget._searchFocusNode),
                child: Material(
                  color: Colors.white.withOpacity(0.25),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: (1 - _animation.value) *
                            MediaQuery.of(context).padding.top),
                    child: Container(
                      height: (1 - _animation.value) * 20 + 38,
                      alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 24),
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(splashColor: Colors.transparent),
                                child: TextField(
                                  controller: _searchEditingController,
                                  cursorColor: Colors.white,
                                  focusNode: widget._searchFocusNode,
                                  decoration: InputDecoration.collapsed(
                                    hintText: 'Search',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            child: IconButton(
                              icon: Icon(
                                Icons.clear,
                              ),
                              onPressed: () => _searchEditingController.clear(),
                            ),
                            duration: Duration(milliseconds: 250),
                            opacity:
                                _searchEditingController.value.text.length > 0
                                    ? 1.0
                                    : 0.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
