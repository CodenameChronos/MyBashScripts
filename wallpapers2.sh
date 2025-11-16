#!/bin/bash

WALLPAPERS="$HOME/Imágenes/Wallpaper"
TARGET_DIR="$WALLPAPERS/FF"
DEFAULT_DIR="$WALLPAPERS/FF"

# =======================================================
# FUNCIÓN: Obtener Fondo Actual (KDE Plasma)
# =======================================================
get_current_wallpaper() {
    # El comando qdbus lee la configuración de la primera actividad de escritorio (índice 0)
    local WALLPAPER_RAW=$(qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var Desktops = desktops();
    Desktops[0].currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
    print(Desktops[0].readConfig('Image'));
    ")
    
    # Quitar las comillas dobles que devuelve qdbus
    echo "$WALLPAPER_RAW" | tr -d '"'
}

# =======================================================
# 2. PROCESAMIENTO DE FLAGS (getopts)
# =======================================================
while getopts "defszr" opt; do 
    case ${opt} in
        d) TARGET_DIR="$WALLPAPERS/Dark Souls" ;;
        e) TARGET_DIR="$WALLPAPERS/Evangelion" ;;
        f) TARGET_DIR="$WALLPAPERS/FF" ;;
        s) TARGET_DIR="$WALLPAPERS/Skyrim" ;;
        z) TARGET_DIR="$WALLPAPERS/Zelda" ;;
        
        r)
            # El flag -r no cambia TARGET_DIR, sino que se ejecuta inmediatamente
            # usando el directorio por defecto (FF) o uno preestablecido.
            
            # --- Lógica de Selección Aleatoria con Verificación de Repetición ---
            CURRENT_WALLPAPER=$(get_current_wallpaper)
            NEW_WALLPAPER=""

            # Bucle para asegurar que se selecciona un fondo diferente al actual
            while [ "$NEW_WALLPAPER" == "$CURRENT_WALLPAPER" ] || [ -z "$NEW_WALLPAPER" ]; do
                # 1. Seleccionar una carpeta temática al azar (nueva lógica -r)
                RVALUE=$(($RANDOM % 5))
                case ${RVALUE} in
                    0) TARGET_DIR_TEMP="$WALLPAPERS/Dark Souls" ;;
                    1) TARGET_DIR_TEMP="$WALLPAPERS/Evangelion" ;;
                    2) TARGET_DIR_TEMP="$WALLPAPERS/FF" ;;
                    3) TARGET_DIR_TEMP="$WALLPAPERS/Skyrim" ;;
                    4) TARGET_DIR_TEMP="$WALLPAPERS/Zelda" ;;
                esac
                
                # 2. Seleccionar un archivo aleatorio de esa carpeta temporal
                NEW_WALLPAPER=$(find "$TARGET_DIR_TEMP" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
            done

            # Comando D-Bus (usando el nuevo fondo)
            qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (var i = 0; i < allDesktops.length; i++) {
                allDesktops[i].wallpaperPlugin = 'org.kde.image';
                allDesktops[i].currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
                allDesktops[i].writeConfig('Image', '$NEW_WALLPAPER');
            }
            "
            echo "Fondo actualizado al azar: $NEW_WALLPAPER"
            exit 0
            ;;
            
        \?)
            echo "Uso: $0 [-d|-e|-f|-s|-z] [nombre_archivo | -r]" >&2
            exit 1
            ;;
    esac
done

# Restablece $1 al primer argumento que NO fue un flag
shift $((OPTIND - 1))

# =======================================================
# 3. LÓGICA DE EJECUCIÓN (Selección Aleatoria en Carpeta Elegida o Específica)
# =======================================================

# --- CASO 3A: Selección Aleatoria en la carpeta elegida (si no se pasó nombre) ---
if [ -z "$1" ]; then
    
    # --- Lógica de Selección Aleatoria con Verificación de Repetición ---
    CURRENT_WALLPAPER=$(get_current_wallpaper)
    NEW_WALLPAPER="$CURRENT_WALLPAPER" # Inicializar con el valor actual para entrar al bucle

    # Bucle para asegurar que se selecciona un fondo diferente al actual
    while [ "$NEW_WALLPAPER" == "$CURRENT_WALLPAPER" ] || [ -z "$NEW_WALLPAPER" ]; do
        NEW_WALLPAPER=$(find "$TARGET_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
        
        # Si la carpeta solo tiene un archivo, debemos salir del bucle para evitar un ciclo infinito.
        if [ "$NEW_WALLPAPER" == "$CURRENT_WALLPAPER" ] && [ $(find "$TARGET_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | wc -l) -le 1 ]; then
            echo "Advertencia: Solo hay un fondo en $TARGET_DIR. No se puede cambiar."
            exit 0
        fi
    done
    
    if [ -f "$NEW_WALLPAPER" ]; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allDesktops = desktops();
        for (var i = 0; i < allDesktops.length; i++) {
            allDesktops[i].wallpaperPlugin = 'org.kde.image';
            allDesktops[i].currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
            allDesktops[i].writeConfig('Image', '$NEW_WALLPAPER');
        }
        "
        echo "Fondo actualizado al azar en $TARGET_DIR: $NEW_WALLPAPER"
        exit 0
    else
        echo "Error: No se encontraron imágenes en $TARGET_DIR" >&2
        exit 1
    fi
fi

# --- CASO 3B: Selección Específica por Nombre ($1) en la carpeta elegida (Sin cambios) ---

WAPP_NAME_LOWER="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

TARGET_WALLPAPER_JPG="$TARGET_DIR/$WAPP_NAME_LOWER.jpg"
TARGET_WALLPAPER_PNG="$TARGET_DIR/$WAPP_NAME_LOWER.png"

if [ -f "$TARGET_WALLPAPER_JPG" ]; then
    WALLPAPER_TO_SET="$TARGET_WALLPAPER_JPG"
elif [ -f "$TARGET_WALLPAPER_PNG" ]; then
    WALLPAPER_TO_SET="$TARGET_WALLPAPER_PNG"
else
    echo "Error: El archivo '$1' no se encontró (.jpg o .png) en $TARGET_DIR" >&2
    exit 1
fi

qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    allDesktops[i].wallpaperPlugin = 'org.kde.image';
    allDesktops[i].currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
    allDesktops[i].writeConfig('Image', '$WALLPAPER_TO_SET');
}
"
echo "Fondo actualizado: $WALLPAPER_TO_SET"
exit 0
