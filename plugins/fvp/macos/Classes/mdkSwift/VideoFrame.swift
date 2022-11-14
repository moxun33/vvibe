//
//  VideoFrame.swift
//
//  Created by WangBin on 2020/12/4.
//

import Foundation
#if canImport(mdk)
import mdk
#endif

public enum PixelFormat : Int32
{
    case Unknown = -1
    case YUV420P
    case NV12
    case YUV422P
    case YUV444P
    case P010LE
    case P016LE
    case YUV420P10LE
    case UYVY422
    case RGB24
    case RGBA
    case RGBX
    case BGRA
    case BGRX
    case RGB565LE
    case RGB48LE
    case GBRP
    case GBRP10LE
    case XYZ12LE
}

public class VideoFrame {
    private var frame : UnsafeMutablePointer<mdkVideoFrameAPI>!

    public init(width:Int32, height:Int32, format:PixelFormat) {
        frame = mdkVideoFrameAPI_new(width, height, MDK_PixelFormat(format.rawValue))
    }

    private init(_ ptr : UnsafeMutablePointer<mdkVideoFrameAPI>!) {
        frame = ptr
    }

    public var planeCount : Int32 {
        frame.pointee.planeCount(frame.pointee.object)
    }

    public func width(plane : Int32 = 0) -> Int32 {
        frame.pointee.width(frame.pointee.object, plane)
    }

    public func height(plane : Int32 = 0) -> Int32 {
        frame.pointee.height(frame.pointee.object, plane)
    }

    public var format : PixelFormat {
        PixelFormat(rawValue: frame.pointee.format(frame.pointee.object).rawValue)!
    }

    public var timestamp : Double {
        get {
            frame.pointee.timestamp(frame.pointee.object)
        }
        set {
            frame.pointee.setTimestamp(frame.pointee.object, newValue)
        }
    }

    public func bytesPerLine(plane:Int32 = 0) -> Int32 {
        return frame.pointee.bytesPerLine(frame.pointee.object, plane)
    }

    func addBuffer(data:Data, stride:Int32, plane:Int32) -> Bool {
        return data.withUnsafeBytes { (ptr)->Bool in
            return frame.pointee.addBuffer(frame.pointee.object, ptr.bindMemory(to:UInt8.self).baseAddress, stride, nil, nil, plane)
        }
    }

    func bufferData(plane:Int32) -> Data {
        let data = frame.pointee.bufferData(frame.pointee.object, plane)
        let buf = UnsafeMutableRawPointer(mutating: data)!
        let size = bytesPerLine(plane: plane)*height(plane: plane)
        return Data(bytesNoCopy: buf, count: Int(size), deallocator: Data.Deallocator.none)
    }

    public func to(format:PixelFormat, width : Int32 = -1, height:Int32 = -1) -> VideoFrame {
        let p = frame.pointee.to(frame.pointee.object, MDK_PixelFormat(format.rawValue), width, height)
        return VideoFrame(p)
    }

    public func save(fileName:String, format:String? = nil, quality:Float)->Bool {
        return frame.pointee.save(frame.pointee.object, fileName, format, quality)
    }
}
