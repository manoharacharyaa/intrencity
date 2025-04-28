import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/providers/auth_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intrencity/providers/validator_provider.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/widgets/auth_button.dart';
import 'package:intrencity/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var selectedCountry = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final validator = context.watch<AuthValidationProvider>();
    final auth = context.watch<AuthenticationProvider>();

    String getCountryPlusPhone() {
      String phoneNumber = validator.selectedCountry == null
          ? '+91 ${phoneController.text}'
          : '+${validator.selectedCountry} ${phoneController.text}';

      return phoneNumber;
    }

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
                  controller: nameController,
                  maxLines: 1,
                  prefixIcon: Icons.person,
                  hintText: 'Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: emailController,
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
                  controller: passwordController,
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
                    validator.passwordIsEmpty(passwordController.text);
                    validator.validatePassword(
                      passwordController.text,
                      confirmPasswordController.text,
                    );
                    if (passwordController.text.isEmpty) {
                      validator.passwordEmpty = true;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: confirmPasswordController,
                  prefixIcon: Icons.lock,
                  hintText: 'Confirm Password',
                  maxLines: 1,
                  obscureText: true,
                  onChanged: (_) {
                    validator.validatePassword(
                      passwordController.text,
                      confirmPasswordController.text,
                    );
                    validator.emptyCheck(confirmPasswordController.text);
                    validator.passwordIsEmpty(passwordController.text);
                  },
                  suffixIcon: validator.isEmpty ||
                          validator.passwordEmpty ||
                          passwordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty
                      ? null
                      : validator.isEqual
                          ? const Icon(Icons.check_circle, color: greenAccent)
                          : const Icon(Icons.cancel, color: redAccent),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter confirm password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              context: context,
                              countryListTheme: CountryListThemeData(
                                flagSize: 25,
                                backgroundColor: scaffoldColor,
                                textStyle: const TextStyle(fontSize: 10),
                                bottomSheetHeight: 500,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                inputDecoration: InputDecoration(
                                  fillColor: textFieldGrey,
                                  filled: true,
                                  labelText: 'Search',
                                  labelStyle:
                                      Theme.of(context).textTheme.titleMedium,
                                  hintText: 'Start typing to search',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              onSelect: (Country country) {
                                validator.country(country.phoneCode);
                              });
                        },
                        child: ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 0.8,
                          ),
                          child: Container(
                            height: 54,
                            decoration: const BoxDecoration(
                              color: textFieldGrey,
                            ),
                            child: Center(
                              child: Text(
                                "+${validator.selectedCountry ?? '91'} ",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: validator.error
                                      ? redAccent
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.only(top: validator.error ? 0 : 0),
                        child: CustomTextFormField(
                          controller: phoneController,
                          maxLines: 1,
                          prefixIcon: Icons.phone,
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                AuthButton(
                  onPressed: () {
                    try {
                      validator.loading(true);
                      assert(EmailValidator.validate(emailController.text));
                      auth
                          .signUp(
                        emailController.text,
                        passwordController.text,
                        nameController.text,
                        getCountryPlusPhone(),
                      )
                          .then(
                        (value) {
                          validator.loading(false);
                          Future.delayed(
                            const Duration(seconds: 1),
                            () {
                              nameController.clear();
                              emailController.clear();
                              phoneController.clear();
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
                          'Signup',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
