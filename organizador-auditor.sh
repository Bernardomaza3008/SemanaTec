#!/bin/bash

# ==============================================================================
# FASE 1: VERIFICACIÓN, DESCOMPRESIÓN Y ORGANIZACIÓN
# ==============================================================================

# Verificar argumentos
if [ "$#" -ne 2 ]; then
    echo "Error: se requieren exactamente 2 argumentos."
    echo "Uso: $0 <ruta_carpeta_zip> <ruta_destino>"
    exit 1
fi

ruta_zip="$1"
ruta_destino="$2"

if [ ! -d "$ruta_zip" ]; then
    echo "Error: la carpeta de origen no existe: $ruta_zip"
    exit 1
fi

archivos_zip=("$ruta_zip"/*.zip)

if [ ! -f "${archivos_zip[0]}" ]; then
    echo "Error: no se encontró ningún archivo ZIP en: $ruta_zip"
    exit 1
fi

if [ ! -d "$ruta_destino" ]; then
    echo "Error: la carpeta destino no existe: $ruta_destino"
    exit 1
fi

# Descomprimir los archivos ZIP
for archivo_zip in "${archivos_zip[@]}"; do
    if ! unzip -t "$archivo_zip" > /dev/null 2>&1; then
        echo "Error: el archivo no es un ZIP válido: $archivo_zip"
        exit 1
    fi

    if ! unzip -o -j "$archivo_zip" -d "$ruta_destino" -x "__MACOSX/*" "*/__MACOSX/*"; then
        echo "Error: no se pudo descomprimir: $archivo_zip"
        exit 1
    fi
done

echo "Archivos descomprimidos correctamente en: $ruta_destino"
echo ""
echo "Organizando archivos por tipo de extensión..."

# Bucle de organización por extensión
find "$ruta_destino" -maxdepth 1 -type f | while read -r archivo; do
    nombre_archivo=$(basename "$archivo")
    extension="${nombre_archivo##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    if [ "$extension" = "$nombre_archivo" ]; then
        subcarpeta="otros"
    else
        subcarpeta="$extension"
    fi

    mkdir -p "$ruta_destino/$subcarpeta"
    mv "$archivo" "$ruta_destino/$subcarpeta/"
done

echo "Organización por carpetas completada."
echo ""

# ==============================================================================
# FASE 2: AUDITORÍA Y FILTRADO LOCAL (PYSIDE6)
# ==============================================================================

DIRECTORIO="$ruta_destino"
NOMBRE_CARPETA_DESTINO="archivos_pyside6"
TERMINOS_REGEX="import PySide6|PySide6"
TERMINO_REPORT="PySide6"

total_archivos=0
archivos_con_pyside6=0

echo "================================================================="
echo "    INFORME DE AUDITORÍA Y FILTRADO LOCAL (PYSIDE6) EN TERMINAL"
echo "================================================================="
echo ""

while IFS= read -r archivo; do

    if [[ "$archivo" == *"/$NOMBRE_CARPETA_DESTINO/"* ]]; then
        continue
    fi

    ((total_archivos++))
    echo "Archivo: $archivo"

    coincidencias=$(grep -i -n -E "$TERMINOS_REGEX" "$archivo")

    if [ -n "$coincidencias" ]; then

        ((archivos_con_pyside6++))
        terminos_encontrados=$(grep -i -o -E "$TERMINOS_REGEX" "$archivo" | sort -u | paste -sd ", " -)

        echo "  Contiene '$TERMINO_REPORT': SÍ (Términos detectados: $terminos_encontrados)"
        echo "  Coincidencias encontradas:"

        echo "$coincidencias" | while IFS= read -r linea; do
            echo "    - Línea $linea"
        done

        dir_origen=$(dirname "$archivo")
        carpeta_destino_local="$dir_origen/$NOMBRE_CARPETA_DESTINO"

        mkdir -p "$carpeta_destino_local"

        nombre_base=$(basename "$archivo")
        destino_final="$carpeta_destino_local/$nombre_base"

        cp "$archivo" "$destino_final"
        echo "  Copiado localmente a: $destino_final"

    else
        echo "  Contiene '$TERMINO_REPORT': NO"
    fi

    echo "-----------------------------------------------------------------"

done < <(find "$DIRECTORIO" -type f -name "*.py")

echo ""
echo "================================================================="
echo "                    RESUMEN FINAL"
echo "================================================================="
echo "Total de archivos .py analizados: $total_archivos"
echo "Archivos que utilizan la librería '$TERMINO_REPORT': $archivos_con_pyside6"
echo "Organización: Las copias filtradas fueron creadas dentro de la subcarpeta '$NOMBRE_CARPETA_DESTINO' en sus respectivas ubicaciones."
echo "================================================================="
