import '../../../core/shared_models/mobile_number.dart';

class TeamMembersInvitations {
  late int totalInvited;
  late int totalAlreadyInvited;
  late ExistingUsers existingUsersInvited;
  late NonExistingUsers nonExistingUsersInvited;
  late ExistingUsers existingUsersAlreadyInvited;
  late NonExistingUsers nonExistingUsersAlreadyInvited;

  TeamMembersInvitations.fromJson(Map<String, dynamic> json) {
    totalInvited = json['totalInvited'];
    totalAlreadyInvited = json['totalAlreadyInvited'];
    existingUsersInvited = ExistingUsers.fromJson(json['existingUsersInvited']);
    nonExistingUsersInvited = NonExistingUsers.fromJson(json['nonExistingUsersInvited']);
    existingUsersAlreadyInvited = ExistingUsers.fromJson(json['existingUsersAlreadyInvited']);
    nonExistingUsersAlreadyInvited = NonExistingUsers.fromJson(json['nonExistingUsersAlreadyInvited']);
  }
  
}

class ExistingUsers {
  late int total;
  late List<ExistingUser> existingUsers;

  ExistingUsers.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    existingUsers = (json['existingUsers'] as List).map((existingUser) => ExistingUser.fromJson(existingUser)).toList();
  }
}

class ExistingUser {
  late String name;
  late String teamMemberStatus;
  late MobileNumber mobileNumber;

  ExistingUser.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    teamMemberStatus = json['teamMemberStatus'];
    mobileNumber = MobileNumber.fromJson(json['mobileNumber']);
  }
}

class NonExistingUsers {
  late int total;
  late List<NonExistingUser> nonExistingUsers;

  NonExistingUsers.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    nonExistingUsers = (json['nonExistingUsers'] as List).map((nonExistingUser) => NonExistingUser.fromJson(nonExistingUser)).toList();
  }
}

class NonExistingUser {
  late String teamMemberStatus;
  late MobileNumber mobileNumber;

  NonExistingUser.fromJson(Map<String, dynamic> json) {
    teamMemberStatus = json['teamMemberStatus'];
    mobileNumber = MobileNumber.fromJson(json['mobileNumber']);
  }
}