part of reply;

class _DefaultResponseBuilder<Q, R> implements ResponseBuilder<Q, R> {
  final Recorder<Q, R> _recorder;
  final Q _request;

  _DefaultResponseBuilder(this._recorder, this._request);

  @override
  ConclusionBuilder<Q, R, Recorder<Q, R>> reply(
    R response, {
    void Function(Branch<Q, R> branch)? andBranch,
  }) {
    if (andBranch != null) {
      throw UnimplementedError();
    }
    if (response == null) {
      throw ArgumentError.notNull('response');
    }
    return _DefaultConclusionBuilder(
      _recorder,
      _request,
      response,
    );
  }
}
