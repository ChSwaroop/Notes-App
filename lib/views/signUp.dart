import 'package:flutter/material.dart';
import 'package:notes/DBreop/authrepo.dart';
import 'package:notes/util/reuse.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _key = GlobalKey<FormState>();
  TextEditingController mail = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController name = TextEditingController();
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
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(
                height: 20,
              ),
              Reusable.textField(context, "Enter your User name", name),
              const SizedBox(
                height: 20,
              ),
              Reusable.textField(context, "Enter your Email", mail),
              const SizedBox(
                height: 20,
              ),
              Reusable.textField(context, "Enter the Password", pass , isHide: isHide , callback: (){
                isHide = !isHide;
                setState(() {
                  
                });
              }),
              const SizedBox(
                height: 20,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Reusable.Button(
                      "Sign Up", 50, theme.primary, Colors.transparent, context,
                      () async {
                      if (_key.currentState!.validate()) {
                        //Call the adduser function of authrepo to create a new user
                        setState(() {
                          isLoading = true;
                        });
                        debugPrint('Button clciked');
                        await AuthRepository().addUser(mail.text.trim(),
                            pass.text.trim(), name.text.trim(), context);

                        setState(() {
                          isLoading = false;
                        });
                      }
                    }),
            ]),
          ),
        ),
      ),
    );
  }
}
