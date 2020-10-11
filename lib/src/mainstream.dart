import 'dart:async';

import 'package:flutter/material.dart';

/// A [StreamBuilder] alternative that provides builder and event callbacks including default visual handlers
class MainStream<T> extends StreamBuilderBase<T, AsyncSnapshot<T>> {
  final ValueChanged<T> onData;
  final ValueChanged<T> onEmptyData;
  final ValueChanged<Object> onError;
  final VoidCallback onDone;
  final T initialData;
  final WidgetBuilder busyBuilder;
  final Widget Function(BuildContext, T) dataBuilder;
  final Widget Function(BuildContext, T) emptyDataBuilder;
  final Widget Function(BuildContext, Object) errorBuilder;

  const MainStream({
    Key key,
    @required Stream<T> stream,
    this.onData,
    this.onEmptyData,
    this.onError,
    this.onDone,
    this.initialData,
    this.busyBuilder,
    this.dataBuilder,
    this.emptyDataBuilder,
    this.errorBuilder,
  })  : assert(stream != null),
        super(key: key, stream: stream);

  @override
  AsyncSnapshot<T> initial() => AsyncSnapshot<T>.withData(ConnectionState.none, initialData);

  @override
  AsyncSnapshot<T> afterConnected(AsyncSnapshot<T> current) => current.inState(ConnectionState.waiting);

  @override
  AsyncSnapshot<T> afterData(AsyncSnapshot<T> current, T data) {
    var emptyData = false;

    if (data == null) {
      emptyData = true;
    } else if (data is List && data.isEmpty) {
      emptyData = true;
    } else if (data is Map && data.isEmpty) {
      emptyData = true;
    }

    if (emptyData) {
      if (onEmptyData != null) onEmptyData(data);
    } else {
      if (onData != null) onData(data);
    }
    return AsyncSnapshot<T>.withData(ConnectionState.active, data);
  }

  @override
  AsyncSnapshot<T> afterError(AsyncSnapshot<T> current, Object error) {
    if (onError != null) {
      onError(error);
    } else {
      print(error);
    }
    return AsyncSnapshot<T>.withError(ConnectionState.active, error);
  }

  @override
  AsyncSnapshot<T> afterDone(AsyncSnapshot<T> current) {
    if (onDone != null) onDone();
    return current.inState(ConnectionState.done);
  }

  @override
  AsyncSnapshot<T> afterDisconnected(AsyncSnapshot<T> current) => current.inState(ConnectionState.none);

  @override
  Widget build(BuildContext context, AsyncSnapshot<T> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return _handleBusy(context);
      case ConnectionState.active:
      case ConnectionState.done:
        return _handleSnapshot(context, snapshot);
      default:
        return _defaultWidget();
    }
  }

  Widget _handleBusy(BuildContext context) {
    if (initialData != null) {
      return _handleData(context, initialData);
    }
    if (busyBuilder == null) {
      return _defaultBusyWidget();
    }
    return busyBuilder(context);
  }

  Widget _handleData(BuildContext context, T data) {
    var emptyData = false;

    if (data == null) {
      emptyData = true;
    } else if (data is List && data.isEmpty) {
      emptyData = true;
    } else if (data is Map && data.isEmpty) {
      emptyData = true;
    }

    if (emptyData) {
      return emptyDataBuilder != null ? emptyDataBuilder(context, data) : _defaultEmptyWidget();
    } else {
      return dataBuilder != null ? dataBuilder(context, data) : _defaultWidget();
    }
  }

  Widget _handleSnapshot(BuildContext context, AsyncSnapshot<T> snapshot) {
    if (snapshot.hasError) {
      return _handleError(context, snapshot.error);
    }
    return _handleData(context, snapshot.data);
  }

  Widget _handleError(BuildContext context, Object error) {
    if (errorBuilder != null) {
      return errorBuilder(context, error);
    }
    return _defaultErrorWidget(error);
  }

  Widget _defaultBusyWidget() => const Center(child: CircularProgressIndicator());

  Widget _defaultErrorWidget(error) => _EmptyErrorWidget(error);
  Widget _defaultEmptyWidget() => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Icon(Icons.radio_button_unchecked, size: 28.0),
        ),
      );

  Widget _defaultWidget() => const SizedBox.shrink();
}

class _EmptyErrorWidget extends StatefulWidget {
  final dynamic error;
  const _EmptyErrorWidget(this.error);

  @override
  __EmptyErrorWidgetState createState() => __EmptyErrorWidgetState();
}

class __EmptyErrorWidgetState extends State<_EmptyErrorWidget> {
  bool errorVisible = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => errorVisible = !errorVisible),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Icon(Icons.error, size: 28.0),
            ),
          ),
          Visibility(
            visible: errorVisible,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(widget.error.toString(), style: TextStyle(fontSize: 11.0)),
            ),
          ),
        ],
      ),
    );
  }
}
