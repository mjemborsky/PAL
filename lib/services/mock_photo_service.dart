import 'package:flutter/foundation.dart';
import '../models/phone_data_models.dart';

class MockPhotoService extends ChangeNotifier {
  final List<MockPhoto> _photos = List.generate(
    10,
    (index) => MockPhoto(
      id: 'photo_$index',
      url: 'https://picsum.photos/id/${100 + index}/800/480',
      caption: 'Ambient Scene #${index + 1}',
      takenAt: DateTime.now().subtract(Duration(days: index * 3)),
    ),
  );

  List<MockPhoto> get photos => List.unmodifiable(_photos);
}
