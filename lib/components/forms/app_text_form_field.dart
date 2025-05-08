import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as flutter_phone_number;
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:gap/gap.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    this.controller,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.hintText,
    this.errorText,
    this.initPhoneCode,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.obscureText = false,
    this.initialValue,
    this.keyboardAppearance,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.prefixIcon,
    this.focusNode,
  });

  final CrossAxisAlignment crossAxisAlignment;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Country? initPhoneCode;
  final TextCapitalization textCapitalization;
  final bool autocorrect, obscureText;
  final String? initialValue;
  final Brightness? keyboardAppearance;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final FocusNode? focusNode;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late Country _selectedDialogCountry;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    } else {
      _controller = widget.controller!;
    }

    final phoneCode =
        CountryWithPhoneCode.getCountryDataByPhone(_controller.text)?.phoneCode;
    _selectedDialogCountry = widget.initPhoneCode ??
        CountryPickerUtils.getCountryByPhoneCode(phoneCode ?? '62');
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (widget.keyboardType == TextInputType.phone &&
        _controller.text.isNotEmpty) {
      var formated = await flutter_phone_number.getFormattedParseResult(
        _controller.text,
        CountryWithPhoneCode.getCountryDataByPhone(_controller.text) ??
            const CountryWithPhoneCode.us(),
      );

      _controller.text = formated?.formattedNumber ?? _controller.text;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.0, vertical: 12),
      child: TextFormField(
        key: widget.key,
        initialValue: widget.initialValue,
        controller: _controller,
        focusNode: widget.focusNode,
        validator: widget.validator,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        onChanged: (value) async {
          if (widget.keyboardType == TextInputType.phone) {
            var formated = await flutter_phone_number.getFormattedParseResult(
                value,
                CountryWithPhoneCode.getCountryDataByPhone(value) ??
                    const CountryWithPhoneCode.us());
            _controller.text = formated?.formattedNumber ?? value;
            _controller.selection =
                TextSelection.collapsed(offset: _controller.text.length);
          }
        },
        inputFormatters: <TextInputFormatter>[
          ...(widget.inputFormatters ?? []),
          if (widget.keyboardType == TextInputType.phone) ...[
            TextInputCountry(_selectedDialogCountry),
          ],
        ],
        textCapitalization: widget.textCapitalization,
        autocorrect: widget.autocorrect,
        keyboardAppearance: widget.keyboardAppearance,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          hintText: widget.hintText,
          suffixIcon: _buildSuffixIcon(),
          prefixIcon: _buildPrefixIcon(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (_controller.text.isEmpty) return null;
    return IconButton(
      onPressed: () {
        _controller.clear();
      },
      icon: const Icon(Icons.close, color: Colors.grey),
    );
  }

  Widget _buildPrefixIcon() {
    if (widget.keyboardType != TextInputType.phone) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: widget.prefixIcon,
      );
    }

    return GestureDetector(
      onTap: _openCountryPickerDialog,
      child: Container(
        padding: const EdgeInsets.only(left: 17, bottom: 0, top: 0),
        margin: const EdgeInsets.only(right: 10),
        decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(
                  color: Colors.grey)), // IconTheme.of(context).color!
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 15,
              width: 22,
              child: CountryPickerUtils.getDefaultFlagImage(
                  _selectedDialogCountry),
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 7,
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCountryPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.pink),
        child: CountryPickerDialog(
          titlePadding: const EdgeInsets.all(8.0),
          searchCursorColor: Colors.pinkAccent,
          searchInputDecoration: const InputDecoration(hintText: 'Search...'),
          isSearchable: true,
          title: const Text('Select your phone code'),
          onValuePicked: (Country country) {
            var oldPhoneCode = _selectedDialogCountry.phoneCode;
            var newPhoneCode = country.phoneCode;
            if (_controller.text.isNotEmpty) {
              _controller.text =
                  "+$newPhoneCode ${_controller.text.substring(oldPhoneCode.length + 1).trim()}";
            }
            setState(() => _selectedDialogCountry = country);
          },
          priorityList: [
            CountryPickerUtils.getCountryByIsoCode('ID'),
            CountryPickerUtils.getCountryByIsoCode('TR'),
            CountryPickerUtils.getCountryByIsoCode('US'),
          ],
          itemBuilder: (Country country) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 18,
                  width: 24,
                  child: CountryPickerUtils.getDefaultFlagImage(country),
                ),
                const Gap(10.0),
                Flexible(
                    child: Text(
                  country.name,
                  style: const TextStyle(fontSize: 15),
                )),
                const Gap(8.0),
                Text(
                  "(+${country.phoneCode})",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TextInputCountry extends TextInputFormatter {
  final Country country;
  TextInputCountry(this.country);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final prefixPhoneCode = "+${country.phoneCode} ";

    var oriText = newValue.text;

    if (newValue.text.contains(prefixPhoneCode)) {
      oriText = oriText.substring(prefixPhoneCode.length).trim();
    }

    var text =
        oriText == prefixPhoneCode.trim() ? "" : (prefixPhoneCode + oriText);

    return TextEditingValue(text: text);
  }
}
