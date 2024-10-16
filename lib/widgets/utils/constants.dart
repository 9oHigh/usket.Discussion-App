import 'package:flutter/material.dart';
import '../../gen/assets.gen.dart';

// Topic Name Mapping
const Map<String, String> topicNameMap = {
  'sports': '스포츠',
  'fashion': '패션',
  'food': '맛집',
  'music': '음악',
  'news': '뉴스',
  'pet': '반려동물',
  'travel': '여행',
  'tv': '방송',
};

// Topic Image Mapping
Map<String, AssetGenImage> topicImageMap = {
  'sports': Assets.images.sports,
  'fashion': Assets.images.fashion,
  'food': Assets.images.food,
  'music': Assets.images.music,
  'news': Assets.images.news,
  'pet': Assets.images.pet,
  'travel': Assets.images.travel,
  'tv': Assets.images.tv,
  'sports-selected': Assets.images.sportsSelected,
  'fashion-selected': Assets.images.fashionSelected,
  'food-selected': Assets.images.foodSelected,
  'music-selected': Assets.images.musicSelected,
  'news-selected': Assets.images.newsSelected,
  'pet-selected': Assets.images.petSelected,
  'travel-selected': Assets.images.travelSelected,
  'tv-selected': Assets.images.tvSelected,
  'my-icon-filled': Assets.images.myIconFilled,
  'my-icon-outlined': Assets.images.myIconOutlined,
};

class AppConstants {
  // 화면 높이, 너비
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // 간격
  static double spaceMedium(BuildContext context) {
    return getScreenHeight(context) * 0.05;
  }

  static double spaceSmall(BuildContext context) {
    return getScreenHeight(context) * 0.015;
  }

  // room list screen
  static double mainInfoWidth(BuildContext context) {
    return getScreenWidth(context) * 0.8;
  }

  // create room screen
  static double textFieldWidth(BuildContext context) {
    return getScreenWidth(context) * 0.9;
  }

  static double listImageSize(BuildContext context) {
    return getScreenHeight(context) * 0.07;
  }

  // filter screen
  static double topicBoxSize(BuildContext context) {
    return getScreenHeight(context) * 0.092;
  }

  static double badgeSize(BuildContext context) {
    return getScreenHeight(context) * 0.025;
  }

  static double filterImageSize(BuildContext context) {
    return getScreenHeight(context) * 0.06;
  }

  static double appBarHieght(BuildContext context) {
    return getScreenHeight(context) * 0.08;
  }
}

class AppColors {
  // 앱 테마
  static const Color primaryColor = Color(0xff6684F3);
  static const Color secondaryColor = Color(0xffDDE7FF);
  static const Color thirdaryColor = Color(0xff3651B2);


  static const Color startColor = Color(0xff6684F3);
  static const Color endColor =Color(0xffB2C7FC);

  static const List<Color> gradientColors = [
    startColor,
    endColor,
  ];

  static const LinearGradient linearGradient = LinearGradient(
    colors: gradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color backgroundColor = Color(0xffEFF3FF);
  static const Color roomTileColor = Color(0xffffffff);

  // 텍스트
  static const Color appBarContentsColor = Color(0xffffffff);
  static const Color buttonTextColor = Color(0xffffffff);
}

class AppFontSizes {
  static const double topicTextSize = 16;
  static const double titleTextSize = 19;
  static const double timeTextSize = 16;
  static const double filterTextSize = 15;
}
