# Build 42 package

This directory is selected by Project Zomboid Build 42.20 and later. The legacy
Build 41 files remain at the repository root so the same package can support both
game builds.

Build 42 definitions must be registered before their scripts load. The B42
framework therefore uses `media/registries.lua` and static script definitions;
runtime Lua only attaches behaviour to definitions that already exist.
