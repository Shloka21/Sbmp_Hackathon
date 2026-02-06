"""
Asset Generator for Finance Quest
Creates all game sprites programmatically with better visuals
"""
import os
from PIL import Image, ImageDraw, ImageFont

# Define paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_DIR = os.path.join(BASE_DIR, "assets", "images")

# Subdirectories
TILES_DIR = os.path.join(ASSETS_DIR, "tiles")
PLAYER_DIR = os.path.join(ASSETS_DIR, "player")
ITEMS_DIR = os.path.join(ASSETS_DIR, "items")
NPC_DIR = os.path.join(ASSETS_DIR, "npc")
UI_DIR = os.path.join(ASSETS_DIR, "ui")
GEMS_DIR = os.path.join(ASSETS_DIR, "gems")


def ensure_dirs():
    """Create all directories"""
    for d in [TILES_DIR, PLAYER_DIR, ITEMS_DIR, NPC_DIR, UI_DIR, GEMS_DIR]:
        os.makedirs(d, exist_ok=True)


def create_character(name, body_color, hair_color, size=64):
    """Create a character sprite"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = size // 2, size // 2
    
    # Body (simple dress/shirt)
    draw.ellipse([cx-12, cy+5, cx+12, cy+28], fill=body_color)
    
    # Head
    draw.ellipse([cx-10, cy-15, cx+10, cy+8], fill=(255, 220, 180))
    
    # Hair
    draw.ellipse([cx-11, cy-17, cx+11, cy-5], fill=hair_color)
    
    # Eyes
    draw.ellipse([cx-5, cy-5, cx-2, cy-1], fill=(50, 50, 50))
    draw.ellipse([cx+2, cy-5, cx+5, cy-1], fill=(50, 50, 50))
    
    # Smile
    draw.arc([cx-5, cy-2, cx+5, cy+5], 0, 180, fill=(150, 80, 80), width=2)
    
    # Legs
    draw.rectangle([cx-8, cy+25, cx-3, cy+30], fill=(100, 80, 60))
    draw.rectangle([cx+3, cy+25, cx+8, cy+30], fill=(100, 80, 60))
    
    return img


def create_alex():
    """Create Alex (player character)"""
    img = create_character("alex", (70, 130, 180), (139, 90, 43))
    img.save(os.path.join(PLAYER_DIR, "alex.png"))
    print("✓ Created Alex")


def create_mom():
    """Create Mom character"""
    img = create_character("mom", (180, 100, 120), (101, 67, 33))
    img.save(os.path.join(NPC_DIR, "mom.png"))
    print("✓ Created Mom")


def create_shop_item(name, color, shape='circle', is_need=True):
    """Create a shop item"""
    size = 48
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = size // 2, size // 2
    
    # Background circle/square
    if is_need:
        bg_color = (80, 180, 80, 180)  # Green for needs
    else:
        bg_color = (180, 80, 80, 180)  # Red for wants
    
    draw.ellipse([4, 4, size-4, size-4], fill=bg_color)
    
    # Item shape
    if shape == 'circle':
        draw.ellipse([12, 12, size-12, size-12], fill=color)
    elif shape == 'rect':
        draw.rectangle([10, 10, size-10, size-10], fill=color)
    elif shape == 'bread':
        draw.ellipse([8, 16, size-8, size-12], fill=color)
        draw.rectangle([10, 20, size-10, size-14], fill=color)
    elif shape == 'carrot':
        draw.polygon([(cx, 8), (cx-8, size-10), (cx+8, size-10)], fill=color)
        draw.rectangle([cx-3, 5, cx+3, 12], fill=(50, 150, 50))
    elif shape == 'coat':
        draw.polygon([(cx-15, 10), (cx+15, 10), (cx+12, size-8), (cx-12, size-8)], fill=color)
    elif shape == 'medicine':
        draw.rectangle([14, 8, size-14, size-8], fill=(255, 255, 255))
        draw.rectangle([cx-3, 12, cx+3, size-12], fill=(200, 50, 50))
        draw.rectangle([14, cy-3, size-14, cy+3], fill=(200, 50, 50))
    
    return img


def create_items():
    """Create all shop items"""
    needs = {
        'bread': ((210, 180, 120), 'bread'),
        'carrot': ((255, 140, 0), 'carrot'),
        'coat': ((100, 80, 60), 'coat'),
        'medicine': ((255, 100, 100), 'medicine'),
        'water': ((100, 180, 255), 'circle'),
        'blanket': ((160, 140, 200), 'rect'),
    }
    
    wants = {
        'candy': ((255, 100, 150), 'circle'),
        'toy': ((255, 200, 0), 'rect'),
        'crown': ((255, 215, 0), 'circle'),
        'balloon': ((255, 80, 80), 'circle'),
        'game': ((100, 200, 100), 'rect'),
        'jewelry': ((200, 150, 255), 'circle'),
    }
    
    for name, (color, shape) in needs.items():
        img = create_shop_item(name, color, shape, is_need=True)
        img.save(os.path.join(ITEMS_DIR, f"{name}.png"))
        print(f"✓ Need: {name}")
    
    for name, (color, shape) in wants.items():
        img = create_shop_item(name, color, shape, is_need=False)
        img.save(os.path.join(ITEMS_DIR, f"{name}.png"))
        print(f"✓ Want: {name}")


def create_gem(color, name):
    """Create a gem for match-3 game"""
    size = 48
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = size // 2, size // 2
    
    # Gem shape (hexagon-ish)
    points = [
        (cx, 4),
        (size-6, cy-8),
        (size-6, cy+8),
        (cx, size-4),
        (6, cy+8),
        (6, cy-8),
    ]
    
    # Outer glow
    draw.polygon(points, fill=tuple(max(0, c-30) for c in color) + (255,))
    
    # Inner gem
    inner_points = [
        (cx, 8),
        (size-10, cy-6),
        (size-10, cy+6),
        (cx, size-8),
        (10, cy+6),
        (10, cy-6),
    ]
    draw.polygon(inner_points, fill=color + (255,))
    
    # Highlight
    draw.ellipse([cx-6, 10, cx+2, 18], fill=(255, 255, 255, 150))
    
    return img


def create_gems():
    """Create gems for match-3 game"""
    gems = {
        'red': (220, 60, 60),
        'blue': (60, 100, 220),
        'green': (60, 180, 60),
        'yellow': (240, 200, 40),
        'purple': (160, 60, 200),
    }
    
    for name, color in gems.items():
        img = create_gem(color, name)
        img.save(os.path.join(GEMS_DIR, f"{name}.png"))
        print(f"✓ Gem: {name}")


def create_ui_elements():
    """Create UI elements"""
    # Coin
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([2, 2, 30, 30], fill=(255, 200, 50))
    draw.ellipse([8, 8, 24, 24], fill=(255, 220, 100))
    draw.text((12, 6), "$", fill=(180, 140, 30))
    img.save(os.path.join(UI_DIR, "coin.png"))
    print("✓ Coin")
    
    # Heart
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.polygon([(16, 28), (4, 14), (4, 8), (10, 4), (16, 10), (22, 4), (28, 8), (28, 14)], 
                 fill=(220, 50, 50))
    img.save(os.path.join(UI_DIR, "heart.png"))
    print("✓ Heart")
    
    # Star
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    points = [(16, 2), (20, 12), (30, 12), (22, 19), (26, 30), (16, 23), (6, 30), (10, 19), (2, 12), (12, 12)]
    draw.polygon(points, fill=(255, 215, 0))
    img.save(os.path.join(UI_DIR, "star.png"))
    print("✓ Star")
    
    # Check mark
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([2, 2, 30, 30], fill=(80, 180, 80))
    draw.line([(8, 16), (14, 22), (24, 10)], fill=(255, 255, 255), width=3)
    img.save(os.path.join(UI_DIR, "check.png"))
    print("✓ Check")
    
    # X mark
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([2, 2, 30, 30], fill=(180, 80, 80))
    draw.line([(10, 10), (22, 22)], fill=(255, 255, 255), width=3)
    draw.line([(22, 10), (10, 22)], fill=(255, 255, 255), width=3)
    img.save(os.path.join(UI_DIR, "cross.png"))
    print("✓ Cross")


def create_backgrounds():
    """Create background elements"""
    # Home background tile
    img = Image.new('RGBA', (64, 64), (240, 230, 210))
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, 64, 64], outline=(200, 190, 170), width=2)
    img.save(os.path.join(TILES_DIR, "floor.png"))
    
    # Wall tile
    img = Image.new('RGBA', (64, 64), (180, 160, 140))
    draw = ImageDraw.Draw(img)
    for y in range(0, 64, 16):
        offset = 16 if (y // 16) % 2 else 0
        for x in range(-16, 80, 32):
            draw.rectangle([x + offset, y, x + offset + 30, y + 14], 
                          fill=(160, 140, 120), outline=(140, 120, 100))
    img.save(os.path.join(TILES_DIR, "wall.png"))
    
    print("✓ Backgrounds")


def main():
    """Generate all assets"""
    print("\n🎨 Generating Finance Quest Assets...\n")
    
    ensure_dirs()
    
    create_alex()
    create_mom()
    create_items()
    create_gems()
    create_ui_elements()
    create_backgrounds()
    
    print("\n✅ All assets generated!")
    print(f"📁 Assets saved to: {ASSETS_DIR}\n")


if __name__ == "__main__":
    main()
