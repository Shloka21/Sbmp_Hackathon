"""
Camera system for Finance Quest
Handles smooth camera following and boundaries
"""
from settings import SCREEN_WIDTH, SCREEN_HEIGHT, TILE_SIZE


class Camera:
    """Camera that follows the player"""
    
    def __init__(self, world_width, world_height):
        self.offset_x = 0
        self.offset_y = 0
        self.world_width = world_width
        self.world_height = world_height
        
        # Smoothing
        self.lerp_speed = 0.1
        self.target_x = 0
        self.target_y = 0
        
        # Dead zone (area where camera doesn't move)
        self.dead_zone_x = SCREEN_WIDTH // 4
        self.dead_zone_y = SCREEN_HEIGHT // 4
    
    def update(self, target):
        """Update camera to follow target (player)"""
        # Calculate where camera should be
        target_center_x = target.rect.centerx
        target_center_y = target.rect.centery
        
        # Target camera position (center player on screen)
        self.target_x = target_center_x - SCREEN_WIDTH // 2
        self.target_y = target_center_y - SCREEN_HEIGHT // 2
        
        # Smooth interpolation
        self.offset_x += (self.target_x - self.offset_x) * self.lerp_speed
        self.offset_y += (self.target_y - self.offset_y) * self.lerp_speed
        
        # Clamp to world boundaries
        self.offset_x = max(0, min(self.offset_x, self.world_width - SCREEN_WIDTH))
        self.offset_y = max(0, min(self.offset_y, self.world_height - SCREEN_HEIGHT))
        
        # If world is smaller than screen, center it
        if self.world_width < SCREEN_WIDTH:
            self.offset_x = (self.world_width - SCREEN_WIDTH) // 2
        if self.world_height < SCREEN_HEIGHT:
            self.offset_y = (self.world_height - SCREEN_HEIGHT) // 2
    
    def apply(self, rect):
        """Apply camera offset to a rect, returning screen position"""
        return rect.move(-int(self.offset_x), -int(self.offset_y))
    
    def get_offset(self):
        """Get current camera offset as tuple"""
        return (int(self.offset_x), int(self.offset_y))
    
    def set_world_size(self, width, height):
        """Update world size"""
        self.world_width = width * TILE_SIZE
        self.world_height = height * TILE_SIZE
    
    def shake(self, intensity=5, duration=10):
        """Camera shake effect (for feedback)"""
        import random
        self.offset_x += random.randint(-intensity, intensity)
        self.offset_y += random.randint(-intensity, intensity)
