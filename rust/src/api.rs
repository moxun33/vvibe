/*
 * @Author: Moxx
 * @Date: 2022-09-02 18:08:14
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-02 18:09:40
 */
mod ffprobe;

//获取ip的地理位置信息

pub fn get_ip_info(ip: String, db_path: String) -> String {
    let searcher = ip2region::Searcher::new(db_path).unwrap();
    match searcher.search(&ip) {
        Ok(info) => info.to_string(),
        Err(err) => err.to_string(),
    }
}

//执行ffprobe，获取url的媒体信息
pub fn get_media_info(url: String, ffprobe_dir: String) -> String {
    let out = ffprobe::ffprobe(url, ffprobe_dir);
}
