import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/gymradar/pages/home/home_widget.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().isLoggedIn && FFAppState().userUid.isNotEmpty) {
        context.goNamed(HomeWidget.routeName);
      }
    });

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() => _isKeyboardVisible = visible);
      });
    }

    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    if (!isWeb) _keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (_model.formKey.currentState == null ||
        !_model.formKey.currentState!.validate()) return;

    safeSetState(() => _model.isLoading = true);

    await Future.delayed(const Duration(milliseconds: 900));

    final email = _model.emailTextController?.text ?? '';
    final pass = _model.passwordTextController?.text ?? '';

    if (email.isNotEmpty && pass.length >= 6) {
      FFAppState().isLoggedIn = true;
      FFAppState().userEmail = email;
      FFAppState().isGuest = false;
      if (mounted) context.goNamed(HomeWidget.routeName);
    } else {
      safeSetState(() {
        _model.stateError = true;
        _model.errorMessage = 'Correo o contraseña incorrectos.';
        _model.isLoading = false;
      });
    }
  }

  void _enterAsGuest() {
    FFAppState().isLoggedIn = false;
    FFAppState().isGuest = true;
    FFAppState().userEmail = '';
    context.goNamed(HomeWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);

    final keyboardOpen = isWeb
        ? MediaQuery.viewInsetsOf(context).bottom > 0
        : _isKeyboardVisible;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).top,
                ),
                child: Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Hero superior ──────────────────────────
                      _buildHero(context, theme),

                      // ── Formulario ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            Text(
                              'Bienvenido',
                              style: GoogleFonts.montserrat(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: theme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inicia sesión para continuar',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: theme.secondaryText,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Error banner
                            if (_model.stateError) _buildErrorBanner(theme),

                            // Email
                            _buildFieldLabel(theme, 'Correo electrónico'),
                            const SizedBox(height: 8),
                            _buildEmailField(theme),

                            const SizedBox(height: 16),

                            // Contraseña
                            _buildFieldLabel(theme, 'Contraseña'),
                            const SizedBox(height: 8),
                            _buildPasswordField(theme),

                            // Olvidé contraseña
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: theme.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            if (!keyboardOpen) ...[
                              // ── Botón Ingresar ─────────────────
                              FFButtonWidget(
                                onPressed: _doLogin,
                                text: 'Ingresar',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 54,
                                  color: theme.primary,
                                  textStyle: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  elevation: 0,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ── Separador ──────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                        color: theme.dividerColor,
                                        thickness: 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'o continúa sin cuenta',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: theme.secondaryText,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                        color: theme.dividerColor,
                                        thickness: 1),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ── Botón invitado ─────────────────
                              FFButtonWidget(
                                onPressed: () async => _enterAsGuest(),
                                text: 'Entrar como invitado',
                                iconData: Icons.person_outline_rounded,
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 54,
                                  color: theme.secondaryBackground,
                                  textStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryText,
                                  ),
                                  elevation: 0,
                                  borderSide: BorderSide(
                                      color: theme.dividerColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ── Link registro ──────────────────
                              Center(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '¿No tienes cuenta?  ',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: theme.secondaryText,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Regístrate gratis',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: theme.secondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      height: 210,
      color: theme.primaryBackground,
      child: Stack(
        children: [
          // Círculo decorativo fondo
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.secondary.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Contenido
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                Text(
                  'Gym Radar',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Encuentra tu gym ideal en Lima',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ERROR BANNER ──────────────────────────────────────────────────
  Widget _buildErrorBanner(FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _model.errorMessage,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: theme.error),
            ),
          ),
        ],
      ),
    );
  }

  // ── LABEL ─────────────────────────────────────────────────────────
  Widget _buildFieldLabel(FlutterFlowTheme theme, String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: theme.secondaryText,
      ),
    );
  }

  // ── INPUT DECORATION ──────────────────────────────────────────────
  InputDecoration _inputDeco(
    FlutterFlowTheme theme, {
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: theme.inputBorder, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    );
    final focusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: theme.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    );
    final errBorder = OutlineInputBorder(
      borderSide: BorderSide(color: theme.error, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'Inter', color: theme.hintText, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: theme.hintText, size: 20),
      suffixIcon: suffixIcon,
      enabledBorder: border,
      focusedBorder: focusBorder,
      errorBorder: errBorder,
      focusedErrorBorder: errBorder.copyWith(
          borderSide: BorderSide(color: theme.error, width: 2)),
      filled: true,
      fillColor: theme.secondaryBackground,
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
    );
  }

  Widget _buildEmailField(FlutterFlowTheme theme) {
    return TextFormField(
      controller: _model.emailTextController,
      focusNode: _model.emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
          fontFamily: 'Inter', color: theme.primaryText, fontSize: 14),
      decoration: _inputDeco(theme,
          hint: 'tu@correo.com', prefixIcon: Icons.email_outlined),
      validator: _model.emailTextControllerValidator.asValidator(context),
    );
  }

  Widget _buildPasswordField(FlutterFlowTheme theme) {
    return TextFormField(
      controller: _model.passwordTextController,
      focusNode: _model.passwordFocusNode,
      obscureText: !_model.passwordVisibility,
      style: TextStyle(
          fontFamily: 'Inter', color: theme.primaryText, fontSize: 14),
      decoration: _inputDeco(
        theme,
        hint: 'Mínimo 6 caracteres',
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: InkWell(
          onTap: () => safeSetState(
              () => _model.passwordVisibility = !_model.passwordVisibility),
          focusNode: FocusNode(skipTraversal: true),
          child: Icon(
            _model.passwordVisibility
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: theme.hintText,
            size: 20,
          ),
        ),
      ),
      validator:
          _model.passwordTextControllerValidator.asValidator(context),
    );
  }
}
