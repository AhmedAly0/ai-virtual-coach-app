"""
Generate the app icon: red background (#FF3B30) with a white dumbbell (fitness_center)
using the Material Icons font from the Flutter SDK.
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

# Configuration
SIZE = 1024
BG_COLOR = (255, 59, 48, 255)  # #FF3B30 (AppTheme.accentRed)
ICON_COLOR = (255, 255, 255, 255)  # White

# Flutter SDK Material Icons font
FONT_PATH = r"D:\Dev tools\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf"

# fitness_center codepoints to try (baseline first, then legacy)
CODEPOINTS = [0xE28D, 0xE39D, 0xEB43]

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "icon")


def generate_icon():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Create base image with red background
    img = Image.new("RGBA", (SIZE, SIZE), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # Load Material Icons font
    if not os.path.exists(FONT_PATH):
        print(f"ERROR: Material Icons font not found at: {FONT_PATH}")
        sys.exit(1)

    font_size = int(SIZE * 0.55)  # Icon takes ~55% of the image
    font = ImageFont.truetype(FONT_PATH, size=font_size)

    # Try each codepoint to find the fitness_center icon
    icon_char = None
    for cp in CODEPOINTS:
        test_char = chr(cp)
        bbox = draw.textbbox((0, 0), test_char, font=font)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        if w > 10 and h > 10:  # Valid glyph found
            icon_char = test_char
            print(f"Using codepoint 0x{cp:04X} (size: {w}x{h})")
            break

    if icon_char is None:
        print("WARNING: Could not find fitness_center glyph, using fallback drawing")
        _draw_dumbbell_fallback(draw)
    else:
        # Center the icon character
        bbox = draw.textbbox((0, 0), icon_char, font=font)
        text_w = bbox[2] - bbox[0]
        text_h = bbox[3] - bbox[1]
        x = (SIZE - text_w) // 2 - bbox[0]
        y = (SIZE - text_h) // 2 - bbox[1]
        draw.text((x, y), icon_char, font=font, fill=ICON_COLOR)

    # Save the main icon
    output_path = os.path.join(OUTPUT_DIR, "app_icon.png")
    img.save(output_path, "PNG")
    print(f"Icon saved to: {output_path}")

    # Also create an adaptive icon foreground (with padding for Android adaptive icons)
    adaptive = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    adaptive_draw = ImageDraw.Draw(adaptive)

    # Adaptive icons need ~66% safe zone, so draw the icon smaller in the center
    adaptive_font_size = int(SIZE * 0.38)
    adaptive_font = ImageFont.truetype(FONT_PATH, size=adaptive_font_size)

    if icon_char:
        bbox = adaptive_draw.textbbox((0, 0), icon_char, font=adaptive_font)
        text_w = bbox[2] - bbox[0]
        text_h = bbox[3] - bbox[1]
        x = (SIZE - text_w) // 2 - bbox[0]
        y = (SIZE - text_h) // 2 - bbox[1]
        adaptive_draw.text((x, y), icon_char, font=adaptive_font, fill=ICON_COLOR)

    adaptive_path = os.path.join(OUTPUT_DIR, "app_icon_foreground.png")
    adaptive.save(adaptive_path, "PNG")
    print(f"Adaptive foreground saved to: {adaptive_path}")

    print("Done!")


def _draw_dumbbell_fallback(draw):
    """Fallback: draw a simple dumbbell shape if font rendering fails."""
    import math

    cx, cy = SIZE // 2, SIZE // 2

    # Draw on a temp image, then rotate
    temp = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    td = ImageDraw.Draw(temp)

    bar_half_len = 280
    bar_thickness = 50
    plate_w = 70
    plate_h = 200
    inner_plate_w = 55
    inner_plate_h = 150

    # Central bar
    td.rectangle(
        [cx - bar_half_len, cy - bar_thickness // 2,
         cx + bar_half_len, cy + bar_thickness // 2],
        fill=ICON_COLOR
    )
    # Left outer plate
    td.rectangle(
        [cx - bar_half_len - 10, cy - plate_h // 2,
         cx - bar_half_len - 10 + plate_w, cy + plate_h // 2],
        fill=ICON_COLOR
    )
    # Left inner plate
    td.rectangle(
        [cx - bar_half_len + plate_w + 10, cy - inner_plate_h // 2,
         cx - bar_half_len + plate_w + 10 + inner_plate_w, cy + inner_plate_h // 2],
        fill=ICON_COLOR
    )
    # Right outer plate
    td.rectangle(
        [cx + bar_half_len + 10 - plate_w, cy - plate_h // 2,
         cx + bar_half_len + 10, cy + plate_h // 2],
        fill=ICON_COLOR
    )
    # Right inner plate
    td.rectangle(
        [cx + bar_half_len - plate_w - 10 - inner_plate_w, cy - inner_plate_h // 2,
         cx + bar_half_len - plate_w - 10, cy + inner_plate_h // 2],
        fill=ICON_COLOR
    )

    # Rotate 45 degrees
    temp = temp.rotate(-45, center=(cx, cy), resample=Image.BICUBIC)

    # Composite onto the main image (draw is associated with parent img)
    # We need to get the parent image from draw
    draw._image.paste(temp, (0, 0), temp)


if __name__ == "__main__":
    generate_icon()
