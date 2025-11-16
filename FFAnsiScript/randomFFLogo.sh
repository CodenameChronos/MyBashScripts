#!/bin/bash

# Directorio donde están todos tus sprites de FF
SPRITE_DIR="$HOME/Imágenes/Icons/AnsiFF"

# El archivo de destino que fastfetch lee
ACTIVE_LOGO="$HOME/Documentos/Scripts/Fastfetch/activeLogo.txt"

# 1. Encuentra todos los archivos de texto en el directorio
#    'shuf -n 1' selecciona uno de ellos al azar
RANDOM_SPRITE=$(find "$SPRITE_DIR" -type f -name "*.txt" | shuf -n 1)

# 2. Copia el sprite aleatorio al archivo activo
if [ -f "$RANDOM_SPRITE" ]; then
    cp "$RANDOM_SPRITE" "$ACTIVE_LOGO"
fi

# 3. Ejecuta fastfetch
fastfetch "$@"
