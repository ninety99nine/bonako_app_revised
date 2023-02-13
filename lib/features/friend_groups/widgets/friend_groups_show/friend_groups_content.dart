import 'package:bonako_demo/features/friend_groups/providers/friend_group_provider.dart';
import 'package:bonako_demo/features/friend_groups/repositories/friend_group_repository.dart';
import 'package:provider/provider.dart';

import '../friend_group_create_or_update/friend_group_create_or_update.dart';
import '../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'friend_groups_in_vertical_infinite_scroll.dart';
import '../friend_groups_show/friend_group_menus.dart';
import 'friend_groups_page/friend_groups_page.dart';
import '../../enums/friend_group_enums.dart';
import '../../models/friend_group.dart';
import 'package:flutter/material.dart';

class FriendGroupsContent extends StatefulWidget {
  
  final bool showingFullPage;
  final bool enableBulkSelection;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;

  const FriendGroupsContent({
    super.key,
    this.onSelectedFriendGroups,
    this.showingFullPage = false,
    required this.enableBulkSelection,
  });

  @override
  State<FriendGroupsContent> createState() => _FriendGroupsContentState();
}

class _FriendGroupsContentState extends State<FriendGroupsContent> {

  FriendGroup? friendGroup;
  Menu selectedMenu = Menu.groups;
  List<FriendGroup> friendGroups = [];
  bool disableFloatingActionButton = false;
  FriendGroupContentView friendGroupContentView = FriendGroupContentView.viewingFriendGroups;

  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  bool get enableBulkSelection => widget.enableBulkSelection;
  bool get hasSelectedFriendGroups => friendGroups.isNotEmpty;
  bool get hasSelectedGroupsMenu => selectedMenu == Menu.groups;
  bool get isViewingAny => (isViewingGroups || isViewingSharedGroups);
  bool get hasSelectedSharedGroupsMenu => selectedMenu == Menu.sharedGroups;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  bool get isViewingGroup => hasSelectedGroupsMenu && friendGroupContentView == FriendGroupContentView.viewingFriendGroup;
  bool get isViewingGroups => hasSelectedGroupsMenu && friendGroupContentView == FriendGroupContentView.viewingFriendGroups;
  bool get isViewingSharedGroup => hasSelectedSharedGroupsMenu && friendGroupContentView == FriendGroupContentView.viewingFriendGroup;
  bool get isViewingSharedGroups => hasSelectedSharedGroupsMenu && friendGroupContentView == FriendGroupContentView.viewingFriendGroups;

  String get subtitle {

    if(isViewingGroups) {
      return 'Select your group';
    }else if(isViewingSharedGroups) {
      return 'Select a shared group';
    }else{
      return 'Add a new group';
    }

  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the friend groups content
    if(isViewingGroups || isViewingSharedGroups) {

      /// Set the filter for the groups that we want to show
      final filter = selectedMenu == Menu.groups ? 'Created' : 'Shared';

      /// Show friend groups view
      return FriendGroupsInVerticalInfiniteScroll(
        filter: filter,
        key: ValueKey(filter),
        onViewFriendGroup: onViewFriendGroup,
        onSelectedFriendGroups: onSelectedFriendGroups,
        onDeletingFriendGroups: onDisableFloatingActionButton,
      );

    /// If we want to view the friend group content
    }else if(isViewingGroup || isViewingSharedGroup) {

      /// Show friend groups view
      return FriendGroupCreateOrUpdate(
        friendGroup: friendGroup!,
        onUpdatedFriendGroup: onUpdatedFriendGroup,
        onSubmitting: onDisableFloatingActionButton,
      );

    /// If we want to view the friend group create content
    }else{

      /// Show the friend group create content
      return FriendGroupCreateOrUpdate(
        onCreatedFriendGroup: onCreatedFriendGroup,
        onSubmitting: onDisableFloatingActionButton,
      );

    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    String text = 'Back';
    Color color = Colors.grey;
    IconData? prefixIcon = Icons.keyboard_double_arrow_left;

    if(isViewingGroups || isViewingSharedGroups) {

      prefixIcon = Icons.add;
      color = Colors.green;

      if(hasSelectedFriendGroups) {

        text = 'Done';
        prefixIcon = null;

      }else if(isViewingGroups || isViewingSharedGroups) {
        text = 'Add Group';
      }

    }

    return CustomElevatedButton(
      text,
      width: 120,
      color: color,
      prefixIcon: prefixIcon,
      onPressed: floatingActionButtonOnPressed,
    );

  }

  /// Action to be called when the floacting action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we should disable the floating action button, then do nothing
    if(disableFloatingActionButton) return; 

    /// If we are done selecting friend groups
    if(hasSelectedFriendGroups) {
              
      /// Close the Modal Bottom Sheet
      onDoneSelectingFriendGroups();

    /// If we are viewing the friend groups content
    }else if(isViewingGroups || isViewingSharedGroups) {

      /// Change to the friend group create view
      changeGroupContentView(FriendGroupContentView.creatingFriendGroup);

    }else{

      /// Change to show friend groups view
      changeGroupContentView(FriendGroupContentView.viewingFriendGroups);

    }

  }

  /// Close the Modal Bottom Sheet since we are done
  void onDoneSelectingFriendGroups() {
    
    Navigator.of(context).pop();

    requestUpdateLastSelectedFriendGroups();

  }

  /// Update the date and time of these selected friend groups
  void requestUpdateLastSelectedFriendGroups() {

    if(hasSelectedFriendGroups) {
      friendGroupRepository.updateLastSelectedFriendGroups(
        friendGroups: friendGroups,
        context: context,
      );
    }

  }

  /// While waiting for an operation to complete disable the 
  /// floating action button so that it is no longer 
  /// performs any actions when clicked
  void onDisableFloatingActionButton(bool status) => disableFloatingActionButton = status;

  /// Called so that we can show the friend groups
  /// view after creating a friend group
  void onCreatedFriendGroup() {
    changeGroupContentView(FriendGroupContentView.viewingFriendGroups);
  }

  /// Called so that we can show the friend groups
  /// view after updating a friend group
  void onUpdatedFriendGroup() {
    changeGroupContentView(FriendGroupContentView.viewingFriendGroups);
  }

  /// Called when the friend groups are selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {
    setState(() => this.friendGroups = friendGroups);

    if(widget.onSelectedFriendGroups != null) {

      /// Notify parent on selected friend groups
      widget.onSelectedFriendGroups!(friendGroups);

    }

    if(enableBulkSelection == false) onDoneSelectingFriendGroups();
  }

  /// Called to change the view from viewing multiple friend groups
  /// to viewing one specific friend group
  void onViewFriendGroup(FriendGroup friendGroup) {
    this.friendGroup = friendGroup;
    changeGroupContentView(FriendGroupContentView.viewingFriendGroup);
  }

  /// Called when the primary content view has been changed,
  /// such as changing from "Groups" to "Shared Groups"
  void onSelectedMenu(Menu selectedMenu) {

    /// Reset the selected friends and friend groups
    friendGroups = [];
    friendGroup = null;
      
    /// Reset the initial friend and friend group views
    friendGroupContentView = FriendGroupContentView.viewingFriendGroups;
    
    setState(() => this.selectedMenu = selectedMenu);
  }

  /// Called to change the view to the specified view
  void changeGroupContentView(FriendGroupContentView friendGroupContentView) {
    setState(() => this.friendGroupContentView = friendGroupContentView);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(friendGroupContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      const CustomTitleLargeText('Groups', padding: EdgeInsets.only(bottom: 8),),
                      
                      /// Subtitle
                      AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: Align(
                          key: ValueKey(subtitle),
                          alignment: Alignment.centerLeft,
                          child: CustomBodyText(subtitle),
                        )
                      ),
                  
                      //  Filter
                      if(isViewingAny) FriendGroupMenus(
                        selectedMenu: selectedMenu,
                        onSelectedMenu: onSelectedMenu,
                      ),
                      
                    ],
                  ),
                ),
          
                /// Content
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    color: Colors.white,
                    child: content,
                  ),
                )
            
              ],
            ),
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Navigator.of(context).pop();
                
                /// Navigate to the page
                Navigator.of(context).pushNamed(FriendGroupsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            top: (isViewingAny ? 116 : 60) + topPadding,
            duration: const Duration(milliseconds: 500),
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}