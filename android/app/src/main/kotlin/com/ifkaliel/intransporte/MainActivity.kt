package com.ifkaliel.intransporte

import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val canalNarracao = "com.ifkaliel.intransporte/narracao"
    private var sintetizador: TextToSpeech? = null
    private var narracaoDisponivel = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sintetizador = TextToSpeech(this) { status ->
            val voz = sintetizador
            if (status == TextToSpeech.SUCCESS && voz != null) {
                val idioma = voz.setLanguage(Locale("pt", "BR"))
                narracaoDisponivel = idioma >= TextToSpeech.LANG_AVAILABLE
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canalNarracao)
            .setMethodCallHandler { chamada, resultado ->
                when (chamada.method) {
                    "falar" -> {
                        val texto = chamada.argument<String>("texto")
                        val voz = sintetizador
                        if (texto.isNullOrBlank()) {
                            resultado.error("TEXTO_VAZIO", "Não há texto para narrar.", null)
                        } else if (!narracaoDisponivel || voz == null) {
                            resultado.error(
                                "VOZ_INDISPONIVEL",
                                "A voz em português ainda não está disponível no dispositivo.",
                                null,
                            )
                        } else {
                            voz.setSpeechRate(0.95f)
                            val estado = voz.speak(
                                texto,
                                TextToSpeech.QUEUE_FLUSH,
                                null,
                                "intransporte-ponto",
                            )
                            if (estado == TextToSpeech.ERROR) {
                                resultado.error("FALHA_NARRACAO", "Não foi possível iniciar a narração.", null)
                            } else {
                                resultado.success(null)
                            }
                        }
                    }

                    "parar" -> {
                        sintetizador?.stop()
                        resultado.success(null)
                    }

                    else -> resultado.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        sintetizador?.stop()
        sintetizador?.shutdown()
        sintetizador = null
        super.onDestroy()
    }
}
