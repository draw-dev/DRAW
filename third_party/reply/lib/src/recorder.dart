part of reply;

class _DefaultRecorder<Q, R> implements Recorder<Q, R> {
  final Equality<Q> _requestEquality;
  final List<Record<Q, R>> _records = <Record<Q, R>>[];

  _DefaultRecorder({Equality<Q>? requestEquality})
      : _requestEquality = requestEquality ?? IdentityEquality();

  @override
  void addRecord(Record<Q, R> record) {
    _records.add(record);
  }

  @override
  ResponseBuilder<Q, R> given(Q request) {
    if (request == null) {
      throw ArgumentError.notNull('request');
    }
    return _DefaultResponseBuilder(this, request);
  }

  @override
  Recording<Q, R> toRecording() {
    return Recording(_records, requestEquality: _requestEquality);
  }
}
