omr_install_dir=/Applications/MoonRay/installs/openmoonray

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
