class DeviceModel {
  final String deviceId;
  final int version;
  final String deviceName;
  final String deviceType;
  final String os;
  final String osVersion;
  final String manufacturer;
  final String model;

  const DeviceModel({
    required this.deviceId,
    required this.version,
    required this.deviceName,
    required this.deviceType,
    required this.os,
    required this.osVersion,
    required this.manufacturer,
    required this.model,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceID': deviceId,
      'version': version,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'os': os,
      'osVersion': osVersion,
      'manufacturer': manufacturer,
      'model': model,
    };
  }
}

class LoginRequestModel {
  final String email;
  final String password;
  final String clientType;
  final DeviceModel device;

  const LoginRequestModel({
    required this.email,
    required this.password,
    required this.clientType,
    required this.device,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'clientType': clientType,
      'device': device.toJson(),
    };
  }
}

class TokenModel {
  final String accessToken;
  final DateTime accessTokenExpiresAtUtc;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;

  const TokenModel({
    required this.accessToken,
    required this.accessTokenExpiresAtUtc,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAtUtc: DateTime.parse(
        json['accessTokenExpiresAtUtc'] as String,
      ),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAtUtc: DateTime.parse(
        json['refreshTokenExpiresAtUtc'] as String,
      ),
    );
  }
}
