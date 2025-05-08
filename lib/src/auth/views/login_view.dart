import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:queen_validators/queen_validators.dart';
import 'package:zegocloud_uikit/components/components.dart';
import 'package:zegocloud_uikit/core/core.dart';
import 'package:zegocloud_uikit/src/auth/services/auth_service.dart';
import 'package:zegocloud_uikit/src/home/views/home_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final pageController = PageController();
  final pageDuration = const Duration(milliseconds: 200);
  final pageCurve = Curves.easeIn;
  final keyPhoneForm = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final codeVerificatioController = TextEditingController();
  final selectedStepNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    pageController.dispose();
    phoneController.dispose();
    codeVerificatioController.dispose();
    selectedStepNotifier.dispose();
    super.dispose();
  }

  Future<void> onBackEvent({required int? currentStep}) async {
    if (currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      pageController.previousPage(duration: pageDuration, curve: pageCurve);
    }
  }

  void onVerification() {
    AuthService.login(
      phoneNumber: phoneController.text,
    ).then((value) async {
      AuthService.onUserLogin();
      if (mounted) {
        Navigator.popAndPushNamed(context, HomePage.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedStepNotifier,
      builder: (context, currentStep, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            onBackEvent(currentStep: currentStep);
          },
          child: GestureDetector(
            onTap: FocusManager.instance.primaryFocus?.unfocus,
            child: Scaffold(
              backgroundColor: context.theme.colorScheme.surface,
              appBar: AppBar(
                leading: currentStep == 0
                    ? null
                    : BackButton(
                        onPressed: () => onBackEvent(currentStep: currentStep),
                      ),
              ),
              body: SafeArea(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) => selectedStepNotifier.value = value,
                  controller: pageController,
                  children: [
                    _buildPhoneField(),
                    _buildPhoneVerification(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Center(
      child: RichText(
        text: const TextSpan(
          text: 'ZE',
          style: TextStyle(color: Colors.black, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
              text: 'GO',
              style: TextStyle(color: Colors.blue),
            ),
            TextSpan(text: 'CLOUD'),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            constraints: BoxConstraints(
                minHeight: context.mediaQuery.size.height -
                    context.mediaQuery.padding.top -
                    kToolbarHeight),
            child: SafeArea(
              child: Form(
                key: keyPhoneForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Gap(30),
                    _buildLogo(),
                    const Gap(30),
                    const TitleText(
                      title: 'What\'s your phone number?',
                      subtitle:
                          'Unregistered mobile phone numbers will be automatically registered',
                      fontSizeTitle: 22,
                      spacer: 27,
                      fontSizeSubtitle: 16,
                      centerText: true,
                    ),
                    const Gap(50),
                    AppTextFormField(
                      controller: phoneController,
                      hintText: 'Enter your phone',
                      keyboardType: TextInputType.phone,
                      validator: qValidator([
                        IsRequired('Phone is required'),
                      ]),
                    ),
                    const Gap(50),
                    AppRoundedButton(
                      label: 'Get Verification Code',
                      onPressed: () {
                        if (keyPhoneForm.currentState!.validate()) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          pageController.nextPage(
                              duration: pageDuration, curve: pageCurve);
                        }
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneVerification() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            constraints: BoxConstraints(
                minHeight: context.mediaQuery.size.height -
                    context.mediaQuery.padding.top -
                    kToolbarHeight),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(30),
                  TitleText(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    title: 'Verification',
                    subtitle:
                        'Please enter the 4 digit verification code sent to ${phoneController.text}\n(Any digits for test)',
                    fontSizeTitle: 22,
                    spacer: 27,
                    fontSizeSubtitle: 16,
                    centerText: true,
                  ),
                  const Gap(50),
                  AppPinCodeTextField(
                    appContext: context,
                    length: 4,
                    hintCharacter: "-",
                    textStyle: TextStyle(color: context.theme.primaryColor),
                    enableActiveFill: true,
                    showCursor: false,
                    autoFocus: true,
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    pinTheme: PinTheme(
                      fieldHeight: 50,
                      fieldWidth: 50,
                      shape: PinCodeFieldShape.circle,
                      activeFillColor:
                          context.theme.colorScheme.primaryContainer,
                      activeColor: context.theme.colorScheme.primaryContainer,
                      inactiveFillColor:
                          context.theme.colorScheme.primaryContainer,
                      inactiveColor: context.theme.colorScheme.primaryContainer,
                      selectedFillColor:
                          context.theme.colorScheme.primaryContainer,
                      selectedColor: context.theme.colorScheme.primaryContainer,
                    ),
                    backgroundColor: context.theme.colorScheme.surface,
                    controller: codeVerificatioController,
                    onCompleted: (value) {
                      onVerification();
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const Gap(50),
                  AppRoundedButton(
                    label: 'Continue',
                    onPressed: codeVerificatioController.text.length < 4
                        ? null
                        : onVerification,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
