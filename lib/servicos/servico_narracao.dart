import 'package:flutter/services.dart';

class ServicoNarracao {
  static const _canal = MethodChannel('com.ifkaliel.intransporte/narracao');

  Future<void> falar(String texto) async {
    await _canal.invokeMethod<void>('falar', {'texto': texto});
  }

  Future<void> parar() async {
    await _canal.invokeMethod<void>('parar');
  }
}
