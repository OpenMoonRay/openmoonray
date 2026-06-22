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

resolve_ocio_package_value() {
    local raw_value="$1"
    local value="${raw_value}"

    case "${value}" in
        \${OCIO-*})
            value="${value#\$\{OCIO-}"
            value="${value%\}}"
            ;;
    esac

    value="${value//\$HOME/${HOME}}"
    case "${value}" in
        "~/"*) value="${HOME}/${value#~/}" ;;
    esac
    echo "${value}"
}

set_ocio_from_houdini_packages() {
    if [ -n "${OCIO:-}" ]; then
        return
    fi

    local package_dirs="${HOUDINI_PACKAGE_DIR:-${HOME}/Library/Preferences/houdini/20.5/packages:${houdini_install_dir}/Frameworks/Houdini.framework/Versions/Current/Resources/packages}"
    local package_dir
    while IFS= read -r package_dir; do
        if [ ! -d "${package_dir}" ]; then
            continue
        fi
        local package_file
        while IFS= read -r package_file; do
            if [ ! -f "${package_file}" ] || ! grep -q '"OCIO"' "${package_file}"; then
                continue
            fi
            local raw_value
            raw_value="$(sed -nE 's/.*"OCIO"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "${package_file}" | head -1)"
            if [ -z "${raw_value}" ]; then
                continue
            fi
            local candidate
            candidate="$(resolve_ocio_package_value "${raw_value}")"
            if [ -f "${candidate}" ]; then
                export OCIO="$(realpath "${candidate}")"
                return
            fi
        done < <(find "${package_dir}" -maxdepth 1 -type f -name '*.json' 2>/dev/null)
    done < <(printf '%s\n' "${package_dirs}" | tr ':' '\n')
}

# Houdini loads package files itself, but standalone MoonRay tools launched from
# this shell do not. Mirror a package-authored OCIO default without overriding an
# explicitly supplied OCIO so husk/hd_usd2rdl use the same color config as Houdini.
set_ocio_from_houdini_packages

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
