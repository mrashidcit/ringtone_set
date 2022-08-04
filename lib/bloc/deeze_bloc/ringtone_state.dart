import 'package:flutter/foundation.dart' show immutable;

import '../../models/models.dart';

@immutable
abstract class RingtoneState {
  const RingtoneState();
}

class LoadingRingtone extends RingtoneState {
  const LoadingRingtone();
}

// ignore: must_be_immutable
class LoadedRingtone extends RingtoneState {
  Deeze? deeze;
  LoadedRingtone({this.deeze});
}

class RingtoneError extends RingtoneState {
  const RingtoneError();
}
