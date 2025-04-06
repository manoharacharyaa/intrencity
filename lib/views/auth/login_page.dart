import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/providers/auth_provider.dart';
import 'package:intrencity/providers/validator_provider.dart';
import 'package:intrencity/widgets/auth_button.dart';
import 'package:intrencity/widgets/custom_text_form_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intrencity/widgets/dilogue_widget.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginEmailController = TextEditingController();
  final forgetPasswordEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).then((_) {
        forgetPasswordEmailController.clear();
      });
      CustomDilogue.showSuccessDialog(context, 'assets/animations/tick.json',
          'Sucessfully Send Password Reser Link');
    } catch (e) {
      CustomDilogue.showSuccessDialog(context, 'assets/animations/cross.json',
          'Error While Sending Password Reser Link');
    }
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    forgetPasswordEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    final size = MediaQuery.of(context).size;
    final auth = context.watch<AuthenticationProvider>();
    final validator = context.watch<AuthValidationProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: loginEmailController,
                  prefixIcon: Icons.mail,
                  maxLines: 1,
                  hintText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: loginPasswordController,
                  prefixIcon:
                      validator.isVisible ? Icons.lock_open : Icons.lock,
                  hintText: 'Password',
                  obscureText: validator.isVisible ? false : true,
                  maxLines: 1,
                  suffixIcon: validator.passwordEmpty
                      ? null
                      : validator.error
                          ? null
                          : IconButton(
                              onPressed: () {
                                validator.invertIsVisible();
                              },
                              icon: validator.isVisible
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                            ),
                  onChanged: (_) {
                    if (loginPasswordController.text.isEmpty) {
                      validator.passwordEmpty = true;
                    }
                    validator.passwordIsEmpty(loginPasswordController.text);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.05),
                AuthButton(
                  onPressed: () {
                    try {
                      validator.loading(true);
                      assert(
                          EmailValidator.validate(loginEmailController.text));
                      auth
                          .login(
                        loginEmailController.text,
                        loginPasswordController.text,
                      )
                          .then(
                        (value) {
                          Future.delayed(
                            const Duration(seconds: 1),
                            () {
                              validator.loading(false);
                              loginEmailController.clear();
                              loginPasswordController.clear();
                              context.pushReplacement('/home-page');
                            },
                          );
                        },
                      ).onError(
                        (error, stackTrace) {
                          validator.loading(false);
                        },
                      );
                    } catch (e) {
                      validator.loading(false);
                      validator.isLoading = false;
                      Fluttertoast.showToast(msg: 'Enter a valid email');
                    }
                    if (_formKey.currentState!.validate()) {
                    } else {
                      validator.setError(true);
                    }
                  },
                  widget: validator.isLoading
                      ? const CupertinoActivityIndicator(radius: 12)
                      : Text(
                          'Login',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ClipSmoothRect(
                        child: Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 20,
                              cornerSmoothing: 1,
                            ),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 26, 25, 25),
                          child: SizedBox(
                            height: size.height * 0.38,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  SizedBox(height: size.height * 0.06),
                                  Lottie.asset('assets/animations/reset.json'),
                                  SizedBox(height: size.height * 0.04),
                                  CustomTextFormField(
                                    controller: forgetPasswordEmailController,
                                    hintText: 'Enter Email',
                                    verticalPadding: 20,
                                    maxLines: 1,
                                    prefixIcon: Icons.email,
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  AuthButton(
                                    height: 55,
                                    widget: Text(
                                      'Reset',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      _resetPassword(
                                        forgetPasswordEmailController.text,
                                        context,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Forget Password',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Divider(
                          thickness: 0.2,
                        ),
                      ),
                    ),
                    Text('or'),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Divider(
                          thickness: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.3),
                GestureDetector(
                  onTap: () {
                    auth.toggleGuest();
                    context.push('/parking-list');
                  },
                  child: const SmoothContainer(
                    height: 60,
                    width: double.infinity,
                    cornerRadius: 15,
                    child: Center(
                      child: Text(
                        "Continue As Guest",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
