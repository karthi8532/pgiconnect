class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() {
    return "AppException: $message (Status Code: $statusCode)";
  }
}

class BadRequestException extends AppException {
  BadRequestException(super.message) : super(statusCode: 400);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends AppException {
  NotFoundException(super.message) : super(statusCode: 404);
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException(super.message) : super(statusCode: 500);
}

class NoInternetException extends AppException {
  NoInternetException(super.message);
}

class TimeoutException extends AppException {
  TimeoutException(super.message);
}
