library kalender_connection;

import 'dart:html';
import 'dart:json' as JSON;
import 'dart:async';
import 'x_appointment.dart';
import 'kalender.dart';
import 'package:web_ui/observe/observable.dart' as __observe;


StatusArea statusArea;

class KalenderConnection {
  WebSocket webSocket;
  String url;
  

  KalenderConnection(this.url) {
    _init();
  }

  send(DateTime time, Map data) {
    var encoded = JSON.stringify({'time': time.toString(), 'data': data});
    _sendEncodedMessage(encoded);
  }
  
  sendRequest(String month) {
    var encoded = JSON.stringify({'time': month.toString()});
    _sendEncodedMessage(encoded);
  }

  _receivedEncodedMessage(String encodedMessage) {
    print("Received encoded message: $encodedMessage");
    var message = JSON.parse(encodedMessage);
    if(message is List) {
      print("got a list: $message");

      clearAllXAppointments();
      
      message.forEach((a) {
        xappointments.where((x) => x.time == DateTime.parse(a['time']))
          .toSet().forEach((x) {
            x.name = a['data']['name'];
            x.number = a['data']['number'];
            x.type = a['data']['type'];
        });
      });
    }
    if(message is Map) {
      print("got a map: $message");
      
      print("${message['time'].substring(0, 7)} == $yearAndMonth");
      
      if (message['time'].substring(0, 7) == yearAndMonth) {
        xappointments.where((x) => x.time == DateTime.parse(message['time']))
        .toSet().forEach((x) {
          x.name = message['data']['name'];
          x.number = message['data']['number'];
          x.type = message['data']['type'];
        });
      }
    }
  }

  _sendEncodedMessage(String encodedMessage) {
    if (webSocket != null && webSocket.readyState == WebSocket.OPEN) {
      webSocket.send(encodedMessage);
    } else {
      print('WebSocket not connected, message $encodedMessage not sent');
    }
  }

  _init([int retrySeconds = 2]) {
    bool encounteredError = false;
    statusArea.displayNotice("Connecting to Web socket");
    webSocket = new WebSocket(url);

    scheduleReconnect() {
      statusArea.displayNotice('web socket closed, retrying in $retrySeconds seconds');
      if (!encounteredError) {
        new Timer(new Duration(seconds:retrySeconds),
            () => _init(retrySeconds*2));
      }
      encounteredError = true;
    }

    webSocket.onOpen.listen((e) {
      statusArea.displayNotice('Connected');
      sendRequest(yearAndMonth);
    });

    webSocket.onClose.listen((e) => scheduleReconnect());
    webSocket.onError.listen((e) => scheduleReconnect());

    webSocket.onMessage.listen((MessageEvent e) {
      print('received message ${e.data}');
      _receivedEncodedMessage(e.data);
    });
  }

}


class StatusArea extends View<ParagraphElement> {
  StatusArea(ParagraphElement elem) : super(elem);

  displayNotice(String notice) {
    _display("Server: $notice\n");
  }
  
  displaySaveMessage(String time, Map data){
    elem.text = "Eintrag gespeichert! $time - $data";
  }

  _display(String str) {
    elem.text = "$str";
  }
}

abstract class View<T> {
  final T elem;

  View(this.elem) {
    bind();
  }

  // bind to event listeners
  void bind() { }
}
//# sourceMappingURL=kalender_connection.dart.map