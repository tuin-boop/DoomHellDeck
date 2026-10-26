$ErrorActionPreference = 'Stop'
$godotCommand = Get-Command godot -ErrorAction SilentlyContinue
if (-not $godotCommand) { throw 'Install Godot 4.7.2 and add godot to PATH, or open project.godot in Godot and press F5.' }
& $godotCommand.Source --path $PSScriptRoot
