#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
//#include "flutter_native_view/flutter_native_view_plugin.h"
#include "flutter_window.h"
#include "utils.h"

//#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>

//auto bdw = bitsdojo_window_configure(BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP);
#include <uni_links_desktop/uni_links_desktop_plugin.h>
int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
     // Replace uni_links_desktop_example with your_window_title.
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"vvibe");
  if (hwnd != NULL) {
    DispatchToUniLinksDesktop(hwnd);

    ::ShowWindow(hwnd, SW_NORMAL);
    ::SetForegroundWindow(hwnd);
    return EXIT_FAILURE;
 }
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 750);

  if (!window.CreateAndShow(L"vvibe", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

 // flutternativeview::NativeViewContainer::GetInstance()->Create();

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
