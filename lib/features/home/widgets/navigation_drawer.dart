import '../../../features/introduction/widgets/landing_page.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../../authentication/repositories/auth_repository.dart';
import '../../user/widgets/user_profile/user_profile_avatar.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/shared_models/user.dart';
import '../../../core/utils/snackbar.dart';
import '../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class NavigationDrawer extends StatefulWidget {

  const NavigationDrawer({super.key});

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {

  User get user => authProvider.user!;
  AuthRepository get authRepository => authProvider.authRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  _requestLogout() {

    //  Show logging out loader
    DialogUtility.showLoader(message: 'Signing out', context: context);

    return authRepository.logout(
      context: context,
    ).then((response) async {

      //  Hide logging out loader
      DialogUtility.hideLoader(context);
      
      /// Get the response body
      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {
        
        /// Show the success message
        SnackbarUtility.showSuccessMessage(message: responseBody['message']);
        
      }

    }).catchError((error) {

      /**
       *  Hide logging out loader
       * 
       *  We are placing this method in the catchError() instead of the whenComplete()
       *  method because should an error occur, then this catchError() method will 
       *  run the SnackbarUtility.showErrorMessage() to show the snackbar message,
       *  but then DialogUtility.hideLoader() would hide the SnackbarUtility 
       *  message instead of the DialogUtility message since catchError() 
       *  would run before whenComplete() showing the snackbar message
       *  and then dismissing the snackbar message instead of the
       *  dialog loader.
       * 
       *  This is because SnackbarUtility.showErrorMessage() will fire first and
       *  then DialogUtility.hideLoader() will fire next. We need to make sure
       *  that DialogUtility.hideLoader() fires first and then
       *  SnackbarUtility.showErrorMessage() fires next.
       */
      DialogUtility.hideLoader(context);
  
      /// Show the fatal error message
      SnackbarUtility.showErrorMessage(message: 'Failed to sign out');

    }).whenComplete(() {

      /**
       *  Navigate to the landing page on successful
       *  or unsuccessful signing out.
       */       
      Navigator.pushReplacementNamed(
        context,
        LandingPage.routeName
      );

    });

  }

  Widget menuItem(String title, { required IconData icon, required void Function() onTap, bool showDivider = true }) {
    return Column(
      children: [
        ListTile(
          leading: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0)
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(icon),
              ),
              CustomBodyText(title, fontWeight: FontWeight.bold,),
            ],
          ),
          onTap: onTap,
        ),
        if(showDivider) const Divider(height: 0,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: UserProfile(user: user),
            ),

            menuItem('Communities', icon: Icons.people, onTap: (){}),
            menuItem('Sign Out', icon: Icons.logout, onTap: _requestLogout),

          ],
        ),
      ),
    );
  }
}