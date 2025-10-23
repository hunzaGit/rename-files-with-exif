#!/bin/bash
set -euo pipefail

# Colores para logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # sin color

log_info()   { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()   { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()  { echo -e "${RED}[ERROR]${NC} $*"; }
log_debug()  { [[ "$DEBUG" == "true" ]] && echo -e "${BLUE}[DEBUG]${NC} $*"; true; }

# VALORES POR DEFECTO
DEBUG=true
SOURCE_DIR=""
TARGET_DIR="DCIM"     # valor por defecto
PREFIX=""
SUFFIX=""
EXTENSIONS="jpg jpeg png heic mpo mp4 mov 3gp"  # valor por defecto
RENAME=false
USE_DATE_NAME=true
OUTPUT_DIR="renamed"
IGNORE_DIRS="renamed"   # <--- valor por defecto añadido


: <<'__HELP__'

### HELP START ############################################################
#
# Script para renombrar fotos y vídeos usando las propiedades exif con exiftool.
# IMPORTANTE: Si hay fecha en el nombre del fichero y la fecha exif no cuadra (tiene una diferencia de 180 días) prioriza la fecha del nombre
#
# Uso:
#   ./rename_media.sh -s <carpeta_principal> [-t <nombre_directorio_objetivo>] [-p <prefijo>] [-e "<extensiones>"] [-o "<output_dir>"] [-h]
#   ./rename_media.sh --source <carpeta_principal> [--target <nombre_directorio_objetivo>] [--prefix <prefijo>] [--suffix <sufijo>] [--ext "<extensiones>"] [-output "<output_dir>"] [--help]
#
# Ejemplo comun:
#   ./rename_files.sh --source "PATH_DIR" --target "Whatsapp" --prefix WA --rename false --output "renamed" --ignore old,mydir --debug true --use_date_name false
#
# Ejemplo fotos Android DCIM:
#   ./rename_files.sh --source "PATH_DIR" --target "DCIM" --rename false --output "renamed" --ignore old,mydir --debug true --use_date_name false 
#
# Ejemplo fotos WhatsApp:
#   ./rename_files.sh --source "PATH_DIR" --target "Whatsapp" --prefix WA --rename false --output "renamed" --ignore old,mydir --debug true --use_date_name true 
#
# Parámetros:
#   -s, --source   Carpeta principal que contiene los backups o subcarpetas con fotos. (Obligatorio)
#
#   -t, --target   Nombre del directorio dentro de la carpeta fuente donde buscar los archivos, por ejemplo "DCIM", "WhatsApp". 
#                   (Opcional, por defecto: "DCIM")
#
#   -p, --prefix   Prefijo opcional que se añadirá al inicio del nombre de cada archivo, seguido de "_". 
#                   (Ej: "viaje" → viaje_20230814_121530.jpg, "WA" → WA_20230814_121530.jpg)
#
#   --suffix       Sufijo opcional que se añadirá al final del nombre de cada archivo, precedido de "_". 
#                   (Ej: "backup" → 20230814_121530_backup.jpg)
#
#   -e, --ext      Lista de extensiones separadas por espacios a procesar.
#                   (Opcional; por defecto: "jpg, jpeg, png, heic, mpo, mp4, mov, 3gp")
#                   Ejemplo: --ext "jpg heic mov "
#
#   -r, --rename       WARNING! Si se indica "true", renombra los archivos **directamente** en su ubicación original.
#                   Por defecto: false
#
#   -o, --output       Carpeta donde guardar los archivos renombrados (relativa al directorio del archivo).
#                   Solo se usa si --rename=false.  
#                   Por defecto: "renamed" dentro del directorio del archivo.
# 
#   -dn, --use_date_name  Boolean WARNING! Si se indica "false", no usa la fecha del nombre del fichero. El nombre es prioritario a la fecha exif
#                   Por defecto: true
#
#   --i, -ignore   Lista de directorios a ignorar
#                   (Opcional; por defecto: "renamed")
#                   Ejemplo: --ignore "renamed,temp,old"
#
#   -d, --debug      Modo de depuración (opcional; por defecto: true)
#                 Si se indica "true", el script mostrará mensajes de depuración detallados
#                 sobre las carpetas encontradas, archivos listados y comandos ejecutados.
#                 Si se indica "false", se muestran solo los mensajes de información y advertencia.
#                 Ejemplo:
#                   ./rename_media.sh --source /backups --target WhatsApp --debug true
#                   ./rename_media.sh -s /backups -t DCIM --debug false

#
#   -h, --help     Muestra este mensaje de ayuda y termina la ejecución.
#
#
# Reglas especiales:
#  • Si se encuentra un fichero con extensión .MPO (panorámica), se renombrará siempre
#    añadiendo el sufijo "_PANO" antes de la extensión, además del prefijo y sufijo normales.
#    Ejemplo: IMG_1234.MPO → prefijo_20230814_121530_sufijo_PANO.MPO
#
#
# Ejemplo:
#   ./rename_files.sh --source /Users/mi_user/Backups --target Fotos --prefix verano_
#   ./rename_files.sh -s /Users/mi_user/Backups -t Fotos -p verano -e "jpg heic mov"

#
# Notas:
#   • WARNING! Si se indica --rename true, se renombran los ficheros originales.
#   • Si no se indica --target, se usará "DCIM".
#   • Si no se indica --prefix, el nombre de archivo no llevará prefijo.
#   • Si no se indica --suffix, el nombre de archivo no llevará sufijo (excepto "_PANO" en extensión MPO).
#   • Si no se indica --ext, se procesarán por defecto: jpg, jpeg, png, heic, mpo, mp4, mov, 3gp
#   • Si no se indica --output, se copian los ficheros renombrados a "renamed"
#   • Usa comillas si las rutas o extensiones contienen espacios.
### HELP END ##############################################################
__HELP__


print_help() {
  #grep '^#' "$0" | sed 's/^# \{0,1\}//'
  sed -n '/^: <<'\''__HELP__'\''$/,/^__HELP__$/p' "$0" | sed '1d;$d'
  exit 1
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
        # Añadir guion bajo al final si no está vacío
        PREFIX="${2}_"
        shift 2
        ;;
      --suffix)
        # Añadir guion bajo al inicio si no está vacío
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
      --ignore|-i) IGNORE_DIRS="$2"; shift 2 ;;  # <--- nueva opción

      --help|-h)
        print_help
        exit 0
        ;;
      *)
        echo "Error: parámetro desconocido '$1'"
        echo "Usa --help para ver la ayuda."
        exit 1
        ;;
    esac
  done

  # Validar que se ha indicado la carpeta source
  if [[ -z "$SOURCE_DIR" ]]; then
    echo "Error: debes indicar la carpeta principal con --source"
    echo "Usa --help para más información."
    exit 1
  fi

  # Si no existe, error
  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: la carpeta $SOURCE_DIR no existe."
    exit 1
  fi


  # Si no se indica prefix, lo dejamos vacío.
  # Si se indica, se añade guion bajo final (si no lo tiene).
  if [[ -n "$PREFIX" ]]; then
    [[ "$PREFIX" != *_ ]] && PREFIX="${PREFIX}_"
  else
    PREFIX=""
  fi

  # Si no se indica sufijo, lo dejamos vacío.
  # Si se indica, se añade guion bajo inicial (si no lo tiene).
  if [[ -n "$SUFFIX" ]]; then
    [[ "$SUFFIX" != _* ]] && SUFFIX="_${SUFFIX}"
  else
    SUFFIX=""
  fi

  ############################################################
  # Construir lista de parámetros -ext para exiftool
  ############################################################
  EXT_ARGS=()
  for ext in $EXTENSIONS; do
    EXT_ARGS+=("-ext" "$ext")
  done


}

# Llamada a la función para procesar los argumentos
parse_args "$@"

echo "##############  PARAMETROS  ###################"
echo "  SOURCE_DIR="$SOURCE_DIR""
echo "  TARGET_DIR="$TARGET_DIR""
echo "  PREFIX="$PREFIX""
echo "  SUFFIX="$SUFFIX""
echo "  EXTENSIONS="$EXTENSIONS""
echo "  IGNORE_DIRS=$IGNORE_DIRS"
echo "  OUTPUT_DIR=$OUTPUT_DIR"
echo "  USE_DATE_NAME=$USE_DATE_NAME"
echo "###############################################"

# Normalizar lista de directorios ignorados
IFS=',' read -r -a IGNORE_ARRAY <<< "${IGNORE_DIRS:-renamed}"

# Añadir también la carpeta de salida a la lista de ignorados, si no está ya
if [[ ! " ${IGNORE_ARRAY[*]} " =~ " ${OUTPUT_DIR} " ]]; then
  IGNORE_ARRAY+=("$OUTPUT_DIR")
fi






log_info "Buscando directorios '$TARGET_DIR' en '$SOURCE_DIR' ignorando: ${IGNORE_ARRAY[*]}"


# Normalizar lista de directorios ignorados (separador ,)
IFS=',' read -r -a IGNORE_ARRAY <<< "${IGNORE_DIRS:-renamed}"

# Añadir también la carpeta de salida (basename) a la lista de ignorados, si no está ya
outbase="$(basename "$OUTPUT_DIR")"
if [[ -n "$outbase" && ! " ${IGNORE_ARRAY[*]} " =~ " ${outbase} " ]]; then
  IGNORE_ARRAY+=("$outbase")
fi

log_info ">>> Ignorando directorios: ${IGNORE_ARRAY[*]} (incluye output basename: $outbase)"

# Generar argumentos -prune para find
PRUNE_ARGS=()
for idir in "${IGNORE_ARRAY[@]}"; do
  idir_trimmed="$(echo "$idir" | xargs)" # quitar espacios alrededor
  [[ -z "$idir_trimmed" ]] && continue
  # prunear cualquier ruta que contenga un segmento con ese nombre
  PRUNE_ARGS+=( -path "*/$idir_trimmed" -prune -o )
done

log_debug "PRUNE_ARGS generados: ${PRUNE_ARGS[*]}"


TARGET_DIRS=()   # inicializar siempre
while IFS= read -r -d '' dir; do
  TARGET_DIRS+=("$dir")
done < <(find "$SOURCE_DIR" "${PRUNE_ARGS[@]}" -type d -name "$TARGET_DIR" -print0 2>/dev/null)

if [[ ${#TARGET_DIRS[@]} -eq 0 ]]; then
  log_warn "No se encontraron directorios que coincidan con '$TARGET_DIR' en '$SOURCE_DIR'."
else
  log_info "Directorios encontrados (${#TARGET_DIRS[@]}):"
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
  log_info "Procesando directorio: $d"
  log_debug "Buscando archivos en $d con extensiones: ${EXTENSIONS[*]}"

  # Crear array de patrones para find
  find_args=()
  for ext in $EXTENSIONS; do
    find_args+=(-iname "*.$ext" -o)
  done
  # Quitar el último -o
  unset 'find_args[${#find_args[@]}-1]'




  #log_debug
  #log_debug "Listar ficheros respetando exclusiones (primer directorio target):"


  #first="${TARGET_DIRS[0]:-}"   # primer directorio, si existe
  #if [[ -n "$first" ]]; then
  #    find "$first" "${PRUNE_ARGS[@]}" -type f \( "${find_args[@]}" \) -print0 2>/dev/null | \
  #    while IFS= read -r -d '' file; do
  #        log_debug "  $file"
  #    done
  #fi
  #log_debug


  # Contar ficheros antes de procesar
  total_files_dir=$(find "$d" "${PRUNE_ARGS[@]}" -type f \( "${find_args[@]}" \) -print0 2>/dev/null | tr -cd '\0' | wc -c)
  if [[ $total_files_dir -eq 0 ]]; then
    log_warn "Sin ficheros válidos en $d"
    continue
  fi
  log_info "Ficheros a procesar en $d: $total_files_dir"

  file_count=0


  while IFS= read -r -d '' file; do
    ((file_count++))
    ((total_files_global++))
    # Calcular porcentaje de avance (entero)
    progress=$(( file_count * 100 / total_files_dir ))
    echo ""
    log_info "→ Procesando fichero $file_count/$total_files_dir (${progress}%): $(basename "$file")"

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
        log_debug "Renombrando '$file' → '$target_dir/$new_name'"
    else
        log_debug "Copiando '$file' → '$target_dir/$new_name'"
    fi




    # Comprobar si existe DateTimeOriginal
    # -s3 devuelve solo el valor, sin nombre de tag
    date_original=$(exiftool -s3 -DateTimeOriginal "$file")


    # Sufijo especial para MPO
    final_suffix="$SUFFIX"
    [[ "${file##*.}" =~ ^[Mm][Pp][Oo]$ ]] && final_suffix="${final_suffix}_PANO"



    if [[ "$USE_DATE_NAME" == "true" ]]; then
   


      # -------------------------
      # Detectar fecha en el nombre (IMG-YYYYMMDD-... o cualquier 8 dígitos contiguos)
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
      # Leer fecha EXIF (DateTimeOriginal) de forma segura
      # -------------------------
      date_original_raw=$(exiftool -s3 -DateTimeOriginal "$file" 2>/dev/null || true)

      # Intentar localizar un patrón YYYY:MM:DD dentro del EXIF (o YYYY-MM-DD)
      exif_year=""
      exif_month=""
      exif_day=""
      if [[ $date_original_raw =~ ([0-9]{4})[:-]([0-9]{2})[:-]([0-9]{2}) ]]; then
        exif_year="${BASH_REMATCH[1]}"
        exif_month="${BASH_REMATCH[2]}"
        exif_day="${BASH_REMATCH[3]}"
      fi

      # Si no conseguimos con DateTimeOriginal, probar FileModifyDate (a veces útil)
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
      # Si tenemos ambas fechas, calcular diferencia aproximada en días
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
      # Si la diferencia es grande, sobrescribimos DateTimeOriginal con la fecha del nombre
      # -------------------------
      THRESHOLD_DAYS=180

      if [[ -n "$filename_date" && $diff_days -gt $THRESHOLD_DAYS ]]; then
        log_warn "EXIF incoherente con nombre en '$(basename "$file")' (diff aprox ${diff_days}d) — usando fecha del nombre: ${fn_year}-${fn_month}-${fn_day}"
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
      log_error "Exiftool falló en '$file'"
    else
      log_debug "Exiftool procesó correctamente '$file'"
    fi


  done < <(find "$d" "${PRUNE_ARGS[@]}" -type f \( "${find_args[@]}" \) -print0)

  log_info "✅ Directorio '$d' completado ($file_count ficheros)"
  log_debug "##################################"

done < <(find "$SOURCE_DIR" "${PRUNE_ARGS[@]}" -type d -name "$TARGET_DIR" -print0 2>/dev/null )


log_info "✅ Renombrado completo."
log_info "📁 Directorios procesados: $total_dirs_processed"
log_info "📸 Ficheros procesados: $total_files_global"
#log_debug "Total de directorios procesados: ${#TARGET_DIRS[@]}"

