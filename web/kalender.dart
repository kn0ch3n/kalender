import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'x_appointment.dart';
import 'x_pause.dart';
import 'dart:json' as JSON;
import 'dart:async';
import 'kalender_connection.dart';
import 'dart:math';

KalenderConnection kalenderConnection;
DivElement termineDiv;
List<DivElement> appointmentColumns = new List<DivElement>();
String selectedDate;
String lastSelectedDate;
final List<String> monthNames = ["Jänner", "Februar", "März", 
                                 "April", "Mai", "Juni", 
                                 "Juli", "August", "September", 
                                 "Oktober", "November", "Dezember"];
final List<String> weekdaysShort = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"];
int daysInMonth;
String monthName;
String yearAndMonth;
int maxDays = 31;

List<XAppointment> xappointments = new List<XAppointment>();

void main() {
  //useShadowDom = true;
  ParagraphElement statusElem = query('#status-area');
  statusArea = new StatusArea(statusElem);
  
  kalenderConnection = new KalenderConnection("ws://127.0.0.1:1337/ws");
  XAppointment.connection = kalenderConnection;
  
  selectedDate = toDateString(new DateTime.now());
  setupUI();
}

String toDateString(DateTime dateTime) {
  var day = dateTime.day > 9 ? dateTime.day : "0" + dateTime.day.toString();
  var month = dateTime.month > 9 ? dateTime.month : "0" + dateTime.month.toString();
  var year = dateTime.year;
  
  return "$year-$month-$day";
}

void setupUI() {
  termineDiv = query("#termine");
  
  for (int i = 1; i <= maxDays; i++) {
    var id = i.toString().length > 1 ? i.toString() : "0" + i.toString();
    var column = query("#termine_$id");
    appointmentColumns.add(column);
    if (column != null) {
      for (int h = 8; h <= 17; h++) {
        for (int m = 0; m <= 40; m += 20) {
          if (h == 12 && m == 0) pauseCreator(new DateTime(2013, 6, i, h, m), column);
          if (h == 12 || h == 13) continue;
          DateTime t = new DateTime(
              int.parse(selectedDate.substring(0, 4)),
              int.parse(selectedDate.substring(5, 7)),
              i, h, m);
          String id = i > 9 ? i.toString() : "0" + i.toString();
          int x = ((h-8)*3 + (m/20) + 1).toInt();
          id += x > 9 ? x.toString() : "0" + x.toString();
          xappointments.add(appointmentCreator(t, id, column));
        }
      }
    }
  }
  
  dateChanged(); // Resize width of the termine div
}

XAppointment appointmentCreator(DateTime time, String id, var parent) {
  var obj = new XAppointment(time, id);
  var lifecycleCaller = new ComponentItem(obj)..create();
  parent.children.add(obj.host);
  lifecycleCaller.insert();
  return obj;
}

void pauseCreator(DateTime time, var parent) {
  var obj = new XPause(time);
  var lifecycleCaller = new ComponentItem(obj)..create();
  parent.children.add(obj.host);
  lifecycleCaller.insert();
}

void dateChanged() {
  //print("selected: $selectedDate , lastSelected: $lastSelectedDate");
  if (lastSelectedDate == null || selectedDate.substring(0, 7) != lastSelectedDate.substring(0, 7)) {
    print("different month, updating view");
    daysInMonth = toDaysInMonth(selectedDate);
    monthName = toMonthName(selectedDate);
    yearAndMonth = selectedDate.substring(0, 7);
    
    for (int i = 1; i <= maxDays; i++) {
      var id = i.toString().length > 1 ? i.toString() : "0" + i.toString();

      // Create the heading for the day
      var headingElement = query("#termine_$id h3");
      if(headingElement != null) {
        var year = selectedDate.substring(0, 4);
        DateTime d = DateTime.parse(selectedDate.substring(0, 8) + id);
        headingElement.innerHtml = "${weekdaysShort[d.weekday - 1]}, $i. $monthName $year";
      }
      
      for (XAppointment x in xappointments) {
        x.time = DateTime.parse(selectedDate.substring(0, 7) + x.time.toString().substring(7));
      }
      
      // hide days not in current month
      var termineElement = query("#termine_$id");
      if(termineElement != null) {
        if(i > daysInMonth) {
          termineElement.style.display = "none";
        } else {
          termineElement.style.display = "inline-block";
        }
      }

      // resize #termine
      query("#termine").style.width = "${daysInMonth * 250}px}";
    }
    
    kalenderConnection.sendRequest(yearAndMonth);
    
  } else {
    print("same month, not updating view");
  }
  
  lastSelectedDate = selectedDate;
}

void clearAllXAppointments() {
  for(var x in xappointments) {
    x.clear();
  }
}

String toMonthName(String dateString) {
  int monthNumber = int.parse(dateString.substring(5, 7));
  return monthNames[monthNumber - 1];
}

int toDaysInMonth(String dateString) {
  String m = dateString.substring(5, 7);
  if(m == "02") {
    int y = int.parse(dateString.substring(0, 4));
    if(y % 4 == 0) {
      if(y % 100 == 0) {
        if(y % 400 == 0){
          return 29;
        }
        return 28;
      }
      return 29;
    }
    return 28;
  } else if(m == "01" || m == "03" || m == "05" || m == "07" || m == "08" || m == "10" || m == "12") {
    return 31;
  } else return 30;
}