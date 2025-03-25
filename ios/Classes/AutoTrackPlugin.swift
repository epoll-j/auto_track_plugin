import Flutter
import UIKit

// 全局日志路径
private let crashLogPath: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    return (paths[0] as NSString).appendingPathComponent("auto_track_crash.log")
}()

// 全局信号处理器
private var signalHandler: (@convention(c) (Int32) -> Void)? = nil

public class AutoTrackPlugin: NSObject, FlutterPlugin {

    // MARK: - 插件注册入口
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "auto_track", binaryMessenger: registrar.messenger())
        let instance = AutoTrackPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        setupNativeCrashHandler()
    }

    // MARK: - 初始化原生崩溃监控
    private static func setupNativeCrashHandler() {
        // 配置异常处理器
        let exceptionClosure: @convention(c) (NSException) -> Void = { exception in
            let report = """
            Exception Name: \(exception.name.rawValue)
            Reason: \(exception.reason ?? "未知原因")
            Call Stack:
            \(exception.callStackSymbols.joined(separator: "\n"))
            """
            writeToFile(content: report)
        }
        NSSetUncaughtExceptionHandler(exceptionClosure)

        // 配置全局信号处理器
        let signalClosure: @convention(c) (Int32) -> Void = { sig in
            let signalName = signalName(for: sig)
            let stack = Thread.callStackSymbols.joined(separator: "\n")
            let report = """
            Signal: \(signalName) (\(sig))
            Call Stack:
            \(stack)
            """
            writeToFile(content: report)

            // 恢复默认处理
            signal(sig, SIG_DFL)
            kill(getpid(), sig)
        }
        signalHandler = signalClosure

        // 注册信号
        let signals = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE]
        signals.forEach { sig in
            var action = sigaction()
            action.__sigaction_u = __sigaction_u(__sa_handler: unsafeBitCast(signalClosure, to: sig_t.self))
            action.sa_flags = SA_NODEFER
            sigaction(sig, &action, nil)
        }
    }

    // MARK: - 方法处理
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getLastCrashReport":
            result(readCrashLog())

        case "cleanCrashReports":
            cleanCrashLogs()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - 测试方法（调试用）
    @objc public static func triggerTestCrash() {
        let numbers = [0]
        let _ = numbers[1] // 触发数组越界崩溃
    }
}

// MARK: - 全局工具方法
private func signalName(for signal: Int32) -> String {
    switch signal {
    case SIGABRT: return "SIGABRT"
    case SIGILL: return "SIGILL"
    case SIGSEGV: return "SIGSEGV"
    case SIGFPE: return "SIGFPE"
    case SIGBUS: return "SIGBUS"
    case SIGPIPE: return "SIGPIPE"
    default: return "UNKNOWN"
    }
}

private func writeToFile(content: String) {
    let device = UIDevice.current
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    let crashInfo = """
    === NATIVE CRASH REPORT ===
    Timestamp: \(formatter.string(from: Date()))
    Device: \(device.model) (\(device.systemName) \(device.systemVersion))

    \(content)
    """

    do {
        try crashInfo.write(toFile: crashLogPath, atomically: true, encoding: .utf8)
    } catch {
        print("日志保存失败: \(error)")
    }
}

private func readCrashLog() -> String? {
    do {
        return try String(contentsOfFile: crashLogPath, encoding: .utf8)
    } catch {
        return nil
    }
}

private func cleanCrashLogs() {
    try? FileManager.default.removeItem(atPath: crashLogPath)
}