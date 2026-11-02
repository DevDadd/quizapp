import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:quizapp/authentication/model/users.dart';

part 'user_controller_state.g.dart';

@CopyWith()
class UserControllerState extends Equatable {
  const UserControllerState({this.user});
  final User? user;
  @override
  List<Object?> get props => [user];
}
