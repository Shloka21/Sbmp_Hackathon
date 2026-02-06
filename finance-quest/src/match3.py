"""
Match-3 Mini-Game for Finance Quest
Candy Crush style game to earn coins
"""
import pygame
import random
import os
from settings import SCREEN_WIDTH, SCREEN_HEIGHT, GEMS_PATH


class Gem(pygame.sprite.Sprite):
    """A gem in the match-3 grid"""
    
    COLORS = ['red', 'blue', 'green', 'yellow', 'purple']
    
    def __init__(self, row, col, gem_type, cell_size):
        super().__init__()
        self.row = row
        self.col = col
        self.gem_type = gem_type
        self.cell_size = cell_size
        
        # Position
        self.target_x = 0
        self.target_y = 0
        self.x = 0
        self.y = 0
        
        # Animation
        self.selected = False
        self.matched = False
        self.falling = False
        
        # Load image
        self.image = self.load_image()
        self.rect = self.image.get_rect()
    
    def load_image(self):
        """Load gem image"""
        path = os.path.join(GEMS_PATH, f"{self.gem_type}.png")
        if os.path.exists(path):
            img = pygame.image.load(path).convert_alpha()
            return pygame.transform.scale(img, (self.cell_size - 4, self.cell_size - 4))
        else:
            return self.create_placeholder()
    
    def create_placeholder(self):
        """Create placeholder gem"""
        colors = {
            'red': (220, 60, 60),
            'blue': (60, 100, 220),
            'green': (60, 180, 60),
            'yellow': (240, 200, 40),
            'purple': (160, 60, 200),
        }
        color = colors.get(self.gem_type, (200, 200, 200))
        
        size = self.cell_size - 4
        surface = pygame.Surface((size, size), pygame.SRCALPHA)
        pygame.draw.ellipse(surface, color, (2, 2, size-4, size-4))
        pygame.draw.ellipse(surface, (255, 255, 255, 100), (6, 6, size//3, size//3))
        
        return surface
    
    def update_position(self, grid_x, grid_y):
        """Update target position based on grid location"""
        self.target_x = grid_x + self.col * self.cell_size + 2
        self.target_y = grid_y + self.row * self.cell_size + 2
        
        if not self.falling:
            self.x = self.target_x
            self.y = self.target_y
        
        self.rect.x = self.x
        self.rect.y = self.y
    
    def animate(self, dt):
        """Animate gem movement"""
        speed = 500  # pixels per second
        
        # Move towards target
        dx = self.target_x - self.x
        dy = self.target_y - self.y
        
        if abs(dx) > 1:
            self.x += dx * min(1, speed * dt / abs(dx)) if dx else 0
        else:
            self.x = self.target_x
            
        if abs(dy) > 1:
            self.y += dy * min(1, speed * dt / abs(dy)) if dy else 0
        else:
            self.y = self.target_y
            self.falling = False
        
        self.rect.x = int(self.x)
        self.rect.y = int(self.y)
        
        return abs(dx) > 1 or abs(dy) > 1


class Match3Game:
    """Match-3 mini-game"""
    
    def __init__(self, screen, on_complete_callback):
        self.screen = screen
        self.on_complete = on_complete_callback
        
        # Grid settings
        self.rows = 8
        self.cols = 8
        self.cell_size = 50
        
        # Calculate grid position (centered)
        self.grid_width = self.cols * self.cell_size
        self.grid_height = self.rows * self.cell_size
        self.grid_x = (SCREEN_WIDTH - self.grid_width) // 2
        self.grid_y = (SCREEN_HEIGHT - self.grid_height) // 2 + 30
        
        # Game state
        self.grid = []
        self.selected = None
        self.swapping = False
        self.animating = False
        self.checking_matches = False
        
        # Score
        self.score = 0
        self.moves_left = 20
        self.target_score = 500
        self.coins_earned = 0
        
        # Initialize
        self.init_grid()
        
        # Fonts
        self.font_large = pygame.font.Font(None, 48)
        self.font_medium = pygame.font.Font(None, 32)
        self.font_small = pygame.font.Font(None, 24)
    
    def init_grid(self):
        """Initialize the grid with random gems"""
        self.grid = []
        for row in range(self.rows):
            grid_row = []
            for col in range(self.cols):
                gem_type = self.get_valid_gem(row, col)
                gem = Gem(row, col, gem_type, self.cell_size)
                gem.update_position(self.grid_x, self.grid_y)
                grid_row.append(gem)
            self.grid.append(grid_row)
    
    def get_valid_gem(self, row, col):
        """Get a gem type that doesn't create a match"""
        available = Gem.COLORS.copy()
        
        # Check horizontal
        if col >= 2:
            if (self.grid[row][col-1].gem_type == self.grid[row][col-2].gem_type):
                if self.grid[row][col-1].gem_type in available:
                    available.remove(self.grid[row][col-1].gem_type)
        
        # Check vertical
        if row >= 2:
            if (self.grid[row-1][col].gem_type == self.grid[row-2][col].gem_type):
                if self.grid[row-1][col].gem_type in available:
                    available.remove(self.grid[row-1][col].gem_type)
        
        return random.choice(available) if available else random.choice(Gem.COLORS)
    
    def handle_click(self, pos):
        """Handle mouse click"""
        if self.animating or self.moves_left <= 0:
            return
        
        # Check if click is in grid
        x, y = pos
        if not (self.grid_x <= x < self.grid_x + self.grid_width and
                self.grid_y <= y < self.grid_y + self.grid_height):
            return
        
        # Get clicked cell
        col = (x - self.grid_x) // self.cell_size
        row = (y - self.grid_y) // self.cell_size
        
        if 0 <= row < self.rows and 0 <= col < self.cols:
            self.select_gem(row, col)
    
    def select_gem(self, row, col):
        """Select a gem"""
        if self.selected is None:
            # First selection
            self.selected = (row, col)
            self.grid[row][col].selected = True
        else:
            # Second selection
            prev_row, prev_col = self.selected
            self.grid[prev_row][prev_col].selected = False
            
            # Check if adjacent
            if self.is_adjacent(prev_row, prev_col, row, col):
                self.swap_gems(prev_row, prev_col, row, col)
            else:
                # New selection
                self.selected = (row, col)
                self.grid[row][col].selected = True
                return
            
            self.selected = None
    
    def is_adjacent(self, r1, c1, r2, c2):
        """Check if two cells are adjacent"""
        return (abs(r1 - r2) == 1 and c1 == c2) or (abs(c1 - c2) == 1 and r1 == r2)
    
    def swap_gems(self, r1, c1, r2, c2):
        """Swap two gems"""
        # Swap in grid
        self.grid[r1][c1], self.grid[r2][c2] = self.grid[r2][c2], self.grid[r1][c1]
        
        # Update positions
        self.grid[r1][c1].row, self.grid[r1][c1].col = r1, c1
        self.grid[r2][c2].row, self.grid[r2][c2].col = r2, c2
        
        # Check for matches
        matches = self.find_matches()
        
        if matches:
            self.moves_left -= 1
            self.process_matches(matches)
        else:
            # Swap back
            self.grid[r1][c1], self.grid[r2][c2] = self.grid[r2][c2], self.grid[r1][c1]
            self.grid[r1][c1].row, self.grid[r1][c1].col = r1, c1
            self.grid[r2][c2].row, self.grid[r2][c2].col = r2, c2
    
    def find_matches(self):
        """Find all matches in the grid"""
        matches = set()
        
        # Horizontal matches
        for row in range(self.rows):
            for col in range(self.cols - 2):
                if (self.grid[row][col].gem_type == 
                    self.grid[row][col+1].gem_type ==
                    self.grid[row][col+2].gem_type):
                    matches.add((row, col))
                    matches.add((row, col+1))
                    matches.add((row, col+2))
        
        # Vertical matches
        for col in range(self.cols):
            for row in range(self.rows - 2):
                if (self.grid[row][col].gem_type ==
                    self.grid[row+1][col].gem_type ==
                    self.grid[row+2][col].gem_type):
                    matches.add((row, col))
                    matches.add((row+1, col))
                    matches.add((row+2, col))
        
        return matches
    
    def process_matches(self, matches):
        """Process matched gems"""
        # Mark as matched
        for row, col in matches:
            self.grid[row][col].matched = True
        
        # Add score
        points = len(matches) * 10
        if len(matches) > 3:
            points *= 2  # Bonus for larger matches
        self.score += points
        
        # Remove matched gems and drop
        self.remove_matched()
        self.drop_gems()
        self.fill_empty()
        
        # Check for chain reactions
        new_matches = self.find_matches()
        if new_matches:
            self.process_matches(new_matches)
    
    def remove_matched(self):
        """Remove matched gems from grid"""
        for row in range(self.rows):
            for col in range(self.cols):
                if self.grid[row][col].matched:
                    self.grid[row][col] = None
    
    def drop_gems(self):
        """Drop gems to fill empty spaces"""
        for col in range(self.cols):
            empty_row = self.rows - 1
            for row in range(self.rows - 1, -1, -1):
                if self.grid[row][col] is not None:
                    if row != empty_row:
                        self.grid[empty_row][col] = self.grid[row][col]
                        self.grid[row][col] = None
                        self.grid[empty_row][col].row = empty_row
                        self.grid[empty_row][col].falling = True
                    empty_row -= 1
    
    def fill_empty(self):
        """Fill empty spaces with new gems"""
        for col in range(self.cols):
            for row in range(self.rows):
                if self.grid[row][col] is None:
                    gem_type = random.choice(Gem.COLORS)
                    gem = Gem(row, col, gem_type, self.cell_size)
                    gem.x = self.grid_x + col * self.cell_size + 2
                    gem.y = self.grid_y - (self.rows - row) * self.cell_size
                    gem.falling = True
                    self.grid[row][col] = gem
    
    def update(self, dt):
        """Update game state"""
        # Update gem positions
        animating = False
        for row in self.grid:
            for gem in row:
                if gem:
                    gem.update_position(self.grid_x, self.grid_y)
                    if gem.animate(dt):
                        animating = True
        
        self.animating = animating
        
        # Check for auto-matches after animations
        if not animating and not self.checking_matches:
            matches = self.find_matches()
            if matches:
                self.process_matches(matches)
        
        # Check game completion
        if self.moves_left <= 0 and not animating:
            self.end_game()
    
    def end_game(self):
        """End the mini-game"""
        # Calculate coins earned
        self.coins_earned = self.score // 10
        if self.score >= self.target_score:
            self.coins_earned += 20  # Bonus
        
        # Callback
        if self.on_complete:
            self.on_complete(self.coins_earned)
    
    def draw(self):
        """Draw the game"""
        # Background
        self.screen.fill((40, 60, 80))
        
        # Title
        title = self.font_large.render("💎 GEM MATCH! 💎", True, (255, 215, 0))
        self.screen.blit(title, title.get_rect(centerx=SCREEN_WIDTH//2, top=10))
        
        # Instructions
        instr = self.font_small.render("Match 3 or more gems to earn coins!", True, (200, 200, 200))
        self.screen.blit(instr, instr.get_rect(centerx=SCREEN_WIDTH//2, top=50))
        
        # Grid background
        pygame.draw.rect(self.screen, (60, 80, 100),
                        (self.grid_x - 5, self.grid_y - 5,
                         self.grid_width + 10, self.grid_height + 10),
                        border_radius=10)
        
        # Grid cells
        for row in range(self.rows):
            for col in range(self.cols):
                x = self.grid_x + col * self.cell_size
                y = self.grid_y + row * self.cell_size
                color = (70, 90, 110) if (row + col) % 2 == 0 else (80, 100, 120)
                pygame.draw.rect(self.screen, color,
                               (x, y, self.cell_size, self.cell_size))
        
        # Draw gems
        for row in self.grid:
            for gem in row:
                if gem and not gem.matched:
                    self.screen.blit(gem.image, gem.rect)
                    if gem.selected:
                        pygame.draw.rect(self.screen, (255, 255, 0),
                                       (gem.rect.x - 2, gem.rect.y - 2,
                                        gem.rect.width + 4, gem.rect.height + 4), 3)
        
        # Score panel
        panel_y = self.grid_y + self.grid_height + 20
        
        # Score
        score_text = self.font_medium.render(f"Score: {self.score}", True, (255, 255, 255))
        self.screen.blit(score_text, (self.grid_x, panel_y))
        
        # Target
        target_color = (100, 255, 100) if self.score >= self.target_score else (255, 200, 100)
        target_text = self.font_medium.render(f"Target: {self.target_score}", True, target_color)
        self.screen.blit(target_text, (self.grid_x + 200, panel_y))
        
        # Moves
        moves_color = (255, 100, 100) if self.moves_left < 5 else (255, 255, 255)
        moves_text = self.font_medium.render(f"Moves: {self.moves_left}", True, moves_color)
        self.screen.blit(moves_text, (self.grid_x + 350, panel_y))
        
        # Progress bar
        bar_width = self.grid_width
        bar_height = 20
        bar_y = panel_y + 40
        
        pygame.draw.rect(self.screen, (40, 40, 40),
                        (self.grid_x, bar_y, bar_width, bar_height), border_radius=5)
        
        progress = min(1.0, self.score / self.target_score)
        fill_width = int(bar_width * progress)
        if fill_width > 0:
            pygame.draw.rect(self.screen, (100, 200, 100),
                           (self.grid_x, bar_y, fill_width, bar_height), border_radius=5)
        
        pygame.draw.rect(self.screen, (100, 100, 100),
                        (self.grid_x, bar_y, bar_width, bar_height), 2, border_radius=5)
