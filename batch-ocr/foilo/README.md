Batch OCR for Foilo

Contents:
- `batch_ocr.sh`: Bash script that processes image files placed in `images/` and runs Kraken OCR on each to create `.txt` outputs in `outputs/`.
- `images/`: directory (created by script) that will hold the input images to be OCR'd (place any uploaded images here).
- `outputs/`: directory (created by script) that will contain OCR text outputs.

Usage:
1. Activate the Kraken virtual environment:
   - On Windows PowerShell: `& "c:\\Users\\Foilo\\Desktop\\homework rp\\kraken_env\\Scripts\\Activate.ps1"`
   - On cmd: `"c:\\Users\\Foilo\\Desktop\\homework rp\\kraken_env\\Scripts\\activate.bat"`
2. Run the script in Git Bash or WSL, or any bash shell that can execute `curl` and `python`:
   - `bash batch_ocr.sh`

Notes:
- The script uses the absolute path to the Kraken executable in this workspace. If you prefer, set the `KRKN` environment variable to `kraken` (if kraken is on your PATH) or to another executable path.
- Some remote image URLs are provided as examples; if a download fails, the script will log the error to `logs/errors.log` and continue.
- This folder is intended for submission to the course repository under `batch-ocr/foilo` together with the generated `outputs/` text files.