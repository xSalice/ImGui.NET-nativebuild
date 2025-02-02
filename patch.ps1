# Paths to the files we need to patch
$headerFile = "cimgui/imgui/backends/imgui_impl_win32.h"
$cppFile = "cimgui/imgui/backends/imgui_impl_win32.cpp"

# Patch the header file
Write-Host "Patching $headerFile..."
$headerContent = Get-Content $headerFile -Raw
# Add windows.h include after #pragma once if it's not already present
if (-not ($headerContent -match '#include <windows.h>')) {
    $headerContent = $headerContent -replace '#pragma once', "#pragma once`n#include <windows.h>"
}
$headerContent = $headerContent -replace '#if 0\r?\nextern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler\(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam\);\r?\n#endif', 'IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);'
Set-Content -Path $headerFile -Value $headerContent -NoNewline

# Patch the cpp file
Write-Host "Patching $cppFile..."
$cppContent = Get-Content $cppFile -Raw
$cppContent = $cppContent -replace 'extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler\(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam\);.*?\r?\n', ''
$cppContent = $cppContent -replace 'extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandlerEx\(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam, ImGuiIO& io\);.*?\r?\n', ''

# Add the new forward declaration after UpdateMonitors
$cppContent = $cppContent -replace 'static void ImGui_ImplWin32_UpdateMonitors\(\);', "static void ImGui_ImplWin32_UpdateMonitors();`nstatic LRESULT CALLBACK ImGui_ImplWin32_WndProcHandlerEx(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam, ImGuiIO& io);"

# Update the function definition
$cppContent = $cppContent -replace 'IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandlerEx\(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam, ImGuiIO& io\)', 'IMGUI_IMPL_API LRESULT CALLBACK ImGui_ImplWin32_WndProcHandlerEx(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam, ImGuiIO& io)'

Set-Content -Path $cppFile -Value $cppContent -NoNewline

Write-Host "Patching complete!"
