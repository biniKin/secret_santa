import 'package:secrete_santa/models/user_model.dart';

class GroupModel {
  final String groupId;
  final String groupName;
  final List<UserModel> members;
  final DateTime exchangeDate;

  GroupModel({
    required this.groupName,
    required this.exchangeDate,
    required this.groupId,
    required this.members
  });

  factory GroupModel.fromJson(Map<String, dynamic> json){
    return GroupModel(
      groupName: json['groupName'], 
      exchangeDate: json['exchangeDate'], 
      groupId: json['groupId'],
      members: json['members'],
    );
  }

}