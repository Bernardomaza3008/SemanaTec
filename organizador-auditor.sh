
#!/bin/bash

# Verificar que se reciban exactamente dos argumentos
if [ "$#" -ne 2 ]; then
    echo "Error: se requieren exactamente 2 argumentos."
    echo "Uso: $0 <ruta_carpeta_zip> <ruta_destino>"
    exit 1
fi

# Guardar los argumentos
ruta_zip="$1"
ruta_destino="$2"

# Verificar que la carpeta de origen exista
if [ ! -d "$ruta_zip" ]; then
    echo "Error: la carpeta de origen no existe: $ruta_zip"
    exit 1
fi

# Buscar archivos ZIP dentro de la carpeta de origen
archivos_zip=("$ruta_zip"/*.zip)

# Verificar que exista al menos un ZIP
if [ ! -f "${archivos_zip[0]}" ]; then
    echo "Error: no se encontró ningún archivo ZIP en: $ruta_zip"
    exit 1
fi

# Verificar que la carpeta destino exista
if [ ! -d "$ruta_destino" ]; then
    echo "Error: la carpeta destino no existe: $ruta_destino"
    exit 1
fi

# Procesar cada archivo ZIP
for archivo_zip in "${archivos_zip[@]}"; do

    # Verificar que el ZIP sea válido
    if ! unzip -t "$archivo_zip" > /dev/null 2>&1; then
        echo "Error: el archivo no es un ZIP válido: $archivo_zip"
        exit 1
    fi

    # Extraer directamente los archivos y excluir __MACOSX
    if ! unzip -o -j "$archivo_zip" -d "$ruta_destino" \
        -x "__MACOSX/*" "*/__MACOSX/*"; then
        echo "Error: no se pudo descomprimir: $archivo_zip"
        exit 1
    fi

done

echo "Archivos descomprimidos correctamente en: $ruta_destino"

