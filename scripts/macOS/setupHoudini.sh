omr_install_dir=/Applications/MoonRay/installs/openmoonray

# save/restore PYTHONPATH, since Houdini seems to reject python3.9
OLDPP=${PYTHONPATH}
source ${omr_install_dir}/scripts/setup.sh
export PYTHONPATH=${OLDPP}

export REL=${omr_install_dir}
export RDL2_DSO_PATH=${omr_install_dir}/rdl2dso.proxy:${omr_install_dir}/rdl2dso
export MOONRAY_CLASS_PATH=${omr_install_dir}/shader_json
export ARRAS_SESSION_PATH=${omr_install_dir}/sessions
PXR_PLUGINPATH_NAME=${omr_install_dir}/plugin/pxr
#export HOUDINI_DSO_ERROR=5
export HOUDINI_PATH=/Applications/Houdini/Houdini21.0.680/Frameworks/Houdini.framework/Versions/Current/Resources/houdini:${omr_install_dir}/houdini/:${omr_install_dir}/plugin/houdini
