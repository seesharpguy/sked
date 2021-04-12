import 'package:flutter/material.dart';
import 'package:sked/base/base_view.dart';
import 'package:sked/viewmodels/home_viewmodel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(onModelReady: (model) {
      model.init();
    }, builder: (context, model, build) {
      return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Hello ${model.displayName}',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ),
                    Center(
                      child: ToggleButtons(
                        children: [
                          Icon(Icons.calendar_today_rounded),
                          Icon(Icons.calendar_view_day_rounded),
                          Icon(Icons.calendar_view_day_outlined)
                        ],
                        isSelected: model.isSelected,
                        onPressed: (index) => model.viewChanged(index),
                      ),
                    ),
                    Expanded(
                        child: SfCalendar(
                      view: CalendarView.month,
                      dataSource: model.dataSource,
                      controller: model.controller,
                      timeZone: 'Eastern Standard Time',
                      showDatePickerButton: true,
                      onViewChanged: (ViewChangedDetails details) {
                        model.calendarChanged(details);
                      },
                      monthViewSettings: MonthViewSettings(
                          appointmentDisplayMode:
                              MonthAppointmentDisplayMode.appointment),
                    ))
                  ],
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}
