class NotConnectedException {}

class CantReachException {}

class InternalServerErrorException {}

class NotFoundException {}

class BadRequestException {
  int statusCode;

  BadRequestException({this.statusCode});
}

class UnknownAPIErrorException {
  int statusCode;
  dynamic data;

  UnknownAPIErrorException({this.statusCode, this.data});
}
