// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS()
library node;

import 'package:js/js.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test_api/src/utils.dart'; // ignore: implementation_imports

@JS('require')
external _Net _require(String module);

@JS('process.argv')
external List<String> get _args;

@JS()
class _Net {
  external _Socket connect(int port);
}

@JS()
class _Socket {
  external void setEncoding(String encoding);
  external void on(String event, void Function(String chunk) callback);
  external void write(String data);
}

/// Returns a [StreamChannel] of JSON-encodable objects that communicates over a
/// socket whose port is given by `process.argv[2]`.
StreamChannel<Object?> socketChannel() {
  var controller =
      StreamChannelController<String?>(allowForeignErrors: false, sync: true);
  var net = _require('net');
  var socket = net.connect(int.parse(_args[2]));
  socket.setEncoding('utf8');

  controller.local.stream.listen((chunk) => socket.write(chunk!));
  socket.on('data', allowInterop(controller.local.sink.add));

  return controller.foreign.transform(chunksToLines).transform(jsonDocument);
}
