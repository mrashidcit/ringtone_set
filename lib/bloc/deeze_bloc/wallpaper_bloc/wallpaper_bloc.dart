import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../models/deeze_model.dart';
import '../deeze_repository.dart';

part 'wallpaper_event.dart';
part 'wallpaper_state.dart';

class WallpaperBloc extends Bloc<WallpaperEvent, WallpaperState> {
  DeezeRepository _DeezeRepository = DeezeRepository();
  WallpaperBloc() : super(WallpaperInitial()) {
    on<WallpaperEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LoadWallpapers>((event, emit) async {
      // TODO: implement event handler
      emit(await _DeezeRepository.getWallPapers());
    });
  }
}
