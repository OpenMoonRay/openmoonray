omr_install_dir=/Applications/MoonRay/installs/openmoonray
houdini_install_dir=${HOUDINI_INSTALL_DIR:-/Applications/Houdini/Houdini22.0.440}

# Houdini's process environment is authoritative.  Standalone MoonRay tools do
# not run through Houdini's package loader, so ask H22 to resolve its own
# package/user default only when the caller did not explicitly supply OCIO.
if [ -z "${OCIO+x}" ]; then
    houdini_hython="${houdini_install_dir}/Frameworks/Houdini.framework/Versions/Current/Resources/bin/hython"
    if [ -x "${houdini_hython}" ]; then
        houdini_package_ocio=$(env -u OCIO "${houdini_hython}" -c \
            'import os; print("__MOONRAY_OCIO__=" + os.environ.get("OCIO", ""))' 2>/dev/null | \
            sed -n 's/^__MOONRAY_OCIO__=//p' | tail -n 1)
        if [ -n "${houdini_package_ocio}" ]; then
            export OCIO="${houdini_package_ocio}"
        else
            echo "MoonRay: Houdini 22 did not resolve an OCIO package default; legacy color handling remains available." >&2
        fi
    else
        echo "MoonRay: cannot query Houdini OCIO default; hython was not found at ${houdini_hython}." >&2
    fi
fi

# save/restore PYTHONPATH, since Houdini supplies its own Python runtime
OLDPP=${PYTHONPATH}
source ${omr_install_dir}/scripts/setup.sh
export PYTHONPATH=${OLDPP}

export REL=${omr_install_dir}
export RDL2_DSO_PATH=${omr_install_dir}/rdl2dso.proxy:${omr_install_dir}/rdl2dso
export MOONRAY_CLASS_PATH=${omr_install_dir}/shader_json
export ARRAS_SESSION_PATH=${omr_install_dir}/sessions
export PXR_PLUGINPATH_NAME=${omr_install_dir}/plugin/pxr

# debugging options for Houdini if you are having trouble loading the Moonray plugin
# export HOUDINI_DSO_ERROR=4
# export HOUDINI_OTL_DEBUG=1
# export HOUDINI_PACKAGE_VERBOSE=1

export HOUDINI_OTLSCAN_PATH="${omr_install_dir}/plugin/houdini/otls:&"
export HOUDINI_PATH="${omr_install_dir}/houdini/:${omr_install_dir}/plugin/houdini:&"
