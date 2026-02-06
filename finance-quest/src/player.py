"""
Player class for Finance Quest
Handles player movement, animation, and interactions
"""
import pygame
import os
from settings import (
    TILE_SIZE, GRAVITY, JUMP_STRENGTH, PLAYER_SPEED, 
    MAX_FALL_SPEED, PLAYER_PATH
)


class Player(pygame.sprite.Sprite):
    def __init__(self, x, y):
        super().__init__()
        
        # Load sprites
        self.animations = self.load_animations()
        self.current_animation = 'idle_right'
        self.animation_frame = 0
        self.animation_speed = 0.15
        
        # Set initial image
        self.image = self.animations[self.current_animation][0]
        self.rect = self.image.get_rect()
        self.rect.x = x
        self.rect.y = y
        
        # Movement
        self.velocity_x = 0
        self.velocity_y = 0
        self.on_ground = False
        self.facing_right = True
        
        # State
        self.is_jumping = False
        self.is_crouching = False
        
    def load_animations(self):
        """Load all player animation sprites"""
        animations = {
            'idle_right': [],
            'idle_left': [],
            'walk_right': [],
            'walk_left': [],
            'jump': []
        }
        
        # Try to load sprites, create placeholder if not found
        sprite_files = {
            'idle_right': ['idle_right.png'],
            'idle_left': ['idle_left.png'],
            'walk_right': ['walk_right_1.png', 'walk_right_2.png'],
            'walk_left': ['walk_right_1.png', 'walk_right_2.png'],  # Will flip
            'jump': ['jump.png']
        }
        
        for anim_name, files in sprite_files.items():
            for file in files:
                path = os.path.join(PLAYER_PATH, file)
                if os.path.exists(path):
                    img = pygame.image.load(path).convert_alpha()
                    img = pygame.transform.scale(img, (TILE_SIZE, TILE_SIZE))
                    
                    # Flip for left-facing animations
                    if 'left' in anim_name and 'idle' not in anim_name:
                        img = pygame.transform.flip(img, True, False)
                    
                    animations[anim_name].append(img)
                else:
                    # Create placeholder sprite
                    animations[anim_name].append(self.create_placeholder())
        
        # Ensure at least one frame per animation
        for anim_name, frames in animations.items():
            if not frames:
                animations[anim_name] = [self.create_placeholder()]
        
        return animations
    
    def create_placeholder(self):
        """Create a placeholder sprite if file not found"""
        surface = pygame.Surface((TILE_SIZE, TILE_SIZE), pygame.SRCALPHA)
        
        # Body (blue)
        pygame.draw.rect(surface, (70, 130, 180), (10, 12, 12, 12))
        
        # Head (skin)
        pygame.draw.ellipse(surface, (255, 200, 150), (9, 2, 14, 12))
        
        # Hair (brown)
        pygame.draw.ellipse(surface, (101, 67, 33), (9, 1, 14, 7))
        
        # Eyes
        pygame.draw.circle(surface, (50, 50, 50), (17, 7), 1)
        pygame.draw.circle(surface, (50, 50, 50), (19, 7), 1)
        
        # Legs (brown)
        pygame.draw.rect(surface, (139, 90, 43), (10, 22, 5, 8))
        pygame.draw.rect(surface, (139, 90, 43), (17, 22, 5, 8))
        
        return surface
    
    def handle_input(self, keys):
        """Handle keyboard input for movement"""
        self.velocity_x = 0
        
        # Left/Right movement
        if keys[pygame.K_LEFT] or keys[pygame.K_a]:
            self.velocity_x = -PLAYER_SPEED
            self.facing_right = False
        elif keys[pygame.K_RIGHT] or keys[pygame.K_d]:
            self.velocity_x = PLAYER_SPEED
            self.facing_right = True
        
        # Jump
        if (keys[pygame.K_UP] or keys[pygame.K_w] or keys[pygame.K_SPACE]) and self.on_ground:
            self.velocity_y = JUMP_STRENGTH
            self.is_jumping = True
            self.on_ground = False
        
        # Crouch
        self.is_crouching = keys[pygame.K_DOWN] or keys[pygame.K_s]
    
    def apply_gravity(self):
        """Apply gravity to vertical movement"""
        self.velocity_y += GRAVITY
        if self.velocity_y > MAX_FALL_SPEED:
            self.velocity_y = MAX_FALL_SPEED
    
    def update_animation(self):
        """Update current animation based on state"""
        if not self.on_ground:
            new_animation = 'jump'
        elif self.velocity_x != 0:
            new_animation = 'walk_right' if self.facing_right else 'walk_left'
        else:
            new_animation = 'idle_right' if self.facing_right else 'idle_left'
        
        if new_animation != self.current_animation:
            self.current_animation = new_animation
            self.animation_frame = 0
        
        # Advance animation frame
        self.animation_frame += self.animation_speed
        frames = self.animations[self.current_animation]
        if self.animation_frame >= len(frames):
            self.animation_frame = 0
        
        self.image = frames[int(self.animation_frame)]
    
    def move(self, tiles):
        """Move player and handle collisions"""
        # Horizontal movement
        self.rect.x += self.velocity_x
        self.check_collision_horizontal(tiles)
        
        # Vertical movement
        self.apply_gravity()
        self.rect.y += self.velocity_y
        self.check_collision_vertical(tiles)
        
        # Update animation
        self.update_animation()
    
    def check_collision_horizontal(self, tiles):
        """Check and resolve horizontal collisions"""
        for tile in tiles:
            if self.rect.colliderect(tile.rect):
                if self.velocity_x > 0:  # Moving right
                    self.rect.right = tile.rect.left
                elif self.velocity_x < 0:  # Moving left
                    self.rect.left = tile.rect.right
    
    def check_collision_vertical(self, tiles):
        """Check and resolve vertical collisions"""
        self.on_ground = False
        
        for tile in tiles:
            if self.rect.colliderect(tile.rect):
                if self.velocity_y > 0:  # Falling
                    self.rect.bottom = tile.rect.top
                    self.velocity_y = 0
                    self.on_ground = True
                    self.is_jumping = False
                elif self.velocity_y < 0:  # Jumping up
                    self.rect.top = tile.rect.bottom
                    self.velocity_y = 0
    
    def update(self, keys, tiles):
        """Main update method"""
        self.handle_input(keys)
        self.move(tiles)
