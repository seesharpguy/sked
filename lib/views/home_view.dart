import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_buttons/flutter_awesome_buttons.dart';
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
          appBar: AppBar(title: Text("sked")),
          drawer: Container(
              width: 600,
              child: Drawer(
                  child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: model.isLoggedIn
                        ? Column(children: [
                            Center(
                              child: Text(
                                'Hello ${model.displayName}',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[300]),
                              ),
                            ),
                            SizedBox(height: 10),
                            CircleAvatar(
                              backgroundImage: NetworkImage(model.avatarUrl),
                              radius: 45,
                            )
                          ])
                        : Container(),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                    ),
                  ),
                  model.isLoggedIn
                      ? Center(
                          child: Container(
                              width: 200,
                              child: DarkButtton(
                                onPressed: () async {
                                  model.logout();
                                  Navigator.pop(context);
                                },
                                title: "Log Out",
                              )))
                      : Center(
                          child: Container(
                              width: 200,
                              child: SignInWithGoogle(
                                  buttonColor: Colors.grey[900],
                                  onPressed: () async {
                                    model.loginWithGoogle();
                                    Navigator.pop(context);
                                  }))),
                  model.isLoggedIn
                      ? Column(
                          children: [
                            Center(
                              child: ToggleButtons(
                                  children: [
                                    Icon(Icons.calendar_today_rounded),
                                    Icon(Icons.calendar_view_day_rounded),
                                    Icon(Icons.calendar_view_day_outlined)
                                  ],
                                  isSelected: model.isSelected,
                                  onPressed: (index) {
                                    model.viewChanged(index);
                                    Navigator.pop(context);
                                  }),
                            ),
                            SimpleGroupedSwitch<String>(
                                controller: model.groupController,
                                values: model.allCalendars
                                    .map((e) => e.id)
                                    .toList(),
                                itemsTitle: model.allCalendars
                                    .map((e) => e.display)
                                    .toList())
                          ],
                        )
                      : Container()
                ],
              ))),
          body: Stack(children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
