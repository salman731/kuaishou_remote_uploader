class KuaishouLiveUser {
  KuaishouLiveUser({
    required this.data,
  });

  final Data? data;

  factory KuaishouLiveUser.fromJson(Map<String, dynamic> json){
    return KuaishouLiveUser(
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

}

class Data {
  Data({
    required this.list,
  });

  final List<ListElement> list;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      list: json["list"] == null ? [] : List<ListElement>.from(json["list"]!.map((x) => ListElement.fromJson(x))),
    );
  }

}

class ListElement {
  ListElement({
    required this.id,
    required this.poster,
    required this.playUrls,
    required this.caption,
    required this.statrtTime,
    required this.author,
    required this.gameInfo,
    required this.hasRedPack,
    required this.hasBet,
    required this.followed,
    required this.expTag,
    required this.hotIcon,
    required this.living,
    required this.quality,
    required this.qualityLabel,
    required this.watchingCount,
    required this.landscape,
    required this.likeCount,
    required this.type,
  });

  final String? id;
  final String? poster;
  final List<PlayUrl> playUrls;
  final String? caption;
  final int? statrtTime;
  final Author? author;
  final GameInfo? gameInfo;
  final bool? hasRedPack;
  final bool? hasBet;
  final bool? followed;
  final String? expTag;
  final String? hotIcon;
  final bool? living;
  final String? quality;
  final String? qualityLabel;
  final String? watchingCount;
  final bool? landscape;
  final String? likeCount;
  final String? type;

  factory ListElement.fromJson(Map<String, dynamic> json){
    return ListElement(
      id: json["id"],
      poster: json["poster"],
      playUrls: json["playUrls"] == null ? [] : List<PlayUrl>.from(json["playUrls"]!.map((x) => PlayUrl.fromJson(x))),
      caption: json["caption"],
      statrtTime: json["statrtTime"],
      author: json["author"] == null ? null : Author.fromJson(json["author"]),
      gameInfo: json["gameInfo"] == null ? null : GameInfo.fromJson(json["gameInfo"]),
      hasRedPack: json["hasRedPack"],
      hasBet: json["hasBet"],
      followed: json["followed"],
      expTag: json["expTag"],
      hotIcon: json["hotIcon"],
      living: json["living"],
      quality: json["quality"],
      qualityLabel: json["qualityLabel"],
      watchingCount: json["watchingCount"],
      landscape: json["landscape"],
      likeCount: json["likeCount"],
      type: json["type"],
    );
  }

}

class Author {
  Author({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.sex,
    required this.living,
    required this.followStatus,
    required this.constellation,
    required this.cityName,
    required this.originUserId,
    required this.privacy,
    required this.isNew,
    required this.timestamp,
    required this.verifiedStatus,
    required this.bannedStatus,
    required this.counts,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? avatar;
  final String? sex;
  final bool? living;
  final String? followStatus;
  final String? constellation;
  final String? cityName;
  final int? originUserId;
  final bool? privacy;
  final bool? isNew;
  final int? timestamp;
  final VerifiedStatus? verifiedStatus;
  final BannedStatus? bannedStatus;
  final Counts? counts;

  factory Author.fromJson(Map<String, dynamic> json){
    return Author(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      avatar: json["avatar"],
      sex: json["sex"],
      living: json["living"],
      followStatus: json["followStatus"],
      constellation: json["constellation"],
      cityName: json["cityName"],
      originUserId: json["originUserId"],
      privacy: json["privacy"],
      isNew: json["isNew"],
      timestamp: json["timestamp"],
      verifiedStatus: json["verifiedStatus"] == null ? null : VerifiedStatus.fromJson(json["verifiedStatus"]),
      bannedStatus: json["bannedStatus"] == null ? null : BannedStatus.fromJson(json["bannedStatus"]),
      counts: json["counts"] == null ? null : Counts.fromJson(json["counts"]),
    );
  }

}

class BannedStatus {
  BannedStatus({
    required this.banned,
    required this.socialBanned,
    required this.isolate,
    required this.defriend,
  });

  final bool? banned;
  final bool? socialBanned;
  final bool? isolate;
  final bool? defriend;

  factory BannedStatus.fromJson(Map<String, dynamic> json){
    return BannedStatus(
      banned: json["banned"],
      socialBanned: json["socialBanned"],
      isolate: json["isolate"],
      defriend: json["defriend"],
    );
  }

}

class Counts {
  Counts({required this.json});
  final Map<String,dynamic> json;

  factory Counts.fromJson(Map<String, dynamic> json){
    return Counts(
        json: json
    );
  }

}

class VerifiedStatus {
  VerifiedStatus({
    required this.verified,
    required this.description,
    required this.type,
    required this.verifiedStatusNew,
  });

  final bool? verified;
  final String? description;
  final int? type;
  final bool? verifiedStatusNew;

  factory VerifiedStatus.fromJson(Map<String, dynamic> json){
    return VerifiedStatus(
      verified: json["verified"],
      description: json["description"],
      type: json["type"],
      verifiedStatusNew: json["new"],
    );
  }

}

class GameInfo {
  GameInfo({
    required this.id,
    required this.name,
    required this.poster,
  });

  final int? id;
  final String? name;
  final String? poster;

  factory GameInfo.fromJson(Map<String, dynamic> json){
    return GameInfo(
      id: json["id"],
      name: json["name"],
      poster: json["poster"],
    );
  }

}

class PlayUrl {
  PlayUrl({
    required this.hideAuto,
    required this.autoDefaultSelect,
    required this.cdnFeature,
    required this.businessType,
    required this.freeTrafficCdn,
    required this.version,
    required this.type,
    required this.adaptationSet,
  });

  final bool? hideAuto;
  final bool? autoDefaultSelect;
  final List<dynamic> cdnFeature;
  final int? businessType;
  final bool? freeTrafficCdn;
  final String? version;
  final String? type;
  final AdaptationSet? adaptationSet;

  factory PlayUrl.fromJson(Map<String, dynamic> json){
    return PlayUrl(
      hideAuto: json["hideAuto"],
      autoDefaultSelect: json["autoDefaultSelect"],
      cdnFeature: json["cdnFeature"] == null ? [] : List<dynamic>.from(json["cdnFeature"]!.map((x) => x)),
      businessType: json["businessType"],
      freeTrafficCdn: json["freeTrafficCdn"],
      version: json["version"],
      type: json["type"],
      adaptationSet: json["adaptationSet"] == null ? null : AdaptationSet.fromJson(json["adaptationSet"]),
    );
  }

}

class AdaptationSet {
  AdaptationSet({
    required this.gopDuration,
    required this.representation,
  });

  final int? gopDuration;
  final List<Representation> representation;

  factory AdaptationSet.fromJson(Map<String, dynamic> json){
    return AdaptationSet(
      gopDuration: json["gopDuration"],
      representation: json["representation"] == null ? [] : List<Representation>.from(json["representation"]!.map((x) => Representation.fromJson(x))),
    );
  }

}

class Representation {
  Representation({
    required this.id,
    required this.url,
    required this.bitrate,
    required this.qualityType,
    required this.level,
    required this.name,
    required this.shortName,
    required this.hidden,
    required this.enableAdaptive,
    required this.defaultSelect,
  });

  final int? id;
  final String? url;
  final int? bitrate;
  final String? qualityType;
  final int? level;
  final String? name;
  final String? shortName;
  final bool? hidden;
  final bool? enableAdaptive;
  final bool? defaultSelect;

  factory Representation.fromJson(Map<String, dynamic> json){
    return Representation(
      id: json["id"],
      url: json["url"],
      bitrate: json["bitrate"],
      qualityType: json["qualityType"],
      level: json["level"],
      name: json["name"],
      shortName: json["shortName"],
      hidden: json["hidden"],
      enableAdaptive: json["enableAdaptive"],
      defaultSelect: json["defaultSelect"],
    );
  }

}
