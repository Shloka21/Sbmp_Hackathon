"""
UI system for Finance Quest
Handles HUD, inventory, dialogue boxes, menus
"""
import pygame
import os
from settings import (
    SCREEN_WIDTH, SCREEN_HEIGHT, UI_PATH, TILE_SIZE,
    WHITE, BLACK, GOLD, RED, PANEL_BG, PANEL_BORDER
)


class UI:
    """Game UI manager"""
    
    def __init__(self, screen):
        self.screen = screen
        self.font_large = None
        self.font_medium = None
        self.font_small = None
        self.ui_images = {}
        
        self.init_fonts()
        self.load_ui_images()
        
        # Inventory
        self.inventory_slots = 6
        self.inventory_visible = False
        self.selected_slot = 0
    
    def init_fonts(self):
        """Initialize fonts"""
        pygame.font.init()
        try:
            self.font_large = pygame.font.Font(None, 48)
            self.font_medium = pygame.font.Font(None, 32)
            self.font_small = pygame.font.Font(None, 24)
        except:
            self.font_large = pygame.font.SysFont('arial', 36)
            self.font_medium = pygame.font.SysFont('arial', 24)
            self.font_small = pygame.font.SysFont('arial', 18)
    
    def load_ui_images(self):
        """Load UI images"""
        ui_files = [
            'heart', 'heart_empty', 'star', 'coin',
            'inventory_slot', 'inventory_slot_selected',
            'button', 'button_hover', 'dialog_box',
            'medal_gold', 'medal_silver', 'medal_bronze'
        ]
        
        for name in ui_files:
            path = os.path.join(UI_PATH, f"{name}.png")
            if os.path.exists(path):
                self.ui_images[name] = pygame.image.load(path).convert_alpha()
            else:
                self.ui_images[name] = self.create_ui_placeholder(name)
    
    def create_ui_placeholder(self, name):
        """Create placeholder UI element"""
        if 'heart' in name:
            surface = pygame.Surface((16, 16), pygame.SRCALPHA)
            color = RED if 'empty' not in name else (100, 100, 100)
            pygame.draw.polygon(surface, color, 
                              [(8, 14), (2, 6), (4, 2), (8, 4), (12, 2), (14, 6)])
            return surface
        
        elif 'star' in name:
            surface = pygame.Surface((24, 24), pygame.SRCALPHA)
            pygame.draw.polygon(surface, GOLD,
                              [(12, 2), (14, 9), (22, 9), (16, 14), (18, 22), 
                               (12, 17), (6, 22), (8, 14), (2, 9), (10, 9)])
            return surface
        
        elif 'coin' in name:
            surface = pygame.Surface((20, 20), pygame.SRCALPHA)
            pygame.draw.circle(surface, GOLD, (10, 10), 9)
            pygame.draw.circle(surface, (200, 160, 0), (10, 10), 6)
            return surface
        
        elif 'slot' in name:
            surface = pygame.Surface((36, 36), pygame.SRCALPHA)
            color = GOLD if 'selected' in name else PANEL_BORDER
            pygame.draw.rect(surface, PANEL_BG, (0, 0, 36, 36))
            pygame.draw.rect(surface, color, (0, 0, 36, 36), 2)
            return surface
        
        elif 'button' in name:
            surface = pygame.Surface((150, 40), pygame.SRCALPHA)
            color = GOLD if 'hover' in name else PANEL_BORDER
            pygame.draw.rect(surface, PANEL_BG, (0, 0, 150, 40), border_radius=5)
            pygame.draw.rect(surface, color, (0, 0, 150, 40), 2, border_radius=5)
            return surface
        
        elif 'dialog' in name:
            surface = pygame.Surface((400, 100), pygame.SRCALPHA)
            pygame.draw.rect(surface, PANEL_BG, (0, 0, 400, 100), border_radius=8)
            pygame.draw.rect(surface, PANEL_BORDER, (0, 0, 400, 100), 3, border_radius=8)
            return surface
        
        elif 'medal' in name:
            surface = pygame.Surface((24, 24), pygame.SRCALPHA)
            colors = {'gold': GOLD, 'silver': (192, 192, 192), 'bronze': (205, 127, 50)}
            color = colors.get(name.split('_')[-1], GOLD)
            pygame.draw.circle(surface, color, (12, 14), 8)
            return surface
        
        return pygame.Surface((32, 32), pygame.SRCALPHA)
    
    def draw_hud(self, economy):
        """Draw the main HUD (coins, health, XP)"""
        # Coins display (top left)
        coin_img = self.ui_images.get('coin')
        if coin_img:
            self.screen.blit(coin_img, (10, 10))
        
        coins_text = self.font_medium.render(f"{economy.coins}", True, GOLD)
        self.screen.blit(coins_text, (35, 12))
        
        # Health display (top left, below coins)
        heart_full = self.ui_images.get('heart')
        heart_empty = self.ui_images.get('heart_empty')
        
        for i in range(economy.max_health):
            heart = heart_full if i < economy.health else heart_empty
            if heart:
                self.screen.blit(heart, (10 + i * 20, 45))
        
        # XP bar (top center)
        self.draw_xp_bar(economy)
        
        # Level display
        level_text = self.font_small.render(
            f"Lv.{economy.level} - {economy.get_level_title()}", True, WHITE)
        text_rect = level_text.get_rect(center=(SCREEN_WIDTH // 2, 55))
        self.screen.blit(level_text, text_rect)
    
    def draw_xp_bar(self, economy):
        """Draw XP progress bar"""
        bar_width = 200
        bar_height = 20
        bar_x = (SCREEN_WIDTH - bar_width) // 2
        bar_y = 10
        
        # Background
        pygame.draw.rect(self.screen, (40, 40, 40), 
                        (bar_x, bar_y, bar_width, bar_height), border_radius=5)
        
        # Fill
        progress = economy.get_xp_progress()
        fill_width = int(bar_width * progress)
        if fill_width > 0:
            pygame.draw.rect(self.screen, (70, 130, 200), 
                           (bar_x, bar_y, fill_width, bar_height), border_radius=5)
        
        # Border
        pygame.draw.rect(self.screen, PANEL_BORDER, 
                        (bar_x, bar_y, bar_width, bar_height), 2, border_radius=5)
        
        # XP text
        xp_text = self.font_small.render(f"XP: {economy.xp}", True, WHITE)
        text_rect = xp_text.get_rect(center=(bar_x + bar_width // 2, bar_y + bar_height // 2))
        self.screen.blit(xp_text, text_rect)
        
        # Star icon
        star = self.ui_images.get('star')
        if star:
            star_small = pygame.transform.scale(star, (16, 16))
            self.screen.blit(star_small, (bar_x - 20, bar_y + 2))
    
    def draw_dialogue_box(self, npc_name, text):
        """Draw dialogue box with NPC text"""
        box_width = SCREEN_WIDTH - 100
        box_height = 120
        box_x = 50
        box_y = SCREEN_HEIGHT - box_height - 20
        
        # Background
        pygame.draw.rect(self.screen, PANEL_BG, 
                        (box_x, box_y, box_width, box_height), border_radius=10)
        pygame.draw.rect(self.screen, PANEL_BORDER, 
                        (box_x, box_y, box_width, box_height), 3, border_radius=10)
        
        # NPC name
        name_text = self.font_medium.render(npc_name, True, GOLD)
        self.screen.blit(name_text, (box_x + 15, box_y + 10))
        
        # Dialogue text (word wrapped)
        self.draw_wrapped_text(text, box_x + 15, box_y + 45, box_width - 30)
        
        # Continue indicator
        continue_text = self.font_small.render("Press E to continue...", True, (180, 180, 180))
        self.screen.blit(continue_text, (box_x + box_width - 180, box_y + box_height - 25))
    
    def draw_wrapped_text(self, text, x, y, max_width):
        """Draw text with word wrapping"""
        words = text.split()
        lines = []
        current_line = []
        
        for word in words:
            test_line = ' '.join(current_line + [word])
            if self.font_medium.size(test_line)[0] <= max_width:
                current_line.append(word)
            else:
                if current_line:
                    lines.append(' '.join(current_line))
                current_line = [word]
        
        if current_line:
            lines.append(' '.join(current_line))
        
        for i, line in enumerate(lines):
            text_surface = self.font_medium.render(line, True, WHITE)
            self.screen.blit(text_surface, (x, y + i * 28))
    
    def draw_inventory(self, items):
        """Draw inventory bar at bottom"""
        slot_size = 40
        total_width = self.inventory_slots * (slot_size + 5)
        start_x = (SCREEN_WIDTH - total_width) // 2
        y = SCREEN_HEIGHT - slot_size - 10
        
        for i in range(self.inventory_slots):
            # Draw slot
            if i == self.selected_slot:
                slot_img = self.ui_images.get('inventory_slot_selected')
            else:
                slot_img = self.ui_images.get('inventory_slot')
            
            x = start_x + i * (slot_size + 5)
            
            if slot_img:
                scaled = pygame.transform.scale(slot_img, (slot_size, slot_size))
                self.screen.blit(scaled, (x, y))
            else:
                pygame.draw.rect(self.screen, PANEL_BG, (x, y, slot_size, slot_size))
                pygame.draw.rect(self.screen, PANEL_BORDER, (x, y, slot_size, slot_size), 2)
            
            # Draw item in slot
            if i < len(items):
                item = items[i]
                item_img = pygame.transform.scale(item.image, (32, 32))
                self.screen.blit(item_img, (x + 4, y + 4))
    
    def draw_interaction_prompt(self, text):
        """Draw interaction prompt above player"""
        prompt = self.font_small.render(text, True, WHITE)
        bg_rect = prompt.get_rect()
        bg_rect.centerx = SCREEN_WIDTH // 2
        bg_rect.bottom = SCREEN_HEIGHT - 80
        
        # Background
        padding = 10
        pygame.draw.rect(self.screen, PANEL_BG,
                        (bg_rect.x - padding, bg_rect.y - padding // 2,
                         bg_rect.width + padding * 2, bg_rect.height + padding),
                        border_radius=5)
        
        self.screen.blit(prompt, bg_rect)
    
    def draw_item_popup(self, item):
        """Draw popup when near item"""
        popup_width = 200
        popup_height = 80
        popup_x = (SCREEN_WIDTH - popup_width) // 2
        popup_y = SCREEN_HEIGHT - 200
        
        # Background
        pygame.draw.rect(self.screen, PANEL_BG,
                        (popup_x, popup_y, popup_width, popup_height),
                        border_radius=8)
        pygame.draw.rect(self.screen, PANEL_BORDER,
                        (popup_x, popup_y, popup_width, popup_height), 2,
                        border_radius=8)
        
        # Item name
        name = item.item_type.replace('_', ' ').title()
        name_text = self.font_medium.render(name, True, WHITE)
        self.screen.blit(name_text, (popup_x + 10, popup_y + 10))
        
        # Price
        price_text = self.font_small.render(f"Price: {item.price} coins", True, GOLD)
        self.screen.blit(price_text, (popup_x + 10, popup_y + 40))
        
        # Type indicator
        type_color = (50, 180, 50) if item.is_need else (180, 50, 50)
        type_str = "NEED" if item.is_need else "WANT"
        type_text = self.font_small.render(type_str, True, type_color)
        self.screen.blit(type_text, (popup_x + popup_width - 60, popup_y + 10))
    
    def draw_game_over(self, economy):
        """Draw game over / ending screen"""
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 180))
        self.screen.blit(overlay, (0, 0))
        
        ending = economy.get_ending_type()
        
        titles = {
            'perfect': "PERFECT! You're a Finance Champion!",
            'good': "GOOD JOB! You survived winter!",
            'warning': "ALMOST... Winter was tough.",
            'failure': "OH NO! You forgot the essentials!"
        }
        
        title_colors = {
            'perfect': GOLD,
            'good': (100, 200, 100),
            'warning': (255, 200, 0),
            'failure': RED
        }
        
        title = self.font_large.render(titles[ending], True, title_colors[ending])
        title_rect = title.get_rect(center=(SCREEN_WIDTH // 2, 200))
        self.screen.blit(title, title_rect)
        
        # Stats
        stats = [
            f"Final Score: {economy.calculate_final_score()}",
            f"Level: {economy.level} - {economy.get_level_title()}",
            f"Coins Saved: {economy.coins}",
            f"Needs Bought: {economy.needs_bought}/6",
            f"Correct Choices: {economy.correct_choices}"
        ]
        
        for i, stat in enumerate(stats):
            text = self.font_medium.render(stat, True, WHITE)
            text_rect = text.get_rect(center=(SCREEN_WIDTH // 2, 300 + i * 40))
            self.screen.blit(text, text_rect)
        
        # Restart prompt
        restart = self.font_medium.render("Press R to restart or L for leaderboard", True, WHITE)
        restart_rect = restart.get_rect(center=(SCREEN_WIDTH // 2, 550))
        self.screen.blit(restart, restart_rect)
    
    def draw_leaderboard(self, leaderboard):
        """Draw leaderboard screen"""
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 200))
        self.screen.blit(overlay, (0, 0))
        
        # Title
        title = self.font_large.render("🏆 FINANCE CHAMPIONS 🏆", True, GOLD)
        title_rect = title.get_rect(center=(SCREEN_WIDTH // 2, 80))
        self.screen.blit(title, title_rect)
        
        # Scores
        scores = leaderboard.get_top_scores()
        
        if not scores:
            no_scores = self.font_medium.render("No scores yet! Be the first!", True, WHITE)
            self.screen.blit(no_scores, no_scores.get_rect(center=(SCREEN_WIDTH // 2, 300)))
        else:
            for i, entry in enumerate(scores):
                y = 150 + i * 50
                
                # Rank with medal
                if i == 0:
                    rank_text = "🥇"
                    color = GOLD
                elif i == 1:
                    rank_text = "🥈"
                    color = (192, 192, 192)
                elif i == 2:
                    rank_text = "🥉"
                    color = (205, 127, 50)
                else:
                    rank_text = f"{i + 1}."
                    color = WHITE
                
                # Draw entry
                entry_text = f"{rank_text} {entry['name']:12} {entry['score']:>6} pts  Lv.{entry['level']}"
                text = self.font_medium.render(entry_text, True, color)
                text_rect = text.get_rect(center=(SCREEN_WIDTH // 2, y))
                self.screen.blit(text, text_rect)
        
        # Close prompt
        close = self.font_small.render("Press ESC to close", True, (180, 180, 180))
        self.screen.blit(close, close.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT - 50)))
    
    def draw_main_menu(self):
        """Draw main menu"""
        # Background
        self.screen.fill((50, 80, 120))
        
        # Title
        title = self.font_large.render("FINANCE QUEST", True, GOLD)
        title_rect = title.get_rect(center=(SCREEN_WIDTH // 2, 150))
        self.screen.blit(title, title_rect)
        
        subtitle = self.font_medium.render("Needs vs Wants", True, WHITE)
        sub_rect = subtitle.get_rect(center=(SCREEN_WIDTH // 2, 200))
        self.screen.blit(subtitle, sub_rect)
        
        # Menu options
        options = ["NEW GAME", "LEADERBOARD", "QUIT"]
        for i, option in enumerate(options):
            y = 350 + i * 70
            
            # Button background
            btn_rect = pygame.Rect(SCREEN_WIDTH // 2 - 100, y - 15, 200, 50)
            pygame.draw.rect(self.screen, PANEL_BG, btn_rect, border_radius=8)
            pygame.draw.rect(self.screen, PANEL_BORDER, btn_rect, 2, border_radius=8)
            
            text = self.font_medium.render(option, True, WHITE)
            text_rect = text.get_rect(center=(SCREEN_WIDTH // 2, y + 10))
            self.screen.blit(text, text_rect)
        
        # Instructions
        instr = self.font_small.render("Use UP/DOWN arrows and ENTER to select", True, (180, 180, 180))
        self.screen.blit(instr, instr.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT - 50)))
