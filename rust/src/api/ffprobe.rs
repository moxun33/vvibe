//! Simple wrapper for the [ffprobe](https://ffmpeg.org/ffprobe.html) CLI utility,
//! which is part of the ffmpeg tool suite.
//!
//! This crate allows retrieving typed information about media files (images and videos)
//! by invoking `ffprobe` with JSON output options and deserializing the data
//! into convenient Rust types.
//!
//!
//!
//! ```rust
//! match ffprobe::ffprobe("path/to/video.mp4") {
//!    Ok(info) => {
//!        dbg!(info);
//!    },
//!    Err(err) => {
//!        eprintln!("Could not analyze file with ffprobe: {:?}", err);
//!     },
//! }
//! ```


use std::process::Command;
use std::os::windows::process::CommandExt;

const CREATE_NO_WINDOW: u32 = 0x08000000;
const DETACHED_PROCESS: u32 = 0x00000008;
/// Execute ffprobe with default settings and return the extracted data.
///
/// See [`ffprobe_config`] if you need to customize settings.
pub fn ffprobe(
    path: impl AsRef<std::path::Path>,
    ffprobe_dir: String,
) -> Result<FfProbe, FfProbeError> {
    ffprobe_config(
        Config {
            count_frames: false,
        },
        path,
        ffprobe_dir,
    )
}

/// Run ffprobe with a custom config.
/// See [`ConfigBuilder`] for more details.
pub fn ffprobe_config(
    config: Config,
    path: impl AsRef<std::path::Path>,
    ffprobe_dir: String,
) -> Result<FfProbe, FfProbeError> {
    let path = path.as_ref();
 
    let mut cmd = Command::new(std::path::Path::new(&ffprobe_dir));
    //println!("{}", cmd.status().unwrap());
    cmd.creation_flags(DETACHED_PROCESS);
    
    // Default args.
    cmd.args(&[
        "-v",
        "quiet",
        "-show_format",
        "-show_streams",
        "-print_format",
        "json",
        "-headers",
        "\"User-Agent: VVibe Windows ZTE\"",
    ]);
    if config.count_frames {
        cmd.arg("-count_frames");
    }

    cmd.arg(path);

    let out = cmd.output().map_err(FfProbeError::Io)?;

    if !out.status.success() {
        return Err(FfProbeError::Status(out));
    }

    serde_json::from_slice::<FfProbe>(&out.stdout).map_err(FfProbeError::Deserialize)
}

/// ffprobe configuration.
///
/// Use [`Config::builder`] for constructing a new config.
#[derive(Clone, Debug)]
pub struct Config {
    count_frames: bool,
}

impl Config {
    /// Construct a new ConfigBuilder.
    pub fn builder() -> ConfigBuilder {
        ConfigBuilder::new()
    }
}

/// Build the ffprobe configuration.
pub struct ConfigBuilder {
    config: Config,
}

impl ConfigBuilder {
    pub fn new() -> Self {
        Self {
            config: Config {
                count_frames: false,
            },
        }
    }

    /// Enable the -count_frames setting.
    /// Will fully decode the file and count the frames.
    /// Frame count will be available in [`Stream::nb_read_frames`].
    pub fn count_frames(mut self, count_frames: bool) -> Self {
        self.config.count_frames = count_frames;
        self
    }

    /// Finalize the builder into a [`Config`].
    pub fn build(self) -> Config {
        self.config
    }

    /// Run ffprobe with the config produced by this builder.
    pub fn run(
        self,
        path: impl AsRef<std::path::Path>,
        ffprobe_dir: String,
    ) -> Result<FfProbe, FfProbeError> {
        ffprobe_config(self.config, path, ffprobe_dir)
    }
}

#[derive(Debug)]
#[non_exhaustive]
pub enum FfProbeError {
    Io(std::io::Error),
    Status(std::process::Output),
    Deserialize(serde_json::Error),
}

impl std::fmt::Display for FfProbeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            FfProbeError::Io(e) => e.fmt(f),
            FfProbeError::Status(o) => {
                write!(
                    f,
                    "ffprobe exited with status code {}: {}",
                    o.status,
                    String::from_utf8_lossy(&o.stderr)
                )
            }
            FfProbeError::Deserialize(e) => e.fmt(f),
        }
    }
}

impl std::error::Error for FfProbeError {}

#[derive(Default, Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
#[cfg_attr(feature = "__internal_deny_unknown_fields", serde(deny_unknown_fields))]
pub struct FfProbe {
    pub streams: Vec<Stream>,
    pub format: Format,
}

#[derive(Default, Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
#[cfg_attr(feature = "__internal_deny_unknown_fields", serde(deny_unknown_fields))]
pub struct Stream {
    pub index: i64,
    pub codec_name: Option<String>,
    pub sample_aspect_ratio: Option<String>,
    pub display_aspect_ratio: Option<String>,
    pub color_range: Option<String>,
    pub color_space: Option<String>,
    pub bits_per_raw_sample: Option<String>,
    pub channel_layout: Option<String>,
    pub max_bit_rate: Option<String>,
    pub nb_frames: Option<String>,
    /// Number of frames seen by the decoder.
    /// Requires full decoding and is only available if the 'count_frames'
    /// setting was enabled.
    pub nb_read_frames: Option<String>,
    pub codec_long_name: Option<String>,
    pub codec_type: Option<String>,
    pub codec_time_base: Option<String>,
    pub codec_tag_string: String,
    pub codec_tag: String,
    pub sample_fmt: Option<String>,
    pub sample_rate: Option<String>,
    pub channels: Option<i64>,
    pub bits_per_sample: Option<i64>,
    pub r_frame_rate: String,
    pub avg_frame_rate: String,
    pub time_base: String,
    pub start_pts: Option<i64>,
    pub start_time: Option<String>,
    pub duration_ts: Option<i64>,
    pub duration: Option<String>,
    pub bit_rate: Option<String>,
    pub disposition: Disposition,
    pub tags: Option<StreamTags>,
    pub profile: Option<String>,
    pub width: Option<i64>,
    pub height: Option<i64>,
    pub coded_width: Option<i64>,
    pub coded_height: Option<i64>,
    pub closed_captions: Option<i64>,
    pub has_b_frames: Option<i64>,
    pub pix_fmt: Option<String>,
    pub level: Option<i64>,
    pub chroma_location: Option<String>,
    pub refs: Option<i64>,
    pub is_avc: Option<String>,
    pub nal_length: Option<String>,
    pub nal_length_size: Option<String>,
    pub field_order: Option<String>,
    pub id: Option<String>,
    #[serde(default)]
    pub side_data_list: Vec<SideData>,
}

#[derive(Default, Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
#[cfg_attr(feature = "__internal_deny_unknown_fields", serde(deny_unknown_fields))]
pub struct SideData {
    pub side_data_type: String,
}

#[derive(Default, Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
#[cfg_attr(feature = "__internal_deny_unknown_fields", serde(deny_unknown_fields))]
pub struct Disposition {
    pub default: i64,
    pub dub: i64,
    pub original: i64,
    pub comment: i64,
    pub lyrics: i64,
    pub karaoke: i64,
    pub forced: i64,
    pub hearing_impaired: i64,
    pub visual_impaired: i64,
    pub clean_effects: i64,
    pub attached_pic: i64,
    pub timed_thumbnails: i64,
}

#[derive(Default, Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
#[cfg_attr(feature = "__internal_deny_unknown_fields", serde(deny_unknown_fields))]
pub struct StreamTags {
    pub language: Option<String>,
    pub creation_time: Option<String>,
    pub handler_name: Option<String>,
    pub encoder: Option<String>,
}

#[derive(Default, Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
#[cfg_attr(feature = "__internal_deny_unknown_fields", serde(deny_unknown_fields))]
pub struct Format {
    pub filename: String,
    pub nb_streams: i64,
    pub nb_programs: i64,
    pub format_name: String,
    pub format_long_name: String,
    pub start_time: Option<String>,
    pub duration: Option<String>,
    // FIXME: wrap with Option<_> on next semver breaking release.
    #[serde(default)]
    pub size: String,
    pub bit_rate: Option<String>,
    pub probe_score: i64,
    pub tags: Option<FormatTags>,
}

#[derive(Default, Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
#[cfg_attr(feature = "__internal_deny_unknown_fields", serde(deny_unknown_fields))]
pub struct FormatTags {
    #[serde(rename = "WMFSDKNeeded")]
    pub wmfsdkneeded: Option<String>,
    #[serde(rename = "DeviceConformanceTemplate")]
    pub device_conformance_template: Option<String>,
    #[serde(rename = "WMFSDKVersion")]
    pub wmfsdkversion: Option<String>,
    #[serde(rename = "IsVBR")]
    pub is_vbr: Option<String>,
    pub major_brand: Option<String>,
    pub minor_version: Option<String>,
    pub compatible_brands: Option<String>,
    pub creation_time: Option<String>,
    pub encoder: Option<String>,
}