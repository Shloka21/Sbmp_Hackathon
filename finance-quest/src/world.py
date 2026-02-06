"""
World/Level management for Finance Quest
Handles tile-based world generation and rendering
"""
import pygame
import os
from settings import TILE_SIZE, TILES_PATH, LEVELS_DIR, SKY_BLUE


class Tile(pygame.sprite.Sprite):
    """A single tile in the world"""
    def __init__(self, x, y, tile_type, image):
        super().__init__()
        self.tile_type = tile_type
        self.image = image
        self.rect = self.image.get_rect()
        self.rect.x = x * TILE_SIZE
        self.rect.y = y * TILE_SIZE
        self.solid = tile_type not in ['air', 'ladder', 'water']


class World:
    """Manages the game world/level"""
    
    # Tile mapping for level files
    TILE_MAP = {
        '.': 'air',
        '#': 'grass',
        'D': 'dirt',
        'S': 'stone',
        'W': 'wood',
        'B': 'brick',
        'L': 'ladder',
        '~': 'water',
        'T': 'leaves',
    }
    
    def __init__(self):
        self.tiles = pygame.sprite.Group()
        self.solid_tiles = pygame.sprite.Group()
        self.tile_images = self.load_tile_images()
        self.width = 0
        self.height = 0
        self.player_spawn = (100, 400)
        
    def load_tile_images(self):
        """Load all tile images"""
        images = {}
        tile_files = {
            'grass': 'grass.png',
            'dirt': 'dirt.png',
            'stone': 'stone.png',
            'wood': 'wood.png',
            'brick': 'brick.png',
            'ladder': 'ladder.png',
            'water': 'water.png',
            'leaves': 'leaves.png',
        }
        
        for tile_name, filename in tile_files.items():
            path = os.path.join(TILES_PATH, filename)
            if os.path.exists(path):
                img = pygame.image.load(path).convert_alpha()
                images[tile_name] = pygame.transform.scale(img, (TILE_SIZE, TILE_SIZE))
            else:
                # Create placeholder
                images[tile_name] = self.create_tile_placeholder(tile_name)
        
        # Create air tile (transparent)
        air_surface = pygame.Surface((TILE_SIZE, TILE_SIZE), pygame.SRCALPHA)
        images['air'] = air_surface
        
        return images
    
    def create_tile_placeholder(self, tile_name):
        """Create placeholder tile if image not found"""
        surface = pygame.Surface((TILE_SIZE, TILE_SIZE))
        
        colors = {
            'grass': (95, 170, 60),
            'dirt': (139, 90, 43),
            'stone': (128, 128, 128),
            'wood': (166, 113, 65),
            'brick': (180, 80, 60),
            'ladder': (120, 77, 43),
            'water': (100, 180, 255),
            'leaves': (60, 160, 60),
        }
        
        color = colors.get(tile_name, (128, 128, 128))
        surface.fill(color)
        
        # Add some texture
        darker = tuple(max(0, c - 30) for c in color)
        for i in range(0, TILE_SIZE, 4):
            pygame.draw.line(surface, darker, (i, 0), (i, TILE_SIZE))
        
        return surface
    
    def load_level(self, level_data):
        """Load a level from string data"""
        self.tiles.empty()
        self.solid_tiles.empty()
        
        lines = level_data.strip().split('\n')
        self.height = len(lines)
        self.width = max(len(line) for line in lines) if lines else 0
        
        for y, line in enumerate(lines):
            for x, char in enumerate(line):
                tile_type = self.TILE_MAP.get(char, 'air')
                
                if tile_type != 'air':
                    tile_image = self.tile_images.get(tile_type, self.tile_images['stone'])
                    tile = Tile(x, y, tile_type, tile_image)
                    self.tiles.add(tile)
                    
                    if tile.solid:
                        self.solid_tiles.add(tile)
                
                # Check for player spawn position
                if char == 'P':
                    self.player_spawn = (x * TILE_SIZE, y * TILE_SIZE - TILE_SIZE)
    
    def load_level_file(self, filename):
        """Load a level from file"""
        path = os.path.join(LEVELS_DIR, filename)
        if os.path.exists(path):
            with open(path, 'r') as f:
                self.load_level(f.read())
        else:
            # Create default level
            self.create_default_level()
    
    def create_default_level(self):
        """Create a default level if no level file exists"""
        # Simple village level
        level = """
................................
................................
................................
................................
................................
.......TTT......TTT.............
......TTTTT....TTTTT............
.......WWW......WWW.............
.......WWW......WWW.............
................................
................................
..........BBBBB.................
..........BBBBB.................
..........B...B....P............
..........B...B.................
##########BBBBB#################
DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
"""
        self.load_level(level)
    
    def draw(self, screen, camera_offset=(0, 0)):
        """Draw the world"""
        # Draw sky background
        screen.fill(SKY_BLUE)
        
        # Draw all tiles with camera offset
        for tile in self.tiles:
            screen.blit(tile.image, 
                       (tile.rect.x - camera_offset[0], 
                        tile.rect.y - camera_offset[1]))
    
    def get_solid_tiles(self):
        """Return list of solid tiles for collision"""
        return list(self.solid_tiles)
