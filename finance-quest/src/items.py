"""
Items system for Finance Quest
Handles collectible items, needs vs wants categorization
"""
import pygame
import os
from settings import (
    TILE_SIZE, ITEMS_PATH, ITEM_PRICES, NEEDS, WANTS,
    XP_CORRECT_NEED, XP_CORRECT_WANT, XP_WRONG_NEED, XP_WRONG_WANT
)


class Item(pygame.sprite.Sprite):
    """A collectible item in the world"""
    
    def __init__(self, x, y, item_type):
        super().__init__()
        self.item_type = item_type
        self.price = ITEM_PRICES.get(item_type, 10)
        self.is_need = item_type in NEEDS
        self.is_want = item_type in WANTS
        
        # Load image
        self.image = self.load_image()
        self.rect = self.image.get_rect()
        self.rect.x = x
        self.rect.y = y
        
        # Floating animation
        self.base_y = y
        self.float_offset = 0
        self.float_speed = 0.05
        self.float_range = 5
        
        # Collected state
        self.collected = False
    
    def load_image(self):
        """Load item image or create placeholder"""
        path = os.path.join(ITEMS_PATH, f"{self.item_type}.png")
        
        if os.path.exists(path):
            img = pygame.image.load(path).convert_alpha()
            return pygame.transform.scale(img, (24, 24))
        else:
            return self.create_placeholder()
    
    def create_placeholder(self):
        """Create placeholder for missing item image"""
        surface = pygame.Surface((24, 24), pygame.SRCALPHA)
        
        # Different colors for needs vs wants
        if self.is_need:
            color = (50, 180, 50)  # Green for needs
        else:
            color = (180, 50, 50)  # Red for wants
        
        pygame.draw.rect(surface, color, (2, 2, 20, 20), border_radius=4)
        pygame.draw.rect(surface, (255, 255, 255), (6, 6, 12, 12), border_radius=2)
        
        return surface
    
    def update(self):
        """Update item animation"""
        if not self.collected:
            # Floating animation
            self.float_offset += self.float_speed
            offset = int(self.float_range * pygame.math.Vector2(0, 1).rotate(self.float_offset * 50).y)
            self.rect.y = self.base_y + offset
    
    def collect(self):
        """Mark item as collected"""
        self.collected = True
        self.kill()
    
    def get_xp_for_correct_choice(self):
        """Get XP reward for correct categorization"""
        if self.is_need:
            return XP_CORRECT_NEED
        return XP_CORRECT_WANT
    
    def get_xp_penalty_for_wrong(self):
        """Get XP penalty for wrong categorization"""
        if self.is_need:
            return XP_WRONG_NEED
        return XP_WRONG_WANT


class ItemManager:
    """Manages all items in the level"""
    
    def __init__(self):
        self.items = pygame.sprite.Group()
        self.collected_items = []
    
    def spawn_item(self, x, y, item_type):
        """Spawn a new item at position"""
        item = Item(x, y, item_type)
        self.items.add(item)
        return item
    
    def spawn_level_items(self):
        """Spawn items for the level"""
        # Needs (scattered in safe areas)
        needs_positions = [
            (200, 400, 'bread'),
            (400, 350, 'carrot'),
            (600, 400, 'coat'),
            (150, 350, 'medicine'),
            (500, 300, 'firewood'),
            (700, 350, 'blanket'),
        ]
        
        # Wants (tempting positions)
        wants_positions = [
            (300, 380, 'toy_sword'),
            (450, 380, 'candy'),
            (550, 350, 'crown'),
            (650, 300, 'painting'),
            (350, 300, 'music_box'),
            (250, 350, 'vase'),
        ]
        
        for x, y, item_type in needs_positions + wants_positions:
            self.spawn_item(x, y, item_type)
    
    def check_player_collision(self, player):
        """Check if player touches any items"""
        touched_items = pygame.sprite.spritecollide(player, self.items, False)
        return touched_items
    
    def update(self):
        """Update all items"""
        self.items.update()
    
    def draw(self, screen, camera_offset=(0, 0)):
        """Draw all items"""
        for item in self.items:
            screen.blit(item.image, 
                       (item.rect.x - camera_offset[0],
                        item.rect.y - camera_offset[1]))
    
    def collect_item(self, item):
        """Collect an item"""
        self.collected_items.append(item)
        item.collect()
    
    def get_needs_collected(self):
        """Count collected needs"""
        return sum(1 for item in self.collected_items if item.is_need)
    
    def get_wants_collected(self):
        """Count collected wants"""
        return sum(1 for item in self.collected_items if item.is_want)
