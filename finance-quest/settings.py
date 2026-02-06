"""
Game Settings for Finance Quest
"""
import os

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_PATH = os.path.join(BASE_DIR, "assets", "images")
TILES_PATH = os.path.join(ASSETS_PATH, "tiles")
PLAYER_PATH = os.path.join(ASSETS_PATH, "player")
ITEMS_PATH = os.path.join(ASSETS_PATH, "items")
NPC_PATH = os.path.join(ASSETS_PATH, "npc")
UI_PATH = os.path.join(ASSETS_PATH, "ui")
GEMS_PATH = os.path.join(ASSETS_PATH, "gems")
LEVELS_PATH = os.path.join(BASE_DIR, "levels")

# Screen
SCREEN_WIDTH = 1024
SCREEN_HEIGHT = 768
FPS = 60
TITLE = "Finance Quest: Needs vs Wants"

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GOLD = (255, 215, 0)
RED = (220, 60, 60)
GREEN = (60, 180, 60)
BLUE = (60, 100, 220)
SKY_BLUE = (135, 200, 235)
PANEL_BG = (60, 50, 40, 220)
PANEL_BORDER = (120, 100, 80)

# Player settings
STARTING_COINS = 0
STARTING_XP = 0
STARTING_HEALTH = 5
MAX_HEALTH = 5

# Tile size
TILE_SIZE = 32

# Physics
GRAVITY = 0.8
JUMP_STRENGTH = -15
PLAYER_SPEED = 5

# Game settings
TOTAL_DAYS = 3

# Items - Needs (essential for survival)
NEEDS = ['bread', 'carrot', 'coat', 'medicine', 'water', 'blanket']

# Items - Wants (nice to have but not essential)
WANTS = ['candy', 'toy', 'crown', 'balloon', 'game', 'jewelry']

# Item prices
ITEM_PRICES = {
    # Needs
    'bread': 15,
    'carrot': 10,
    'coat': 25,
    'medicine': 20,
    'water': 5,
    'blanket': 20,
    # Wants
    'candy': 8,
    'toy': 15,
    'crown': 30,
    'balloon': 5,
    'game': 25,
    'jewelry': 35,
}

# Daily tasks (needs Mom asks for each day)
DAILY_TASKS = {
    1: ['bread', 'water'],              # Day 1: Basic food needs
    2: ['carrot', 'medicine', 'coat'],  # Day 2: Health & warmth
    3: ['blanket', 'bread', 'water'],   # Day 3: Comfort & food
}

# XP rewards
XP_CORRECT_NEED = 20
XP_CORRECT_WANT = 5
XP_WRONG_NEED = -10
XP_WRONG_WANT = -5
XP_TALK_NPC = 10
XP_COMPLETE_DAY = 50

# Level thresholds
LEVEL_THRESHOLDS = {
    1: 0,
    2: 50,
    3: 100,
    4: 200,
    5: 350,
}

LEVEL_TITLES = {
    1: "Beginner",
    2: "Learner",
    3: "Saver",
    4: "Smart Shopper",
    5: "Finance Champion",
}
