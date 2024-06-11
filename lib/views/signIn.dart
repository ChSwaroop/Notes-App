import 'package:flutter/material.dart';
import 'package:notes/DBreop/authrepo.dart';
import 'package:notes/util/reuse.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _key = GlobalKey<FormState>();
  TextEditingController mail = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool isLoading = false;
  bool isHide = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Form(
          key: _key,
          child: Column(children: [
            const SizedBox(
              height: 30,
            ),
            Reusable.textField(context, "Enter your Email", mail),
            const SizedBox(
              height: 20,
            ),
            Reusable.textField(context, "Enter the Password", pass , isHide: isHide, callback: (){
              isHide = !isHide;
              setState(() {
              
            });}),
            const SizedBox(
              height: 30,
            ),
            isLoading
                ? const CircularProgressIndicator()
                : Reusable.Button(
                    "Sign In", 50, theme.primary, Colors.transparent, context,
                    () async {
                    if (_key.currentState!.validate()) {
                      //Call the login function of auth repo to login the user to app;
                      setState(() {
                        isLoading = true;
                      });
                      await AuthRepository()
                          .login(mail.text.trim(), pass.text.trim(), context);

                      setState(() {
                        isLoading = false;
                      });
                    }
                  }),
            const SizedBox(
              height: 5,
            ),
          ]),
        ),
      ),
    );
  }
}
