class BadRequestException implements Exception {
  String message;

  BadRequestException(this.message);
}

class ConflictException implements Exception {
  String message;

  ConflictException(this.message);
}

class ServerException implements Exception {
  String message;

  ServerException(this.message);
}

class ForbiddenException implements Exception {
  String message;

  ForbiddenException(this.message);
}
