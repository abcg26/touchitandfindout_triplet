import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'bluetooth/fake_device_link.dart';
import 'screens/shell.dart';
import 'state/alarm_controller.dart';
import 'theme/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Tifo.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TifoApp());
}

class TifoApp extends StatelessWidget {
  const TifoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Swap FakeDeviceLink for the real BLE link once the HM-10 arrives.
      create: (_) => AlarmController(FakeDeviceLink()),
      child: MaterialApp(
        title: 'TIFO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Tifo.black,
          colorScheme: const ColorScheme.dark(
            primary: Tifo.yellow,
            surface: Tifo.black,
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        home: const AppShell(),
      ),
    );
  }
}
