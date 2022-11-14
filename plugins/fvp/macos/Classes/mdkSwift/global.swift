//
//  global.swift
//
//  Created by iqiyi on 2020/12/3.
//

import Foundation
#if canImport(mdk)
import mdk
#endif


public enum MediaType : Int32 {
    case Unknown = -1
    case Video = 0
    case Audio = 1
    case Subtitle = 2
}

public struct MediaStatus : RawRepresentable {
    public let rawValue: Int32
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    static let NoMedia = MediaStatus(rawValue: 0)
    static let Unloaded = MediaStatus(rawValue: 1)
    static let Loading = MediaStatus(rawValue: 1<<1)
    static let Loaded = MediaStatus(rawValue: 1<<2)
    static let Prepared = MediaStatus(rawValue: 1<<8)
    static let Stalled = MediaStatus(rawValue: 1<<3)
    static let Buffering = MediaStatus(rawValue: 1<<4)
    static let Buffered = MediaStatus(rawValue: 1<<5)
    static let End = MediaStatus(rawValue: 1<<6)
    static let Seeking = MediaStatus(rawValue: 1<<7)
    static let Invalid = MediaStatus(rawValue: 1<<31)
}

public enum State : UInt32 {
    case Stopped = 0
    case Playing = 1
    case Paused = 2
}

public enum SeekFlag : UInt32 {
    case From0 = 1
    case FromStart = 2
    case FromNow = 4
    case Frame = 64
    case KeyFrame = 256
    case FastFrom0 = 257
    case FastFromNow = 260
    case Default = 258 // FromStart|KeyFrame
}

public enum VideoEffect : UInt32 {
    case Brightness = 0
    case Contrast = 1
    case Hue = 2
    case Saturation = 3
}

public enum LogLevel : UInt32 {
    case Off = 0
    case Error = 1
    case Warning = 2
    case Info = 3
    case Debug = 4
    case All = 5
}

public func version() ->Int32 {
    return MDK_version()
}

public var logLevel : LogLevel {
    get {
        LogLevel(rawValue: MDK_logLevel().rawValue)!
    }

    set {
        MDK_setLogLevel(MDK_LogLevel(newValue.rawValue))
    }
}

public typealias LogHandler = (LogLevel,String)->Void
public func setLogHandler(_ callback:LogHandler?) {
    struct H {
        static var cb : UnsafeMutableRawPointer? //LogHandler?
    }
    if H.cb == nil {
        H.cb = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<LogHandler>.stride, alignment: MemoryLayout<LogHandler>.alignment)
    }
    var tmp = callback
    H.cb?.initializeMemory(as: LogHandler.self, from: &tmp!, count: 1)
    func _f(level : MDK_LogLevel, msg : UnsafePointer<CChar>?, opaque : UnsafeMutableRawPointer?) {
        let f = opaque?.load(as: LogHandler.self)
        f!(LogLevel(rawValue: level.rawValue)!, String(cString: msg!))
    }
    var h = mdkLogHandler()
    if callback == nil {
        h.opaque = nil
    } else {
        h.opaque = H.cb
    }
    h.cb = _f
    MDK_setLogHandler(h)
}

public func setGlobalOption<T>(name:String, value:T) {
    if let v = value as? String {
        v.withCString({
            MDK_setGlobalOptionString(name, $0)
        })
    } else if let v = value as? Int32 {
        MDK_setGlobalOptionInt32(name, v)
    } else if let v = value as? Bool {
        let i = Int32(v ? 1 : 0)
        MDK_setGlobalOptionInt32(name, i)
    } else if let v = value as? Int {
        let i = Int32(v)
        MDK_setGlobalOptionInt32(name, i)
    }
}
