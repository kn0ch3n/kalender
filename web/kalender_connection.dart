library kalender_connection;

import 'dart:html';
import 'dart:json' as JSON;
import 'dart:async';
import 'x_appointment.dart';
import 'x_pause.dart';
import 'x_summary.dart';
import 'kalender.dart' as kalender;

StatusArea statusArea;

class KalenderConnection {
  WebSocket webSocket;
  String url;
  

  KalenderConnection(this.url) {
    _init();
  }

  send(String type, DateTime time, Map data) {
    var encoded = JSON.stringify({'mtype': type, 'time': time.toString(), 'data': data});
    _sendEncodedMessage(encoded);
  }
  
  sendRequest(String month) {
    var encoded = JSON.stringify({'mtype': 'request', 'time': month.toString()});
    _sendEncodedMessage(encoded);
  }

  _receivedEncodedMessage(String encodedMessage, {bool updateNextFreeSpots: true}) {
    var message = JSON.parse(encodedMessage);
    //print("Received message: $message");
    
    if (message is Map && message.containsKey('mtype')) {
      if (message['mtype'] == 'month') {
        print("Received a month message: $message");
        message['data'].forEach((m) => _receivedEncodedMessage(JSON.stringify(m), updateNextFreeSpots: false));
        kalender.updateNextFreeSpots();
      } else if (message['mtype'] == 'appointment') {
        kalender.xappointments[DateTime.parse(message['time'])]
          ..name = message['data']['name']
          ..number = message['data']['number']
          ..type = message['data']['type']
          ..color = message['data']['color']
          ..setDirty();
        if (updateNextFreeSpots) kalender.updateNextFreeSpots();
      } else if (message['mtype'] == 'pause') {
        kalender.xpauses.where((x) => x.time == DateTime.parse(message['time'])).toSet().forEach((x) {
          x.name = message['data']['name'];
          x.text = message['data']['text'];
          XPause.dirtyPauses.add(x);
        });
      } else if (message['mtype'] == 'summary') {
        kalender.xsummaries.where((x) => x.time == DateTime.parse(message['time'])).toSet().forEach((x) {
          x.text = message['data']['text'];
          XSummary.dirtySummaries.add(x);
      });
      } else {
        print("Unknown mtype: ${message['mtype']}");
      }
    } else {
      print("Message has wrong format... discarded!");
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
      sendRequest(kalender.yearAndMonth);
    });

    webSocket.onClose.listen((e) => scheduleReconnect());
    webSocket.onError.listen((e) => scheduleReconnect());

    webSocket.onMessage.listen((MessageEvent e) {
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
    print("displaySaveMessage");
    //elem.text = "Eintrag gespeichert! $time - $data"; //that's not how it works =/
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