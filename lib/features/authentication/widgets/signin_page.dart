import '../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../core/shared_widgets/buttons/previous_text_button.dart';
import '../../../core/shared_widgets/buttons/custom_text_button.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../models/account_existence_user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_form_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../enums/auth_enums.dart';
import 'reset_password_page.dart';
import 'auth_scaffold.dart';
import 'signup_page.dart';
import 'dart:convert';

class SigninPage extends StatefulWidget {

  static const routeName = 'SigninPage';

  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();

}

class _SigninPageState extends State<SigninPage> {
  
  AuthFormService authForm = AuthFormService(AuthFormType.signin, SigninStage.enterMobileNumber);

  @override
  void initState() {
    
    super.initState();

    /**
     *  Set this Scaffold setState function to update the state 
     *  whenever the action floating button must appear or 
     *  disappear. The floating action button appears as
     *  a prompt for the user to tap and get redirected 
     *  to the device keypad where the verification
     *  shortcode is pasted so that the user can
     *  quickly dial. Its a convinient approach
     *  of quickly navigating to the dialer
     *  and dialing the verification
     *  shortcode.
     */
    authForm.scaffoldSetState = setState;

  }

  @override
  Widget build(BuildContext context) {
    
    /// The AuthScaffold is a wrapper around the SigninForm
    return AuthScaffold(
      title: 'Sign In',
      authForm: authForm,
      imageUrl: 'assets/images/auth/lady-texting.png',
      form: SigninForm(
        authForm: authForm
      ),
    );
  }
}

class SigninForm extends StatefulWidget {
  
  final AuthFormService authForm;

  const SigninForm({ super.key, required this.authForm });

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {

  int _animatedSwitcherKey = 1;
  
  void _startSubmittionLoader() => setState(() => authForm.isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => authForm.isSubmitting = false);

  AuthFormService get authForm => widget.authForm;
  AuthRepository get authRepository => authProvider.authRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  void initState() {
    
    super.initState();

    /**
     *  Check if we have an incomplete Form, then set the
     *  saved form data and the last recorded SigninStage
     */
    authForm.setIncompleteFormData(authProvider).then((_) {

      /// Check if the last recorded SigninStage index is set
      if( authForm.lastRecordedStageIndex != null ) {

        /// If the last recorded SigninStage was the verification code stage
        if( SigninStage.values[authForm.lastRecordedStageIndex!] == SigninStage.enterVerificationCode ) {

          /// Show the floating action button
          authForm.toggleShowFloatingButton(authForm.verificationCodeShortcode, context);

        }

        /**
         *  Set the last recorded SigninStage.
         *  This will change the UI to the matching stage so
         *  that the user can continue from where they left of 
         */
        _changeSigninStage(SigninStage.values[authForm.lastRecordedStageIndex!]);

      }

      /// Check if the user has an incomplete signup form
      authForm.hasFormOnDevice(AuthFormType.signup).then((hasIncompleteSignupForm) {

        /// Navigate to the SignupPage to continue with this incomplete form
        if(hasIncompleteSignupForm) Navigator.pushNamed(context, SignupPage.routeName);

      });

      /// Check if the user has an incomplete reset password form
      authForm.hasFormOnDevice(AuthFormType.resetPassword).then((hasIncompleteResetPasswordForm) {

        /// Navigate to the ResetPasswordPage to continue with this incomplete form
        if(hasIncompleteResetPasswordForm) Navigator.pushNamed(context, ResetPasswordPage.routeName);

      });

    });

  }

  void _onSignin() {

    if(authForm.isSubmitting) return;

    authForm.resetServerValidationErrors(setState: setState);

    authForm.validateForm(context).then((status) async {

      if( status ) {

        authForm.saveForm();

        if(authForm.lastRecordedStage == SigninStage.enterMobileNumber) {

          await _requestMobileAccountExistence();

        }else if (authForm.lastRecordedStage == SigninStage.setNewPassword) {

          await _requestValidateResetPassword();

        }else if (
          authForm.lastRecordedStage == SigninStage.enterPassword ||
          authForm.lastRecordedStage == SigninStage.enterVerificationCode
        ) {
          
          await _requestSignin();
          return;

        }
        
        /// Save the form on the device - We must save after the _changeSigninStage.
        /// Only save after the _requestMobileAccountExistence() and the
        /// _requestValidateResetPassword() since the _requestSignin()
        /// will unsave the form once the signin is successful.
        authForm.saveFormOnDevice();

      }

    });

  }

  Future<void> _requestMobileAccountExistence() async {

    _startSubmittionLoader();
    
    await authRepository.checkIfMobileAccountExists(
      mobileNumber: authForm.mobileNumberWithExtension,
      context: context,
    ).then((response) async {

      if( response.statusCode == 200 ) {

        final responseBody = jsonDecode(response.body);
        authForm.user = AccountExistenceUser.fromJson(responseBody);
        
        if( authForm.user!.attributes.requiresPassword ) {

          _changeSigninStage(SigninStage.setNewPassword);

        }else {

          _changeSigninStage(SigninStage.enterPassword);

        }
        
      }else if(response.statusCode == 422) {

        await authForm.handleServerValidation(response, context);
        
      }

    }).catchError((error) {

      authForm.showSnackbarUnknownError(context);

    }).whenComplete((){

      _stopSubmittionLoader();

    });

  }

  Future<void> _requestValidateResetPassword() async {

    _startSubmittionLoader();

    /**
     *  Run the validateResetPassword() method to ensure that we 
     *  do not have any validation errors on the password and 
     *  the password confirmation fields before proceeding.
     */
    await authRepository.validateResetPassword(
      passwordConfirmation: authForm.passwordConfirmation,
      password: authForm.password!,
      context: context,
    ).then((response) async {

      if(response.statusCode == 200) {

        await _generateMobileVerificationCodeForSignin();

      }else if(response.statusCode == 422) {

        await authForm.handleServerValidation(response, context);
        
      }

    }).catchError((error) {

      authForm.showSnackbarUnknownError(context);

    }).whenComplete((){

      _stopSubmittionLoader();

    });
    

  }

  Future<void> _generateMobileVerificationCodeForSignin() async {

    _startSubmittionLoader();

    await authRepository.generateMobileVerificationCodeForSignin(
      mobileNumber: authForm.mobileNumberWithExtension,
      context: context,
    ).then((response) async {

      if(response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);
        authForm.verificationCodeMessage = responseBody['message'];
        authForm.verificationCodeShortcode = responseBody['shortcode'];

        /// Show the floating action button
        authForm.toggleShowFloatingButton(authForm.verificationCodeShortcode, context);

        _changeSigninStage(SigninStage.enterVerificationCode);

      }else if(response.statusCode == 422) {

        await authForm.handleServerValidation(response, context);
        
      }

    }).catchError((error) {

      authForm.showSnackbarUnknownError(context);

    }).whenComplete((){

      _stopSubmittionLoader();

    });
    

  }

  Future _requestSignin() {

    _startSubmittionLoader();

    return authRepository.signin(
      passwordConfirmation: authForm.passwordConfirmation,
      mobileNumber: authForm.mobileNumberWithExtension,
      verificationCode: authForm.verificationCode,
      password: authForm.password!,
      context: context,
    ).then((response) async {

      if(response.statusCode == 200) {

        authForm.showSnackbarSigninSuccess(response, context);

        /// Remove the forms from the device
        await authForm.unsaveFormOnDevice();
        
      }else if(response.statusCode == 422) {

        await authForm.handleServerValidation(response, context);
        
      }

    }).catchError((error) {

      authForm.showSnackbarUnknownError(context);

    }).whenComplete((){

      _stopSubmittionLoader();

    });

  }

  void _changeSigninStage(SigninStage currSigninStage) {
    setState(() {
      authForm.lastRecordedStage = currSigninStage;
      _animatedSwitcherKey += 1;
    });
  }

  Widget _getPreviousTextButton() {
    return PreviousTextButton(
      'Back',
      disabled: authForm.isSubmitting,
      mainAxisAlignment: MainAxisAlignment.start,
      onPressed: () async {

        if( authForm.lastRecordedStage == SigninStage.enterPassword ) {

          _changeSigninStage(SigninStage.enterMobileNumber);
          
        }else if( authForm.lastRecordedStage == SigninStage.setNewPassword ) {

          _changeSigninStage(SigninStage.enterMobileNumber);

        }else if( authForm.lastRecordedStage == SigninStage.enterVerificationCode ) {

          _changeSigninStage(SigninStage.setNewPassword);

          /// Hide the floating action button
          authForm.toggleShowFloatingButton(null, context);

        }

        /// Save the form on the device
        authForm.saveFormOnDevice();

      },
    );
  }

  Widget _getSubmitButton() {

    String text = '';

    if( authForm.lastRecordedStage == SigninStage.enterMobileNumber ) {
      text = 'Continue';
    }else if( authForm.lastRecordedStage == SigninStage.enterPassword ) {
      text = 'Sign In';
    }else if( authForm.lastRecordedStage == SigninStage.setNewPassword ) {
      text = 'Continue';
    }else if( authForm.lastRecordedStage == SigninStage.enterVerificationCode ) {
      text = 'Verify';
    }

    return CustomElevatedButton(
      text,
      onPressed: _onSignin,
      isLoading: authForm.isSubmitting,
      //  disabled: authForm.isSubmitting,
      suffixIcon: Icons.arrow_forward_rounded,
    );
  }

  Widget _getSignupButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomBodyText('Don\'t have an account yet?'),
        CustomTextButton(
          'Sign Up',
          onPressed: () {
              
            /// Navigate to the SignupPage
            Navigator.pushNamed(context, SignupPage.routeName).whenComplete(() {

              /// If we return back, save the form again
              authForm.saveFormOnDevice();

            });

          },
          disabled: authForm.isSubmitting,
        )
      ],
    );
  }

  Widget _getForgotPasswordButton() {
    return Align(
      alignment: Alignment.center,
      child: CustomTextButton(
        'Forgot your password?',
        onPressed: () {

          /// Set the required arguments
          final Map arguments = {
            'mobileNumber': authForm.mobileNumber,
            'user': authForm.user,
          };
          
          /// Navigate to the ResetPasswordPage
          Navigator.pushNamed(context, ResetPasswordPage.routeName, arguments: arguments).whenComplete(() {

            /// If we return back, save the form again
            authForm.saveFormOnDevice();

          });

        },
        disabled: authForm.isSubmitting,
      ),
    );
  }

  List<Widget> getAuthForm() {

    List<Widget> formFields = [];

    final enterVerificationCode = authForm.lastRecordedStage == SigninStage.enterVerificationCode;
    final enterMobileNumber = authForm.lastRecordedStage == SigninStage.enterMobileNumber;
    final setNewPassword = authForm.lastRecordedStage == SigninStage.setNewPassword;
    final enterPassword = authForm.lastRecordedStage == SigninStage.enterPassword;

    if( enterMobileNumber ) {

      formFields.addAll([
        const CustomBodyText('Enter your Orange mobile number to sign in'),
        const SizedBox(height: 16),
        authForm.getMobileNumberField(setState),
      ]);

    }else if( enterPassword ) {

      formFields.addAll([
        authForm.getAccountAvatarChip(),
        const SizedBox(height: 16),
        const CustomBodyText('Enter your account password to sign in'),
        const SizedBox(height: 16),
        authForm.getPasswordField(setState, _onSignin),
      ]);

    }else if( setNewPassword ) {

      formFields.addAll([
        authForm.getAccountAvatarChip(),
        const SizedBox(height: 16),
        const CustomBodyText('Set a new password for your account'),
        const SizedBox(height: 16),
        authForm.getPasswordField(setState, _onSignin),
        const SizedBox(height: 16),
        authForm.getPasswordConfirmationField(setState, _onSignin)
      ]);

    }else if( enterVerificationCode ) {

      formFields.addAll([
        authForm.getAccountAvatarChip(),
        const SizedBox(height: 16),
        authForm.getVerificationCodeMessage(authForm.verificationCodeMessage!, authForm.verificationCodeShortcode!, context),
        const SizedBox(height: 16),
        authForm.getMobileVerificationField(setState)
      ]);

    }

    Widget submitAndPreviousTextButton = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _getPreviousTextButton(),
        _getSubmitButton()
      ],
    );

    formFields.addAll([      
      const SizedBox(height: 16),
      enterMobileNumber ? _getSubmitButton() : submitAndPreviousTextButton,
    ]);

    if(enterMobileNumber) {
      formFields.addAll([
        const SizedBox(height: 16),
        _getSignupButton()
      ]);
    }

    if(enterPassword) {
      formFields.addAll([
        const SizedBox(height: 16),
        _getForgotPasswordButton()
      ]);
    }

    return formFields;

  }

  @override
  Widget build(BuildContext context) {
    
    return Form(
      key: authForm.formKey,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          
          /**
           *  AnimatedSize helps to animate the sizing of the
           *  form from a bigger height to a smaller height.
           *  When adding or removing some form fields, the
           *  transition will be jumpy since the height is
           *  not the same. This helps animate those
           *  height differences
           */
          AnimatedSize(
            clipBehavior: Clip.none,
            duration: const Duration(milliseconds: 500),
            /**
             *  AnimatedSwitcher helps to animate the fading of the
             *  form as the form fields are swapped and the form
             *  transitions from one stage to another
             */
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                key: ValueKey(_animatedSwitcherKey),
                children: <Widget>[
                  ...getAuthForm()
                ],
              ),
            ),
          ),
          
          //  if(authForm.isSubmitting) const CustomCircularProgressIndicator()
        ],
      ),
    );
  }
}
