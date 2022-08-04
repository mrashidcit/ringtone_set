import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class RingtoneEvent {
  const RingtoneEvent();
}

class LoadRingtone extends RingtoneEvent {
  final String type;
  const LoadRingtone(this.type);
}
