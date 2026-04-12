#!/usr/bin/env bash
set -euo pipefail

# Unsplash Image Downloader for Book Covers and Chapter Images
# Downloads portrait image by keyword, resizes to specified dimensions, converts to grayscale
# Adds book title label at the bottom unless --no-label (chapter images)
#
# Requirements: curl, jq, ImageMagick (magick or convert)

# Defaults
readonly DEFAULT_WIDTH=758
readonly DEFAULT_HEIGHT=1024
KEYWORD=""
OUTPUT_PATH=""
WIDTH=""
HEIGHT=""
NO_LABEL=0

# Temporary files for cleanup
TEMP_IMAGE=""
TEMP_TITLE=""
TEMP_LABELED=""

# Cleanup function
cleanup() {
    rm -f "$TEMP_IMAGE" "$TEMP_TITLE" "$TEMP_LABELED"
}
trap cleanup EXIT

# Show usage
usage() {
    echo "Usage: $0 --keyword <keyword> --output <output_path> [--width width] [--height height] [--no-label]"
    echo ""
    echo "Options:"
    echo "  --keyword <keyword>   Search keyword for image (required)"
    echo "  --output <path>       Output path for the cover image (required)"
    echo "  --width <pixels>      Image width (default: $DEFAULT_WIDTH)"
    echo "  --height <pixels>     Image height (default: $DEFAULT_HEIGHT)"
    echo "  --no-label            Skip folder-name bar at bottom (chapter images)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --keyword adventure --output ./books/my-book/cover.jpeg"
    echo "  $0 --keyword 'night sky' --output ./cover.jpeg --width 758 --height 1024"
}

# Detect ImageMagick command (magick on newer installs, convert on older)
detect_imagemagick() {
    if command -v magick &>/dev/null; then
        echo "magick"
    elif command -v convert &>/dev/null; then
        echo "convert"
    else
        echo ""
    fi
}

# Detect identify command (part of ImageMagick)
detect_identify() {
    if command -v magick &>/dev/null; then
        echo "magick identify"
    elif command -v identify &>/dev/null; then
        echo "identify"
    else
        echo ""
    fi
}

# Show help when no arguments given
if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

# Parse command-line arguments (long options only; -h/--help for help)
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        --keyword) KEYWORD="$2"; shift 2 ;;
        --output) OUTPUT_PATH="$2"; shift 2 ;;
        --width) WIDTH="$2"; shift 2 ;;
        --height) HEIGHT="$2"; shift 2 ;;
        --no-label) NO_LABEL=1; shift ;;
        --) shift; break ;;
        -*) echo "Unknown option: $1" >&2; usage; exit 1 ;;
        *) echo "Unexpected argument: $1" >&2; usage; exit 1 ;;
    esac
done

# Set default dimensions if not provided
if [[ -z "$WIDTH" ]]; then
    if [[ "$NO_LABEL" -eq 1 ]]; then
        WIDTH=$((DEFAULT_WIDTH / 2))
    else
        WIDTH="$DEFAULT_WIDTH"
    fi
fi

if [[ -z "$HEIGHT" ]]; then
    if [[ "$NO_LABEL" -eq 1 ]]; then
        HEIGHT=$((DEFAULT_HEIGHT / 2))
    else
        HEIGHT="$DEFAULT_HEIGHT"
    fi
fi

# Validate required arguments
if [[ -z "$KEYWORD" ]] || [[ -z "$OUTPUT_PATH" ]]; then
    echo "Error: keyword and output path are required." >&2
    usage
    exit 1
fi

# Check required commands
IMAGEMAGICK_CMD=$(detect_imagemagick)
if [[ -z "$IMAGEMAGICK_CMD" ]]; then
    echo "Error: ImageMagick not found (install with: brew install imagemagick or apt install imagemagick)" >&2
    exit 1
fi

IDENTIFY_CMD=$(detect_identify)
if [[ -z "$IDENTIFY_CMD" ]]; then
    echo "Error: ImageMagick identify not found" >&2
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "Error: curl is not installed." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed (install with: brew install jq or apt install jq)" >&2
    exit 1
fi

# Extract folder and filename from output path
OUTPUT_FOLDER="$(dirname "$OUTPUT_PATH")"
FILENAME="$(basename "$OUTPUT_PATH")"

# Create output folder if it doesn't exist
if [[ ! -d "$OUTPUT_FOLDER" ]]; then
    echo "Creating output folder: $OUTPUT_FOLDER"
    mkdir -p "$OUTPUT_FOLDER"
fi

TEMP_IMAGE="${OUTPUT_FOLDER}/temp_download_${FILENAME}.jpg"
OUTPUT_IMAGE="$OUTPUT_PATH"

# Get script directory to find .env file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts -> generate-image -> skills -> .cursor -> repo root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# Load environment variables from .env if it exists (values may contain spaces; never use xargs|export)
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            export "${BASH_REMATCH[1]}=${BASH_REMATCH[2]}"
        fi
    done < "$PROJECT_ROOT/.env"
fi

# Get Unsplash API key from environment
UNSPLASH_KEY="${UNSPLASH_API_KEY:-${UNSPLASH_SECRET_KEY:-}}"

if [[ -z "$UNSPLASH_KEY" ]]; then
    echo "Error: No Unsplash API key found in environment variables." >&2
    echo "Set UNSPLASH_API_KEY or UNSPLASH_SECRET_KEY in .env file or environment." >&2
    exit 1
fi

echo "[$FILENAME] Searching for portrait image: '$KEYWORD' on Unsplash..."

# Use Unsplash's random photo endpoint with query parameter
API_URL="https://api.unsplash.com/photos/random?query=${KEYWORD}&orientation=portrait&client_id=${UNSPLASH_KEY}"

echo "[$FILENAME] Fetching image URL from Unsplash API..."

# Get the image data from API
RESPONSE=$(curl -s "$API_URL")

# Extract the download URL from JSON response
# Use jq if available, otherwise fall back to grep/sed
if command -v jq &>/dev/null; then
    IMAGE_URL=$(echo "$RESPONSE" | jq -r '.urls.raw' 2>/dev/null)
else
    # Fallback: extract "raw":"<url>" from the urls object using grep/sed
    IMAGE_URL=$(echo "$RESPONSE" | grep -o '"raw":"[^"]*"' | head -1 | sed 's/"raw":"//;s/"$//')
fi

if [[ -z "$IMAGE_URL" ]] || [[ "$IMAGE_URL" == "null" ]]; then
    echo "[$FILENAME] Error: Could not fetch image from Unsplash." >&2
    echo "Response: $RESPONSE" >&2
    exit 1
fi

echo "[$FILENAME] Downloading image..."

# Download the image
if curl -L -s -o "$TEMP_IMAGE" "$IMAGE_URL"; then
    echo "[$FILENAME] Image downloaded successfully."
else
    echo "[$FILENAME] Error: Failed to download image." >&2
    exit 1
fi

# Check if file was actually downloaded
if [[ ! -f "$TEMP_IMAGE" ]]; then
    echo "[$FILENAME] Error: Downloaded file not found." >&2
    exit 1
fi

echo "[$FILENAME] Resizing to ${WIDTH}x${HEIGHT}, converting to grayscale..."

# Resize with proper aspect ratio handling and convert to grayscale
if "$IMAGEMAGICK_CMD" "$TEMP_IMAGE" \
    -resize "${WIDTH}x${HEIGHT}^" \
    -gravity center \
    -extent "${WIDTH}x${HEIGHT}" \
    -colorspace Gray \
    "$OUTPUT_IMAGE"; then
    echo "[$FILENAME] Image processed successfully!"
else
    echo "[$FILENAME] Error: Failed to process image with ImageMagick." >&2
    exit 1
fi

if [[ "$NO_LABEL" -eq 1 ]]; then
    echo "[$FILENAME] Skipping bottom label (--no-label)."
else
    # Add text label to the image
    echo "[$FILENAME] Adding text label to image..."

    # Get the book folder name (use output folder directly)
    DIR_NAME="$(basename "$OUTPUT_FOLDER")"
    # Replace underscores with spaces for the title
    DIR_NAME="${DIR_NAME//_/ }"

    echo "[$FILENAME] Directory name for label: $DIR_NAME"

    # Get image dimensions
    DIMS=$($IDENTIFY_CMD -format "%w %h" "$OUTPUT_IMAGE")
    CURRENT_WIDTH=$(echo "$DIMS" | cut -d' ' -f1)
    CURRENT_HEIGHT=$(echo "$DIMS" | cut -d' ' -f2)

    # Calculate bar height (proportional to image height, min 50px)
    BAR_HEIGHT=$((CURRENT_HEIGHT / 8))
    if [[ $BAR_HEIGHT -lt 50 ]]; then
        BAR_HEIGHT=50
    fi

    # Max font size (proportional to bar height); min font size for readability
    MAX_FONT_SIZE=$((BAR_HEIGHT * 7 / 10))
    readonly MIN_FONT_SIZE=12
    AVAILABLE_WIDTH=$((CURRENT_WIDTH - 80))

    # Write title to temp file to avoid escaping issues in ImageMagick
    TEMP_TITLE="${OUTPUT_FOLDER}/temp_title_${FILENAME}.txt"
    printf '%s' "$DIR_NAME" > "$TEMP_TITLE"

    # Find font size so that text fits in available width
    FONT_SIZE=$MAX_FONT_SIZE
    while [[ $FONT_SIZE -ge $MIN_FONT_SIZE ]]; do
        TEXT_WIDTH=$("$IMAGEMAGICK_CMD" -font Helvetica -pointsize "$FONT_SIZE" "label:@$TEMP_TITLE" -format "%w" info: 2>/dev/null || echo 9999)
        if [[ -n "$TEXT_WIDTH" ]] && [[ "$TEXT_WIDTH" -le "$AVAILABLE_WIDTH" ]]; then
            break
        fi
        FONT_SIZE=$((FONT_SIZE - 4))
    done

    if [[ $FONT_SIZE -lt $MIN_FONT_SIZE ]]; then
        FONT_SIZE=$MIN_FONT_SIZE
    fi

    # Create temporary labeled image
    TEMP_LABELED="${OUTPUT_FOLDER}/temp_labeled_${FILENAME}"

    # Add label: extend canvas at bottom with black bar and add white text
    if "$IMAGEMAGICK_CMD" "$OUTPUT_IMAGE" \
        -gravity South \
        -background black \
        -splice "0x${BAR_HEIGHT}" \
        -gravity South \
        -fill white \
        -font Helvetica \
        -pointsize "$FONT_SIZE" \
        -annotate "+0+$((BAR_HEIGHT / 4))" "$DIR_NAME" \
        "$TEMP_LABELED"; then
        # Replace original with labeled version
        mv "$TEMP_LABELED" "$OUTPUT_IMAGE"
        echo "[$FILENAME] Text label added successfully!"
    else
        echo "[$FILENAME] Warning: Failed to add text label, but image was saved without label."
        rm -f "$TEMP_LABELED"
    fi
fi

echo "[$FILENAME] Done! Saved as: $OUTPUT_IMAGE"
