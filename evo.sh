#!/usr/bin/env bash

set -e
set -x

# Set default values for DATADIR and NCORES
DEFAULT_DATADIR="/JawTitan/EvalPlus/humaneval"
DEFAULT_NCORES=$(nproc)

# Check if the user has provided a custom value for DATADIR and NCORES
while getopts ":d:n:" opt; do
  case ${opt} in
    d )
      DATADIR=$OPTARG
      ;;
    n )
      NCORES=$OPTARG
      ;;
    \? )
      echo "Invalid option: -$OPTARG. Example: bash evo.sh -d /path/to/humaneval -n 32" 1>&2
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument. Example: bash evo.sh -d /path/to/humaneval -n 32" 1>&2
      exit 1
      ;;
  esac
done

# Set DATADIR and NCORES to default values if they are not provided by the user
DATADIR=${DATADIR:-$DEFAULT_DATADIR}
NCORES=${NCORES:-$DEFAULT_NCORES}

export PYTHONPATH=$(pwd)

models=("codegen-2b" "codegen-6b" "codegen-16b" "vicuna-7b" "vicuna-13b" "stablelm-7b" "chatgpt")
temps=("0.2" "0.4" "0.6" "0.8")

for model in "${models[@]}"; do
  for temp in "${temps[@]}"; do
    folder="${DATADIR}/${model}_temp_${temp}"
    if [ -d "$folder" ]; then
      yes | python eval_plus/evaluation/evaluate.py --dataset humaneval --r_folder "$folder" --parallel ${NCORES} --i-just-wanna-run --extra --full
    else
      echo "Folder does not exist: $folder"
    fi
  done
done