import '../../../team_members/widgets/team_member_invitations_show/team_member_invitation_status.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_models/user.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {

  final User user;

  const UserProfile({
    super.key,
    required this.user
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  User get user => widget.user;
  String get name => user.attributes.name;
  String get mobileNumber {
    if(user.mobileNumber != null) {
      
      return user.mobileNumber!.withoutExtension;
    
    }else{

      /// Get the mobile number through the user association attribute.
      /// This occurs if this is a Guest user (non-existing user) who
      /// was invited to join a store as a team member.
      if(user.attributes.userAssociationAsTeamMember != null) {
        if(user.attributes.userAssociationAsTeamMember!.mobileNumber != null) {
          return user.attributes.userAssociationAsTeamMember!.mobileNumber!.withoutExtension;
        }
      /// Get the mobile number through the user association attribute.
      /// This occurs if this is a Guest user (non-existing user) who
      /// was invited to join a store as a follower.
      }else if(user.attributes.userAssociationAsFollower != null) {
        if(user.attributes.userAssociationAsFollower!.mobileNumber != null) {
          return user.attributes.userAssociationAsFollower!.mobileNumber!.withoutExtension;
        }
      }

      return '';
    }
  }

  String get acceptedInvitation {

    /// Get the invitation status through the user association attribute.
    if(user.attributes.userAssociationAsTeamMember != null) {
      return user.attributes.userAssociationAsTeamMember!.acceptedInvitation.name;
    /// Get the invitation status through the user association attribute.
    }else if(user.attributes.userAssociationAsFollower != null) {
      return user.attributes.userAssociationAsFollower!.acceptedInvitation.name;
    }else{
      return '';
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    
            /// Avatar
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
    
            /// Spacer
            const SizedBox(width: 16),
    
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    
                /// Name
                CustomTitleMediumText(name),
    
                /// Spacer
                if(acceptedInvitation.isNotEmpty) const SizedBox(height: 4),
                
                /// Accepted Invitation Status
                if(acceptedInvitation.isNotEmpty) TeamMemberInvitationStatus(
                  acceptedInvitation: acceptedInvitation,
                  dotPlacement: 'left'
                ),
    
                /// Spacer
                const SizedBox(height: 4),
    
                /// Mobile Number
                CustomBodyText(mobileNumber, lightShade: true,),
              ],

            )
    
          ],
        ),
      ],
    );
  }
}