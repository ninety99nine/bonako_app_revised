import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:bonako_demo/features/stores/widgets/stores_in_horizontal_list_view_infinite_scroll/stores_in_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/user/widgets/user_profile/user_orders_in_horizontal_list_view_infinite_scroll.dart';
import '../../../authentication/repositories/auth_repository.dart';
import '../../../user/widgets/user_profile/user_profile_avatar.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProfilePageContent extends StatefulWidget {

  const ProfilePageContent({super.key});

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {

  User get user => authProvider.user!;
  AuthRepository get authRepository => authProvider.authRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /// Profile
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                child: UserProfile(user: user)
              ),
          
              /// Spacer
              const SizedBox(height: 24),
        
              /// Orders
              UserOrdersInHorizontalListViewInfiniteScroll(
                user: user
              ),
          
              /// Spacer
              const SizedBox(height: 16),
        
              const StoresInHorizontalListViewInfiniteScroll(
                userAssociation: UserAssociation.customer,
              ),
          
              /// Spacer
              const SizedBox(height: 16),
        
              const StoresInHorizontalListViewInfiniteScroll(
                userAssociation: UserAssociation.recentVisiter,
              ),
              /// Spacer
              const SizedBox(height: 100),
        
              /*
              /// Spacer
              const SizedBox(height: 60),
        
              /// Re-order
              const CustomTitleMediumText('2 communities'),
          
              /// Re-order
              const CustomTitleMediumText('joined @'),
          
              /// Re-order
              const CustomTitleMediumText('my stores'),
          
              /// Spacer
              const SizedBox(height: 24),
          
              /// My Orders
              const CustomTitleMediumText('Home & Work Address (Add / Edit)'),
          
              /// Spacer
              const SizedBox(height: 24),
          
              /// My Orders
              const CustomTitleMediumText('My Orders'),
          
              /// Spacer
              const SizedBox(height: 24),
          
              /// Re-order
              const CustomTitleMediumText('Re-order'),
          
              /// Spacer
              const SizedBox(height: 24),
          
              /// Recent Visits
              const CustomTitleMediumText('Recent Visits'),
          
              /// Spacer
              const SizedBox(height: 24),
          
              /// Re-order
              const CustomTitleMediumText('Following: Local Business I Support'),
              */
              
            ],
          ),
        ),
      ),
    );
  }
}