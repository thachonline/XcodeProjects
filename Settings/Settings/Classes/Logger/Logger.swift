//
//  Logger.swift
//  WeatherApp
//
//  Created by Bondar Yaroslav on 15/06/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import Foundation

func print(_ items: Any...) {
    #if DEBUG
    Swift.print(items)
    #endif
}

func log(_ closure: @autoclosure () -> Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    #if DEBUG
    Logger.shared.log(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    #endif
}


public enum LogLevel {
    case none
    /// Prints the request and response at their respective `.simple` levels.
    case simple
    /// Prints the request and response at their respective `.verbose` levels.
    case verbose
    
    case debug
}

final public class Logger {
    
    static let shared = Logger()
    
    func configure(closure: (Logger) -> Void) {
        closure(self)
    }
    
    /// for test: Thread.sleep(forTimeInterval: 2)
    private var watchdog: Watchdog?
    public var watchMainThead = false {
        didSet {
            if !watchMainThead {
                watchdog = nil
            } else if watchdog == nil {
                watchdog = Watchdog(threshold: 0.4)
            }
        }
    }
    
    /// can be used another log method
    /// NetworkActivityLogger.shared.startLogging()
    public var logLevel: LogLevel = .simple
    public var logRequests = true
    public var logResponse = true
    
    public var showDate = false
    public var showThreadName = false
    public var showFileName = true
    public var showLineNumber = true
    public var showFunctionName = true
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .medium
        return df
    }()
    
    lazy var fileLogger = FileLogger(fileName: "app.log")
    
    func log(_ closure: @autoclosure () -> Any?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        
        var res = ""
        
        if showDate {
            res += "\(dateFormatter.string(from: Date())) "
        }
        
        if showThreadName {
            if Thread.isMainThread {
                res += "[main] "
            } else if let threadName = Thread.current.name, !threadName.isEmpty {
                res += "[\(threadName)] "
            } else if let queueName = DispatchQueue.currentQueueLabel, !queueName.isEmpty {
                res += "[\(queueName)] "
            } else {
                res += String(format: "[%p] ", Thread.current) //"[\(Thread.current)] "
            }
        }
        
        if showFileName {
            let file = (fileName as NSString).lastPathComponent
            let line = showLineNumber ? ":\(lineNumber)" : ""
            res += "[\(file)\(line)] "
        } else if showLineNumber {
            res += "[\(lineNumber)] "
        }
        
        if showFunctionName {
            res += "\(functionName) "
        }
        
        if !res.isEmpty {
            res += "> "
        }
        
        res += String(describing: closure() ?? "nil")
        print(res)
        fileLogger.writeToFile("\(res)\n")
    }
    
    var fileUrl: URL {
        return fileLogger.fileUrl
    }
}

final class FileLogger {
    
    let fileUrl: URL
    
    private lazy var fileHandle: FileHandle? = {
        let filePath = fileUrl.path
        let isFileExists = FileManager.default.fileExists(atPath: filePath)
        
        if !isFileExists {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: fileUrl)
            return fileHandle
        } catch {
            #if DEBUG
                fatalError("could not open path to log file")
            #else
                print("Serious error in logging: could not open path to log file. \(error).")
            #endif
        }
        
        return nil
    }()
    
    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    convenience init(fileName: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileUrl = documentDirectory.appendingPathComponent(fileName)
        self.init(fileUrl: fileUrl)
    }
    
    deinit {
        fileHandle?.closeFile()
    }
    
    func writeToFile(_ logMessage: String) {
        if let data = logMessage.data(using: .utf8) {
            fileHandle?.write(data)
        } else {
            print("Serious error in logging: could not encode logged string into data.")
        }
    }
}
