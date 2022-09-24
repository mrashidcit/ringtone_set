part of 'wallpaper_bloc.dart';

@immutable
abstract class WallpaperState {}

class WallpaperInitial extends WallpaperState {}

class WallpaperLoaded extends WallpaperState {
  List<DeezeItemModel>? deeze;
  WallpaperLoaded({this.deeze});
}

class WallpaperError extends WallpaperState {}
