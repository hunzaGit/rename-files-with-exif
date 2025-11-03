#!/bin/bash
set -euo pipefail

# Colors for logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # colorless

log_info()   { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()   { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()  { echo -e "${RED}[ERROR]${NC} $*"; }
log_debug()  { [[ "$DEBUG" == "true" ]] && echo -e "${BLUE}[DEBUG]${NC} $*"; true; }

# DEFAULT VALUES
DEBUG=true
SOURCE_DIR=""
TARGET_DIR="DCIM"     # default value
PREFIX=""
SUFFIX=""
EXTENSIONS="jpg jpeg png heic mpo mp4 mov 3gp dng avi"   # default value
RENAME=false
USE_DATE_NAME=true
OUTPUT_DIR="renamed"
IGNORE_DIRS="renamed"   # <--- default value added

: <<'__HELP__'
### HELP START ####################################################
#
# Script for renaming photos and videos using exif properties with exiftool.
# IMPORTANT: If there is a date in the file name and the exif date does not match 
# (there is a difference of 180 days), prioritize the date in the name.
#
# Usage:
#   ./rename_media.sh -s <main_folder> [-t <target_directory_name>] 
#     [-p <prefix>] [-e "<extensions>"] [-o "<output_dir>"] [-h]
#
# Examples:
#   ./rename_files.sh --source "PATH_DIR" --target "Whatsapp" --prefix WA \
#     --rename false --output "renamed" --ignore old,mydir --debug true \
#     --use_date_name false
#
#   ./rename_files.sh --source "PATH_DIR" --target "DCIM" --rename false \
#     --output "renamed" --debug true
#
# Parameters:
#   -s, --source       Main folder (Required)
#   -t, --target       Directory where to search for files (default: "DCIM")
#   -p, --prefix       Prefix for names (e.g., "WA" → WA_20230814.jpg)
#   --suffix           Suffix for names (e.g., "backup" → 20230814_backup.jpg)
#   -e, --ext          Extensions to process (default: jpg jpeg png heic mpo mp4 mov 3gp dng avi)
#   -r, --rename       true=renames originals, false=copies to OUTPUT_DIR (default: false)
#   -o, --output       Destination folder if --rename=false (default: "renamed")
#   -dn, --use_date_name  true=prioritizes date in name if it differs from EXIF (default: true)
#   -i, --ignore       Directories to ignore, separated by commas (default: "renamed")
#   -d, --debug        Debug mode true/false (default: false)
#   -h, --help         Display this help message
#
#
# Special rules:
#  • .MPO files (panoramas) automatically add the suffix "_PANO" in addition to the normal prefix and suffix.
#    Example: IMG_1234.MPO → prefix_20230814_121530_suffix_PANO.MPO
#
#
# Example:
#   ./rename_files.sh --source /Users/my_user/Backups --target Photos --prefix summer_
#   ./rename_files.sh -s /Users/my_user/Backups -t Photos -p summer -e "jpg heic mov"
#
#
# Notes:
#   • WARNING! If --rename true is specified, the original files will be renamed.
#   • Use quotation marks if the paths or extensions contain spaces.
#   • If --target is not specified, "DCIM" will be used.
#   • If --prefix is not specified, the file name will not have a prefix.
#   • If --suffix is not specified, the file name will not have a suffix (except "_PANO" in MPO extension).
#   • If --ext is not specified, the following will be processed by default: jpg, jpeg, png, heic, mpo, mp4, mov, 3gp, dng, avi
#   • If --output is not specified, the renamed files are copied to "renamed".
### HELP END ##############################################################
__HELP__

print_help() {
  #grep '^#' "$0" | sed 's/^# \{0,1\}//'
  sed -n '/^: <<'\''__HELP__'\''$/,/^__HELP__$/p' "$0" | sed '1d;$d'
  exit 0
}


parse_args() {


  while [[ $# -gt 0 ]]; do
    case "$1" in
      --debug|-d)
      DEBUG="$2"
      shift 2
      ;;
      --source|-s)
        SOURCE_DIR="$2"
        shift 2
        ;;
      --target|-t)
        TARGET_DIR="$2"
        shift 2
        ;;
      --prefix|-p)
        # Add an underscore at the end if it is not empty
        PREFIX="${2}_"
        shift 2
        ;;
      --suffix)
        # Add underscore at the beginning if it is not empty
        SUFFIX="_${2}"
        shift 2
        ;;
      --ext|-e)
        EXTENSIONS="$2"
        shift 2
        ;;
      --rename|-r)
        RENAME="$2"
        shift 2
        ;;
      --use_date_name|-dn)
        USE_DATE_NAME="$2"
        shift 2
        ;;
      --output|-o)
        OUTPUT_DIR="$2"
        shift 2
        ;;
      --ignore|-i) IGNORE_DIRS="$2"; shift 2 ;;

      --help|-h)
        print_help
        exit 0
        ;;
      *)
        echo "Error: unknown parameter '$1'"
        echo "Use --help to view the help.."
        exit 1
        ;;
    esac
  done

  # Validate that the source folder has been specified
  if [[ -z "$SOURCE_DIR" ]]; then
    echo "Error: you must specify the main folder with --source"
    echo "Use --help for more information."
    exit 1
  fi

  # If it does not exist, error
  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: the $SOURCE_DIR folder does not exist."
    exit 1
  fi


  # If no prefix is specified, leave it empty.
  # If specified, add a trailing underscore (if it does not have one).
  if [[ -n "$PREFIX" ]]; then
    [[ "$PREFIX" != *_ ]] && PREFIX="${PREFIX}_"
  else
    PREFIX=""
  fi

  # If no suffix is specified, leave it empty.
  # If specified, add an initial underscore (if it does not have one).
  if [[ -n "$SUFFIX" ]]; then
    [[ "$SUFFIX" != _* ]] && SUFFIX="_${SUFFIX}"
  else
    SUFFIX=""
  fi

  ####################################################
  # Build list of -ext parameters for exiftool
  #################### ########################################
  EXT_ARGS=()
  for ext in $EXTENSIONS; do
    EXT_ARGS+=("-ext" "$ext")
  done


}

# Call to the function to process the arguments
parse_args "$@"
echo ""
log_debug "##############  PARAMETERS  ###################"
log_debug "  SOURCE_DIR="$SOURCE_DIR""
log_debug "  TARGET_DIR="$TARGET_DIR""
log_debug "  OUTPUT_DIR=$OUTPUT_DIR"
log_debug "  IGNORE_DIRS=$IGNORE_DIRS"
log_debug "  RENAME=$RENAME"
log_debug "  PREFIX="$PREFIX""
log_debug "  SUFFIX="$SUFFIX""
log_debug "  EXTENSIONS="$EXTENSIONS""
log_debug "  USE_DATE_NAME=$USE_DATE_NAME"
log_debug "  DEBUG_MODE=$DEBUG"
log_debug "###############################################"
echo ""

# Normalize list of ignored directories
IFS=',' read -r -a IGNORE_ARRAY <<< "${IGNORE_DIRS:-renamed}"

# Also add the output folder to the ignore list, if it is not already there.
if [[ ! " ${IGNORE_ARRAY[*]} " =~ " ${OUTPUT_DIR} " ]]; then
  IGNORE_ARRAY+=("$OUTPUT_DIR")
fi






log_info "Searching for directories '$TARGET_DIR' in '$SOURCE_DIR' ignoring: ${IGNORE_ARRAY[*]}"


# Normalize list of ignored directories (separator ,)
IFS=',' read -r -a IGNORE_ARRAY <<< "${IGNORE_DIRS:-renamed}"

# Also add the output folder (basename) to the ignore list, if it is not already there.
outbase="$(basename "$OUTPUT_DIR")"
if [[ -n "$outbase" && ! " ${IGNORE_ARRAY[*]} " =~ " ${outbase} " ]]; then
  IGNORE_ARRAY+=("$outbase")
fi

log_info ">>> Ignoring directories: ${IGNORE_ARRAY[*]} (includes basename output: $outbase)"

# Generate -prune arguments for find
PRUNE_ARGS=()
for idir in "${IGNORE_ARRAY[@]}"; do
  idir_trimmed="$(echo "$idir" | xargs)" # quitar espacios alrededor
  [[ -z "$idir_trimmed" ]] && continue
  # prune any route that contains a segment with that name
  PRUNE_ARGS+=( -path "*/$idir_trimmed" -prune -o )
done

log_debug "Generated PRUNE_ARGS: ${PRUNE_ARGS[*]}"


TARGET_DIRS=()   # inicializar siempre
while IFS= read -r -d '' dir; do
  TARGET_DIRS+=("$dir")
done < <(find "$SOURCE_DIR" "${PRUNE_ARGS[@]}" -type d -name "$TARGET_DIR" -print0 2>/dev/null)

if [[ ${#TARGET_DIRS[@]} -eq 0 ]]; then
  log_warn "No directories matching '$TARGET_DIR' were found in '$SOURCE_DIR'."
else
  log_info "Directories found (${#TARGET_DIRS[@]}):"
  for dir in "${TARGET_DIRS[@]}"; do
    log_debug "  $dir"
  done
fi


total_files_global=0
total_dirs_processed=0

while IFS= read -r -d '' d; do
  ((total_dirs_processed++))

  echo
  log_debug "##################################"
  log_info "Processing directory: $d"
  log_debug "Searching for files in $d with extensions: ${EXTENSIONS[*]}"

  # Crear array de patrones para find
  find_args=()
  for ext in $EXTENSIONS; do
    find_args+=(-iname "*.$ext" -o)
  done
  # Quitar el último -o
  unset 'find_args[${#find_args[@]}-1]'



  # Contar ficheros antes de procesar
  total_files_dir=$(find "$d" "${PRUNE_ARGS[@]}" -type f \( "${find_args[@]}" \) -print0 2>/dev/null | tr -cd '\0' | wc -c)
  if [[ $total_files_dir -eq 0 ]]; then
    log_warn "No valid files in $d"
    continue
  fi
  log_info "Files to process in $d: $total_files_dir"

  file_count=0


  while IFS= read -r -d '' file; do
    ((file_count++))
    ((total_files_global++))
    # Calcular porcentaje de avance (entero)
    progress=$(( file_count * 100 / total_files_dir ))
    echo ""
    log_info "→ Processing file $file_count/$total_files_dir (${progress}%): $(basename "$file")"

    # Skip empty files (0 bytes)
    if [[ ! -s "$file" ]]; then
      log_warn "Skipping empty file: $(basename "$file")"
      continue
    fi

    if [[ "$RENAME" == "true" ]]; then
      target_dir=$(dirname "$file")
      exiftool_opts=(-overwrite_original)
    else
      target_dir="$OUTPUT_DIR"
      [[ ! "$target_dir" = /* ]] && target_dir="$(dirname "$file")/$OUTPUT_DIR"
      mkdir -p "$target_dir"
      exiftool_opts=(-o "$target_dir/%f.%e")
    fi

    # === calcular nombre nuevo esperado ===
    date_original=$(exiftool -s3 -DateTimeOriginal "$file")
    if [[ -z "$date_original" ]]; then
        date_original=$(exiftool -s3 -FileModifyDate "$file")
    fi

    # Normalizar formato de fecha EXIF (reemplazar ":" y corregir separadores)
    # Ejemplo: "2012:08:12 02:53:48+02:00" → "2012-08-12 02:53:48"
    date_clean=$(echo "$date_original" | sed -E 's/:/-/; s/:/-/; s/([0-9]{2}):([0-9]{2}):([0-9]{2})/\1:\2:\3/' | cut -d'+' -f1)

    # Usar date de forma portable entre macOS y Linux
    if date -j -f "%Y-%m-%d %H:%M:%S" "$date_clean" +"%Y%m%d_%H%M%S" >/dev/null 2>&1; then
        # macOS
        new_base=$(date -j -f "%Y-%m-%d %H:%M:%S" "$date_clean" +"${PREFIX}%Y%m%d_%H%M%S")
    else
        # GNU/Linux
        new_base=$(date -d "$date_clean" +"${PREFIX}%Y%m%d_%H%M%S" 2>/dev/null || date +"${PREFIX}%Y%m%d_%H%M%S")
    fi

    final_suffix="$SUFFIX"
    [[ "${file##*.}" =~ ^[Mm][Pp][Oo]$ ]] && final_suffix="${final_suffix}_PANO"

    ext="${file##*.}"
    new_name="${new_base}${final_suffix}.${ext}"

    if [[ "$RENAME" == "true" ]]; then
        log_debug "Renaming '$file' → '$target_dir/$new_name'"
    else
        log_debug "Copying '$file' → '$target_dir/$new_name'"
    fi




    # Check if DateTimeOriginal exists
    # -s3 returns only the value, without the tag name
    date_original=$(exiftool -s3 -DateTimeOriginal "$file")


    # Sufijo especial para MPO
    final_suffix="$SUFFIX"
    [[ "${file##*.}" =~ ^[Mm][Pp][Oo]$ ]] && final_suffix="${final_suffix}_PANO"



    if [[ "$USE_DATE_NAME" == "true" ]]; then
   


      # -------------------------
      # Detect date in name (IMG-YYYYMMDD-... or any 8 contiguous digits)
      # -------------------------
      filename_date=""
      if [[ "$(basename "$file")" =~ ([0-9]{8}) ]]; then
        date_str="${BASH_REMATCH[1]}"            # YYYYMMDD
        fn_year="${date_str:0:4}"
        fn_month="${date_str:4:2}"
        fn_day="${date_str:6:2}"
        filename_date="${fn_year}:${fn_month}:${fn_day} 00:00:00"
      fi

      # -------------------------
      # Read EXIF date (DateTimeOriginal) securely
      # -------------------------
      date_original_raw=$(exiftool -s3 -DateTimeOriginal "$file" 2>/dev/null || true)

      # Attempt to locate a pattern YYYY:MM:DD within the EXIF (or YYYY-MM-DD)
      exif_year=""
      exif_month=""
      exif_day=""
      if [[ $date_original_raw =~ ([0-9]{4})[:-]([0-9]{2})[:-]([0-9]{2}) ]]; then
        exif_year="${BASH_REMATCH[1]}"
        exif_month="${BASH_REMATCH[2]}"
        exif_day="${BASH_REMATCH[3]}"
      fi

      # If DateTimeOriginal does not work, try FileModifyDate (sometimes useful).
      if [[ -z "$exif_year" ]]; then
        date_mod_raw=$(exiftool -s3 -FileModifyDate "$file" 2>/dev/null || true)
        if [[ $date_mod_raw =~ ([0-9]{4})[:-]([0-9]{2})[:-]([0-9]{2}) ]]; then
          exif_year="${BASH_REMATCH[1]}"
          exif_month="${BASH_REMATCH[2]}"
          exif_day="${BASH_REMATCH[3]}"
          date_original_raw="$date_mod_raw"
        fi
      fi

      # -------------------------
      # If we have both dates, calculate the approximate difference in days.
      # -------------------------
      diff_days=0
      if [[ -n "$filename_date" && -n "$exif_year" ]]; then
        # convertir a enteros
        y1=$((10#$fn_year)); m1=$((10#$fn_month)); d1=$((10#$fn_day))
        y2=$((10#$exif_year)); m2=$((10#$exif_month)); d2=$((10#$exif_day))

        # aproximación: años*365 + meses*30 + dias
        days1=$(( y1*365 + m1*30 + d1 ))
        days2=$(( y2*365 + m2*30 + d2 ))

        if (( days1 > days2 )); then
          diff_days=$(( days1 - days2 ))
        else
          diff_days=$(( days2 - days1 ))
        fi
      fi

      # -------------------------
      # If the difference is large, we overwrite DateTimeOriginal with the date from the name.
      # -------------------------
      THRESHOLD_DAYS=180

      if [[ -n "$filename_date" && $diff_days -gt $THRESHOLD_DAYS ]]; then
        log_warn "EXIF inconsistent with name in '$(basename "$file")' (diff approx ${diff_days}d) — using date from name: ${fn_year}-${fn_month}-${fn_day}"
        # Setear DateTimeOriginal a la fecha del nombre (a mediodía para evitar timezone issues)
        exiftool -overwrite_original -DateTimeOriginal="${fn_year}:${fn_month}:${fn_day} 00:00:00" "$file"
        # actualizar la variable raw para que el siguiente renombrado use la nueva EXIF
        date_original_raw="${fn_year}:${fn_month}:${fn_day} 00:00:00"
      fi

    fi




    #echo "date_original = $date_original"
    if [[ -n "$date_original" ]]; then
        exiftool "${exiftool_opts[@]}" "${EXT_ARGS[@]}" \
          -d "${PREFIX}%Y%m%d_%H%M%S%%+c${final_suffix}.%%e" \
          '-FileName<DateTimeOriginal' "$file"
    else
        exiftool "${exiftool_opts[@]}" "${EXT_ARGS[@]}" \
          -d "${PREFIX}%Y%m%d_%H%M%S%%+c${final_suffix}.%%e" \
          '-FileName<FileModifyDate' "$file"
    fi

    if [[ $? -ne 0 ]]; then
      log_error "Exiftool failed on '$file'"
    else
      log_debug "Exiftool successfully processed '$file'"
    fi


  done < <(find "$d" "${PRUNE_ARGS[@]}" -type f \( "${find_args[@]}" \) -print0)
  echo ""
  log_info "✅ Directory '$d' completed ($file_count files)"
  log_debug "##################################"

done < <(find "$SOURCE_DIR" "${PRUNE_ARGS[@]}" -type d -name "$TARGET_DIR" -print0 2>/dev/null )

echo ""
log_info "✅ Renaming complete."
log_info "📁 Directories processed: $total_dirs_processed"
log_info "📸 Files processed: $total_files_global"
#log_debug "Total directories processed: ${#TARGET_DIRS[@]}"

