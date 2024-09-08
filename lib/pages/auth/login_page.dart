import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/home_page.dart';
import 'package:intrencity_provider/providers/auth_provider.dart';
import 'package:intrencity_provider/providers/validator_provider.dart';
import 'package:intrencity_provider/widgets/auth_button.dart';
import 'package:intrencity_provider/widgets/custom_text_form_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
                            const Duration(seconds: 2),
                            () {
                              validator.loading(false);
                              loginEmailController.clear();
                              loginPasswordController.clear();
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
                      ? const CupertinoActivityIndicator()
                      : Text(
                          'Login',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w800,
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
