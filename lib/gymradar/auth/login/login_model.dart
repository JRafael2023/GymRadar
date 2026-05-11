import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  // ── Estado UI ───────────────────────────────────────────────────
  bool stateError = false;
  String errorMessage = 'Correo o contraseña incorrectos.';
  bool isLoading = false;

  // ── Form ────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  // ── Email ────────────────────────────────────────────────────────
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;

  String? _emailValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Formato de correo incorrecto';
    }
    return null;
  }

  // ── Contraseña ──────────────────────────────────────────────────
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  bool passwordVisibility = false;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  String? _passwordValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (val.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // ── Resultado ───────────────────────────────────────────────────
  String? loginResult;

  @override
  void initState(BuildContext context) {
    emailTextControllerValidator = _emailValidator;
    passwordTextControllerValidator = _passwordValidator;
    passwordVisibility = false;
  }

  @override
  void dispose() {
    emailFocusNode?.dispose();
    emailTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
