library kalender;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'x_appointment.dart';
import 'x_pause.dart';
import 'x_summary.dart';
import 'dart:json' as JSON;
import 'dart:async';
import 'kalender_connection.dart';
import 'dart:math';
import 'dart:isolate';

final List<String> monthNames = ["Jänner", "Februar", "März", "April", "Mai", "Juni", 
                                 "Juli", "August", "September", "Oktober", "November", "Dezember"];
final List<String> weekdaysShort = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"];
KalenderConnection kalenderConnection;
DivElement termineDiv;
List<DivElement> appointmentColumns = new List<DivElement>();
String selectedDate;
String lastSelectedDate;
int currentDaysInMonth;
String monthName;
String yearAndMonth;
int maxDays = 31;
int columnWidth = 300;
Map<DateTime, XAppointment> xappointments = new Map<DateTime, XAppointment>();
List<XPause> xpauses = new List<XPause>();
List<XSummary> xsummaries = new List<XSummary>();

void main() {
  ParagraphElement statusElem = query('#status-area');
  statusArea = new StatusArea(statusElem);
  kalenderConnection = new KalenderConnection("ws://127.0.0.1:1337/ws");
  XAppointment.connection = kalenderConnection;
  XPause.connection = kalenderConnection;
  XSummary.connection = kalenderConnection;
  selectedDate = toDateString(new DateTime.now());
  setupUI();

  // Listeners
  document.body.onMouseWheel.listen((WheelEvent e) {
    e.preventDefault();
    document.body.scrollLeft += e.deltaY;
  });
}

String toDateString(DateTime dateTime) {
  var day = dateTime.day > 9 ? dateTime.day : "0" + dateTime.day.toString();
  var month = dateTime.month > 9 ? dateTime.month : "0" + dateTime.month.toString();
  var year = dateTime.year;
  return "$year-$month-$day";
}

void setupUI() {
  termineDiv = query("#termine");
  int year = int.parse(selectedDate.substring(0, 4));
  int month = int.parse(selectedDate.substring(5, 7));
  for (int i = 1; i <= maxDays; i++) {
    var id = i.toString().length > 1 ? i.toString() : "0" + i.toString();
    var column = query("#termine_$id");
    appointmentColumns.add(column);
    if (column != null) {
      xsummaries.add(summaryCreator(new DateTime(year, month, i), column));
      for (int h = 8; h <= 17; h++) {
        for (int m = 0; m <= 40; m += 20) {
          DateTime t = new DateTime(year, month, i, h, m);
          if (h == 12 && m == 0) xpauses.add(pauseCreator(t, column));
          if (h == 12 || h == 13) continue;
          String id = i > 9 ? i.toString() : "0" + i.toString();
          int x = ((h-8)*3 + (m/20) + 1).toInt();
          id += x > 9 ? x.toString() : "0" + x.toString();
          xappointments[t] = (appointmentCreator(t, id, column));
        }
      }
    }
  }
  dateChanged(); // To resize width of the termine div
}

XAppointment appointmentCreator(DateTime time, String id, var parent) {
  var obj = new XAppointment(time, id);
  var lifecycleCaller = new ComponentItem(obj)..create();
  parent.children.add(obj.host);
  lifecycleCaller.insert();
  return obj;
}

XPause pauseCreator(DateTime time, var parent) {
  var obj = new XPause(time);
  var lifecycleCaller = new ComponentItem(obj)..create();
  parent.children.add(obj.host);
  lifecycleCaller.insert();
  return obj;
}

XSummary summaryCreator(DateTime time, var parent) {
  var obj = new XSummary(time);
  var lifecycleCaller = new ComponentItem(obj)..create();
  parent.children.add(obj.host);
  lifecycleCaller.insert();
  return obj;
}

void dateChanged() {
  print("in dateChanged: selectedDate: $selectedDate , lastSelectedDate: $lastSelectedDate");
  if (lastSelectedDate == null || selectedDate.length >= 7 && selectedDate.substring(0, 7) != lastSelectedDate.substring(0, 7)) {
    updateView();
  } else {
    print("dateChanged(): same month, not updating view");
  }
  if(selectedDate.length >= 7) {
    //scroll to the right day
    document.body.scrollLeft = (int.parse(selectedDate.substring(8, 10)) - 1) * columnWidth;
    lastSelectedDate = selectedDate;
  }
}

void updateView() {
  //called when month is changed
  clearAllXAppointments();
  currentDaysInMonth = daysInMonth(selectedDate);
  monthName = toMonthName(selectedDate);
  yearAndMonth = selectedDate.substring(0, 7);
  var year = selectedDate.substring(0, 4);
  for (int i = 1; i <= maxDays; i++) {
    var id = i.toString().length > 1 ? i.toString() : "0" + i.toString();
    // Create the heading for the day
    var headingElement = query("#termine_$id h3");
    if(headingElement != null) {
      DateTime d = DateTime.parse(selectedDate.substring(0, 8) + id);
      if(d.add(new Duration(days: 1)).isAfter(new DateTime.now()) && !(weekdaysShort[d.weekday - 1] == "So")) {
        headingElement.classes.remove("before");
      } else {
        headingElement.classes.add("before");
      }
      headingElement.innerHtml = "${weekdaysShort[d.weekday - 1]}, $i. $monthName $year";
    }
    // Hide days not in current month
    if(i >= 28) {
      var termineElement = query("#termine_$id");
      if(termineElement != null) {
        if(i > currentDaysInMonth) {
          termineElement.style.display = "none";
        } else {
          termineElement.style.display = "inline-block";
        }
      }
    }
  }
  // Change the times of the XAppointment instances
  for (XAppointment x in xappointments.values) {
    x.time = DateTime.parse(selectedDate.substring(0, 7) + x.time.toString().substring(7));
  }
  // Change the times of the XPause instances
  for (XPause x in xpauses) {
    x.time = DateTime.parse(selectedDate.substring(0, 7) + x.time.toString().substring(7));
  }
  // resize #termine
  query("#termine").style.width = "${currentDaysInMonth * columnWidth + 50}px}";
  updateHeight();
  // request this months appointments
  kalenderConnection.sendRequest(yearAndMonth);
}

void updateHeight() {
  print("TODO: fix updating the height so it actually works...");
  query("#termine").style.height = (window.innerHeight).toString() + "px";
}

void updateNextFreeSpots() {
  print("updating free spots");
  var nextFreeSpots = query("#next-free-spots");
  nextFreeSpots.children.clear();
  var candidates = xappointments.values.where((x) {
    return x.time.isAfter(new DateTime.now()) && x.isEmpty();
  }).toList();
  candidates.sort((XAppointment a, XAppointment b) {
    if (a.time == b) {
      return 0;
    } else if (a.time.isAfter(b.time)) {
      return 1;
    } else {
      return -1;
    }});
  candidates.take(30).forEach((a) {
    var li = new LIElement();
    li.text = "$a";
    nextFreeSpots.children.add(li);
  });
}

void clearAllXAppointments() {
  for(var x in XAppointment.dirtyAppointments) {
    x.clear();
  }
  XAppointment.dirtyAppointments.clear();
}

String toMonthName(String dateString) {
  int monthNumber = int.parse(dateString.substring(5, 7));
  return monthNames[monthNumber - 1];
}

int daysInMonth(String dateString) {
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
  } else if(m == "04" || m == "06" || m == "09" || m == "11") {
    return 30;
  } else return 31;
}

extend(XAppointment source) {
  var nextId = getNextId(source.id);
  var doAgain = true;

  while(doAgain) {
    doAgain = false;
    if(nextId != null) {
      xappointments.values.where((a) => a.id == nextId).toSet().forEach((a) {
        if(a.name == source.name && a.number == source.number && a.type == source.type && a.color == source.color) doAgain = true;
        else {
          a.name = source.name;
          a.number = source.number;
          a.type = source.type;
          a.color = source.color;
          XAppointment.dirtyAppointments.add(a);
          a.valueChanged();
        }
      });
    }
    if(doAgain) nextId = getNextId(nextId);
  }
}

String getNextId(String currentId) {
  int currentPos = int.parse(currentId.substring(2, 4));
  int nextPos = (currentPos + 1);
  if(nextPos > 30) return null; // out of range
  String nextPosString = nextPos < 10 ? "0" + nextPos.toString() : nextPos.toString();
  var nextId = currentId.substring(0, 2) + nextPosString;
  
  return nextId;
}
