import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class NetworkFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class CacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UnAuthorizedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UnknownFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidSessionFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class FailureWithMessage extends Failure {
  final String message;
  FailureWithMessage({required this.message});
  @override
  List<Object?> get props => [];
}

class VerificationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NoDataFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}
