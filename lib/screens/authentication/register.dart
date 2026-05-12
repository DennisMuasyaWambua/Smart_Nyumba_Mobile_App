import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/constants.dart';

import '../../widgets/auth/_auth_widgets.dart';

class Register extends StatefulWidget {
  static const routeName = "/register";

  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  int currentStep = 0;
  String? _selectedRole;

  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _blockNumberController;
  late TextEditingController _houseNumberController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _approverEmailController;
  late TextEditingController _estateNameController;
  late TextEditingController _estateLocationController;
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
    _phoneNumberController = TextEditingController();
    _approverEmailController = TextEditingController();
    _estateNameController = TextEditingController();
    _estateLocationController = TextEditingController();
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
    _phoneNumberController.dispose();
    _approverEmailController.dispose();
    _estateNameController.dispose();
    _estateLocationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  height: 500,
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
                          // All roles now go through all steps (no skipping)
                          if (currentStep != 2) {
                            currentStep = currentStep + 1;
                          }
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          // Go back one step
                          if (currentStep != 0) {
                            currentStep = currentStep - 1;
                          }
                        });
                      },
                      controlsBuilder: (_, ControlsDetails details) {
                        // StepperControls widget contains the routing information
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
                          phoneNumber: _phoneNumberController.text,
                          approverEmail: _approverEmailController.text,
                          estateName: _estateNameController.text,
                          estateLocation: _estateLocationController.text,
                          password: _passwordController.text,
                          confirmPassword: _confirmPasswordController.text,
                          role: _selectedRole ?? '',
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
                              textInputAction: TextInputAction.next,
                            ),
                            RegisterInputField(
                              controller: _lastNameController,
                              prefixIcon: Icons.person,
                              hintText: "Last Name",
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                            ),
                            RegisterInputField(
                              controller: _idNumberController,
                              prefixIcon: Icons.credit_card_off_rounded,
                              hintText: "ID Number",
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                            RegisterInputField(
                              controller: _mobileNumberController,
                              prefixIcon: Icons.phone,
                              hintText: "Mobile Number",
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            // Show phone number only for non-tenants
                            if (_selectedRole != null && _selectedRole != 'tenant')
                              RegisterInputField(
                                controller: _phoneNumberController,
                                prefixIcon: Icons.phone_android,
                                hintText: "Phone Number (Alternative)",
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                              ),
                            RegisterRoleDropdown(
                              selectedRole: _selectedRole,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              },
                            ),
                          ]),
                        ),
                        Step(
                          isActive: currentStep > 0,
                          title: const SizedBox(),
                          content: Column(
                            children: [
                              // For tenants: show block and house number
                              if (_selectedRole == 'tenant') ...[
                                RegisterInputField(
                                  controller: _blockNumberController,
                                  prefixIcon: Icons.apartment_rounded,
                                  hintText: "Block Number",
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                ),
                                RegisterInputField(
                                  controller: _houseNumberController,
                                  prefixIcon: Icons.house,
                                  hintText: "House Number",
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.done,
                                ),
                              ]
                              // For landlords: show estate name, location, and approver email
                              else if (_selectedRole == 'landlord') ...[
                                RegisterInputField(
                                  controller: _estateNameController,
                                  prefixIcon: Icons.business,
                                  hintText: "Estate/Block Name",
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                ),
                                RegisterInputField(
                                  controller: _estateLocationController,
                                  prefixIcon: Icons.location_on,
                                  hintText: "Estate Location/Address",
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                ),
                                RegisterInputField(
                                  controller: _approverEmailController,
                                  prefixIcon: Icons.admin_panel_settings,
                                  hintText: "Approver Email (Admin)",
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                ),
                              ]
                              // For caretakers and accounts: show approver email only
                              else ...[
                                RegisterInputField(
                                  controller: _approverEmailController,
                                  prefixIcon: Icons.admin_panel_settings,
                                  hintText: "Approver Email (Admin)",
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
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
                                textInputAction: _selectedRole == 'tenant'
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                              ),
                              // Show password fields only for tenants
                              if (_selectedRole == 'tenant') ...[
                                RegisterPasswordField(
                                  controller: _passwordController,
                                ),
                                RegisterConfirmPasswordField(
                                  controller: _confirmPasswordController,
                                ),
                              ] else ...[
                                const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    "Password will be auto-generated and sent to your email",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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
