import 'package:aer/UI/utils/constant.dart';
import 'package:flutter/material.dart';

typedef AnimationCompleteCallback = void Function(bool value);

typedef OnClickButtonCallback = void Function(String value);

class SearchButton extends StatefulWidget {
  final bool searchExpanded;
  final AnimationCompleteCallback? animFinishedCallback;
  final AnimationCompleteCallback? onClickedCallback;
  final OnClickButtonCallback? onSubmitCallback;
  final bool autoFocus;

  const SearchButton(
      {super.key,
      required this.searchExpanded,
      this.animFinishedCallback,
      this.onClickedCallback,
      this.onSubmitCallback,
      this.autoFocus = true});

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> with AutomaticKeepAliveClientMixin {
  final FocusNode _focusNode = FocusNode();
  final _searchTextController = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Flexible(
      fit: FlexFit.loose,
      child: GestureDetector(
        onTap: () {
          widget.onClickedCallback!(true);
          if (widget.searchExpanded) {
            _focusNode.requestFocus();
          }
        },
        child: AnimatedContainer(
          width: !widget.searchExpanded ? 50 : MediaQuery.of(context).size.width * 0.9,
          height: 48,
          duration: const Duration(milliseconds: 10),
          padding: EdgeInsets.symmetric(
              horizontal: !widget.searchExpanded ? 16.0 : 0.0, vertical: !widget.searchExpanded ? 4.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(48.0),
          ),
          onEnd: () {
            widget.animFinishedCallback!(widget.searchExpanded);
            if (widget.searchExpanded) {
              _focusNode.requestFocus();
            }
          },
          child: widget.searchExpanded
              ? TextFormField(
                  controller: _searchTextController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 2.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    prefixIcon: GestureDetector(
                      onTap: () {
                        widget.onClickedCallback!(false);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _onButtonPress();
                      },
                      child: const Icon(
                        Icons.search_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.grey.shade900,
                  cursorWidth: 1.0,
                  cursorRadius: const Radius.circular(50.0),
                  onFieldSubmitted: (value) {
                    _onButtonPress();
                  },
                  onTapOutside: (event) {
                    widget.onClickedCallback!(false);
                  },
                )
              : const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                ),
        ),
      ),
    );
  }

  _onButtonPress() {
    widget.onSubmitCallback!(_searchTextController.text);
    widget.onClickedCallback!(false);
  }

  @override
  bool get wantKeepAlive => true;
}
