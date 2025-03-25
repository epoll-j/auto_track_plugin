import Flutter
import UIKit


private let crashLogPath: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    return (paths[0] as NSString).appendingPathComponent("auto_track_crash.log")
}()


private let signalHandler: @convention(c) (Int32) -> Void = { sig in
    let signalName = signalName(for: sig)
    let stack = Thread.callStackSymbols.joined(separator: "\n")
    let report = """
    Signal: \(signalName) (\(sig))
    Call Stack:
    \(stack)
    """
    writeToFile(content: report)
    // 恢复默认处理并重新抛出信号
    signal(sig, SIG_DFL)
    kill(getpid(), sig)
}

public class AutoTrackPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "auto_track", binaryMessenger: registrar.messenger())
        let instance = AutoTrackPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        setupNativeCrashHandler()
    }
    
    // MARK: - 初始化原生崩溃监控
    private static func setupNativeCrashHandler() {
        NSSetUncaughtExceptionHandler { exception in
            let report = """
            Exception Name: \(exception.name.rawValue)
            Reason: \(exception.reason ?? "未知原因")
            Call Stack:
            \(exception.callStackSymbols.joined(separator: "\n"))
            """
            writeToFile(content: report)
        }
        
        let signals = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE, SIGTRAP]
        signals.forEach { sig in
            signal(sig, signalHandler)
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
            
        case "testCrash":
            triggerTestCrash()
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - 崩溃处理工具方法
private func signalName(for signal: Int32) -> String {
    switch signal {
    case SIGABRT: return "SIGABRT"
    case SIGILL: return "SIGILL"
    case SIGSEGV: return "SIGSEGV"
    case SIGFPE: return "SIGFPE"
    case SIGBUS: return "SIGBUS"
    case SIGPIPE: return "SIGPIPE"
    case SIGTRAP: return "SIGTRAP"
    default: return "UNKNOWN"
    }
}

private func writeToFile(content: String) {
    guard let cString = (content + "\n").cString(using: .utf8) else { return }
    let fd = open(crashLogPath, O_WRONLY | O_CREAT | O_APPEND, 0o644)
    if fd != -1 {
        write(fd, cString, strlen(cString))
        close(fd)
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

private func triggerTestCrash() {
    
    let testMode = 0
    
    if testMode == 0 {
        // Swift崩溃（数组越界触发SIGTRAP）
        let numbers = [0]
        _ = numbers[1]
    } else {
        // Objective-C异常
        NSException(name: .genericException, reason: "Test Crash", userInfo: nil).raise()
    }
}
