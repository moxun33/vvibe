/*
 * @Author: Moxx
 * @Date: 2022-09-02 18:08:14
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-02 22:33:49
 */



//获取ip的地理位置信息

pub fn get_ip_info(ip: String, db_path: String) -> String {
    let searcher = ip2region::Searcher::new(db_path).unwrap();
    match searcher.search(&ip) {
        Ok(info) => info.to_string(),
        Err(err) => err.to_string(),
    }
}




