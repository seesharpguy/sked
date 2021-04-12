import 'package:flutter/material.dart';
import 'package:sked/base/base_model.dart';
import 'package:sked/utils/locator.dart';
import 'package:provider/provider.dart';

class BaseView<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;
  final Function(T) onModelDone;

  BaseView({@required this.builder, this.onModelReady, this.onModelDone});

  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<BaseView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  void deactivate() {
    if (widget.onModelDone != null) {
      widget.onModelDone(model);
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    /*return ChangeNotifierProvider<T>(
      builder: (context) => model,
      child: Consumer<T>(builder: widget.builder),

    );*/
    return ChangeNotifierProvider<T>.value(
      //builder: (context) => model,
      child: Consumer<T>(builder: widget.builder), value: model,
    );
  }
}
