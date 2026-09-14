# Houdini 22 OCIO color management

MoonRay uses Houdini's active OpenColorIO (OCIO) configuration when rendering
through Solaris or `husk`. MoonRay produces linear pixels in the render working
space; Houdini applies the selected display and view transform in Solaris and
MPlay, and `husk` can apply the requested file-output conversion.

This integration targets Houdini 22.0.440, Hydra 2.0, Python 3.13, and OCIO 2.5.

## Configuration and working space

The `OCIO` environment inherited by the Houdini process is authoritative. This
allows Houdini packages, a studio launcher, or an explicitly exported value to
select the configuration. USD `colorConfiguration` stage overrides are not
currently consumed.

For standalone MoonRay tools, `scripts/macOS/setupHoudini.sh` asks Houdini 22 to
resolve its package/user OCIO default only when `OCIO` is absent. An explicitly
supplied `OCIO` value is preserved.

The Hydra delegate consumes the standard
`UsdRenderSettings.renderingColorSpace` value. It resolves the render working
space in this order:

1. The authored `renderingColorSpace`, when it names a usable non-data color
   space, role, or alias.
2. The OCIO `rendering` role.
3. The `scene_linear` role.
4. The `default_float` role.
5. The `reference` role.
6. The `default` role, with a warning.

The default source for authored scene colors is resolved from `scene_linear`,
then `default_float`, `reference`, and `default`. When Hydra delivers color-space
metadata for a material parameter or color primvar, that metadata takes
precedence for the value.

Changing `renderingColorSpace` rebuilds the processors, republishes the working
space to MoonRay's texture system, invalidates affected resources, and restarts
the render. Houdini should therefore refresh Solaris IPR without stale material
or texture data.

## What is transformed

Only values with color meaning are transformed:

- RGB and RGBA material parameters
- light and light-filter colors
- primvars whose USD role is `color`
- native MoonRay image textures
- `UsdUVTexture`
- supported MaterialX `color3` and `color4` image signatures

RGBA transforms affect RGB only; alpha is preserved. Positions, normals,
vectors, UVs, masks, scalar values, and other data values are not transformed.
MaterialX float and vector image signatures, normal maps, and utility maps are
explicitly treated as raw data.

## Texture source color spaces

`ImageMap` provides a `source_color_space` string parameter. Its default is
`auto`:

- `auto` applies the active OCIO config's file rules to the texture filename.
- A color-space name, role, or alias selects that source explicitly.
- `raw`, `data`, or `none` bypasses color conversion.
- A color space marked as data by OCIO also bypasses conversion.

The Houdini ImageMap node builds the parameter menu from the active config with
Houdini 22's `PyOpenColorIO`, including available roles and color spaces. The
policy applies to ordinary images, tiled `.tx` files, and UDIM inputs.

`UsdUVTexture.sourceColorSpace` remains supported. Its `raw`, `sRGB`, and `auto`
values map to raw data, an OCIO-resolved sRGB space, and OCIO file rules,
respectively. The optional `source_color_space` string overrides that enum when
it is non-empty and accepts the same values as `ImageMap.source_color_space`.

Texture processors are shared using the OCIO config cache ID, resolved source,
and render target as the cache key.

### Legacy gamma compatibility

The existing texture gamma parameters remain loadable for older scenes but are
deprecated. A resolved OCIO policy takes precedence. Legacy gamma is used only
when OCIO is unavailable or the requested conversion cannot be resolved, and a
texture emits that fallback warning only once.

For new scenes, set an accurate source color space or use `auto`; do not use the
gamma parameter to describe a texture's encoding.

## Display and file output

MoonRay does not bake a display/view transform into its render buffers. Beauty
and color AOVs stay linear in `renderingColorSpace`, while raw/data AOVs remain
non-color data.

- Solaris and MPlay apply Houdini's display/view transform.
- Normal `husk` operation can perform Houdini's configured output conversion.
- `husk --ocio 0` writes the unconverted linear render result and is useful for
  validating the selected working space.

Avoid adding a second display transform in a MoonRay material or post-process;
doing so will double-transform the image in the Houdini viewer.

## Diagnostics and troubleshooting

At startup and whenever the working space changes, hdMoonray reports the OCIO
version, config path/cache ID, source and target spaces, how they were resolved,
whether conversion is active, and any fallback reason. Texture warnings include
the filename and corresponding source/target decision.

If MoonRay reports that OCIO is unset or invalid:

1. Inspect `OCIO` inside the same Houdini process or shell used to launch the
   renderer.
2. Confirm that the path is readable and the config validates in Houdini 22's
   `PyOpenColorIO`.
3. Confirm that the config provides a non-data `rendering` or `scene_linear`
   role, or author a valid `renderingColorSpace` on the render settings.
4. Relaunch Houdini after changing its package configuration so the new process
   inherits the intended environment.

An invalid configuration or missing role produces an actionable warning rather
than terminating the render. If no valid OCIO conversion can be built, scene
colors remain unchanged and legacy texture gamma remains available as a
compatibility fallback.

## Binary compatibility

The Houdini-facing Hydra delegate builds against the matching SideFX OCIO 2.5
headers and `libOpenColorIO_sidefx.2.5` from the configured Houdini installation.
MoonRay's core shading and texture DSOs continue to use the bundled standard
`libOpenColorIO.2.5`. The two implementations communicate the resolved target
name through the internal `MOONRAY_OCIO_RENDERING_COLOR_SPACE` bridge; OCIO
objects never cross that ABI boundary.

