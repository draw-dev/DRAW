part of reply;

class _DefaultConclusionBuilder<Q, R, T extends Recorder<Q, R>>
    implements ConclusionBuilder<Q, R, T> {
  final T _recorder;
  final Q _request;
  final R _response;

  _DefaultConclusionBuilder(
    this._recorder,
    this._request,
    this._response,
  );

  @override
  T always() {
    return _recorder
      ..addRecord(_DefaultRecord(_request, _response, always: true));
  }

  @override
  T once() {
    return _recorder..addRecord(_DefaultRecord(_request, _response));
  }

  @override
  T times(int times) {
    for (var i = 0; i < times; i++) {
      _recorder.addRecord(_DefaultRecord(_request, _response));
    }
    return _recorder;
  }
}

class _DefaultRecord<Q, R> implements Record<Q, R> {
  @override
  final bool always;

  @override
  final Q request;

  @override
  final R response;

  const _DefaultRecord(this.request, this.response, {this.always = false});
}
