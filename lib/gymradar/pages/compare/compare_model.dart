import '/flutter_flow/flutter_flow_util.dart';
import 'compare_widget.dart' show CompareWidget;
import 'package:flutter/material.dart';

class CompareModel extends FlutterFlowModel<CompareWidget> {
  TextEditingController? searchController;
  FocusNode? searchFocusNode;
  String query = '';

  @override
  void initState(BuildContext context) {
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    searchController?.dispose();
    searchFocusNode?.dispose();
  }
}
