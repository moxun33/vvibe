#include "fvp_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <chrono>
#include <memory>
#include <sstream>

using namespace std;

#define MS_ENSURE(f, ...) MS_CHECK(f, return __VA_ARGS__;)
#define MS_WARN(f) MS_CHECK(f)
#define MS_CHECK(f, ...)                                                                                                                                                                              \
    do                                                                                                                                                                                                \
    {                                                                                                                                                                                                 \
        while (FAILED(GetLastError()))                                                                                                                                                                \
        {                                                                                                                                                                                             \
        }                                                                                                                                                                                             \
        printf(#f "\n");                                                                                                                                                                              \
        fflush(nullptr);                                                                                                                                                                              \
        HRESULT __ms_hr__ = (f);                                                                                                                                                                      \
        if (FAILED(__ms_hr__))                                                                                                                                                                        \
        {                                                                                                                                                                                             \
            std::clog << #f "  ERROR@" << __LINE__ << __FUNCTION__ << ": (" << std::hex << __ms_hr__ << std::dec << ") " << std::error_code(__ms_hr__, std::system_category()).message() << std::endl \
                      << std::flush;                                                                                                                                                                  \
            __VA_ARGS__                                                                                                                                                                               \
        }                                                                                                                                                                                             \
    } while (false)

namespace fvp
{

    using flutter::EncodableList;
    using flutter::EncodableMap;
    using flutter::EncodableValue;
    std::unique_ptr<flutter::MethodChannel<EncodableValue>,
                    std::default_delete<flutter::MethodChannel<EncodableValue>>>
        channel = nullptr;

    // static
    void FvpPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar)
    {
        channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "fvp",
                &flutter::StandardMethodCodec::GetInstance());
        auto plugin = std::make_unique<FvpPlugin>(registrar->texture_registrar()
#ifdef VIEW_HAS_GetGraphicsAdapter
                                                      ,
                                                  registrar->GetView()->GetGraphicsAdapter()
#endif
        );

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result)
            {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

        registrar->AddPlugin(std::move(plugin));
    }

    FvpPlugin::FvpPlugin(flutter::TextureRegistrar *tr, IDXGIAdapter *adapter)
        : texture_registrar_(tr), adapter_(adapter)
    {
    }

    FvpPlugin::~FvpPlugin() {}

    void FvpPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {

        const flutter::EncodableMap *argsList = std::get_if<flutter::EncodableMap>(method_call.arguments());
        const string methodName = method_call.method_name();
        // std::cout << "start fvp plugin!" << std::endl;
        if (methodName == "CreateRT")
        {
            MS_WARN(D3D11CreateDevice(adapter_.Get(), adapter_ ? D3D_DRIVER_TYPE_UNKNOWN : D3D_DRIVER_TYPE_HARDWARE, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev_, nullptr, &ctx_));
            if (!dev_)
            {
                result->Error("device", "create device failed");
                return;
            }
            ComPtr<ID3D10Multithread> mt;
            if (SUCCEEDED(dev_.As(&mt)))
                mt->SetMultithreadProtected(TRUE);
            D3D11_TEXTURE2D_DESC desc{};
            desc.Width = 1920;
            desc.Height = 1080;
            desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM; // rgba eglbind error
            desc.MipLevels = 1;
            desc.ArraySize = 1;
            desc.SampleDesc.Count = 1;
            desc.Usage = D3D11_USAGE_DEFAULT;
            desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
            desc.MiscFlags = D3D11_RESOURCE_MISC_SHARED; // | D3D11_RESOURCE_MISC_SHARED_NTHANDLE;
            MS_WARN(dev_->CreateTexture2D(&desc, nullptr, &tex_));
            if (!tex_)
            {
                result->Success();
                return;
            }
            ComPtr<ID3D11RenderTargetView> rtv;
            dev_->CreateRenderTargetView(tex_.Get(), nullptr, &rtv);
            const float c[] = {0.0f, 0.0f, 0.0f, 1.0f};
            ctx_->ClearRenderTargetView(rtv.Get(), c);

            ComPtr<IDXGIResource> res;
            MS_WARN(tex_.As(&res));
            MS_WARN(res->GetSharedHandle(&shared_handle_));
            surface_desc_ = make_unique<FlutterDesktopGpuSurfaceDescriptor>();

            surface_desc_->struct_size = sizeof(FlutterDesktopGpuSurfaceDescriptor);
            surface_desc_->handle = shared_handle_; // tex_.Get();
            // surface_desc_->handle = tex_.Get(); // eglbind error
            surface_desc_->width = surface_desc_->visible_width = desc.Width;
            surface_desc_->height = surface_desc_->visible_height = desc.Height;
            surface_desc_->release_context = nullptr;
            surface_desc_->release_callback = [](void *release_context) {};
            // surface_desc_->format = kFlutterDesktopPixelFormatBGRA8888;
            fltex_ = make_unique<flutter::TextureVariant>(flutter::GpuSurfaceTexture(
                kFlutterDesktopGpuSurfaceTypeDxgiSharedHandle
                // kFlutterDesktopGpuSurfaceTypeD3d11Texture2D
                ,
                [&](size_t width, size_t height)
                {
                    // printf("ObtainDescriptorCallback %llux%llu. shared_handle_ %p\n", width, height, shared_handle_); fflush(nullptr);
                    // player_.renderVideo(); // stutter
                    return surface_desc_.get();
                }));
            texture_id_ = texture_registrar_->RegisterTexture(fltex_.get());
            result->Success(flutter::EncodableValue(texture_id_));

        //    player_.setLoop(-1);
            player_.setDecoders(MediaType::Video, {"MFT:d3d=11", "D3D11", "FFmpeg"});
            D3D11RenderAPI ra{};
            ra.rtv = tex_.Get();
            player_.setRenderAPI(&ra);
            player_.setVideoSurfaceSize(desc.Width, desc.Height);
            player_.setBackgroundColor(0, 0, 0, -1);
            player_.setProperty("user-agent", "FVP ZTE");
            //SetGlobalOption("videoout.clear_on_stop", 1);
            player_.setBufferRange(1000, 10000);
            player_.onEvent([](const MediaEvent &e)
                            {
                                std::cout << "----**** media event: " << e.category << ", error: " <<e.error << ", detail: " <<e.detail << std::endl;
                                EncodableMap data = EncodableMap();
                                data[EncodableValue("category")] = EncodableValue(e.category);
                                data[EncodableValue("error")] = EncodableValue((int)e.error);
                                data[EncodableValue("detail")] = EncodableValue(e.detail);
                                /* data[EncodableValue("decoder")] = EncodableValue(EncodableMap{EncodableValue("stream"),EncodableValue(e.decoder.stream)}); */
                                channel->InvokeMethod("onEvent", std::make_unique<flutter::EncodableValue>(data));
                                return false; });
            player_.onMediaStatusChanged([](MediaStatus s)
                                         {
                                        //MediaStatus s = player.mediaStatus();
                                        printf("************Media status: %d, loading: %d, buffering: %d, prepared: %d, EOF: %d**********\n", s, s&MediaStatus::Loading, s&MediaStatus::Buffering, s&MediaStatus::Prepared, s&MediaStatus::End);
                                         
                                        channel->InvokeMethod("onMediaStatusChanged", std::make_unique<flutter::EncodableValue>(EncodableValue(static_cast<int>(s))));
                                        return true; });
            player_.onStateChanged([&](State s)
                                   {
                                   // printf("state changed to %d ", s);
                                 channel->InvokeMethod("onStateChanged",std::make_unique<flutter::EncodableValue>(EncodableValue(static_cast<int>(s)))); });
            player_.setRenderCallback([&](void *)
                                      {
                                        player_.renderVideo();
                                        texture_registrar_->MarkTextureFrameAvailable(texture_id_); });
        }
        if (methodName == "stop")
        {
            //停止播放
            player_.setNextMedia(nullptr,-1);
            player_.set(State::Stopped);
            player_.waitFor(State::Stopped);
            player_.setMedia(nullptr);
        
            result->Success(EncodableValue(1));
        }
        if (methodName == "setMedia")
        {
            std::cout << "to set new media" << std::endl;
            auto url_it = argsList->find(flutter::EncodableValue("url"));
            std::string url;
            if (url_it != argsList->end())
            {
                url = std::get<std::string>(url_it->second);
            }
             
            player_.setNextMedia(nullptr,-1);
            player_.set(State::Stopped);
            player_.waitFor(State::Stopped);

            player_.setMedia(nullptr);
            player_.setMedia(url.c_str());
            player_.set(State::Playing);
            player_.waitFor(State::Playing);

            // player_.setActiveTracks(MediaType::Video,std::set(0));
           // auto &c = player_.mediaInfo().video[0].codec;
            // player_.setVideoSurfaceSize(c.width, c.height);
           // player_.resizeSurface(c.width, c.height);
            result->Success(EncodableValue(1));
        }
        if (methodName == "getMediaInfo")
        {

            auto info = player_.mediaInfo();
            if (!(info.start_time > 0 && info.video.size() > 0 && info.audio.size() > 0))
            {
                result->Error("get metadata failed");
                return;
            }
            VideoStreamInfo video = info.video.front();
            AudioStreamInfo audio = info.audio.front();

            result->Success(EncodableValue(EncodableMap{
                {EncodableValue("start_time"), EncodableValue(info.start_time)},
                {EncodableValue("duration"), EncodableValue(info.duration)},
                {EncodableValue("bit_rate"), EncodableValue(info.bit_rate)},
                {EncodableValue("size"), EncodableValue(info.size)},
                {EncodableValue("format"), EncodableValue(info.format)},
                {EncodableValue("streams"), EncodableValue(info.streams)},
                {EncodableValue("metadata"), EncodableValue(EncodableMap{})},
                {EncodableValue("video"), EncodableValue(EncodableMap{
                                              {EncodableValue("codec"), EncodableValue(EncodableMap{
                                                                            {EncodableValue("codec"), EncodableValue(video.codec.codec)},
                                                                            /* {EncodableValue("codec_tag"), EncodableValue(video.codec.codec_tag > 0 ? video.codec.codec_tag : 0)}, */
                                                                            {EncodableValue("profile"), EncodableValue(video.codec.profile)},
                                                                            {EncodableValue("level"), EncodableValue(video.codec.level)},
                                                                            {EncodableValue("bit_rate"), EncodableValue(video.codec.bit_rate)},
                                                                            {EncodableValue("format"), EncodableValue(video.codec.format)},
                                                                            {EncodableValue("frame_rate"), EncodableValue(video.codec.frame_rate)},
                                                                            {EncodableValue("format_name"), EncodableValue(video.codec.format_name)},
                                                                            {EncodableValue("width"), EncodableValue(video.codec.width)},
                                                                            {EncodableValue("height"), EncodableValue(video.codec.height)},
                                                                        })},
                                              {EncodableValue("start_time"), EncodableValue(video.start_time)},
                                              {EncodableValue("metadata"), EncodableValue(EncodableMap{})},
                                              {EncodableValue("rotation"), EncodableValue(video.rotation)},
                                              {EncodableValue("duration"), EncodableValue(video.duration)},
                                              {EncodableValue("frames"), EncodableValue(video.frames)},
                                              {EncodableValue("index"), EncodableValue(video.index)},
                                          })},
                {EncodableValue("audio"), EncodableValue(EncodableMap{
                                              {EncodableValue("codec"), EncodableValue(EncodableMap{
                                                                            {EncodableValue("codec"), EncodableValue(audio.codec.codec)},
                                                                            /* {EncodableValue("codec_tag"), EncodableValue(audio.codec.codec_tag > 0 ? audio.codec.codec_tag : 0)}, */
                                                                            {EncodableValue("profile"), EncodableValue(audio.codec.profile)},
                                                                            {EncodableValue("level"), EncodableValue(audio.codec.level)},
                                                                            {EncodableValue("bit_rate"), EncodableValue(audio.codec.bit_rate)},
                                                                            {EncodableValue("frame_rate"), EncodableValue(audio.codec.frame_rate)},
                                                                            {EncodableValue("channels"), EncodableValue(audio.codec.channels)},
                                                                            {EncodableValue("block_align"), EncodableValue(audio.codec.block_align)},
                                                                            {EncodableValue("frame_size"), EncodableValue(audio.codec.frame_size)},
                                                                            {EncodableValue("raw_sample_size"), EncodableValue(audio.codec.raw_sample_size)},
                                                                        })},
                                              {EncodableValue("start_time"), EncodableValue(audio.start_time)},
                                              {EncodableValue("metadata"), EncodableValue(EncodableMap{})},
                                              {EncodableValue("duration"), EncodableValue(audio.duration)},
                                              {EncodableValue("frames"), EncodableValue(audio.frames)},
                                              {EncodableValue("index"), EncodableValue(audio.index)},
                                          })},
                /* {EncodableValue("bit_rate"), EncodableValue(EncodableList{
                                               EncodableValue(1),
                                               EncodableValue(2.0),
                                               EncodableValue(4),
            })*/
            }));
        }

        if (methodName == "playOrPause")
        {
            if (player_.state() == State::Playing)
            {
                player_.set(State::Paused);
                player_.waitFor(State::Paused);
            }
            else
            {
                player_.set(State::Playing);
                player_.waitFor(State::Playing);
            }
            result->Success(EncodableValue(1));
        }
        if (methodName == "setVolume")
        {
            auto v_it = argsList->find(EncodableValue("volume"));
            float v = 1.0;
            if (v_it != argsList->end())
            {
                v = (float)std::get<double>(v_it->second);
            }
            player_.setVolume(v);
            result->Success(EncodableValue(1));
        }
        if (methodName == "setMute")
        {
            auto m_it = argsList->find(EncodableValue("mute"));
            bool m = true;
            if (m_it != argsList->end())
            {
                m = std::get<bool>(m_it->second);
            }
            player_.setMute(m);
            result->Success(EncodableValue(1));
        }
        if (methodName == "setTimeout")
        {
            auto t_it = argsList->find(EncodableValue("time"));
            int t = 10000;
            if (t_it != argsList->end())
            {
                t = std::get<int>(t_it->second);
            }
            player_.setTimeout(t);
            result->Success(EncodableValue(1));
        }
        if (methodName == "getState")
        {
            State t = player_.state();
            result->Success(EncodableValue(static_cast<int>(t)));
        }
        if (methodName == "getStatus")
        {
            MediaStatus t = player_.mediaStatus();
            result->Success(EncodableValue(static_cast<int>(t)));
        }
        if (methodName == "snapshot")
        {

            Player::SnapshotRequest req{};
            // player_.snapshot(&req, nullptr);
            player_.snapshot(&req, [](Player::SnapshotRequest *r, double t)
                             {
                                std::chrono::milliseconds ms = std::chrono::duration_cast< std::chrono::milliseconds >(
                                    std::chrono::system_clock::now().time_since_epoch()
                                );
                                 return "snapshots/" + std::to_string(ms.count()) + "-snapshot.jpg"; });
            result->Success(EncodableValue("done"));
        }
        if (methodName == "setUserAgent")
        {
            auto v_it = argsList->find(EncodableValue("ua"));
            string v = "FVP";
            if (v_it != argsList->end())
            {
                v = std::get<string>(v_it->second);
            }
            player_.setProperty("user-agent", v);
            result->Success(EncodableValue(1));
        }
        if (methodName == "volume")
        {
            float t = player_.volume();
            result->Success(EncodableValue((float)(t)));
        }
        else
        {
            result->NotImplemented();
        }
    }

} // namespace fvp
