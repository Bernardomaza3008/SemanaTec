palabra=$1
ruta=$2
echo "Buscando la palabra \"$palabra\"..."
echo "Ruta de búsqueda: $ruta"
echo "Archivos encontrados:"
echo ""
grep -rniI "$palabra" "$ruta"

