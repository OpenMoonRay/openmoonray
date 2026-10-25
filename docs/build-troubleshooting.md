# Build Troubleshooting

## Common Errors

### Missing submodules
Fix:
git submodule update --init --recursive

### Missing dependencies
Install:
- libtbb-dev
- libjsoncpp-dev
- libopenexr-dev

### TBB not found (modern systems)
Use:
-DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake

