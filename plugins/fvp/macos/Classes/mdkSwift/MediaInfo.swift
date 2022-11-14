//
//  MediaInfo.swift
//
//  Created by WangBin on 2020/12/4.
//

import Foundation
#if canImport(mdk)
import mdk
#endif

public struct AudioCodecParameters {
    public var codec: String!
    public var codec_tag: UInt32 = 0
    public var extra_data = [UInt8]() /* without padding data */
    public var bit_rate: Int64 = 0
    public var profile: Int32 = 0
    public var level: Int32 = 0
    public var frame_rate: Float = 0

    public var is_float: Bool = false
    public var is_unsigned: Bool = false
    public var is_planar: Bool = false
    public var raw_sample_size: Int32 = 0
    public var channels: Int32 = 0
    public var sample_rate: Int32 = 0
    public var block_align: Int32 = 0
    public var frame_size: Int32 = 0 /* const samples per channel in a frame */
}

public struct AudioStreamInfo {
    public var index: Int32 = 0
    public var start_time: Int64 = 0 /* ms */
    public var duration: Int64 = 0 /* ms */
    public var frames: Int64 = 0
    public var metadata = [String:String]()
    public var codec = AudioCodecParameters()
}


public struct VideoCodecParameters {
    public var codec: String!
    public var codec_tag: UInt32 = 0
    public var extra_data = [UInt8]() /* without padding data */
    public var bit_rate: Int64 = 0
    public var profile: Int32 = 0
    public var level: Int32 = 0
    public var frame_rate: Float = 0

    public var format: Int32 = 0 //
    public var format_name: String? //

    public var width: Int32 = 0
    public var height: Int32 = 0
    public var b_frames: Int32 = 0
}

public struct VideoStreamInfo {

    public var index: Int32 = 0

    public var start_time: Int64 = 0

    public var duration: Int64 = 0

    public var frames: Int64 = 0

    public var rotation: Int32 = 0

    public var metadata = [String:String]()

    public var codec = VideoCodecParameters()
}

public struct ChapterInfo {

    public var start_time: Int64 = 0

    public var end_time: Int64 = 0

    public var title: String? // nil if no title
}

public struct MediaInfo {
    public var start_time: Int64 = 0 // ms

    public var duration: Int64 = 0

    public var bit_rate: Int64 = 0

    public var size: Int64 = 0

    public var format: String?

    public var streams: Int32 = 0

    public var chapters = [ChapterInfo]()

    public var metadata = [String:String]()

    public var audio = [AudioStreamInfo]()

    public var video = [VideoStreamInfo]()
}

private func from(c cp:mdkAudioCodecParameters, to p:inout AudioCodecParameters) -> Void {
    p.codec = String(cString: cp.codec)
    p.codec_tag = cp.codec_tag
    if cp.extra_data != nil && cp.extra_data_size > 0 {
        p.extra_data = Array(UnsafeBufferPointer(start: cp.extra_data, count: Int(cp.extra_data_size)))
    }
    p.bit_rate = cp.bit_rate
    p.profile = cp.profile
    p.level = cp.level
    p.frame_rate = cp.frame_rate
    p.is_float = cp.is_float
    p.is_planar = cp.is_planar
    p.is_unsigned = cp.is_unsigned
    p.raw_sample_size = cp.raw_sample_size
    p.channels = cp.channels
    p.sample_rate = cp.sample_rate
    p.block_align = cp.block_align
    p.frame_size = cp.frame_size
}

private func from(c cp:mdkVideoCodecParameters, to p:inout VideoCodecParameters) -> Void {
    p.codec = String(cString: cp.codec)
    p.codec_tag = cp.codec_tag
    if cp.extra_data != nil && cp.extra_data_size > 0 {
        p.extra_data = Array(UnsafeBufferPointer(start: cp.extra_data, count: Int(cp.extra_data_size)))
    }
    p.bit_rate = cp.bit_rate
    p.profile = cp.profile
    p.level = cp.level
    p.frame_rate = cp.frame_rate

    p.format = cp.format
    p.format_name = String(cString: cp.format_name)
    p.width = cp.width
    p.height = cp.height
    p.b_frames = cp.b_frames
}

internal func from(c pcinfo:UnsafePointer<mdkMediaInfo>?, to info:inout MediaInfo) -> Void {
    info = MediaInfo()
    guard let cinfo = pcinfo?.pointee  else {
        return
    }
    info.start_time = cinfo.start_time
    info.duration = cinfo.duration
    info.bit_rate = cinfo.bit_rate
    info.size = cinfo.size
    info.format = String(cString: cinfo.format)
    info.streams = cinfo.streams

    var entry = mdkStringMapEntry()
    while MDK_MediaMetadata(pcinfo, &entry) {
        info.metadata[String(cString: entry.key)] = String(cString: entry.value)
    }
    for i in 0..<Int(cinfo.nb_chapters) {
        let cci = cinfo.chapters[i]
        var ci = ChapterInfo()
        ci.start_time = cci.start_time
        ci.end_time = cci.end_time
        if cci.title != nil {
            ci.title = String(cString: cci.title)
        }
        info.chapters.append(ci)
    }
    for i in 0..<Int(cinfo.nb_audio) {
        var si = AudioStreamInfo()
        var csi = cinfo.audio[i]
        si.index = csi.index
        si.start_time = csi.start_time
        si.duration = csi.duration
        si.frames = csi.frames
        var cc = mdkAudioCodecParameters()
        MDK_AudioStreamCodecParameters(&csi, &cc)
        from(c: cc, to: &si.codec)
        var e = mdkStringMapEntry()
        while MDK_AudioStreamMetadata(&csi, &e) {
            si.metadata[String(cString: e.key)] = String(cString: e.value)
        }
        info.audio.append(si)
    }

    for i in 0..<Int(cinfo.nb_video) {
        var si = VideoStreamInfo()
        var csi = cinfo.video[i]
        si.index = csi.index
        si.start_time = csi.start_time
        si.duration = csi.duration
        si.frames = csi.frames
        si.rotation = csi.rotation
        var cc = mdkVideoCodecParameters()
        MDK_VideoStreamCodecParameters(&csi, &cc)
        from(c: cc, to: &si.codec)
        var e = mdkStringMapEntry()
        while MDK_VideoStreamMetadata(&csi, &e) {
            si.metadata[String(cString: e.key)] = String(cString: e.value)
        }
        info.video.append(si)
    }
}
