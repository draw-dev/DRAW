import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:reply/reply.dart';
import 'package:test/test.dart';

void main() {
  group('Simple request/response', () {
    late Recorder<String, String> recorder;
    const notInfiniteButALot = 100;
    setUp(() => recorder = Recorder<String, String>());

    test('should support responding once', () {
      recorder.given('Hello').reply('Hi there!').once();
      final recording = recorder.toRecording();
      expect(recording.hasRecord('Hello'), isTrue);
      expect(recording.reply('Hello'), 'Hi there!');
      expect(recording.hasRecord('Hello'), isFalse);
      expect(() => recording.reply('Hello'), throwsStateError);
    });

    test('should support emitting a response n times', () {
      recorder.given('Hello').reply('Hi there!').times(2);
      final recording = recorder.toRecording();
      expect(recording.reply('Hello'), 'Hi there!');
      expect(recording.reply('Hello'), 'Hi there!');
      expect(() => recording.reply('Hello'), throwsStateError);
    });

    test('should support emitting a response ∞ times', () {
      recorder.given('Hello').reply('Hi there!').always();
      final recording = recorder.toRecording();
      for (var i = 0; i < notInfiniteButALot; i++) {
        expect(recording.reply('Hello'), 'Hi there!');
      }
      expect(recording.hasRecord('Hello'), isTrue);
    });

    test('should encode as a valid JSON', () {
      recorder
          .given('Hello')
          .reply('Hi there!')
          .times(2)
          .given('Thanks')
          .reply('You are welcome!')
          .always();
      final json = recorder.toRecording().toJsonEncodable(
            encodeRequest: (q) => q,
            encodeResponse: (r) => r,
          );
      expect(json, [
        {
          'always': false,
          'request': 'Hello',
          'response': 'Hi there!',
        },
        {
          'always': false,
          'request': 'Hello',
          'response': 'Hi there!',
        },
        {
          'always': true,
          'request': 'Thanks',
          'response': 'You are welcome!',
        },
      ]);
      expect(jsonDecode(jsonEncode(json)), json);
      final copy = Recording<String?, String?>.fromJson(
        json,
        toRequest: (q) => q,
        toResponse: (r) => r,
      );
      expect(copy.hasRecord('Hello'), isTrue);
      expect(copy.hasRecord('Thanks'), isTrue);
    });
  });

  group('Custom equality', () {
    late Recorder<_CustomRequest, String> recorder;

    setUp(() {
      recorder = Recorder<_CustomRequest, String>(
        requestEquality: const _CustomRequestEquality(),
      );
    });

    test('should be used to determine request matches', () {
      recorder.given(_CustomRequest(123, 'A')).reply('Hello').once();
      final recording = recorder.toRecording();
      expect(
        recording.hasRecord(_CustomRequest(123, 'B')),
        isTrue,
      );
    });
  });
}

class _CustomRequest {
  final int idNumber;
  final String name;

  _CustomRequest(this.idNumber, this.name);
}

class _CustomRequestEquality implements Equality<_CustomRequest> {
  const _CustomRequestEquality();

  @override
  bool equals(_CustomRequest e1, _CustomRequest e2) {
    return e1.idNumber == e2.idNumber;
  }

  @override
  int hash(_CustomRequest e) => e.idNumber;

  @override
  bool isValidKey(Object? o) => o is _CustomRequest;
}
