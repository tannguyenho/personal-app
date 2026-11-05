import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:wakeup_server/wakeup_server.dart';

Future<void> main() async {
  final config = ServerConfig.fromEnvironment();

  Pool<void>? pool;
  if (config.databaseUrl != null) {
    pool = Pool.withUrl(config.databaseUrl!);
  }

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(
        buildApp(
          config,
          isDatabaseUp: pool == null
              ? null
              : () async {
                  try {
                    await pool!.execute('SELECT 1');
                    return true;
                  } on Object {
                    return false;
                  }
                },
        ),
      );

  final server = await io.serve(handler, InternetAddress.anyIPv4, config.port);
  stdout.writeln('wakeup_server nghe trên cổng ${server.port}');

  ProcessSignal.sigterm.watch().listen((_) async {
    await server.close();
    await pool?.close();
    exit(0);
  });
}
