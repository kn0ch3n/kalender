library kalenderserver;

import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'file-logger.dart' as log;
import 'server-utils.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:json' as json;

class StaticFileHandler {
  final String basePath;

  StaticFileHandler(this.basePath);

  _send404(HttpResponse response) {
    response.statusCode = HttpStatus.NOT_FOUND;
    response.close();
  }

  // TODO: etags, last-modified-since support
  onRequest(HttpRequest request) {
    final String path =
        request.uri.path == '/' ? '/kalender.html' : request.uri.path;
    final File file = new File('${basePath}${path}');
    file.exists().then((bool found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            _send404(request.response);
          } else {
            file.openRead().pipe(request.response)
              .catchError((e) => print(e));
          }
        });
      } else {
        _send404(request.response);
      }
    });
  }
}

class KalenderHandler {
  Set<WebSocket> webSocketConnections = new Set<WebSocket>();
  Db db;
  DbCollection collection;
  Map<String,Map> appointments = new Map<String,Map>();

  KalenderHandler(String basePath) {
    log.initLogging('${basePath}/kalender-log.txt');
    db = new Db("mongodb://127.0.0.1/kalender_appointments");
  }

  onConnection(WebSocket conn) {
    print('new ws conn');
    webSocketConnections.add(conn);
    conn.listen((message) {
      print('new ws msg: $message');
      var msgObject = json.parse(message);
      
      if(msgObject["time"].length == 7) {
        
        print("That's a request for a month!");
        
        // Answer with all the appointments in that month
        List<String> appointments = [];
        print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
        db.open().then((o){
          collection = db.collection('kalender_appointments');
          print("searching matches in time for ${msgObject['time']}");
          collection.find(where.match("time", msgObject['time'])).each((v) {
            appointments.add(v);
          }).then((_) {
            print("Sending appointments to client: $appointments");
            queue(() => conn.add(json.stringify(appointments)));
          });
        });
        
      } else {
        
        print("That's an appointment to save and forward to other clients!");
        
        // save in database
        print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
        db.open().then((o){
          collection = db.collection('kalender_appointments');
          db.ensureIndex("kalender_appointments", keys: {"time": 1}, unique: true);
          print("Inserting $msgObject into kalender_appointments");
          collection.findOne({"time": msgObject["time"]}).then((v) {
            if(v != null) {
              //print("Record found: $v");
              v["data"] = msgObject["data"];
              collection.save(v);
            } else {
              //print("Creating new Record: $msgObject");
              collection.insert(msgObject);
            }
          });
        });

        // forward message to other clients
        webSocketConnections.forEach((connection) {
          if (conn != connection) {
            print('queued msg to be sent');
            queue(() => connection.add(message));
          }
        });
        //time('send to isolate', () => log.log(message));
      }
    }, onDone: () => webSocketConnections.remove(conn),
      onError: (e) => webSocketConnections.remove(conn)
    );
  }
}

runServer(String basePath, int port) {
  KalenderHandler kalenderHandler = new KalenderHandler(basePath);
  StaticFileHandler fileHandler = new StaticFileHandler(basePath);
  
  HttpServer.bind('127.0.0.1', port)
    .then((HttpServer server) {
      print('listening for connections on $port');
      
      var sc = new StreamController();
      sc.stream.transform(new WebSocketTransformer()).listen(kalenderHandler.onConnection);

      server.listen((HttpRequest request) {
        if (request.uri.path == '/ws') {
          sc.add(request);
        } else {
          fileHandler.onRequest(request);
        }
      });
    },
    onError: (error) => print("Error starting HTTP server: $error"));
}

main() {
  var script = new File(new Options().script);
  var directory = script.directory;
  runServer("${directory.path}/web", 1337);
}
