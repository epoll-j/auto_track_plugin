package mobi.iflow.flutter.auto_track.auto_track

import androidx.annotation.NonNull
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.util.Date

class AutoTrackPlugin : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  private val crashLogPath: String by lazy {
    File(context.filesDir, "crash_reports").apply {
      if (!exists()) mkdirs()
    }.absolutePath + File.separator + "auto_track_crash.log"
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "auto_track")
    channel.setMethodCallHandler(this)
//    setupNativeCrashHandler()
  }

  private fun setupNativeCrashHandler() {
    val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()

    Thread.setDefaultUncaughtExceptionHandler { thread, ex ->
      Thread {
        writeToFile(buildCrashReport(ex))

//        Handler(Looper.getMainLooper()).postDelayed({
//          defaultHandler?.uncaughtException(thread, ex)
//          android.os.Process.killProcess(android.os.Process.myPid())
//        }, 700)
      }.start()
    }
  }

  private fun buildCrashReport(ex: Throwable): String {
    return StringWriter().use { sw ->
      ex.printStackTrace(PrintWriter(sw))
      """
=== NATIVE CRASH REPORT ===
Timestamp: ${Date().time}
Stack Trace:
${sw}
=== END CRASH REPORT ===            
""".trimIndent()
    }
  }

  private fun writeToFile(content: String) {
    try {
      File(crashLogPath).apply {
        parentFile?.mkdirs()
        appendText("$content")
      }
    } catch (e: Exception) {
      Log.e("AutoTrack", "保存崩溃日志失败", e)
    }
  }

  private fun readCrashLog(): String? {
    return try {
      File(crashLogPath).takeIf { it.exists() }?.readText()
    } catch (e: Exception) {
      null
    }
  }

  private fun cleanCrashLogs() {
    try {
      File(crashLogPath).delete()
    } catch (e: Exception) {
      Log.e("AutoTrack", "清理日志失败", e)
    }
  }

//  private fun rotateLogs() {
//    val file = File(crashLogPath)
//    if (file.length() > 1024 * 1024) {
//      file.delete()
//      file.createNewFile()
//    }
//  }

  private fun triggerTestCrash() {
    Handler(Looper.getMainLooper()).postDelayed({
      throw RuntimeException("This is a test crash")
    }, 100)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getLastCrashReport" -> {
        result.success(readCrashLog())
      }
      "cleanCrashReports" -> {
        result.success(null)
        cleanCrashLogs()
      }
      "enableNativeCrashHandler" -> {
        setupNativeCrashHandler()
        result.success(null)
      }
      "testCrash" -> {
        triggerTestCrash()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}