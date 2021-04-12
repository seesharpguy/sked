import 'dart:async';
import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:sked/base/base_model.dart';
import 'package:sked/models/user.dart';
import 'package:sked/services/authentication_service.dart';
import 'package:sked/utils/locator.dart';
import 'package:sked/utils/view_state.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart' as mat;
import 'package:date_utils/date_utils.dart';

class HomeViewModel extends BaseModel {
  final AuthenticationService _auth = locator<AuthenticationService>();

  SkedUser _currentUser;

  List<SkedEvent> _meetings = <SkedEvent>[];
  Map<String, String> _colors = {};

  DateTime _beginDate = DateUtils.firstDayOfMonth(DateTime.now()).toUtc();
  DateTime _endDate = DateUtils.lastDayOfMonth(DateTime.now()).toUtc();
  bool _isLoggedIn = false;

  EventDataSource _dataSource;
  List<bool> _isSelected = [true, false, false];
  CalendarView _view = CalendarView.month;
  CalendarController _controller = CalendarController();
  GroupController _groupController = GroupController(isMultipleSelection: true);

  SkedUser get currentUser => _auth.currentUser;
  String get avatarUrl => _currentUser?.photoURL;
  String get displayName => _currentUser?.displayName;
  bool get isLoggedIn => _isLoggedIn;

  List<SkedEvent> get meetings => _meetings;
  CalendarController get controller => _controller;
  GroupController get groupController => _groupController;
  Map<String, String> get colors => _colors;

  List<String> _selectedCalendars = [];
  List<SkedCalendar> _allCalendars = <SkedCalendar>[];
  CalendarList _calendarList;

  CalendarView get view => _view;
  List<bool> get isSelected => _isSelected;

  EventDataSource get dataSource => _dataSource;

  List<SkedCalendar> get allCalendars => _allCalendars;

  set meetings(List<SkedEvent> appts) {
    _meetings = appts;
    notifyListeners();
  }

  set dataSource(EventDataSource ds) {
    _dataSource = ds;
    notifyListeners();
  }

  set isLoggedIn(bool loggedIn) {
    _isLoggedIn = loggedIn;
    notifyListeners();
  }

  set allCalendars(List<SkedCalendar> calendars) {
    _allCalendars = calendars;
    notifyListeners();
  }

  void viewChanged(int index) {
    for (var i = 0; i < isSelected.length; i++) {
      isSelected[i] = false;
    }

    isSelected[index] = true;

    switch (index) {
      case 0:
        _controller.view = CalendarView.month;
        break;
      case 1:
        _controller.view = CalendarView.week;
        break;
      case 2:
        _controller.view = CalendarView.day;
        break;
      default:
        _controller.view = CalendarView.month;
        break;
    }
    notifyListeners();
  }

  void calendarChanged(ViewChangedDetails details) async {
    if (details.visibleDates.isNotEmpty) {
      _beginDate = DateUtils.firstDayOfMonth(details.visibleDates[0]).toUtc();
      _endDate = DateUtils.lastDayOfMonth(
              details.visibleDates[details.visibleDates.length - 1])
          .toUtc();
    }

    resetCalendar();
    await getEvents();
  }

  void init() async {
    dataSource = EventDataSource(_meetings);

    await checkLogin();
    await getEvents();

    _groupController.listen((value) {
      _selectedCalendars = value;
      _groupController.initSelectedItem = value;
      resetCalendar();
      getEvents();
    });
  }

  Future loginWithGoogle() async {
    state = ViewState.Busy;
    try {
      await _auth.signInWithGoogle();
      await checkLogin();
      await getEvents();
      state = ViewState.Idle;
    } catch (e) {
      throw e;
    }
  }

  Future<void> checkLogin() async {
    final bool loggedIn = await _auth.isUserLoggedIn();

    if (loggedIn) {
      _currentUser = _auth.currentUser;
    }

    isLoggedIn = loggedIn;
  }

  mat.Color getColor(String colorNumber) {
    mat.Color color = mat.Color(0x039be5);

    if (_colors.isNotEmpty) {
      final code = _colors[colorNumber];
      final intCode = int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
      color = mat.Color(intCode);
    }

    return color;
  }

  Future loadCalendars() async {
    if (isLoggedIn) {
      final calendarClient = CalendarApi(_auth.authClient);

      final allCollors = await calendarClient.colors.get();

      allCollors.calendar.entries.forEach((element) {
        _colors[element.key] = element.value.background;
      });

      CalendarList calendarList = await calendarClient.calendarList.list();

      _calendarList = calendarList;

      List<SkedCalendar> listOfCalendars = [];
      calendarList.items.forEach((element) {
        listOfCalendars.add(SkedCalendar(element.summary, element.id));
      });

      allCalendars = listOfCalendars;
    }
  }

  Future getEvents() async {
    if (isLoggedIn) {
      final calendarClient = CalendarApi(_auth.authClient);

      if (_allCalendars.length == 0) {
        await loadCalendars();
      }

      final matchingCalendars = _calendarList.items
          .where((item) => _selectedCalendars.contains(item.id));

      for (var calendar in matchingCalendars) {
        Events events = await calendarClient.events
            .list(calendar.id, timeMin: _beginDate, timeMax: _endDate);

        for (var event in events.items) {
          if (event.start != null && event.start.dateTime != null) {
            _meetings.add(SkedEvent(event.summary, event.start.dateTime,
                event.end.dateTime, getColor(calendar.colorId), false));
          }
        }
      }

      meetings = _meetings;
      dataSource = EventDataSource(meetings);
    }
  }

  void signOutGoogle() async {
    await _auth.logout();
  }

  void logout() async {
    signOutGoogle();
    resetCalendar();
    isLoggedIn = false;
    notifyListeners();
  }

  resetCalendar() {
    _meetings = <SkedEvent>[];
    dataSource = EventDataSource(_meetings);
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<SkedEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  mat.Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class SkedEvent {
  SkedEvent(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  mat.Color background;
  bool isAllDay;
}

class SkedCalendar {
  SkedCalendar(this.display, this.id);

  String display;
  String id;
}
