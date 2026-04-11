#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
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

  // Startup window: 800x600, centered
  HMONITOR hMon = MonitorFromPoint({0, 0}, MONITOR_DEFAULTTOPRIMARY);
  UINT dpi = FlutterDesktopGetDpiForMonitor(hMon);
  double sf = (dpi > 0) ? (dpi / 96.0) : 1.0;

  int physW = GetSystemMetrics(SM_CXSCREEN);
  int physH = GetSystemMetrics(SM_CYSCREEN);
  int logW = static_cast<int>(physW / sf);
  int logH = static_cast<int>(physH / sf);

  int winW = 800;
  int winH = 600;
  int ox = (logW - winW) / 2;
  int oy = (logH - winH) / 2;
  if (ox < 0) ox = 10;
  if (oy < 0) oy = 10;

  Win32Window::Point origin(ox, oy);
  Win32Window::Size size(winW, winH);
  if (!window.Create(L"\u65e0\u754c", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
