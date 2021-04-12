import 'dart:async';
import 'package:sked/base/base_model.dart';
import 'package:sked/models/user.dart';
import 'package:sked/services/authentication_service.dart';
import 'package:sked/utils/locator.dart';
import 'package:sked/services/navigation_service.dart';
import 'package:sked/utils/routeNames.dart';
import 'package:sked/utils/view_state.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart' as mat;
import 'package:date_utils/date_utils.dart';

class HomeViewModel extends BaseModel {
  final AuthenticationService _auth = locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final StreamController<String> _toastController =
      StreamController<String>.broadcast();

  SkedUser _currentUser;

  List<SkedEvent> _meetings = <SkedEvent>[];
  Map<String, String> _colors = {};

  DateTime _beginDate = DateUtils.firstDayOfMonth(DateTime.now()).toUtc();
  DateTime _endDate = DateUtils.lastDayOfMonth(DateTime.now()).toUtc();

  EventDataSource _dataSource;
  List<bool> _isSelected = [true, false, false];
  CalendarView _view = CalendarView.month;
  CalendarController _controller = CalendarController();

  SkedUser get currentUser => _auth.currentUser;
  String get avatarUrl => _currentUser?.photoURL;
  String get displayName => _currentUser?.displayName;
  List<SkedEvent> get meetings => _meetings;
  CalendarController get controller => _controller;
  Map<String, String> get colors => _colors;

  CalendarView get view => _view;
  List<bool> get isSelected => _isSelected;

  EventDataSource get dataSource => _dataSource;

  set meetings(List<SkedEvent> appts) {
    _meetings = appts;
    notifyListeners();
  }

  set dataSource(EventDataSource ds) {
    _dataSource = ds;
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

    _meetings = <SkedEvent>[];
    await getEvents();
  }

  void init() async {
    // final bool isLoggedIn = await _auth.isUserLoggedIn();

    // if (!isLoggedIn) {
    //   _navigationService.navigateTo(RouteName.Login);
    // } else {
    //   _currentUser = _auth.currentUser;
    //   getEvents();
    // }

    dataSource = EventDataSource(_meetings);

    _currentUser = _auth.currentUser;
    await getEvents();
  }

  Future loginWithGoogle() async {
    state = ViewState.Busy;
    try {
      await _auth.signInWithGoogle();
      await getEvents();
      state = ViewState.Idle;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _auth.isUserLoggedIn();
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

  Future getEvents() async {
    if (await isLoggedIn()) {
      final calendarClient = CalendarApi(_auth.authClient);

      final List<String> mycalendars = [
        "Family",
        "RyanAndAlison",
        "ryan.r.sites@gmail.com"
      ];

      final allCollors = await calendarClient.colors.get();

      allCollors.calendar.entries.forEach((element) {
        _colors[element.key] = element.value.background;
      });

      CalendarList allCalendars = await calendarClient.calendarList.list();

      final matchingCalendars = allCalendars.items
          .where((item) => mycalendars.contains(item.summary));

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
    _navigationService.navigateTo(RouteName.Login);
  }

  clearAllModels() {}
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
