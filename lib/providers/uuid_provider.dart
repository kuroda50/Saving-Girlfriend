import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uuidProvider = Provider<Uuid>((ref) => const Uuid());
