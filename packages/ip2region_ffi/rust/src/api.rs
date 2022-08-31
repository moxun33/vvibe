use ip2region;
//ip2region
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
