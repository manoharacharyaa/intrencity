import 'package:country_picker/country_picker.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/home_page.dart';
import 'package:intrencity_provider/providers/auth_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intrencity_provider/providers/validator_provider.dart';
import 'package:intrencity_provider/widgets/auth_button.dart';
import 'package:intrencity_provider/widgets/custom_text_form_field.dart';
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
                            cornerRadius: 18,
                            cornerSmoothing: 1,
                          ),
                          child: Container(
                            height: 60,
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
                        padding:
                            EdgeInsets.only(bottom: validator.error ? 0 : 0),
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

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Container(
                            height: size.height * 0.2,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(55, 255, 255, 255),
                            ),
                            child: const Text('Enter a valid email'),
                          ),
                        ),
                      );
                    }
                    if (_formKey.currentState!.validate()) {
                    } else {
                      validator.errorCheck();
                    }
                  },
                  widget: validator.isLoading
                      ? const CupertinoActivityIndicator(radius: 14)
                      : Text(
                          'Signup',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                ),
                SizedBox(height: size.height * 0.02),
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
                SizedBox(height: size.height * 0.03),
                ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      await auth.signInWithGoogle().then(
                            (_) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            ),
                          );
                    },
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(width: size.width * 0.15),
                          Image.asset(
                            'assets/images/google_gradient.png',
                            height: 29,
                          ),
                          SizedBox(width: size.width * 0.05),
                          Text(
                            'Signin with Google',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                          )
                        ],
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
