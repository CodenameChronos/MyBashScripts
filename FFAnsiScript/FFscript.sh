#!/bin/bash

SPRITE="$1"
TARGET_DIRECTORY="$HOME/Imágenes/Icons/AnsiFF/"

if [ -z "$1" ]; then
	RANDOM_SPRITE=$(find $TARGET_DIRECTORY -type f -name "*.txt" | shuf -n 1)

	if [ -f "$RANDOM_SPRITE" ]; then
		cat "$RANDOM_SPRITE"
		exit 0
	else
		echo "No se encontraron archivos en $TARGET_DIRECTORY"
		exit 1
	fi
fi


TARGET_SPRITE_LOWER="$(echo "$1" | tr '[:upper:]' '[:lower:]').txt"
TARGET_SPRITE="$TARGET_DIRECTORY/$TARGET_SPRITE_LOWER"

if [ -f "$TARGET_SPRITE" ]; then
	cat "$TARGET_SPRITE"
	exit 0
else 
	echo "Archivo no encontrado"
	exit 1
fi
