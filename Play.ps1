$ErrorActionPreference = 'Stop'
$projectDirectory = $PSScriptRoot
$godotCommand = Get-Command godot -ErrorAction SilentlyContinue
$enginePath = if ($godotCommand) { $godotCommand.Source } else { 'C:\Users\pvand\Documents\ChatGPT\ISODOOMVOXEL\.tools\godot\Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64.exe' }
if (-not (Test-Path -LiteralPath $enginePath)) {
    throw 'Install Godot 4 and add godot to PATH, or open project.godot in Godot and press F6.'
}
& $enginePath --path $projectDirectory
