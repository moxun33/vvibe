#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}

use serde_json::json;
use xdb::{search_by_ip, searcher_init};
use ffmpeg;
mod metadata;




pub fn get_ip_info(ip: String, db_path: String) -> String {
    searcher_init(Some(db_path.to_owned()));
    match search_by_ip(ip.as_str()) {
        Ok(info) => {
            info.to_string()
        }
        Err(err) => {
            err.to_string()
        }
    }
}
//执行ffprobe，获取url的媒体信息
/* pub fn get_media_infooo(url: String, ffprobe_dir: String) -> String {
    let out = ffprobe::ffprobe(url, ffprobe_dir);
    match out {
        Ok(info) => serde_json::to_string(&json!(info)).unwrap(),
        Err(err) => err.to_string(),
    } }*/
//执行ffmpeg，获取url的媒体信息
pub fn get_media_info(url: String,dir: String) -> String  {
    ffmpeg::init().unwrap();
     let v=std::path::Path::new(&url);
   let out=ffmpeg::format::input(&v);
   match out {
    Ok(context) =>  serde_json::to_string(&json!(metadata::Metadata::new(&context))).unwrap(),//serde_json::to_string(&json!(context.streams())).unwrap(),
    Err(err) => err.to_string(),
    }
}