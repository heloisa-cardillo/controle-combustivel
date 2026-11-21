import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:controle_combustivel/features/combustivel/presentation/screens/tela_inicial.dart';
import 'package:controle_combustivel/features/combustivel/utils/cores.dart';

class ControleCombustivelApp extends StatelessWidget {
  const ControleCombustivelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combustível',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _criarTema(),
      home: const TelaInicial(),
    );
  }

  ThemeData _criarTema() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Cores.azul,
        primary: Cores.azul,
        error: Cores.erro,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Cores.fundo,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Cores.titulo,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Cores.titulo,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Cores.texto,
        displayColor: Cores.titulo,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black12,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Cores.borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Cores.borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Cores.azul, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          backgroundBuilder: (context, estados, filho) {
            final desativado = estados.contains(WidgetState.disabled);
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: desativado ? null : Cores.gradiente,
                color: desativado ? Cores.cinza.withValues(alpha: 0.4) : null,
              ),
              child: filho,
            );
          },
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Cores.titulo,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: Cores.borda),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
