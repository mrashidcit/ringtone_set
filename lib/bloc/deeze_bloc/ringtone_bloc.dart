import 'package:bloc/bloc.dart';

import 'ringtone_event.dart';
import 'deeze_repository.dart';
import 'ringtone_state.dart';

class RingtoneBloc extends Bloc<RingtoneEvent, RingtoneState> {
  DeezeRepository _DeezeRepository = DeezeRepository();
  RingtoneBloc() : super(const LoadingRingtone()) {
    on<LoadRingtone>(((event, emit) async {
      final type = event.type;
      emit(await _DeezeRepository.getRingtone());
    }));
  }
}
