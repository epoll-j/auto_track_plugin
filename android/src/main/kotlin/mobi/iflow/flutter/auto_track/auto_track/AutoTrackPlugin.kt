package mobi.iflow.flutter.auto_track.auto_track

import androidx.annotation.NonNull

import android.content.Context
import android.util.Log
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.util.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AutoTrackPlugin */
class AutoTrackPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context

  private val crashLogPath: String by lazy {
    File(context.filesDir, "auto_track_crash.log").absolutePath
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "auto_track")
    channel.setMethodCallHandler(this)
    setupNativeCrashHandler()
  }

  // 初始化崩溃监控
  private fun setupNativeCrashHandler() {
    val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()

    Thread.setDefaultUncaughtExceptionHandler { thread, ex ->
      // 生成崩溃报告
      val report = buildCrashReport(ex, context)
      writeToFile(report)

      // 调用默认处理器（崩溃弹窗）
      defaultHandler?.uncaughtException(thread, ex)
    }
  }

  // 修复后的 buildCrashReport
  private fun buildCrashReport(ex: Throwable, context: Context): String {
    val sw = StringWriter()
    val pw = PrintWriter(sw)
    ex.printStackTrace(pw)

    return """
            === NATIVE CRASH REPORT ===
            Timestamp: \(  {Date()}
            Device:   \){android.os.Build.MANUFACTURER} \(  {android.os.Build.MODEL}
            OS Version: Android   \){android.os.Build.VERSION.RELEASE}
            
            Stack Trace:
            \(  {sw.toString()}
        """.trimIndent()
  }

  // 修复后的 writeToFile
  private fun writeToFile(content: String) {
    try {
      // 正确写法（插入变量）
      File(crashLogPath).appendText("$content \n")
    } catch (e: Exception) {
      Log.e("AutoTrack", "保存崩溃日志失败", e)
    }
  }

  // 读取日志
  private fun readCrashLog(): String? {
    return try {
      File(crashLogPath).readText()
    } catch (e: Exception) {
      null
    }
  }

  // 清理日志
  private fun cleanCrashLogs() {
    File(crashLogPath).delete()
  }

  // 触发测试崩溃
  private fun triggerTestCrash() {
    throw RuntimeException("This is a test crash")
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getLastCrashReport" -> result.success(readCrashLog())
      "cleanCrashReports" -> {
        cleanCrashLogs()
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
