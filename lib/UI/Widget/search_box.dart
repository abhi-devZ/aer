import 'package:aer/UI/utils/constant.dart';
import 'package:aer/helper/url_helper.dart';
import 'package:flutter/material.dart';

import 'gradient_shadow_container.dart';

typedef OnSubmitCallback = void Function(String value);

class SearchBox extends StatefulWidget {
  final bool isLoading;
  final String searchTerm;
  final OnSubmitCallback? onSubmitTextField;

  const SearchBox({
    super.key,
    required this.searchTerm,
    this.isLoading = false,
    this.onSubmitTextField,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    _controller.text = DomainHelper.extractBaseDomain(widget.searchTerm);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AdvancedGradientShadowContainer(
        width: double.maxFinite,
        style: GradientShadowStyle.rotate,
        shadowSpread: 4,
        shadowBlur: 8,
        hasGradient: widget.isLoading,
        color: const Color(0xFF131217),
        gradientColors: const [
          Colors.cyanAccent,
          Colors.purpleAccent,
          Colors.redAccent,
          Colors.orangeAccent,
        ],
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 16.0, bottom: 2.0),
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
            suffixIcon: GestureDetector(
              onTap: () {
                if (widget.onSubmitTextField != null) {
                  onSubmitQuery();
                }
              },
              child: const Icon(
                Icons.search_rounded,
                size: 20,
              ),
            ),
          ),
          // style: const TextStyle(color: Colors.black),
          cursorColor: Colors.white,
          cursorWidth: 1.0,
          cursorRadius: const Radius.circular(50.0),
          onFieldSubmitted: (value) {
            onSubmitQuery();
          },
          onTapOutside: (event) {
            // constructSearchQueryUrl();
            _focusNode.unfocus();
            logger.e("onOutside");
          },
        ),
      ),
    );
  }

  void onSubmitQuery() {
    if (widget.onSubmitTextField != null && _controller.text.isNotEmpty) {
      widget.onSubmitTextField!(_controller.text);
    }
  }
}
