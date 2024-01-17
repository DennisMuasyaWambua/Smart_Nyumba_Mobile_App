import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/constants.dart';

import '../../widgets/auth/_auth_widgets.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  int currentStep = 0;
  
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _blockNumberController;
  late TextEditingController _houseNumberController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _idNumberController = TextEditingController();
    _blockNumberController = TextEditingController();
    _houseNumberController = TextEditingController();
    _mobileNumberController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  // Disposing controllers after use avoids memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _blockNumberController.dispose();
    _houseNumberController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 0, top: 8.0),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(Constants.SMART_NYUMBA_BLACK),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: 'HindJalandhar',
                    fontWeight: FontWeight.w600,
                    fontSize: 41,
                    color: royalBlue,
                  ),
                ),
              ),
              const Text(
                "Hassle free property management",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontFamily: 'HindJalandhar',
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  color: royalBlue,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Expanded(
                  // The theme is to make the stepper at the top royalBlue
                  child: Theme(
                    data: ThemeData(
                      colorScheme: const ColorScheme(
                        brightness: Brightness.light,
                        primary: royalBlue,
                        onPrimary: Colors.white,
                        secondary: royalBlue,
                        onSecondary: Colors.white,
                        error: Color.fromRGBO(183, 28, 28, 1),
                        onError: Colors.white,
                        background: Color(0x61000000),
                        onBackground: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: Stepper(
                      type: StepperType.horizontal,
                      elevation: 0,
                      currentStep: currentStep,
                      onStepContinue: () {
                        setState(() {
                          currentStep != 2 ? currentStep = currentStep + 1 : null;
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          currentStep != 0 ? currentStep = currentStep - 1 : null;
                        });
                      },
                      controlsBuilder: (_, ControlsDetails details) {
                        return StepperControls(
                          currentStep: currentStep,
                          details: details,
                          email: _emailController.text,
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          idNumber: _idNumberController.text,
                          blockNumber: _blockNumberController.text,
                          houseNumber: _houseNumberController.text,
                          mobileNumber: _mobileNumberController.text,
                          password: _passwordController.text,
                        );
                      },
                      steps: [
                        Step(
                          isActive: currentStep > -1,
                          title: const SizedBox(),
                          content: Column(children: [
                            RegisterInputField(
                              controller: _firstNameController,
                              prefixIcon: Icons.person,
                              hintText: "First Name",
                              keyboardType: TextInputType.name,
                            ),
                            RegisterInputField(
                              controller: _lastNameController,
                              prefixIcon: Icons.person,
                              hintText: "Last Name",
                              keyboardType: TextInputType.name,
                            ),
                            RegisterInputField(
                              controller: _idNumberController,
                              prefixIcon: Icons.credit_card_off_rounded,
                              hintText: "ID Number",
                              keyboardType: TextInputType.number,
                            ),
                            RegisterInputField(
                              controller: _mobileNumberController,
                              prefixIcon: Icons.phone,
                              hintText: "Phone Number",
                              keyboardType: TextInputType.phone,
                            ),
                          ]),
                        ),
                        Step(
                          isActive: currentStep > 0,
                          title: const SizedBox(),
                          content: Column(
                            children: [
                              RegisterInputField(
                                controller: _blockNumberController,
                                prefixIcon: Icons.apartment_rounded,
                                hintText: "Block Number",
                                keyboardType: TextInputType.name,
                              ),
                              RegisterInputField(
                                controller: _houseNumberController,
                                prefixIcon: Icons.house,
                                hintText: "House Number",
                                keyboardType: TextInputType.name,
                              ),
                            ],
                          ),
                        ),
                        Step(
                          isActive: currentStep > 1,
                          title: const SizedBox(),
                          content: Column(
                            children: [
                              RegisterInputField(
                                controller: _emailController,
                                prefixIcon: Icons.email,
                                hintText: "Email",
                                keyboardType: TextInputType.emailAddress,
                              ),
                              RegisterPasswordField(
                                controller: _passwordController,
                              ),
                              RegisterConfirmPasswordField(
                                controller: _confirmPasswordController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
