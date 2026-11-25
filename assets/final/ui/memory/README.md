# Memory UI assets

Source: user-supplied `Memory_UI_Pack_v1.zip`, found in Windows Downloads on 2026-11-23. The supplied README identifies the panel as AI-generated, based on the existing inventory art. The original transparent PNG (1586×992) and seven SVG icons are retained without raster stretching or baked-in UI text.

Only runtime art and Godot import descriptions are included here. `vscode_prompt.txt`, HTML sample data, preview PNG/SVG files, build scripts and the ZIP remain outside the project. The HTML is a design reference, not a save implementation. No new CG was generated.

Runtime: `scenes/ui/memory_ui.gd` renders the full panel with its original aspect ratio. Godot draws localized text and interactive controls in the inset content area.
