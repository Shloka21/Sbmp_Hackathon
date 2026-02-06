"""
Alex's RPG Adventure: Needs vs Wants
A standalone RPG script reusing Finance Quest assets
"""
import pygame
import sys
import os
import random

# Initialize Pygame
pygame.init()

# ------------------ CONFIGURATION ------------------
SCREEN_WIDTH, SCREEN_HEIGHT = 1000, 700
SCREEN = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Alex's RPG Adventure")
CLOCK = pygame.time.Clock()

# Asset Paths (Using existing Finance Quest assets)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_DIR = os.path.join(BASE_DIR, "finance-quest", "assets", "images")
PLAYER_IMG_PATH = os.path.join(ASSETS_DIR, "player", "alex.png")
MOM_IMG_PATH = os.path.join(ASSETS_DIR, "npc", "mom.png")
ITEMS_DIR = os.path.join(ASSETS_DIR, "items")
FLOOR_IMG_PATH = os.path.join(ASSETS_DIR, "tiles", "floor.png")

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
BG_COLOR = (40, 40, 50)
PANEL_COLOR = (245, 245, 245)
GREEN = (72, 187, 120)
RED = (245, 101, 101)
GOLD = (236, 201, 75)

# Fonts
FONT_UI = pygame.font.SysFont("arial", 20)
FONT_TITLE = pygame.font.SysFont("arial", 32, bold=True)

# ------------------ HELPERS ------------------
def load_image(path, size=None):
    if os.path.exists(path):
        img = pygame.image.load(path).convert_alpha()
        if size:
            img = pygame.transform.scale(img, size)
        return img
    else:
        # Fallback square
        surf = pygame.Surface(size if size else (40, 40))
        surf.fill((200, 100, 200))
        return surf

# ------------------ CLASSES ------------------
class Player(pygame.sprite.Sprite):
    def __init__(self, x, y):
        super().__init__()
        self.image = load_image(PLAYER_IMG_PATH, (64, 64))
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = 5
        self.inventory = []
        self.coins = 50

    def move(self, keys):
        dx, dy = 0, 0
        if keys[pygame.K_LEFT]: dx = -self.speed
        if keys[pygame.K_RIGHT]: dx = self.speed
        if keys[pygame.K_UP]: dy = -self.speed
        if keys[pygame.K_DOWN]: dy = self.speed

        self.rect.x += dx
        self.rect.y += dy

        # Clamp to screen
        self.rect.clamp_ip(SCREEN.get_rect())

class NPC(pygame.sprite.Sprite):
    def __init__(self, x, y, name, img_path):
        super().__init__()
        self.image = load_image(img_path, (64, 64))
        self.rect = self.image.get_rect(topleft=(x, y))
        self.name = name

class Item(pygame.sprite.Sprite):
    def __init__(self, x, y, name, is_need, price):
        super().__init__()
        self.name = name
        self.is_need = is_need
        self.price = price
        path = os.path.join(ITEMS_DIR, f"{name.lower()}.png")
        self.image = load_image(path, (40, 40))
        self.rect = self.image.get_rect(center=(x, y))

# ------------------ GAME ENGINE ------------------
class RPGGame:
    def __init__(self):
        self.reset()
        self.floor_img = load_image(FLOOR_IMG_PATH, (64, 64))

    def reset(self):
        self.player = Player(100, 300)
        self.mom = NPC(800, 300, "Mom", MOM_IMG_PATH)
        
        self.items = pygame.sprite.Group()
        self.all_sprites = pygame.sprite.Group(self.player, self.mom)
        
        self.day = 1
        self.state = "START" # START, PLAYING, SHOP, HOME, END_DAY
        self.message = "Go talk to Mom!"
        self.message_timer = 0
        
        # Daily Quest
        self.needs_list = ["bread", "water"]
        self.wants_list = ["candy", "toy"]
        
        # Shop Setup
        self.shop_items = {}
        for i, name in enumerate(self.needs_list):
            item = Item(300 + i*100, 200, name, True, 15)
            self.shop_items[name] = item
        for i, name in enumerate(self.wants_list):
            item = Item(300 + i*100, 400, name, False, 20)
            self.shop_items[name] = item

    def spawn_shop(self):
        self.items.empty()
        for item in self.shop_items.values():
            self.items.add(item)

    def draw_bg(self):
        for y in range(0, SCREEN_HEIGHT, 64):
            for x in range(0, SCREEN_WIDTH, 64):
                SCREEN.blit(self.floor_img, (x, y))

    def show_message(self, text, duration=120):
        self.message = text
        self.message_timer = duration

    def update(self):
        keys = pygame.key.get_pressed()
        self.player.move(keys)
        
        # Interaction with Mom
        if self.player.rect.colliderect(self.mom.rect.inflate(20, 20)):
            if keys[pygame.K_SPACE]:
                if self.state == "START":
                    self.state = "SHOPPING"
                    self.show_message("Mom: Go buy Bread and Water! Avoid toys!")
                    self.spawn_shop()
                elif self.state == "SHOPPING":
                    self.evaluate_day()

        # Interaction with Items
        if self.state == "SHOPPING":
            hits = pygame.sprite.spritecollide(self.player, self.items, False)
            for item in hits:
                if keys[pygame.K_e]:
                    if self.player.coins >= item.price:
                        self.player.coins -= item.price
                        self.player.inventory.append(item.name)
                        item.kill() # Remove from world
                        self.show_message(f"Bought {item.name}!")
                    else:
                        self.show_message("Not enough money!")

        if self.message_timer > 0:
            self.message_timer -= 1

    def evaluate_day(self):
        missed = [n for n in self.needs_list if n not in self.player.inventory]
        bought_wants = [i for i in self.player.inventory if i in self.wants_list]
        
        if not missed and not bought_wants:
            self.show_message("Mom: Perfect job! You got everything!")
        elif bought_wants:
            self.show_message("Mom: Why did you buy toys? We need food!")
        else:
            self.show_message("Mom: You forgot some items!")
            
        self.state = "START" # Reset for demo loops
        self.player.inventory = []
        self.player.rect.topleft = (100, 300)
        self.items.empty()

    def draw_ui(self):
        # Top Panel
        pygame.draw.rect(SCREEN, PANEL_COLOR, (0, 0, SCREEN_WIDTH, 80))
        pygame.draw.line(SCREEN, (200,200,200), (0,80), (SCREEN_WIDTH,80), 3)
        
        # Stats
        txt_coins = FONT_UI.render(f"Coins: ${self.player.coins}", True, GOLD)
        txt_day = FONT_UI.render(f"Day: {self.day}", True, BLACK)
        txt_inv = FONT_UI.render(f"Bag: {', '.join(self.player.inventory)}", True, BLACK)
        
        SCREEN.blit(txt_coins, (20, 20))
        SCREEN.blit(txt_day, (150, 20))
        SCREEN.blit(txt_inv, (300, 20))
        
        # Instructions
        if self.state == "START":
            instr = "WALK into check Mom (SPACE)"
        else:
            instr = "WALK into Items + 'E' to Buy | SPACE at Mom to Finish"
        txt_instr = FONT_UI.render(instr, True, (100, 100, 150))
        SCREEN.blit(txt_instr, (600, 20))

        # Floating Message
        if self.message_timer > 0:
            surf = FONT_TITLE.render(self.message, True, RED)
            rect = surf.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT - 100))
            bg_rect = rect.inflate(40, 20)
            pygame.draw.rect(SCREEN, WHITE, bg_rect, border_radius=15)
            pygame.draw.rect(SCREEN, BLACK, bg_rect, 2, border_radius=15)
            SCREEN.blit(surf, rect)

    def draw(self):
        self.draw_bg()
        self.all_sprites.draw(SCREEN)
        self.items.draw(SCREEN)
        self.draw_ui()
        pygame.display.flip()

# Main Loop
game = RPGGame()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
            
    game.update()
    game.draw()
    CLOCK.tick(60)
