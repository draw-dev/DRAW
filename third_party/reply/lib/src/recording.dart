part of reply;

class _DefaultRecording<Q, R> implements Recording<Q, R> {
  final List<Record<Q, R>> _records;
  final Equality<Q> _requestEquality;

  _DefaultRecording(
    Iterable<Record<Q, R>> records, {
    Equality<Q>? requestEquality,
  })  : _records = records.toList(),
        _requestEquality = requestEquality ?? IdentityEquality();

  @override
  bool hasRecord(Q request) {
    return _records.any((r) => _requestEquality.equals(request, r.request));
  }

  @override
  R reply(Q request) {
    for (var i = 0; i < _records.length; i++) {
      if (_requestEquality.equals(_records[i].request, request)) {
        return _replyAt(i);
      }
    }
    throw StateError('No record found for $request.');
  }

  R _replyAt(int index) {
    final record = _records[index];
    if (!record.always) {
      _records.removeAt(index);
    }
    return record.response;
  }

  @override
  dynamic toJsonEncodable({
    required Function(Q request) encodeRequest,
    required Function(R response) encodeResponse,
  }) =>
      _records.map((record) {
        return {
          'always': record.always,
          'request': encodeRequest(record.request),
          'response': encodeResponse(record.response),
        };
      }).toList();
}
