/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/fashion-selected.png
  AssetGenImage get fashionSelected =>
      const AssetGenImage('assets/images/fashion-selected.png');

  /// File path: assets/images/fashion.png
  AssetGenImage get fashion => const AssetGenImage('assets/images/fashion.png');

  /// File path: assets/images/food-selected.png
  AssetGenImage get foodSelected =>
      const AssetGenImage('assets/images/food-selected.png');

  /// File path: assets/images/food.png
  AssetGenImage get food => const AssetGenImage('assets/images/food.png');

  /// File path: assets/images/home-icon_filled.png
  AssetGenImage get homeIconFilled =>
      const AssetGenImage('assets/images/home-icon_filled.png');

  /// File path: assets/images/home-icon_outlined.png
  AssetGenImage get homeIconOutlined =>
      const AssetGenImage('assets/images/home-icon_outlined.png');

  /// File path: assets/images/music-selected.png
  AssetGenImage get musicSelected =>
      const AssetGenImage('assets/images/music-selected.png');

  /// File path: assets/images/music.png
  AssetGenImage get music => const AssetGenImage('assets/images/music.png');

  /// File path: assets/images/my-icon_filled.png
  AssetGenImage get myIconFilled =>
      const AssetGenImage('assets/images/my-icon_filled.png');

  /// File path: assets/images/my-icon_outlined.png
  AssetGenImage get myIconOutlined =>
      const AssetGenImage('assets/images/my-icon_outlined.png');

  /// File path: assets/images/news-selected.png
  AssetGenImage get newsSelected =>
      const AssetGenImage('assets/images/news-selected.png');

  /// File path: assets/images/news.png
  AssetGenImage get news => const AssetGenImage('assets/images/news.png');

  /// File path: assets/images/pet-selected.png
  AssetGenImage get petSelected =>
      const AssetGenImage('assets/images/pet-selected.png');

  /// File path: assets/images/pet.png
  AssetGenImage get pet => const AssetGenImage('assets/images/pet.png');

  /// File path: assets/images/sports-selected.png
  AssetGenImage get sportsSelected =>
      const AssetGenImage('assets/images/sports-selected.png');

  /// File path: assets/images/sports.png
  AssetGenImage get sports => const AssetGenImage('assets/images/sports.png');

  /// File path: assets/images/travel-selected.png
  AssetGenImage get travelSelected =>
      const AssetGenImage('assets/images/travel-selected.png');

  /// File path: assets/images/travel.png
  AssetGenImage get travel => const AssetGenImage('assets/images/travel.png');

  /// File path: assets/images/tv-selected.png
  AssetGenImage get tvSelected =>
      const AssetGenImage('assets/images/tv-selected.png');

  /// File path: assets/images/tv.png
  AssetGenImage get tv => const AssetGenImage('assets/images/tv.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        fashionSelected,
        fashion,
        foodSelected,
        food,
        homeIconFilled,
        homeIconOutlined,
        musicSelected,
        music,
        myIconFilled,
        myIconOutlined,
        newsSelected,
        news,
        petSelected,
        pet,
        sportsSelected,
        sports,
        travelSelected,
        travel,
        tvSelected,
        tv
      ];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
