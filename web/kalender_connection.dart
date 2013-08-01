library kalender_connection;

import 'dart:html';
import 'dart:json' as JSON;
import 'dart:async';
import 'x_appointment.dart';
import 'x_pause.dart';
import 'kalender.dart' as kalender;

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
    var message = JSON.parse(encodedMessage);
    if(message is List) {
      print("Received a list (a whole month): $message");
      
      message.forEach((a) {
        if(a['data'].containsKey('number')) {
          // it's an appointment
          kalender.xappointments.where((x) => x.time == DateTime.parse(a['time'])).toSet().forEach((x) {
              x.name = a['data']['name'];
              x.number = a['data']['number'];
              x.type = a['data']['type'];
              x.color = a['data']['color'];
              XAppointment.dirtyAppointments.add(x);
          });
        } else if (a['data'].containsKey('text')) {
          //it's a pause
          kalender.xpauses.where((x) => x.time == DateTime.parse(a['time'])).toSet().forEach((x) {
              x.name = a['data']['name'];
              x.text = a['data']['text'];
              XPause.dirtyPauses.add(x);
          });
        }
      });
    }
    
    if (message is Map) {
      if (message['data'].containsKey('number')) {
        print("Received a map (an appointment): $message");
        
        if (message['time'].substring(0, 7) == kalender.yearAndMonth) {
          // It's in the selected month, let's do something
          kalender.xappointments.where((x) => x.time == DateTime.parse(message['time'])).toSet().forEach((x) {
            x.name = message['data']['name'];
            x.number = message['data']['number'];
            x.type = message['data']['type'];
            x.color = message['data']['color'];
            XAppointment.dirtyAppointments.add(x);
          });
        }
      } else if (message['data'].containsKey('text')){
        print("Received a map (a pause): $message");

        if (message['time'].substring(0, 7) == kalender.yearAndMonth) {
          // It's in the selected month, let's do something
          kalender.xpauses.where((x) => x.time == DateTime.parse(message['time'])).toSet().forEach((x) {
            x.name = message['data']['name'];
            x.text = message['data']['text'];
            XPause.dirtyPauses.add(x);
          });
        }
      }
    }

    kalender.updateNextFreeSpots();
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