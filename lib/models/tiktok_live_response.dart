class TiktokLiveResponse {
  TiktokLiveResponse({
    required this.statusCode,
    required this.extra,
    required this.data,
  });

  final int? statusCode;
  final Extra? extra;
  final List<TiktokUser> data;

  factory TiktokLiveResponse.fromJson(Map<String, dynamic> json){
    return TiktokLiveResponse(
      statusCode: json["status_code"],
      extra: json["extra"] == null ? null : Extra.fromJson(json["extra"]),
      data: json["data"] == null ? [] : List<TiktokUser>.from(json["data"]!.map((x) => TiktokUser.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "extra": extra?.toJson(),
    "data": data.map((x) => x?.toJson()).toList(),
  };

}

class TiktokUser {
  TiktokUser({
    required this.type,
    required this.rid,
    required this.data,
    required this.liveReason,
    required this.flareInfo,
    required this.sortStatsTags,
    required this.roomEventTracking,
  });

  final int? type;
  final String? rid;
  final Data? data;
  final String? liveReason;
  final Banner? flareInfo;
  final SortStatsTags? sortStatsTags;
  final String? roomEventTracking;

  factory TiktokUser.fromJson(Map<String, dynamic> json){
    return TiktokUser(
      type: json["type"],
      rid: json["rid"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      liveReason: json["live_reason"],
      flareInfo: json["flare_info"] == null ? null : Banner.fromJson(json["flare_info"]),
      sortStatsTags: json["sort_stats_tags"] == null ? null : SortStatsTags.fromJson(json["sort_stats_tags"]),
      roomEventTracking: json["room_event_tracking"],
    );
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "rid": rid,
    "data": data?.toJson(),
    "live_reason": liveReason,
    "flare_info": flareInfo?.toJson(),
    "sort_stats_tags": sortStatsTags?.toJson(),
    "room_event_tracking": roomEventTracking,
  };

}

class Data {
  Data({
    required this.id,
    required this.idStr,
    required this.status,
    required this.ownerUserId,
    required this.title,
    required this.userCount,
    required this.osType,
    required this.clientVersion,
    required this.cover,
    required this.streamUrl,
    required this.stats,
    required this.feedRoomLabel,
    required this.owner,
    required this.roomAuth,
    required this.likeCount,
    required this.anchorTabType,
    required this.commerceInfo,
    required this.interactionQuestionVersion,
    required this.streamUrlFilteredInfo,
    required this.blurredCover,
    required this.taxonomyTagInfo,
    required this.hashtag,
    required this.linkMic,
    required this.feedRoomLabels,
    required this.liveTypeThirdParty,
    required this.liveRoomMode,
    required this.squareCoverImg,
    required this.rectangleCoverImg,
  });

  final int? id;
  final String? idStr;
  final int? status;
  final int? ownerUserId;
  final String? title;
  final int? userCount;
  final int? osType;
  final int? clientVersion;
  final BlurredCover? cover;
  final StreamUrl? streamUrl;
  final Stats? stats;
  final RectangleCoverImgClass? feedRoomLabel;
  final Owner? owner;
  final RoomAuth? roomAuth;
  final int? likeCount;
  final int? anchorTabType;
  final Banner? commerceInfo;
  final int? interactionQuestionVersion;
  final Banner? streamUrlFilteredInfo;
  final BlurredCover? blurredCover;
  final TaxonomyTagInfo? taxonomyTagInfo;
  final Hashtag? hashtag;
  final LinkMic? linkMic;
  final List<FeedRoomLabelElement> feedRoomLabels;
  final bool? liveTypeThirdParty;
  final int? liveRoomMode;
  final BlurredCover? squareCoverImg;
  final RectangleCoverImgClass? rectangleCoverImg;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      id: json["id"],
      idStr: json["id_str"],
      status: json["status"],
      ownerUserId: json["owner_user_id"],
      title: json["title"],
      userCount: json["user_count"],
      osType: json["os_type"],
      clientVersion: json["client_version"],
      cover: json["cover"] == null ? null : BlurredCover.fromJson(json["cover"]),
      streamUrl: json["stream_url"] == null ? null : StreamUrl.fromJson(json["stream_url"]),
      stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
      feedRoomLabel: json["feed_room_label"] == null ? null : RectangleCoverImgClass.fromJson(json["feed_room_label"]),
      owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
      roomAuth: json["room_auth"] == null ? null : RoomAuth.fromJson(json["room_auth"]),
      likeCount: json["like_count"],
      anchorTabType: json["anchor_tab_type"],
      commerceInfo: json["commerce_info"] == null ? null : Banner.fromJson(json["commerce_info"]),
      interactionQuestionVersion: json["interaction_question_version"],
      streamUrlFilteredInfo: json["stream_url_filtered_info"] == null ? null : Banner.fromJson(json["stream_url_filtered_info"]),
      blurredCover: json["blurred_cover"] == null ? null : BlurredCover.fromJson(json["blurred_cover"]),
      taxonomyTagInfo: json["taxonomy_tag_info"] == null ? null : TaxonomyTagInfo.fromJson(json["taxonomy_tag_info"]),
      hashtag: json["hashtag"] == null ? null : Hashtag.fromJson(json["hashtag"]),
      linkMic: json["link_mic"] == null ? null : LinkMic.fromJson(json["link_mic"]),
      feedRoomLabels: json["feed_room_labels"] == null ? [] : List<FeedRoomLabelElement>.from(json["feed_room_labels"]!.map((x) => FeedRoomLabelElement.fromJson(x))),
      liveTypeThirdParty: json["live_type_third_party"],
      liveRoomMode: json["live_room_mode"],
      squareCoverImg: json["square_cover_img"] == null ? null : BlurredCover.fromJson(json["square_cover_img"]),
      rectangleCoverImg: json["rectangle_cover_img"] == null ? null : RectangleCoverImgClass.fromJson(json["rectangle_cover_img"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_str": idStr,
    "status": status,
    "owner_user_id": ownerUserId,
    "title": title,
    "user_count": userCount,
    "os_type": osType,
    "client_version": clientVersion,
    "cover": cover?.toJson(),
    "stream_url": streamUrl?.toJson(),
    "stats": stats?.toJson(),
    "feed_room_label": feedRoomLabel?.toJson(),
    "owner": owner?.toJson(),
    "room_auth": roomAuth?.toJson(),
    "like_count": likeCount,
    "anchor_tab_type": anchorTabType,
    "commerce_info": commerceInfo?.toJson(),
    "interaction_question_version": interactionQuestionVersion,
    "stream_url_filtered_info": streamUrlFilteredInfo?.toJson(),
    "blurred_cover": blurredCover?.toJson(),
    "taxonomy_tag_info": taxonomyTagInfo?.toJson(),
    "hashtag": hashtag?.toJson(),
    "link_mic": linkMic?.toJson(),
    "feed_room_labels": feedRoomLabels.map((x) => x?.toJson()).toList(),
    "live_type_third_party": liveTypeThirdParty,
    "live_room_mode": liveRoomMode,
    "square_cover_img": squareCoverImg?.toJson(),
    "rectangle_cover_img": rectangleCoverImg?.toJson(),
  };

}

class BlurredCover {
  BlurredCover({
    required this.urlList,
    required this.uri,
    required this.height,
    required this.width,
    required this.avgColor,
  });

  final List<String> urlList;
  final String? uri;
  final int? height;
  final int? width;
  final String? avgColor;

  factory BlurredCover.fromJson(Map<String, dynamic> json){
    return BlurredCover(
      urlList: json["url_list"] == null ? [] : List<String>.from(json["url_list"]!.map((x) => x)),
      uri: json["uri"],
      height: json["height"],
      width: json["width"],
      avgColor: json["avg_color"],
    );
  }

  Map<String, dynamic> toJson() => {
    "url_list": urlList.map((x) => x).toList(),
    "uri": uri,
    "height": height,
    "width": width,
    "avg_color": avgColor,
  };

}

class Banner {
  Banner({required this.json});
  final Map<String,dynamic> json;

  factory Banner.fromJson(Map<String, dynamic> json){
    return Banner(
        json: json
    );
  }

  Map<String, dynamic> toJson() => {
  };

}

class RectangleCoverImgClass {
  RectangleCoverImgClass({
    required this.urlList,
    required this.uri,
    required this.avgColor,
  });

  final List<String> urlList;
  final String? uri;
  final String? avgColor;

  factory RectangleCoverImgClass.fromJson(Map<String, dynamic> json){
    return RectangleCoverImgClass(
      urlList: json["url_list"] == null ? [] : List<String>.from(json["url_list"]!.map((x) => x)),
      uri: json["uri"],
      avgColor: json["avg_color"],
    );
  }

  Map<String, dynamic> toJson() => {
    "url_list": urlList.map((x) => x).toList(),
    "uri": uri,
    "avg_color": avgColor,
  };

}

class FeedRoomLabelElement {
  FeedRoomLabelElement({
    required this.position,
    required this.text,
    required this.icon,
    required this.logExtra,
    required this.backgroundColor,
  });

  final int? position;
  final tText? text;
  final RectangleCoverImgClass? icon;
  final String? logExtra;
  final String? backgroundColor;

  factory FeedRoomLabelElement.fromJson(Map<String, dynamic> json){
    return FeedRoomLabelElement(
      position: json["position"],
      text: json["text"] == null ? null : tText.fromJson(json["text"]),
      icon: json["icon"] == null ? null : RectangleCoverImgClass.fromJson(json["icon"]),
      logExtra: json["log_extra"],
      backgroundColor: json["background_color"],
    );
  }

  Map<String, dynamic> toJson() => {
    "position": position,
    "text": text?.toJson(),
    "icon": icon?.toJson(),
    "log_extra": logExtra,
    "background_color": backgroundColor,
  };

}

class tText {
  tText({
    required this.defaultPattern,
    required this.defaultFormat,
  });

  final String? defaultPattern;
  final DefaultFormat? defaultFormat;

  factory tText.fromJson(Map<String, dynamic> json){
    return tText(
      defaultPattern: json["default_pattern"],
      defaultFormat: json["default_format"] == null ? null : DefaultFormat.fromJson(json["default_format"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "default_pattern": defaultPattern,
    "default_format": defaultFormat?.toJson(),
  };

}

class DefaultFormat {
  DefaultFormat({
    required this.color,
    required this.weight,
  });

  final String? color;
  final int? weight;

  factory DefaultFormat.fromJson(Map<String, dynamic> json){
    return DefaultFormat(
      color: json["color"],
      weight: json["weight"],
    );
  }

  Map<String, dynamic> toJson() => {
    "color": color,
    "weight": weight,
  };

}

class Hashtag {
  Hashtag({
    required this.id,
    required this.title,
    required this.image,
  });

  final int? id;
  final String? title;
  final RectangleCoverImgClass? image;

  factory Hashtag.fromJson(Map<String, dynamic> json){
    return Hashtag(
      id: json["id"],
      title: json["title"],
      image: json["image"] == null ? null : RectangleCoverImgClass.fromJson(json["image"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image": image?.toJson(),
  };

}

class LinkMic {
  LinkMic({
    required this.linkedUserList,
  });

  final List<Owner> linkedUserList;

  factory LinkMic.fromJson(Map<String, dynamic> json){
    return LinkMic(
      linkedUserList: json["linked_user_list"] == null ? [] : List<Owner>.from(json["linked_user_list"]!.map((x) => Owner.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "linked_user_list": linkedUserList.map((x) => x?.toJson()).toList(),
  };

}

class Owner {
  Owner({
    required this.id,
    required this.nickname,
    required this.bioDescription,
    required this.avatarThumb,
    required this.avatarMedium,
    required this.avatarLarge,
    required this.status,
    required this.modifyTime,
    required this.followInfo,
    required this.payGrade,
    required this.userAttr,
    required this.ownRoom,
    required this.displayId,
    required this.secUid,
    required this.idStr,
    required this.mintTypeLabel,
    required this.linkMicStats,
  });

  final int? id;
  final String? nickname;
  final String? bioDescription;
  final Avatar? avatarThumb;
  final Avatar? avatarMedium;
  final Avatar? avatarLarge;
  final int? status;
  final int? modifyTime;
  final FollowInfo? followInfo;
  final Banner? payGrade;
  final Banner? userAttr;
  final OwnRoom? ownRoom;
  final String? displayId;
  final String? secUid;
  final String? idStr;
  final List<int> mintTypeLabel;
  final int? linkMicStats;

  factory Owner.fromJson(Map<String, dynamic> json){
    return Owner(
      id: json["id"],
      nickname: json["nickname"],
      bioDescription: json["bio_description"],
      avatarThumb: json["avatar_thumb"] == null ? null : Avatar.fromJson(json["avatar_thumb"]),
      avatarMedium: json["avatar_medium"] == null ? null : Avatar.fromJson(json["avatar_medium"]),
      avatarLarge: json["avatar_large"] == null ? null : Avatar.fromJson(json["avatar_large"]),
      status: json["status"],
      modifyTime: json["modify_time"],
      followInfo: json["follow_info"] == null ? null : FollowInfo.fromJson(json["follow_info"]),
      payGrade: json["pay_grade"] == null ? null : Banner.fromJson(json["pay_grade"]),
      userAttr: json["user_attr"] == null ? null : Banner.fromJson(json["user_attr"]),
      ownRoom: json["own_room"] == null ? null : OwnRoom.fromJson(json["own_room"]),
      displayId: json["display_id"],
      secUid: json["sec_uid"],
      idStr: json["id_str"],
      mintTypeLabel: json["mint_type_label"] == null ? [] : List<int>.from(json["mint_type_label"]!.map((x) => x)),
      linkMicStats: json["link_mic_stats"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nickname": nickname,
    "bio_description": bioDescription,
    "avatar_thumb": avatarThumb?.toJson(),
    "avatar_medium": avatarMedium?.toJson(),
    "avatar_large": avatarLarge?.toJson(),
    "status": status,
    "modify_time": modifyTime,
    "follow_info": followInfo?.toJson(),
    "pay_grade": payGrade?.toJson(),
    "user_attr": userAttr?.toJson(),
    "own_room": ownRoom?.toJson(),
    "display_id": displayId,
    "sec_uid": secUid,
    "id_str": idStr,
    "mint_type_label": mintTypeLabel.map((x) => x).toList(),
    "link_mic_stats": linkMicStats,
  };

}

class Avatar {
  Avatar({
    required this.urlList,
    required this.uri,
  });

  final List<String> urlList;
  final String? uri;

  factory Avatar.fromJson(Map<String, dynamic> json){
    return Avatar(
      urlList: json["url_list"] == null ? [] : List<String>.from(json["url_list"]!.map((x) => x)),
      uri: json["uri"],
    );
  }

  Map<String, dynamic> toJson() => {
    "url_list": urlList.map((x) => x).toList(),
    "uri": uri,
  };

}

class FollowInfo {
  FollowInfo({
    required this.followingCount,
    required this.followerCount,
    required this.followStatus,
  });

  final int? followingCount;
  final int? followerCount;
  final int? followStatus;

  factory FollowInfo.fromJson(Map<String, dynamic> json){
    return FollowInfo(
      followingCount: json["following_count"],
      followerCount: json["follower_count"],
      followStatus: json["follow_status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "following_count": followingCount,
    "follower_count": followerCount,
    "follow_status": followStatus,
  };

}

class OwnRoom {
  OwnRoom({
    required this.roomIds,
    required this.roomIdsStr,
  });

  final List<int> roomIds;
  final List<String> roomIdsStr;

  factory OwnRoom.fromJson(Map<String, dynamic> json){
    return OwnRoom(
      roomIds: json["room_ids"] == null ? [] : List<int>.from(json["room_ids"]!.map((x) => x)),
      roomIdsStr: json["room_ids_str"] == null ? [] : List<String>.from(json["room_ids_str"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "room_ids": roomIds.map((x) => x).toList(),
    "room_ids_str": roomIdsStr.map((x) => x).toList(),
  };

}

class RoomAuth {
  RoomAuth({
    required this.chat,
    required this.gift,
    required this.luckMoney,
    required this.digg,
    required this.userCard,
    required this.banner,
    required this.landscape,
    required this.publicScreen,
    required this.giftAnchorMt,
    required this.donationSticker,
    required this.interactionQuestion,
    required this.chatL2,
    required this.viewers,
    required this.share,
    required this.transactionHistory,
    required this.userCount,
    required this.rank,
    required this.broadcastMessage,
  });

  final bool? chat;
  final bool? gift;
  final bool? luckMoney;
  final bool? digg;
  final bool? userCard;
  final int? banner;
  final int? landscape;
  final int? publicScreen;
  final int? giftAnchorMt;
  final int? donationSticker;
  final bool? interactionQuestion;
  final bool? chatL2;
  final bool? viewers;
  final bool? share;
  final int? transactionHistory;
  final int? userCount;
  final int? rank;
  final int? broadcastMessage;

  factory RoomAuth.fromJson(Map<String, dynamic> json){
    return RoomAuth(
      chat: json["Chat"],
      gift: json["Gift"],
      luckMoney: json["LuckMoney"],
      digg: json["Digg"],
      userCard: json["UserCard"],
      banner: json["Banner"],
      landscape: json["Landscape"],
      publicScreen: json["PublicScreen"],
      giftAnchorMt: json["GiftAnchorMt"],
      donationSticker: json["DonationSticker"],
      interactionQuestion: json["InteractionQuestion"],
      chatL2: json["ChatL2"],
      viewers: json["Viewers"],
      share: json["Share"],
      transactionHistory: json["transaction_history"],
      userCount: json["UserCount"],
      rank: json["Rank"],
      broadcastMessage: json["BroadcastMessage"],
    );
  }

  Map<String, dynamic> toJson() => {
    "Chat": chat,
    "Gift": gift,
    "LuckMoney": luckMoney,
    "Digg": digg,
    "UserCard": userCard,
    "Banner": banner,
    "Landscape": landscape,
    "PublicScreen": publicScreen,
    "GiftAnchorMt": giftAnchorMt,
    "DonationSticker": donationSticker,
    "InteractionQuestion": interactionQuestion,
    "ChatL2": chatL2,
    "Viewers": viewers,
    "Share": share,
    "transaction_history": transactionHistory,
    "UserCount": userCount,
    "Rank": rank,
    "BroadcastMessage": broadcastMessage,
  };

}

class Stats {
  Stats({
    required this.totalUser,
    required this.enterCount,
    required this.shareCount,
  });

  final int? totalUser;
  final int? enterCount;
  final int? shareCount;

  factory Stats.fromJson(Map<String, dynamic> json){
    return Stats(
      totalUser: json["total_user"],
      enterCount: json["enter_count"],
      shareCount: json["share_count"],
    );
  }

  Map<String, dynamic> toJson() => {
    "total_user": totalUser,
    "enter_count": enterCount,
    "share_count": shareCount,
  };

}

class StreamUrl {
  StreamUrl({
    required this.rtmpPullUrl,
    required this.flvPullUrl,
    required this.flvPullUrlParams,
    required this.liveCoreSdkData,
    required this.streamSizeWidth,
    required this.streamSizeHeight,
  });

  final String? rtmpPullUrl;
  final FlvPullUrl? flvPullUrl;
  final FlvPullUrl? flvPullUrlParams;
  final LiveCoreSdkData? liveCoreSdkData;
  final int? streamSizeWidth;
  final int? streamSizeHeight;

  factory StreamUrl.fromJson(Map<String, dynamic> json){
    return StreamUrl(
      rtmpPullUrl: json["rtmp_pull_url"],
      flvPullUrl: json["flv_pull_url"] == null ? null : FlvPullUrl.fromJson(json["flv_pull_url"]),
      flvPullUrlParams: json["flv_pull_url_params"] == null ? null : FlvPullUrl.fromJson(json["flv_pull_url_params"]),
      liveCoreSdkData: json["live_core_sdk_data"] == null ? null : LiveCoreSdkData.fromJson(json["live_core_sdk_data"]),
      streamSizeWidth: json["stream_size_width"],
      streamSizeHeight: json["stream_size_height"],
    );
  }

  Map<String, dynamic> toJson() => {
    "rtmp_pull_url": rtmpPullUrl,
    "flv_pull_url": flvPullUrl?.toJson(),
    "flv_pull_url_params": flvPullUrlParams?.toJson(),
    "live_core_sdk_data": liveCoreSdkData?.toJson(),
    "stream_size_width": streamSizeWidth,
    "stream_size_height": streamSizeHeight,
  };

}

class FlvPullUrl {
  FlvPullUrl({
    required this.sd2,
    required this.sd1,
    required this.hd1,
    required this.fullHd1,
  });

  final String? sd2;
  final String? sd1;
  final String? hd1;
  final String? fullHd1;

  factory FlvPullUrl.fromJson(Map<String, dynamic> json){
    return FlvPullUrl(
      sd2: json["SD2"],
      sd1: json["SD1"],
      hd1: json["HD1"],
      fullHd1: json["FULL_HD1"],
    );
  }

  Map<String, dynamic> toJson() => {
    "SD2": sd2,
    "SD1": sd1,
    "HD1": hd1,
    "FULL_HD1": fullHd1,
  };

}

class LiveCoreSdkData {
  LiveCoreSdkData({
    required this.pullData,
  });

  final PullData? pullData;

  factory LiveCoreSdkData.fromJson(Map<String, dynamic> json){
    return LiveCoreSdkData(
      pullData: json["pull_data"] == null ? null : PullData.fromJson(json["pull_data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "pull_data": pullData?.toJson(),
  };

}

class PullData {
  PullData({
    required this.streamData,
    required this.options,
  });

  final String? streamData;
  final Options? options;

  factory PullData.fromJson(Map<String, dynamic> json){
    return PullData(
      streamData: json["stream_data"],
      options: json["options"] == null ? null : Options.fromJson(json["options"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "stream_data": streamData,
    "options": options?.toJson(),
  };

}

class Options {
  Options({
    required this.defaultQuality,
  });

  final DefaultQuality? defaultQuality;

  factory Options.fromJson(Map<String, dynamic> json){
    return Options(
      defaultQuality: json["default_quality"] == null ? null : DefaultQuality.fromJson(json["default_quality"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "default_quality": defaultQuality?.toJson(),
  };

}

class DefaultQuality {
  DefaultQuality({
    required this.name,
    required this.sdkKey,
  });

  final String? name;
  final String? sdkKey;

  factory DefaultQuality.fromJson(Map<String, dynamic> json){
    return DefaultQuality(
      name: json["name"],
      sdkKey: json["sdk_key"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "sdk_key": sdkKey,
  };

}

class TaxonomyTagInfo {
  TaxonomyTagInfo({
    required this.level1Tag,
    required this.level2Tag,
  });

  final List<String> level1Tag;
  final String? level2Tag;

  factory TaxonomyTagInfo.fromJson(Map<String, dynamic> json){
    return TaxonomyTagInfo(
      level1Tag: json["level1_tag"] == null ? [] : List<String>.from(json["level1_tag"]!.map((x) => x)),
      level2Tag: json["level2_tag"],
    );
  }

  Map<String, dynamic> toJson() => {
    "level1_tag": level1Tag.map((x) => x).toList(),
    "level2_tag": level2Tag,
  };

}

class SortStatsTags {
  SortStatsTags({
    required this.forAppLog,
    required this.forClientFunc,
  });

  final List<ForAppLog> forAppLog;
  final List<ForClientFunc> forClientFunc;

  factory SortStatsTags.fromJson(Map<String, dynamic> json){
    return SortStatsTags(
      forAppLog: json["for_app_log"] == null ? [] : List<ForAppLog>.from(json["for_app_log"]!.map((x) => ForAppLog.fromJson(x))),
      forClientFunc: json["for_client_func"] == null ? [] : List<ForClientFunc>.from(json["for_client_func"]!.map((x) => ForClientFunc.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "for_app_log": forAppLog.map((x) => x?.toJson()).toList(),
    "for_client_func": forClientFunc.map((x) => x?.toJson()).toList(),
  };

}

class ForAppLog {
  ForAppLog({
    required this.key,
    required this.value,
  });

  final String? key;
  final String? value;

  factory ForAppLog.fromJson(Map<String, dynamic> json){
    return ForAppLog(
      key: json["key"],
      value: json["value"],
    );
  }

  Map<String, dynamic> toJson() => {
    "key": key,
    "value": value,
  };

}

class ForClientFunc {
  ForClientFunc({
    required this.key,
  });

  final String? key;

  factory ForClientFunc.fromJson(Map<String, dynamic> json){
    return ForClientFunc(
      key: json["key"],
    );
  }

  Map<String, dynamic> toJson() => {
    "key": key,
  };

}

class Extra {
  Extra({
    required this.logPb,
    required this.cost,
    required this.maxTime,
    required this.total,
    required this.banner,
    required this.unreadExtra,
    required this.now,
  });

  final LogPb? logPb;
  final int? cost;
  final int? maxTime;
  final int? total;
  final Banner? banner;
  final String? unreadExtra;
  final int? now;

  factory Extra.fromJson(Map<String, dynamic> json){
    return Extra(
      logPb: json["log_pb"] == null ? null : LogPb.fromJson(json["log_pb"]),
      cost: json["cost"],
      maxTime: json["max_time"],
      total: json["total"],
      banner: json["banner"] == null ? null : Banner.fromJson(json["banner"]),
      unreadExtra: json["unread_extra"],
      now: json["now"],
    );
  }

  Map<String, dynamic> toJson() => {
    "log_pb": logPb?.toJson(),
    "cost": cost,
    "max_time": maxTime,
    "total": total,
    "banner": banner?.toJson(),
    "unread_extra": unreadExtra,
    "now": now,
  };

}

class LogPb {
  LogPb({
    required this.imprId,
    required this.sessionId,
  });

  final String? imprId;
  final int? sessionId;

  factory LogPb.fromJson(Map<String, dynamic> json){
    return LogPb(
      imprId: json["impr_id"],
      sessionId: json["session_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "impr_id": imprId,
    "session_id": sessionId,
  };

}
