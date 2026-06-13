omr_install_dir=/Applications/MoonRay/installs/openmoonray
houdini_install_dir=${HOUDINI_INSTALL_DIR:-/Applications/Houdini/Houdini20.5.584}
houdini_fallback="${houdini_install_dir}/Frameworks/Houdini.framework/Versions/Current/Resources/houdini"

# save/restore PYTHONPATH, since Houdini runtime can be sensitive to non-Houdini site-packages
OLDPP=${PYTHONPATH}
if [ -f "${omr_install_dir}/scripts/setup.sh" ]; then
    source "${omr_install_dir}/scripts/setup.sh"
fi
export PYTHONPATH=${OLDPP}

export REL="${omr_install_dir}"
export RDL2_DSO_PATH="${omr_install_dir}/rdl2dso.proxy:${omr_install_dir}/rdl2dso"
export MOONRAY_CLASS_PATH="${omr_install_dir}/shader_json"
export ARRAS_SESSION_PATH="${omr_install_dir}/sessions"

prepend_unique_path() {
    local add_path="$1"
    local current="${2:-}"
    case ":${current}:" in
        *":${add_path}:"*) echo "${current}" ;;
        *)
            if [ -n "${current}" ]; then
                echo "${add_path}:${current}"
            else
                echo "${add_path}"
            fi
            ;;
    esac
}

prepend_existing_path() {
    local add_path="$1"
    local current="${2:-}"
    if [ -d "${add_path}" ]; then
        prepend_unique_path "${add_path}" "${current}"
    else
        echo "${current}"
    fi
}

# Preserve any existing USD plugin search path while guaranteeing MoonRay plugin location is present.
export PXR_PLUGINPATH_NAME="$(prepend_unique_path "${omr_install_dir}/plugin/pxr" "${PXR_PLUGINPATH_NAME}")"
export PXR_PLUGIN_PATH="$(prepend_unique_path "${omr_install_dir}/plugin/pxr" "${PXR_PLUGIN_PATH}")"
export PXR_PLUGINPATH_NAME="${PXR_PLUGINPATH_NAME%:}"
export PXR_PLUGIN_PATH="${PXR_PLUGIN_PATH%:}"
export PYTHONPATH="$(prepend_existing_path "${omr_install_dir}/lib/python" "${PYTHONPATH}")"

# Prefer layering MoonRay onto an existing Houdini env (from houdini_setup).
# If that wasn't sourced yet, fall back to the configured Houdini resources path.
if [ -n "${HOUDINI_PATH}" ]; then
    export HOUDINI_PATH="$(prepend_existing_path "${omr_install_dir}/plugin/houdini" "${HOUDINI_PATH}")"
    export HOUDINI_PATH="$(prepend_existing_path "${omr_install_dir}/houdini" "${HOUDINI_PATH}")"
else
    export HOUDINI_PATH="${houdini_fallback}:&"
    export HOUDINI_PATH="$(prepend_existing_path "${omr_install_dir}/plugin/houdini" "${HOUDINI_PATH}")"
    export HOUDINI_PATH="$(prepend_existing_path "${omr_install_dir}/houdini" "${HOUDINI_PATH}")"
fi
