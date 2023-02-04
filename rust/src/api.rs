#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}

use serde_json::json;

mod ffprobe;
pub fn get_ip_info(ip: String, db_path: String) -> String {
    let searcher = ip2region::Searcher::new(db_path).unwrap();
    match searcher.search(&ip) {
        Ok(info) => {
            info.to_string()
        }
        Err(err) => {
            err.to_string()
        }
    }
}
//执行ffprobe，获取url的媒体信息
pub fn get_media_info(url: String, ffprobe_dir: String) -> String {
    let out = ffprobe::ffprobe(url, ffprobe_dir);
    match out {
        Ok(info) => serde_json::to_string(&json!(info)).unwrap(),
        Err(err) => err.to_string(),
    }
}