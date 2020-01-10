/// Used to control the submission of the Form widgets.
abstract class SubmitController<T> {
  T submit();

  void register(SubmitCallback<T> onSubmit);

  void dispose();
}

typedef SubmitCallback<T> = T Function();

class SingleListenerController<T> implements SubmitController<T> {
  SubmitCallback<T> _onSubmit;

  void register(SubmitCallback<T> onSubmit) {
    assert(_onSubmit == null,
        "Another callback is registered on this controller, deregister it first");
    _onSubmit = onSubmit;
  }

  void deregister() {
    _onSubmit = null;
  }

  T submit() {
    assert(_onSubmit != null, "No callback registered for this controller");
    return _onSubmit();
  }

  dispose() {
    _onSubmit = null;
  }
}
