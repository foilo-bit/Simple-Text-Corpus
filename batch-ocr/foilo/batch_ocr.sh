#!/usr/bin/env bash
set -euo pipefail

# Batch OCR script for Foilo
# - Downloads a set of images (if remote)
# - Runs kraken on each image to produce a text output
# Usage: activate your kraken venv (recommended), then run:
#   bash batch_ocr.sh

# Path to kraken executable (adjust if needed). If you have kraken on PATH just set KRKN=kraken
KRKN="c:\\Users\\Foilo\\Desktop\\homework rp\\kraken_env\\Scripts\\kraken.exe"

mkdir -p images outputs logs

# Process all images found in the local images/ directory (no downloads by default).
# Enable nullglob so the glob doesn't remain literal if no files match.
shopt -s nullglob
IMAGES=(images/*.{png,jpg,jpeg,tif,tiff,webp})
if [ ${#IMAGES[@]} -eq 0 ]; then
  echo "No images found in images/ — place images in the 'images/' directory and re-run."
  exit 1
fi

# Ensure model is available (English best model as default; change model name as needed)
# This will fetch model if not present locally (harmless if already cached).
"$KRKN" get en_best.mlmodel || true

# Process each image
n=0
for src in "${IMAGES[@]}"; do
  n=$((n+1))
  echo -e "\n[$n] Processing: $src"
  fname="$(basename "$src")"

  # choose model: environment variable MODEL overrides default
  MODEL="${MODEL:-catmus-print-tiny.mlmodel}"
  # run kraken pipeline: binarize -> segment -> ocr
  out="outputs/${fname%.*}.txt"
  echo "Running binarize+segment+ocr on $src -> $out (model=$MODEL)"
  "$KRKN" -i "$src" "$out" binarize segment ocr -m "$MODEL" || { echo "kraken failed on $fname" >> logs/errors.log; continue; }
  echo "Done: $out"
done

# Summary
echo "\nCompleted. OCR outputs are in 'outputs/'. Check 'logs/errors.log' for any errors."