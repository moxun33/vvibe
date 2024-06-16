 

mod api;

 

//执行ffmpeg，获取url的媒体信息
pub fn get_meta_info()  {
    let out = api::get_media_info("https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8".to_string());
      println!("{}",out);

}
pub fn get_ip(){
   let out = api::get_ip_info("58.244.130.20".to_string(), "./../assets/ip2region.xdb".to_string());
   println!("{}",out);
}
fn main(){
   //get_ip();
   // get_meta_info();
}