#!/bin/bash

# This script runs the preprocesses the annotated 'tasks.c' file
# and loads the result into the VeriFast IDE.
#
# This script expects the following arguments:
# $1 : Absolute path to the base directory of this repository.
# $2 : Absolute path to the VeriFast installation directory.
# $3 (Optional) : Font size



# Checking validity of command line arguments.
HELP="false"
if [ $1 == "-h" ] || [ $1 == "--help" ]; then
    HELP="true"
else
    if [[ $# < 2  ||  $# > 3 ]] ; then
        echo Wrong number of arguments. Found $#, expected 2 or 3.
        HELP="true"
    fi

    if [ ! -d "$1" ]; then
        echo "Directory (\$1) '$1' does not exist."
        HELP="true"
    fi

    if [ ! -d "$2" ]; then
        echo "Directory (\$2) '$2' does not exist."
        HELP="true"
    fi

    if ! [[ "$3" =~ ^[1-9]*$ ]] ; then 
      echo "Argument (\$3) '$3' is not a number."
      HELP="true"
    fi
fi

if [ "$HELP" != "false" ]; then
    echo Expected call of the form
    echo "run-vfide.sh <REPO_BASE_DIR> <VERIFAST_DIR> [<FONT_SIZE>]"
    echo "where:"
    echo "- <REPO_BASE_DIR> is the absolute path to the base directory of this repository"
    echo "- <VERIFAST_DIR> is the absolute path to the VeriFast installation directory"
    echo "- <FONT_SIZE> is an optional argument specifying the font size"
    exit
fi


# Relative or absolute path to the directory this script and `paths.sh` reside in.
PREFIX=`dirname $0`
# Absolute path to the base of this repository.
REPO_BASE_DIR="$1"
# Absolute path the VeriFast installation directory
VF_DIR="$2"

FONT_SIZE=17
if [ "$3" != "" ]
then
  FONT_SIZE="$3"
fi

# Load functions used to compute paths.
. "$PREFIX/paths.sh"


VF_PROOF_BASE_DIR=`vf_proof_base_dir $REPO_BASE_DIR`


PP_SCRIPT_DIR=`pp_script_dir $REPO_BASE_DIR`
PREP="$PP_SCRIPT_DIR/prepare_file_for_VeriFast.sh"
TASK_C=`vf_annotated_tasks_c $REPO_BASE_DIR`
PP_TASK_C=`pp_vf_tasks_c $REPO_BASE_DIR`

PROOF_SETUP_DIR=`vf_proof_setup_dir $REPO_BASE_DIR`
PROOF_FILES_DIR=`vf_proof_dir $REPO_BASE_DIR`

PP_ERR_LOG="`pp_log_dir $REPO_BASE_DIR`/preprocessing_errors.txt"




ensure_output_dirs_exist $REPO_BASE_DIR

"$PREP" "$TASK_C" "$PP_TASK_C" "$PP_ERR_LOG" \
  "$REPO_BASE_DIR" "$VF_PROOF_BASE_DIR" "$VF_DIR"

# Remarks:
# - Recently, provenance checks have been added to VF that break old proofs
#   involving pointer comparisons. The flag `-assume_no_provenance` turns them
#   off.

"$VF_DIR/bin/vfide" "$PP_TASK_C" \
    -I $PROOF_SETUP_DIR \
    -I $PROOF_FILES_DIR \
    -assume_no_provenance \
    -disable_overflow_check \
    "$PP_TASK_C" \
    -codeFont "$FONT_SIZE" -traceFont "$FONT_SIZE" \
