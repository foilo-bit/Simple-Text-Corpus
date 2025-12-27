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

# List of image sources (local files use file:// prefix); add or edit as needed.
# Note: some remote downloads may fail depending on availability; the script will skip failures.
IMAGES=(
  "file:///c:/Users/Foilo/Desktop/homework rp/Simple-Text-Corpus/assets/manuscript-Q90r.png"
  "file:///c:/Users/Foilo/Desktop/homework rp/Simple-Text-Corpus/ocr_laila/kalila_bin.png"
  "file:///c:/Users/Foilo/Desktop/homework rp/kalila wa dimna.webp"
  "https://upload.wikimedia.org/wikipedia/commons/7/70/Beowulf_Cotton_MS_Vitellius_A_XV_f._132r.jpg"
  "https://upload.wikimedia.org/wikipedia/commons/4/4d/Book_of_Kells%2C_folio_32v.jpg"
  "https://upload.wikimedia.org/wikipedia/commons/8/8a/Gutenberg_Bible%2C_incunabula_sample.jpg"
  "https://upload.wikimedia.org/wikipedia/commons/3/37/Codex_Sinaiticus_folio_sample.jpg"
  "https://upload.wikimedia.org/wikipedia/commons/9/9e/Arabic_manuscript_sample.jpg"
  "https://upload.wikimedia.org/wikipedia/commons/2/2e/Printed_book_page_sample.jpg"
  "https://upload.wikimedia.org/wikipedia/commons/0/0f/Medieval_manuscript_page_sample.jpg"
)

# Ensure model is available (English best model as default; change model name as needed)
# This will fetch model if not present locally (harmless if already cached).
"$KRKN" get en_best.mlmodel || true

# Process each image
n=0
for src in "${IMAGES[@]}"; do
  n=$((n+1))
  echo "\n[$n] Processing: $src"
  # determine filename
  if [[ "$src" == file://* ]]; then
    localpath="${src#file://}"
    fname="$(basename "$localpath")"
    # copy local file into images/ (handles space in paths)
    cp -v "$localpath" "images/$fname" 2>>logs/errors.log || { echo "Failed to copy $localpath"; continue; }
  else
    # remote download
    fname="$(basename "$src")"
    # replace %2C etc. for nicer names
    fname_decoded=$(python - <<PY
import urllib.parse, sys
print(urllib.parse.unquote(sys.argv[1]))
PY
"$fname")
    fname="${fname_decoded}"
    if [[ -f "images/$fname" ]]; then
      echo "images/$fname already exists, skipping download"
    else
      echo "Downloading $src -> images/$fname"
      curl -L -f -o "images/$fname" "$src" || { echo "Download failed: $src" >> logs/errors.log; continue; }
    fi
  fi

  # run kraken OCR: input -> outputs/<basename>.txt
  out="outputs/${fname%.*}.txt"
  echo "Running kraken on images/$fname -> $out"
  "$KRKN" -i "images/$fname" "$out" ocr -m en_best.mlmodel || { echo "kraken failed on $fname" >> logs/errors.log; continue; }
  echo "Done: $out"
done

# Summary
echo "\nCompleted. OCR outputs are in 'outputs/'. Check 'logs/errors.log' for any errors."