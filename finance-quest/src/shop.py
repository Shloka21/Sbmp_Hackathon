"""
Shop system for Finance Quest
Player can buy items to fulfill needs
"""
import pygame
from settings import (
    TILE_SIZE, SCREEN_WIDTH, SCREEN_HEIGHT,
    WHITE, BLACK, GOLD, PANEL_BG, PANEL_BORDER,
    ITEM_PRICES, NEEDS, WANTS
)


class ShopItem:
    """An item available in the shop"""
    
    ITEM_EFFECTS = {
        # Needs - restore important stats
        'bread': {'hunger': 30, 'description': 'Fills you up a bit'},
        'carrot': {'hunger': 20, 'health': 1, 'description': 'Healthy and filling'},
        'coat': {'warmth': 50, 'description': 'Keeps you warm'},
        'medicine': {'health': 2, 'description': 'Restores health'},
        'firewood': {'warmth': 40, 'description': 'Keeps home warm'},
        'blanket': {'warmth': 30, 'rest': 20, 'description': 'Better sleep'},
        
        # Wants - mostly cosmetic/fun
        'toy_sword': {'happiness': 10, 'description': 'Fun but not useful'},
        'candy': {'hunger': 5, 'happiness': 15, 'description': 'Tasty treat!'},
        'crown': {'happiness': 20, 'description': 'Feel like royalty'},
        'painting': {'happiness': 15, 'description': 'Pretty decoration'},
        'music_box': {'happiness': 25, 'description': 'Nice tunes'},
        'vase': {'happiness': 10, 'description': 'Decorative'},
    }
    
    def __init__(self, item_type):
        self.item_type = item_type
        self.price = ITEM_PRICES.get(item_type, 10)
        self.is_need = item_type in NEEDS
        self.effects = self.ITEM_EFFECTS.get(item_type, {})
        self.stock = 3  # Limited stock per day
        
    @property
    def name(self):
        return self.item_type.replace('_', ' ').title()
    
    @property
    def description(self):
        return self.effects.get('description', 'An item')
    
    def get_effect_text(self):
        """Get text describing item effects"""
        effects = []
        if 'hunger' in self.effects:
            effects.append(f"+{self.effects['hunger']} Hunger")
        if 'health' in self.effects:
            effects.append(f"+{self.effects['health']} Health")
        if 'warmth' in self.effects:
            effects.append(f"+{self.effects['warmth']} Warmth")
        if 'happiness' in self.effects:
            effects.append(f"+{self.effects['happiness']} Happiness")
        if 'rest' in self.effects:
            effects.append(f"+{self.effects['rest']} Rest")
        return ', '.join(effects) if effects else 'No special effects'
    
    def apply_effects(self, player_status):
        """Apply item effects to player status"""
        if 'hunger' in self.effects:
            player_status.add_hunger(self.effects['hunger'])
        if 'health' in self.effects:
            player_status.add_health(self.effects['health'])
        if 'warmth' in self.effects:
            player_status.add_warmth(self.effects['warmth'])
        if 'happiness' in self.effects:
            player_status.add_happiness(self.effects['happiness'])
    
    def purchase(self):
        """Reduce stock when purchased"""
        if self.stock > 0:
            self.stock -= 1
            return True
        return False
    
    def restock(self):
        """Restock for new day"""
        self.stock = 3


class Shop:
    """The village shop"""
    
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.rect = pygame.Rect(x, y, TILE_SIZE * 3, TILE_SIZE * 2)
        
        # Shop inventory
        self.items = self.create_inventory()
        
        # UI state
        self.is_open = False
        self.selected_index = 0
        self.scroll_offset = 0
        self.items_per_page = 6
    
    def create_inventory(self):
        """Create shop's item inventory"""
        items = []
        # Add all needs first (encouraged)
        for item_type in NEEDS:
            items.append(ShopItem(item_type))
        # Then add wants (tempting)
        for item_type in WANTS:
            items.append(ShopItem(item_type))
        return items
    
    def is_player_nearby(self, player):
        """Check if player is close enough to enter shop"""
        return self.rect.colliderect(player.rect.inflate(TILE_SIZE, TILE_SIZE))
    
    def open(self):
        """Open the shop"""
        self.is_open = True
        self.selected_index = 0
    
    def close(self):
        """Close the shop"""
        self.is_open = False
    
    def navigate(self, direction):
        """Navigate shop menu"""
        if direction == 'up':
            self.selected_index = max(0, self.selected_index - 1)
        elif direction == 'down':
            self.selected_index = min(len(self.items) - 1, self.selected_index + 1)
        
        # Scroll if needed
        if self.selected_index < self.scroll_offset:
            self.scroll_offset = self.selected_index
        elif self.selected_index >= self.scroll_offset + self.items_per_page:
            self.scroll_offset = self.selected_index - self.items_per_page + 1
    
    def get_selected_item(self):
        """Get currently selected item"""
        if 0 <= self.selected_index < len(self.items):
            return self.items[self.selected_index]
        return None
    
    def purchase_selected(self, economy, player_status):
        """Attempt to purchase selected item"""
        item = self.get_selected_item()
        if item and item.stock > 0 and economy.can_afford(item.price):
            economy.spend_coins(item.price)
            item.purchase()
            item.apply_effects(player_status)
            
            # Track purchase for XP
            is_correct = item.is_need
            if is_correct:
                economy.add_xp(15)
                economy.needs_bought += 1
            else:
                economy.add_xp(-5)
                economy.wants_bought += 1
            
            return True, item
        return False, item
    
    def restock_all(self):
        """Restock all items for new day"""
        for item in self.items:
            item.restock()
    
    def draw(self, screen, economy):
        """Draw shop interface"""
        if not self.is_open:
            return
        
        # Background overlay
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 180))
        screen.blit(overlay, (0, 0))
        
        # Shop panel
        panel_width = 500
        panel_height = 450
        panel_x = (SCREEN_WIDTH - panel_width) // 2
        panel_y = (SCREEN_HEIGHT - panel_height) // 2
        
        pygame.draw.rect(screen, PANEL_BG, 
                        (panel_x, panel_y, panel_width, panel_height),
                        border_radius=10)
        pygame.draw.rect(screen, PANEL_BORDER,
                        (panel_x, panel_y, panel_width, panel_height),
                        3, border_radius=10)
        
        # Title
        font_large = pygame.font.Font(None, 40)
        font_medium = pygame.font.Font(None, 28)
        font_small = pygame.font.Font(None, 22)
        
        title = font_large.render("🏪 VILLAGE SHOP", True, GOLD)
        screen.blit(title, (panel_x + 20, panel_y + 15))
        
        # Coins display
        coins = font_medium.render(f"Your coins: {economy.coins}", True, GOLD)
        screen.blit(coins, (panel_x + panel_width - 180, panel_y + 20))
        
        # Items list
        list_y = panel_y + 60
        visible_items = self.items[self.scroll_offset:self.scroll_offset + self.items_per_page]
        
        for i, item in enumerate(visible_items):
            actual_index = self.scroll_offset + i
            item_y = list_y + i * 55
            
            # Selection highlight
            if actual_index == self.selected_index:
                pygame.draw.rect(screen, (100, 80, 60),
                               (panel_x + 10, item_y, panel_width - 20, 50),
                               border_radius=5)
                pygame.draw.rect(screen, GOLD,
                               (panel_x + 10, item_y, panel_width - 20, 50),
                               2, border_radius=5)
            
            # Item type indicator (NEED/WANT)
            type_color = (100, 200, 100) if item.is_need else (200, 100, 100)
            type_text = "NEED" if item.is_need else "WANT"
            type_label = font_small.render(type_text, True, type_color)
            screen.blit(type_label, (panel_x + 20, item_y + 5))
            
            # Item name
            name_color = WHITE if item.stock > 0 else (100, 100, 100)
            name = font_medium.render(item.name, True, name_color)
            screen.blit(name, (panel_x + 80, item_y + 5))
            
            # Price
            price_color = GOLD if economy.can_afford(item.price) else (150, 100, 100)
            price = font_medium.render(f"{item.price} coins", True, price_color)
            screen.blit(price, (panel_x + panel_width - 120, item_y + 5))
            
            # Description
            desc = font_small.render(item.description, True, (180, 180, 180))
            screen.blit(desc, (panel_x + 80, item_y + 28))
            
            # Stock
            stock_text = f"Stock: {item.stock}" if item.stock > 0 else "SOLD OUT"
            stock_color = WHITE if item.stock > 0 else (200, 100, 100)
            stock = font_small.render(stock_text, True, stock_color)
            screen.blit(stock, (panel_x + panel_width - 120, item_y + 28))
        
        # Selected item details
        selected = self.get_selected_item()
        if selected:
            details_y = panel_y + panel_height - 80
            pygame.draw.line(screen, PANEL_BORDER, 
                           (panel_x + 20, details_y - 10),
                           (panel_x + panel_width - 20, details_y - 10), 2)
            
            effects = font_small.render(f"Effects: {selected.get_effect_text()}", True, (150, 200, 150))
            screen.blit(effects, (panel_x + 20, details_y))
        
        # Instructions
        instr = font_small.render("↑↓ Navigate | ENTER Buy | ESC Close", True, (150, 150, 150))
        screen.blit(instr, (panel_x + panel_width // 2 - 120, panel_y + panel_height - 30))
