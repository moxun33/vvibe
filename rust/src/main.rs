 

mod api;

 

//执行ffprobe，获取url的媒体信息
pub fn get_info()  {
    let out = api::get_media_info("https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8".to_string(), "./../assets/ffprobe.exe".to_string());
      println!("{}",out);

}

fn main(){
   
   // get_info();
}