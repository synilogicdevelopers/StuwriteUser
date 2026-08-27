import 'package:stuwrite_user/interface/repo_interface.dart';

abstract class NotificationRepositoryInterface implements RepositoryInterface{
  Future<dynamic>  seenNotification(int id);

}