import 'bioanalyst_info.dart';
import 'user_info.dart';

class AuxBioanalyst {
  final UserInfo user;
  final BioanalystInfo bioanalyst;

  AuxBioanalyst({
    required this.user,
    required this.bioanalyst,
  });

  factory AuxBioanalyst.fromJson(Map<String, dynamic> json) {
    return AuxBioanalyst(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      bioanalyst: BioanalystInfo.fromJson(
        json['bioanalyst'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'bioanalyst': bioanalyst.toJson(),
    };
  }

  AuxBioanalyst copyWith({
    UserInfo? user,
    BioanalystInfo? bioanalyst,
  }) {
    return AuxBioanalyst(
      user: user ?? this.user,
      bioanalyst: bioanalyst ?? this.bioanalyst,
    );
  }
}
