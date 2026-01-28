#!/bin/bash
# generate-default-faces.sh
# Script to generate a set of default avatar faces for SDDM theme

set -e

THEME_DIR="/usr/share/sddm/themes/ubuntu-budgie-login"
FACES_DIR="$THEME_DIR/faces"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run as root (use sudo)"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Installing..."
    apt-get update && apt-get install -y imagemagick
fi

# Create faces directory
echo "Creating faces directory at $FACES_DIR..."
mkdir -p "$FACES_DIR"

# Ubuntu Budgie color palette
COLORS=(
    "#5294e2"  # Budgie Blue
    "#f9ae58"  # Orange
    "#f04a50"  # Red
    "#64ba9d"  # Teal
    "#9b59b6"  # Purple
    "#3498db"  # Light Blue
    "#e74c3c"  # Coral
    "#2ecc71"  # Green
    "#f39c12"  # Amber
    "#1abc9c"  # Turquoise
    "#95a5a6"  # Gray
    "#16a085"  # Dark Teal
    "#8e44ad"  # Dark Purple
    "#d35400"  # Pumpkin
    "#c0392b"  # Dark Red
)

# Geometric shapes to use
SHAPES=("circle" "square" "triangle" "hexagon" "diamond")

echo "Generating avatar faces..."

generate_circle() {
    local output="$1"
    local color="$2"
    local number="$3"
    
    convert -size 256x256 xc:transparent \
        -fill "$color" \
        -draw "circle 128,128 128,20" \
        -gravity center \
        -pointsize 100 \
        -fill white \
        -font "DejaVu-Sans-Bold" \
        -annotate +0+0 "$number" \
        "$output"
}

generate_square() {
    local output="$1"
    local color="$2"
    local number="$3"
    
    convert -size 256x256 xc:transparent \
        -fill "$color" \
        -draw "roundRectangle 28,28 228,228 30,30" \
        -gravity center \
        -pointsize 100 \
        -fill white \
        -font "DejaVu-Sans-Bold" \
        -annotate +0+0 "$number" \
        "$output"
}

generate_hexagon() {
    local output="$1"
    local color="$2"
    local number="$3"
    
    convert -size 256x256 xc:transparent \
        -fill "$color" \
        -draw "polygon 128,20 228,84 228,172 128,236 28,172 28,84" \
        -gravity center \
        -pointsize 100 \
        -fill white \
        -font "DejaVu-Sans-Bold" \
        -annotate +0+0 "$number" \
        "$output"
}

generate_diamond() {
    local output="$1"
    local color="$2"
    local number="$3"
    
    convert -size 256x256 xc:transparent \
        -fill "$color" \
        -draw "polygon 128,20 228,128 128,236 28,128" \
        -gravity center \
        -pointsize 100 \
        -fill white \
        -font "DejaVu-Sans-Bold" \
        -annotate +0+0 "$number" \
        "$output"
}

# Generate 15 different avatars
for i in {1..15}; do
    COLOR="${COLORS[$((i-1))]}"
    OUTPUT="$FACES_DIR/face-$i.png"
    
    # Cycle through different shapes
    SHAPE_IDX=$(( (i-1) % 4 ))
    
    case $SHAPE_IDX in
        0)
            echo "  Generating face-$i.png (circle)..."
            generate_circle "$OUTPUT" "$COLOR" "$i"
            ;;
        1)
            echo "  Generating face-$i.png (square)..."
            generate_square "$OUTPUT" "$COLOR" "$i"
            ;;
        2)
            echo "  Generating face-$i.png (hexagon)..."
            generate_hexagon "$OUTPUT" "$COLOR" "$i"
            ;;
        3)
            echo "  Generating face-$i.png (diamond)..."
            generate_diamond "$OUTPUT" "$COLOR" "$i"
            ;;
    esac
    
    # Set proper permissions
    chown root:root "$OUTPUT"
    chmod 644 "$OUTPUT"
done

echo ""
echo "Successfully generated 15 avatar faces in $FACES_DIR"
echo ""
echo "These avatars will be automatically assigned to users who don't have"
echo "a custom avatar configured. Each user will consistently receive the"
echo "same avatar based on their username."
echo ""
echo "To customize avatars, users can:"
echo "  1. Copy an image to ~/.face or ~/.face.icon"
echo "  2. Set it via AccountsService in /var/lib/AccountsService/icons/"
echo ""
echo "For more information, see the FACES_README.md file."
