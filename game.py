"""
Alex: Needs vs Wants - Educational Game
Enhanced UI Version
"""
import pygame
import sys
import random
import math

# Initialize Pygame
pygame.init()

# ------------------ CONFIGURATION ------------------
SCREEN_WIDTH, SCREEN_HEIGHT = 1024, 768
SCREEN = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Alex's Finance Quest: Needs vs Wants")
CLOCK = pygame.time.Clock()

# Color Palette (Modern & Accessible)
COLORS = {
    'bg': (245, 247, 250),           # Off-white background
    'panel_bg': (255, 255, 255),     # White panels
    'text_dark': (45, 55, 72),       # Dark slate for text
    'text_light': (113, 128, 150),   # Grey for subtitles
    'accent_green': (72, 187, 120),  # Success/Needs
    'accent_red': (245, 101, 101),   # Danger/Wants
    'accent_blue': (66, 153, 225),   # Action/Eat
    'accent_gold': (236, 201, 75),   # XP/Day
    'primary': (85, 60, 154),        # Purple for main elements
    'overlay': (0, 0, 0, 180),       # Dark overlay for modals
}

# Fonts
def get_font(size, bold=False):
    return pygame.font.SysFont("arial", size, bold=bold)

FONTS = {
    'h1': get_font(64, True),
    'h2': get_font(48, True),
    'h3': get_font(32, True),
    'body': get_font(24),
    'small': get_font(18),
}

# ------------------ UI CLASSES ------------------
class Button:
    def __init__(self, text, x, y, w, h, base_color, hover_color, action_key=None):
        self.rect = pygame.Rect(x, y, w, h)
        self.text = text
        self.base_color = base_color
        self.hover_color = hover_color
        self.current_color = base_color
        self.is_hovered = False
        self.action_key = action_key
        self.scale = 1.0

    def start_hover(self):
        if not self.is_hovered:
            self.is_hovered = True
            # Optional: Add scale effect logic here
            
    def end_hover(self):
        self.is_hovered = False

    def draw(self, surface):
        # Update color
        target_color = self.hover_color if self.is_hovered else self.base_color
        
        # Draw shadow
        shadow_rect = self.rect.copy()
        shadow_rect.y += 4
        pygame.draw.rect(surface, (0, 0, 0, 30), shadow_rect, border_radius=12)
        
        # Draw button
        pygame.draw.rect(surface, target_color, self.rect, border_radius=12)
        
        # Draw text
        text_surf = FONTS['body'].render(self.text, True, (255, 255, 255))
        text_rect = text_surf.get_rect(center=self.rect.center)
        surface.blit(text_surf, text_rect)
        
        # Draw white border
        pygame.draw.rect(surface, (255, 255, 255, 50), self.rect, 2, border_radius=12)

    def is_clicked(self, pos):
        return self.rect.collidepoint(pos)

class FloatingText:
    def __init__(self, text, x, y, color):
        self.text = text
        self.x = x
        self.y = y
        self.color = color
        self.life = 60  # Frames to live
        self.visible = True
        
    def update(self):
        self.y -= 1  # Float up
        self.life -= 1
        if self.life <= 0:
            self.visible = False
            
    def draw(self, surface):
        if self.visible:
            alpha = min(255, self.life * 5)
            surf = FONTS['body'].render(self.text, True, self.color)
            surf.set_alpha(alpha)
            surface.blit(surf, (self.x, self.y))

# ------------------ GAME ENGINE ------------------
class Game:
    def __init__(self):
        # Game State
        self.reset()
        
        # Floating texts
        self.particles = []
        
        # UI Elements
        self.setup_ui()

    def reset(self):
        self.hearts = 3
        self.day = 1
        self.xp = 0
        self.needs_completed = False
        self.ate_food = False
        self.game_state = "MENU"  # MENU, PLAYING, WON, GAME_OVER
        self.needs = ["Rice", "Vegetables", "School Books"]
        self.wants = ["Video Game", "Ice Cream", "New Toy"]

    def setup_ui(self):
        # Layout metrics
        cx = SCREEN_WIDTH // 2
        cy = SCREEN_HEIGHT // 2
        
        # Buttons
        btn_w, btn_h = 220, 60
        
        # Actions configuration
        self.btn_buy_needs = Button("Buy Needs ($15)", cx - 300, 450, btn_w, btn_h, COLORS['accent_green'], (85, 200, 130))
        self.btn_eat_food = Button("Eat Healthy Food", cx - 50, 450, btn_w + 100, btn_h, COLORS['accent_blue'], (90, 170, 240))
        self.btn_buy_wants = Button("Buy Wants ($30)", cx + 180, 450, btn_w, btn_h, COLORS['accent_red'], (255, 120, 120))
        
        self.btn_next_day = Button("End Day >>", cx - 110, 600, 220, 70, COLORS['accent_gold'], (250, 220, 100))
        
        self.btn_start = Button("START GAME", cx - 125, cy + 50, 250, 80, COLORS['primary'], (100, 80, 180))
        self.btn_restart = Button("PLAY AGAIN", cx - 125, cy + 100, 250, 80, COLORS['primary'], (100, 80, 180))

    def update(self):
        mouse_pos = pygame.mouse.get_pos()
        
        # Handle Hover States
        for btn in [self.btn_buy_needs, self.btn_eat_food, self.btn_buy_wants, self.btn_next_day, self.btn_start, self.btn_restart]:
            if btn.is_clicked(mouse_pos):
                btn.start_hover()
            else:
                btn.end_hover()
                
        # Update particles
        for p in self.particles[:]:
            p.update()
            if not p.visible:
                self.particles.remove(p)

    def draw_particle(self, text, pos, color):
        self.particles.append(FloatingText(text, pos[0], pos[1], color))

    def handle_event(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            pos = pygame.mouse.get_pos()
            
            if self.game_state == "MENU":
                if self.btn_start.is_clicked(pos):
                    self.game_state = "PLAYING"
                    
            elif self.game_state == "PLAYING":
                # Buy Needs
                if self.btn_buy_needs.is_clicked(pos):
                    if not self.needs_completed:
                        self.needs_completed = True
                        self.xp += 20
                        self.draw_particle("+20 XP", pos, COLORS['accent_green'])
                        self.draw_particle("Needs Met!", (pos[0], pos[1]-30), COLORS['accent_green'])
                    else:
                        self.draw_particle("Already Bought!", pos, COLORS['text_dark'])

                # Buy Wants
                elif self.btn_buy_wants.is_clicked(pos):
                    self.hearts = max(0, self.hearts - 1)
                    self.xp += 5
                    self.draw_particle("-1 Heart", pos, COLORS['accent_red'])
                    self.draw_particle("+5 XP (Fun)", (pos[0], pos[1]-30), COLORS['accent_gold'])
                    if self.hearts <= 0:
                        self.game_state = "GAME_OVER"

                # Eat Food
                elif self.btn_eat_food.is_clicked(pos):
                    if not self.ate_food:
                        self.ate_food = True
                        self.xp += 10
                        self.draw_particle("+10 XP", pos, COLORS['accent_blue'])
                        self.draw_particle("Yummy!", (pos[0], pos[1]-30), COLORS['accent_blue'])
                    else:
                        self.draw_particle("Full Already!", pos, COLORS['text_dark'])

                # Next Day
                elif self.btn_next_day.is_clicked(pos):
                    self.process_next_day(pos)

            elif self.game_state in ["GAME_OVER", "WON"]:
                if self.btn_restart.is_clicked(pos):
                    self.reset()
                    self.game_state = "PLAYING"

    def process_next_day(self, pos):
        penalties = []
        if not self.needs_completed:
            self.hearts -= 1
            penalties.append("Needs Not Met!")
        if not self.ate_food:
            self.hearts -= 1
            penalties.append("Hungry!")
            
        if self.hearts <= 0:
            self.game_state = "GAME_OVER"
            return
            
        if penalties:
            for i, p in enumerate(penalties):
                self.draw_particle(f"-1 Heart: {p}", (pos[0], pos[1] - 30 * i), COLORS['accent_red'])
        else:
            self.draw_particle("Perfect Day! +50 XP", pos, COLORS['accent_gold'])
            self.xp += 50
            
        self.day += 1
        self.needs_completed = False
        self.ate_food = False
        
        if self.day > 3:
            self.game_state = "WON"

    def draw(self):
        SCREEN.fill(COLORS['bg'])

        if self.game_state == "MENU":
            self.draw_menu()
        elif self.game_state == "PLAYING":
            self.draw_game()
        elif self.game_state == "GAME_OVER":
            self.draw_game_overlay("GAME OVER", "You lost all your health! Prioritize Needs!", COLORS['accent_red'])
        elif self.game_state == "WON":
            self.draw_game_overlay("YOU WIN!", f"Great Job! Final XP: {self.xp}", COLORS['accent_green'])

        # Draw particles on top of everything
        for p in self.particles:
            p.draw(SCREEN)

        pygame.display.flip()

    def draw_menu(self):
        # Background pattern (simple grid)
        self.draw_grid_bg()
        
        # Title Card
        title = FONTS['h1'].render("ALEX'S FINANCE QUEST", True, COLORS['primary'])
        subtitle = FONTS['h3'].render("Learn Needs vs Wants", True, COLORS['text_light'])
        
        t_rect = title.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT//2 - 120))
        s_rect = subtitle.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT//2 - 60))
        
        SCREEN.blit(title, t_rect)
        SCREEN.blit(subtitle, s_rect)
        
        self.btn_start.draw(SCREEN)
        
        # Credits
        footer = FONTS['small'].render("Created by Finance Quest Team", True, (150, 150, 150))
        SCREEN.blit(footer, footer.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT - 30)))

    def draw_grid_bg(self):
        for x in range(0, SCREEN_WIDTH, 40):
            pygame.draw.line(SCREEN, (230, 230, 230), (x, 0), (x, SCREEN_HEIGHT))
        for y in range(0, SCREEN_HEIGHT, 40):
            pygame.draw.line(SCREEN, (230, 230, 230), (0, y), (SCREEN_WIDTH, y))

    def draw_game(self):
        # 1. Header Bar
        pygame.draw.rect(SCREEN, COLORS['panel_bg'], (0, 0, SCREEN_WIDTH, 100))
        pygame.draw.line(SCREEN, (220, 220, 220), (0, 100), (SCREEN_WIDTH, 100), 2)
        
        # Day Indicator
        day_surf = FONTS['h2'].render(f"Day {self.day}", True, COLORS['text_dark'])
        SCREEN.blit(day_surf, (40, 25))
        
        # Stats layout
        stats_x = SCREEN_WIDTH - 300
        
        # Hearts
        heart_txt = "❤️ " * self.hearts + "🖤 " * (3 - self.hearts)
        hearts_surf = FONTS['h3'].render(heart_txt, True, COLORS['accent_red'])
        SCREEN.blit(hearts_surf, (stats_x, 30))
        
        # XP
        xp_bg = pygame.Rect(stats_x - 120, 30, 100, 40)
        pygame.draw.rect(SCREEN, (240, 240, 240), xp_bg, border_radius=8)
        xp_surf = FONTS['body'].render(f"XP: {self.xp}", True, COLORS['text_dark'])
        SCREEN.blit(xp_surf, (stats_x - 110, 35))

        # 2. Main Content Area
        cx = SCREEN_WIDTH // 2
        
        # Needs Column (Left)
        self.draw_panel("NEEDS (Must Have)", self.needs, 150, 180, COLORS['accent_green'], self.needs_completed)
        
        # Wants Column (Right)
        self.draw_panel("WANTS (Nice to Have)", self.wants, 600, 180, COLORS['accent_red'], False)
        
        # Status Badges vertical center
        if self.ate_food:
            self.draw_badge("Fed & Healthy", (cx, 380), COLORS['accent_blue'])
        else:
            self.draw_badge("Still Hungry!", (cx, 380), COLORS['accent_red'])

        # 3. Action Bar
        self.btn_buy_needs.draw(SCREEN)
        self.btn_buy_wants.draw(SCREEN)
        self.btn_eat_food.draw(SCREEN)
        self.btn_next_day.draw(SCREEN)

    def draw_panel(self, title, items, x, y, accent_color, is_completed):
        w, h = 300, 200
        rect = pygame.Rect(x, y, w, h)
        
        # Panel Background
        pygame.draw.rect(SCREEN, COLORS['panel_bg'], rect, border_radius=15)
        
        # Header strip
        header_rect = pygame.Rect(x, y, w, 50)
        pygame.draw.rect(SCREEN, accent_color, header_rect, border_top_left_radius=15, border_top_right_radius=15)
        
        title_surf = FONTS['body'].render(title, True, (255, 255, 255))
        SCREEN.blit(title_surf, (x + 20, y + 10))
        
        # Shadow
        pygame.draw.rect(SCREEN, (0,0,0,10), (x+5, y+5, w, h), border_radius=15)
        
        # Border
        if is_completed:
            pygame.draw.rect(SCREEN, accent_color, rect, 3, border_radius=15)
            # Checkmark overlay
            check_surf = FONTS['h1'].render("DONE", True, (0, 0, 0))
            check_surf.set_alpha(30)
            SCREEN.blit(check_surf, (x + 80, y + 80))
        
        # Items
        for i, item in enumerate(items):
            bullet = "✓" if is_completed else "•"
            txt = FONTS['body'].render(f"{bullet} {item}", True, COLORS['text_dark'])
            SCREEN.blit(txt, (x + 30, y + 70 + i * 40))

    def draw_badge(self, text, center, color):
        font = FONTS['body']
        surf = font.render(text, True, (255, 255, 255))
        rect = surf.get_rect(center=center)
        padding = 20
        bg_rect = rect.inflate(padding, padding)
        
        pygame.draw.rect(SCREEN, color, bg_rect, border_radius=20)
        SCREEN.blit(surf, rect)

    def draw_game_overlay(self, title_text, sub_text, color):
        # Draw game behind it first
        self.draw_game()
        
        # Overlay
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
        overlay.set_alpha(200)
        overlay.fill((255, 255, 255))
        SCREEN.blit(overlay, (0, 0))
        
        # Content box
        cx, cy = SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2
        
        # Title
        t_surf = FONTS['h1'].render(title_text, True, color)
        t_rect = t_surf.get_rect(center=(cx, cy - 50))
        SCREEN.blit(t_surf, t_rect)
        
        # Subtitle
        s_surf = FONTS['h3'].render(sub_text, True, COLORS['text_dark'])
        s_rect = s_surf.get_rect(center=(cx, cy + 20))
        SCREEN.blit(s_surf, s_rect)
        
        # Button
        self.btn_restart.draw(SCREEN)

# Main Loop
game = Game()

while True:
    game.update()
    game.draw()
    
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        game.handle_event(event)
        
    CLOCK.tick(60)
