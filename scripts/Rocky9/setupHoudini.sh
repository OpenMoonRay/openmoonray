omr_install_dir=/opt/MoonRay/installs/openmoonray

# save/restore PYTHONPATH, since Houdini runtime can be sensitive to non-Houdini site-packages
OLDPP=${PYTHONPATH}
source ${omr_install_dir}/scripts/setup.sh
export PYTHONPATH=${OLDPP}

export REL=${omr_install_dir}
export RDL2_DSO_PATH=${omr_install_dir}/rdl2dso.proxy:${omr_install_dir}/rdl2dso
export MOONRAY_CLASS_PATH=${omr_install_dir}/shader_json
export ARRAS_SESSION_PATH=${omr_install_dir}/sessions
PXR_PLUGINPATH_NAME=${omr_install_dir}/plugin/pxr
export HOUDINI_PATH=/opt/hfs20.0/houdini:${omr_install_dir}/houdini/:${omr_install_dir}/plugin/houdini
