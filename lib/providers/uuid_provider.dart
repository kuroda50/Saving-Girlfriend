import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final uuidProvider = Provider<String>((ref) => const Uuid().v4());
