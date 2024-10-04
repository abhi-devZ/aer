import 'package:aer/UI/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'gradient_shadow_container.dart';

typedef OnSubmitCallback = void Function(String value);

class SearchBox extends StatefulWidget {
  final bool isLoading;
  final bool hasLeading;
  final String? searchTerm;
  final OnSubmitCallback? onSubmitTextField;

  const SearchBox({
    super.key,
    this.searchTerm,
    this.isLoading = false,
    this.onSubmitTextField,
    this.hasLeading = false
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  GradientShadowStyle shadowStyle = GradientShadowStyle.none;

  get searchIcon => IconButton(
        onPressed: () {
          if (widget.onSubmitTextField != null) {
            onSubmitQuery();
          }
        },
        icon: const FaIcon(
          FontAwesomeIcons.magnifyingGlass,
          size: 16,
          color: Color(0xFFF3F2F7),
        ),
      );

  get cancelIcon => IconButton(
        onPressed: () {},
        icon: const FaIcon(
          FontAwesomeIcons.xmark,
          size: 16,
          color: Color(0xFFF3F2F7),
        ),
      );

  @override
  void initState() {
    super.initState();
    if (widget.searchTerm != null) {
      _controller.text = widget.searchTerm!;
    }
    if (widget.isLoading) {
      shadowStyle = GradientShadowStyle.rotate;
    }
    _focusNode.addListener(() {
      if (!widget.isLoading) {
        if (_focusNode.hasFocus) {
          shadowStyle = GradientShadowStyle.pulse;
        } else {
          shadowStyle = GradientShadowStyle.none;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AdvancedGradientShadowContainer(
        width: double.maxFinite,
        style: shadowStyle,
        shadowSpread: 4,
        shadowBlur: 8,
        color: const Color(0xFF131217),
        gradientColors: const [
          Colors.cyanAccent,
          Colors.purpleAccent,
          Colors.orangeAccent,
          Colors.redAccent,
        ],
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: false,
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
            prefixIcon: widget.hasLeading ? searchIcon : null,
            suffixIcon: widget.hasLeading ? cancelIcon : searchIcon,
          ),
          // style: const TextStyle(color: Colors.black),
          cursorColor: Colors.white,
          cursorWidth: 1.0,
          cursorRadius: const Radius.circular(50.0),
          onFieldSubmitted: (value) {
            onSubmitQuery();
          },
          onTapOutside: (event) {
            logger.e("onOutside");
            FocusScope.of(context).unfocus();
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
