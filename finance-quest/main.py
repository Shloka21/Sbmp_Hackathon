"""
Finance Quest: Needs vs Wants
Complete Educational Game

Game Flow:
1. Mom gives today's shopping list (NEEDS)
2. Play Match-3 mini-game to earn coins
3. Visit Shop to buy items
4. Return home and give items to Mom for evaluation
5. Repeat for 3 days
"""
import pygame
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from settings import (
    SCREEN_WIDTH, SCREEN_HEIGHT, FPS, TITLE,
    WHITE, BLACK, GOLD, RED, GREEN, BLUE,
    PANEL_BG, PANEL_BORDER,
    NEEDS, WANTS, ITEM_PRICES, DAILY_TASKS, TOTAL_DAYS,
    PLAYER_PATH, NPC_PATH, ITEMS_PATH, UI_PATH
)
from src.match3 import Match3Game


class GameState:
    MENU = 'menu'
    MOM_TASK = 'mom_task'
    MATCH3 = 'match3'
    SHOP = 'shop'
    GIVE_TO_MOM = 'give_to_mom'
    EVALUATION = 'evaluation'
    DAY_END = 'day_end'
    GAME_OVER = 'game_over'
    FINAL_SCORE = 'final_score'


class FinanceQuest:
    """Main game class"""
    
    def __init__(self):
        pygame.init()
        pygame.mixer.init()
        
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption(TITLE)
        self.clock = pygame.time.Clock()
        
        # Fonts
        self.font_title = pygame.font.Font(None, 64)
        self.font_large = pygame.font.Font(None, 48)
        self.font_medium = pygame.font.Font(None, 32)
        self.font_small = pygame.font.Font(None, 24)
        
        # Load images
        self.load_images()
        
        # Game state
        self.state = GameState.MENU
        self.running = True
        self.menu_selection = 0
        
        # Game data
        self.reset_game()
    
    def load_images(self):
        """Load game images"""
        self.images = {}
        
        # Alex
        alex_path = os.path.join(PLAYER_PATH, "alex.png")
        if os.path.exists(alex_path):
            self.images['alex'] = pygame.transform.scale(
                pygame.image.load(alex_path).convert_alpha(), (80, 80))
        else:
            self.images['alex'] = self.create_character_placeholder((70, 130, 180))
        
        # Mom
        mom_path = os.path.join(NPC_PATH, "mom.png")
        if os.path.exists(mom_path):
            self.images['mom'] = pygame.transform.scale(
                pygame.image.load(mom_path).convert_alpha(), (80, 80))
        else:
            self.images['mom'] = self.create_character_placeholder((180, 100, 120))
        
        # Items
        self.item_images = {}
        for item in NEEDS + WANTS:
            path = os.path.join(ITEMS_PATH, f"{item}.png")
            if os.path.exists(path):
                self.item_images[item] = pygame.transform.scale(
                    pygame.image.load(path).convert_alpha(), (48, 48))
            else:
                color = (80, 180, 80) if item in NEEDS else (180, 80, 80)
                self.item_images[item] = self.create_item_placeholder(color)
    
    def create_character_placeholder(self, color):
        """Create placeholder character"""
        img = pygame.Surface((80, 80), pygame.SRCALPHA)
        pygame.draw.ellipse(img, color, (20, 30, 40, 45))
        pygame.draw.ellipse(img, (255, 220, 180), (25, 10, 30, 25))
        pygame.draw.circle(img, (50, 50, 50), (35, 20), 3)
        pygame.draw.circle(img, (50, 50, 50), (45, 20), 3)
        return img
    
    def create_item_placeholder(self, color):
        """Create placeholder item"""
        img = pygame.Surface((48, 48), pygame.SRCALPHA)
        pygame.draw.ellipse(img, color, (4, 4, 40, 40))
        return img
    
    def reset_game(self):
        """Reset game state for new game"""
        self.current_day = 1
        self.coins = 0
        self.total_score = 0
        self.inventory = []  # Items player has bought
        self.todays_tasks = []  # What Mom asked for today
        self.shop_selection = 0
        self.match3_game = None
        self.day_results = []  # Results for each day
    
    def run(self):
        """Main game loop"""
        while self.running:
            self.handle_events()
            self.update()
            self.draw()
            self.clock.tick(FPS)
        
        pygame.quit()
        sys.exit()
    
    def handle_events(self):
        """Handle pygame events"""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            
            elif event.type == pygame.KEYDOWN:
                self.handle_keydown(event)
            
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if self.state == GameState.MATCH3 and self.match3_game:
                    self.match3_game.handle_click(event.pos)
    
    def handle_keydown(self, event):
        """Handle key presses"""
        if self.state == GameState.MENU:
            self.handle_menu_input(event)
        elif self.state == GameState.MOM_TASK:
            if event.key in [pygame.K_RETURN, pygame.K_e]:
                self.start_match3()
        elif self.state == GameState.MATCH3:
            if event.key == pygame.K_ESCAPE:
                self.end_match3(0)
        elif self.state == GameState.SHOP:
            self.handle_shop_input(event)
        elif self.state == GameState.GIVE_TO_MOM:
            if event.key in [pygame.K_RETURN, pygame.K_e]:
                self.evaluate_shopping()
        elif self.state == GameState.EVALUATION:
            if event.key in [pygame.K_RETURN, pygame.K_e]:
                self.end_day()
        elif self.state == GameState.DAY_END:
            if event.key in [pygame.K_RETURN, pygame.K_e]:
                self.next_day()
        elif self.state == GameState.FINAL_SCORE:
            if event.key in [pygame.K_RETURN, pygame.K_r]:
                self.state = GameState.MENU
    
    def handle_menu_input(self, event):
        """Handle menu navigation"""
        if event.key == pygame.K_UP:
            self.menu_selection = (self.menu_selection - 1) % 2
        elif event.key == pygame.K_DOWN:
            self.menu_selection = (self.menu_selection + 1) % 2
        elif event.key == pygame.K_RETURN:
            if self.menu_selection == 0:
                self.start_new_game()
            else:
                self.running = False
    
    def handle_shop_input(self, event):
        """Handle shop navigation"""
        all_items = NEEDS + WANTS
        
        if event.key == pygame.K_UP:
            self.shop_selection = (self.shop_selection - 1) % len(all_items)
        elif event.key == pygame.K_DOWN:
            self.shop_selection = (self.shop_selection + 1) % len(all_items)
        elif event.key == pygame.K_RETURN:
            self.buy_selected_item()
        elif event.key == pygame.K_ESCAPE or event.key == pygame.K_h:
            # Go home (to Mom)
            self.state = GameState.GIVE_TO_MOM
    
    def start_new_game(self):
        """Start a new game"""
        self.reset_game()
        self.show_mom_task()
    
    def show_mom_task(self):
        """Show Mom giving today's task"""
        self.todays_tasks = DAILY_TASKS.get(self.current_day, ['bread', 'water'])
        self.state = GameState.MOM_TASK
    
    def start_match3(self):
        """Start the match-3 mini-game"""
        self.match3_game = Match3Game(self.screen, self.end_match3)
        self.state = GameState.MATCH3
    
    def end_match3(self, coins_earned):
        """End match-3 and go to shop"""
        self.coins += coins_earned
        self.match3_game = None
        self.state = GameState.SHOP
        self.shop_selection = 0
    
    def buy_selected_item(self):
        """Buy the selected item"""
        all_items = NEEDS + WANTS
        item = all_items[self.shop_selection]
        price = ITEM_PRICES.get(item, 10)
        
        if self.coins >= price and item not in self.inventory:
            self.coins -= price
            self.inventory.append(item)
    
    def evaluate_shopping(self):
        """Mom evaluates the shopping"""
        self.state = GameState.EVALUATION
    
    def end_day(self):
        """End the current day"""
        # Calculate day score
        correct = 0
        wrong_needs = 0
        wrong_wants = 0
        
        for task in self.todays_tasks:
            if task in self.inventory:
                correct += 1
        
        for item in self.inventory:
            if item not in self.todays_tasks:
                if item in WANTS:
                    wrong_wants += 1
                else:
                    # Bought a need that wasn't asked for - still okay
                    pass
        
        day_score = correct * 30 - wrong_wants * 10
        
        self.day_results.append({
            'day': self.current_day,
            'tasks': self.todays_tasks.copy(),
            'bought': self.inventory.copy(),
            'correct': correct,
            'wrong_wants': wrong_wants,
            'score': day_score
        })
        
        self.total_score += day_score
        self.state = GameState.DAY_END
    
    def next_day(self):
        """Move to next day or end game"""
        self.inventory = []
        
        if self.current_day >= TOTAL_DAYS:
            self.state = GameState.FINAL_SCORE
        else:
            self.current_day += 1
            self.show_mom_task()
    
    def update(self):
        """Update game state"""
        dt = self.clock.get_time() / 1000.0
        
        if self.state == GameState.MATCH3 and self.match3_game:
            self.match3_game.update(dt)
    
    def draw(self):
        """Draw current state"""
        if self.state == GameState.MENU:
            self.draw_menu()
        elif self.state == GameState.MOM_TASK:
            self.draw_mom_task()
        elif self.state == GameState.MATCH3:
            if self.match3_game:
                self.match3_game.draw()
        elif self.state == GameState.SHOP:
            self.draw_shop()
        elif self.state == GameState.GIVE_TO_MOM:
            self.draw_give_to_mom()
        elif self.state == GameState.EVALUATION:
            self.draw_evaluation()
        elif self.state == GameState.DAY_END:
            self.draw_day_end()
        elif self.state == GameState.FINAL_SCORE:
            self.draw_final_score()
        
        pygame.display.flip()
    
    def draw_menu(self):
        """Draw main menu"""
        # Background gradient
        for y in range(SCREEN_HEIGHT):
            ratio = y / SCREEN_HEIGHT
            color = (int(40 + 30 * ratio), int(60 + 20 * ratio), int(100 - 20 * ratio))
            pygame.draw.line(self.screen, color, (0, y), (SCREEN_WIDTH, y))
        
        # Title
        title = self.font_title.render("💰 FINANCE QUEST 💰", True, GOLD)
        self.screen.blit(title, title.get_rect(centerx=SCREEN_WIDTH//2, top=100))
        
        subtitle = self.font_large.render("Needs vs Wants", True, WHITE)
        self.screen.blit(subtitle, subtitle.get_rect(centerx=SCREEN_WIDTH//2, top=170))
        
        # Characters
        self.screen.blit(self.images['alex'], (SCREEN_WIDTH//2 - 120, 250))
        self.screen.blit(self.images['mom'], (SCREEN_WIDTH//2 + 40, 250))
        
        # Menu options
        options = ["🎮 START GAME", "🚪 EXIT"]
        for i, option in enumerate(options):
            y = 400 + i * 70
            color = GOLD if i == self.menu_selection else WHITE
            text = self.font_large.render(option, True, color)
            rect = text.get_rect(centerx=SCREEN_WIDTH//2, top=y)
            
            if i == self.menu_selection:
                pygame.draw.rect(self.screen, (80, 60, 40),
                               (rect.x - 20, rect.y - 5, rect.width + 40, rect.height + 10),
                               border_radius=10)
            
            self.screen.blit(text, rect)
        
        # Instructions
        instr = self.font_small.render("Use ↑↓ and ENTER to select", True, (180, 180, 180))
        self.screen.blit(instr, instr.get_rect(centerx=SCREEN_WIDTH//2, bottom=SCREEN_HEIGHT-30))
    
    def draw_mom_task(self):
        """Draw Mom giving today's task"""
        # Background
        self.screen.fill((240, 230, 210))
        
        # Header
        header = self.font_large.render(f"☀️ DAY {self.current_day} - Morning ☀️", True, (100, 80, 60))
        self.screen.blit(header, header.get_rect(centerx=SCREEN_WIDTH//2, top=30))
        
        # Mom
        mom_x = SCREEN_WIDTH // 4
        self.screen.blit(pygame.transform.scale(self.images['mom'], (120, 120)), 
                        (mom_x - 60, 120))
        
        # Mom's name
        name = self.font_medium.render("Mom", True, (180, 100, 120))
        self.screen.blit(name, name.get_rect(centerx=mom_x, top=250))
        
        # Dialogue box
        box_x = SCREEN_WIDTH // 2 - 50
        box_width = SCREEN_WIDTH // 2 + 20
        pygame.draw.rect(self.screen, (255, 250, 240),
                        (box_x, 130, box_width, 150), border_radius=15)
        pygame.draw.rect(self.screen, (180, 160, 140),
                        (box_x, 130, box_width, 150), 3, border_radius=15)
        
        # Mom's message
        messages = {
            1: "Good morning Alex! Today we need some basic supplies.",
            2: "Alex, it's getting colder. We need warm things and medicine!",
            3: "Last day before winter! Let's stock up on essentials.",
        }
        
        msg = messages.get(self.current_day, "Please buy these items today:")
        text = self.font_medium.render(msg, True, (60, 50, 40))
        self.screen.blit(text, (box_x + 20, 150))
        
        # Shopping list title
        list_title = self.font_medium.render("📋 Today's Shopping List (NEEDS):", True, (60, 100, 60))
        self.screen.blit(list_title, (box_x + 20, 200))
        
        # List items
        for i, item in enumerate(self.todays_tasks):
            item_text = self.font_medium.render(f"✓ {item.title()}", True, (80, 140, 80))
            if item in self.item_images:
                self.screen.blit(self.item_images[item], (box_x + 30, 235 + i * 45))
            self.screen.blit(item_text, (box_x + 85, 245 + i * 45))
        
        # Alex
        alex_x = 3 * SCREEN_WIDTH // 4
        self.screen.blit(pygame.transform.scale(self.images['alex'], (100, 100)),
                        (alex_x - 50, 400))
        
        # Alex's response bubble
        pygame.draw.ellipse(self.screen, (230, 240, 255),
                           (alex_x - 100, 350, 200, 50))
        response = self.font_small.render("I'll do my best, Mom!", True, (60, 60, 100))
        self.screen.blit(response, response.get_rect(centerx=alex_x, centery=375))
        
        # Continue prompt
        prompt = self.font_medium.render("Press ENTER to work and earn coins! 💎", True, (100, 100, 100))
        self.screen.blit(prompt, prompt.get_rect(centerx=SCREEN_WIDTH//2, bottom=SCREEN_HEIGHT-50))
    
    def draw_shop(self):
        """Draw shop screen"""
        # Background
        self.screen.fill((60, 50, 70))
        
        # Header
        header = self.font_large.render("🏪 VILLAGE SHOP 🏪", True, GOLD)
        self.screen.blit(header, header.get_rect(centerx=SCREEN_WIDTH//2, top=20))
        
        # Coins display
        coins = self.font_medium.render(f"💰 Your Coins: {self.coins}", True, GOLD)
        self.screen.blit(coins, (30, 20))
        
        # Day and tasks reminder
        tasks_str = ", ".join(self.todays_tasks)
        reminder = self.font_small.render(f"Mom wants: {tasks_str}", True, (150, 255, 150))
        self.screen.blit(reminder, (30, 55))
        
        # Items grid
        all_items = NEEDS + WANTS
        items_per_row = 4
        item_width = 200
        item_height = 80
        start_x = (SCREEN_WIDTH - items_per_row * item_width) // 2
        start_y = 100
        
        for i, item in enumerate(all_items):
            row = i // items_per_row
            col = i % items_per_row
            x = start_x + col * item_width
            y = start_y + row * item_height
            
            # Item box
            is_selected = i == self.shop_selection
            is_bought = item in self.inventory
            is_need = item in NEEDS
            is_task = item in self.todays_tasks
            
            if is_bought:
                bg_color = (40, 80, 40)
            elif is_selected:
                bg_color = (80, 70, 100)
            else:
                bg_color = (50, 45, 60)
            
            pygame.draw.rect(self.screen, bg_color,
                           (x + 5, y + 5, item_width - 10, item_height - 10),
                           border_radius=8)
            
            border_color = GOLD if is_selected else ((100, 200, 100) if is_need else (200, 100, 100))
            pygame.draw.rect(self.screen, border_color,
                           (x + 5, y + 5, item_width - 10, item_height - 10),
                           2, border_radius=8)
            
            # Item image
            if item in self.item_images:
                self.screen.blit(self.item_images[item], (x + 15, y + 16))
            
            # Item name
            name_color = WHITE if not is_bought else (150, 200, 150)
            name = self.font_medium.render(item.title(), True, name_color)
            self.screen.blit(name, (x + 70, y + 15))
            
            # Price
            price = ITEM_PRICES.get(item, 10)
            price_color = GOLD if self.coins >= price else (150, 100, 100)
            price_text = self.font_small.render(f"${price}", True, price_color)
            self.screen.blit(price_text, (x + 70, y + 45))
            
            # Type indicator
            type_text = "NEED" if is_need else "WANT"
            type_color = (100, 200, 100) if is_need else (200, 100, 100)
            type_label = self.font_small.render(type_text, True, type_color)
            self.screen.blit(type_label, (x + 130, y + 45))
            
            # Task indicator
            if is_task:
                star = self.font_small.render("⭐", True, GOLD)
                self.screen.blit(star, (x + item_width - 35, y + 10))
            
            # Bought indicator
            if is_bought:
                check = self.font_medium.render("✓", True, (100, 255, 100))
                self.screen.blit(check, (x + item_width - 35, y + 40))
        
        # Inventory display
        inv_y = start_y + (len(all_items) // items_per_row + 1) * item_height + 20
        pygame.draw.rect(self.screen, (40, 35, 50),
                        (50, inv_y, SCREEN_WIDTH - 100, 100), border_radius=10)
        
        inv_title = self.font_medium.render("🎒 Your Items:", True, WHITE)
        self.screen.blit(inv_title, (70, inv_y + 10))
        
        for i, item in enumerate(self.inventory):
            if item in self.item_images:
                self.screen.blit(self.item_images[item], (70 + i * 55, inv_y + 45))
        
        # Instructions
        instr = self.font_small.render("↑↓ Navigate | ENTER Buy | H Go Home to Mom", True, (180, 180, 180))
        self.screen.blit(instr, instr.get_rect(centerx=SCREEN_WIDTH//2, bottom=SCREEN_HEIGHT-15))
    
    def draw_give_to_mom(self):
        """Draw giving items to Mom screen"""
        self.screen.fill((240, 230, 210))
        
        # Header
        header = self.font_large.render("🏠 Back Home 🏠", True, (100, 80, 60))
        self.screen.blit(header, header.get_rect(centerx=SCREEN_WIDTH//2, top=30))
        
        # Characters
        self.screen.blit(pygame.transform.scale(self.images['alex'], (100, 100)),
                        (SCREEN_WIDTH//3 - 50, 150))
        self.screen.blit(pygame.transform.scale(self.images['mom'], (100, 100)),
                        (2*SCREEN_WIDTH//3 - 50, 150))
        
        # Alex's items
        box_y = 280
        pygame.draw.rect(self.screen, (255, 250, 240),
                        (100, box_y, SCREEN_WIDTH - 200, 150), border_radius=15)
        
        text = self.font_medium.render("Alex: Mom, here's what I bought!", True, (60, 60, 100))
        self.screen.blit(text, (120, box_y + 20))
        
        for i, item in enumerate(self.inventory):
            if item in self.item_images:
                self.screen.blit(self.item_images[item], (130 + i * 60, box_y + 70))
        
        if not self.inventory:
            empty = self.font_medium.render("(Nothing bought)", True, (150, 100, 100))
            self.screen.blit(empty, (130, box_y + 80))
        
        # Continue prompt
        prompt = self.font_medium.render("Press ENTER for Mom's evaluation!", True, (100, 80, 60))
        self.screen.blit(prompt, prompt.get_rect(centerx=SCREEN_WIDTH//2, bottom=SCREEN_HEIGHT-50))
    
    def draw_evaluation(self):
        """Draw Mom's evaluation"""
        self.screen.fill((240, 230, 210))
        
        # Header
        header = self.font_large.render("📝 Mom's Evaluation 📝", True, (100, 80, 60))
        self.screen.blit(header, header.get_rect(centerx=SCREEN_WIDTH//2, top=30))
        
        # Calculate results
        correct_needs = [t for t in self.todays_tasks if t in self.inventory]
        missing_needs = [t for t in self.todays_tasks if t not in self.inventory]
        bought_wants = [i for i in self.inventory if i in WANTS]
        
        y = 100
        
        # Mom's image
        self.screen.blit(pygame.transform.scale(self.images['mom'], (80, 80)),
                        (SCREEN_WIDTH//2 - 40, y))
        y += 100
        
        # Good items
        if correct_needs:
            good_text = self.font_medium.render("✅ Great job! You got these NEEDS:", True, (60, 140, 60))
            self.screen.blit(good_text, (150, y))
            y += 40
            for item in correct_needs:
                item_text = self.font_medium.render(f"  ✓ {item.title()}", True, (80, 160, 80))
                self.screen.blit(item_text, (170, y))
                y += 30
            y += 20
        
        # Missing items
        if missing_needs:
            miss_text = self.font_medium.render("❌ Oh no! You forgot these NEEDS:", True, (180, 60, 60))
            self.screen.blit(miss_text, (150, y))
            y += 40
            for item in missing_needs:
                item_text = self.font_medium.render(f"  ✗ {item.title()}", True, (200, 80, 80))
                self.screen.blit(item_text, (170, y))
                y += 30
            y += 20
        
        # Wants bought
        if bought_wants:
            want_text = self.font_medium.render("⚠️ You spent money on WANTS:", True, (200, 150, 50))
            self.screen.blit(want_text, (150, y))
            y += 40
            for item in bought_wants:
                item_text = self.font_medium.render(f"  • {item.title()} (not essential!)", True, (180, 130, 50))
                self.screen.blit(item_text, (170, y))
                y += 30
        
        # Summary message
        y = SCREEN_HEIGHT - 150
        if len(correct_needs) == len(self.todays_tasks) and not bought_wants:
            msg = "🌟 PERFECT! You bought exactly what we needed!"
            color = GOLD
        elif len(correct_needs) == len(self.todays_tasks):
            msg = "Good job getting the needs, but be careful with wants!"
            color = (150, 200, 100)
        elif correct_needs:
            msg = "You got some needs, but we're missing important items..."
            color = (200, 180, 100)
        else:
            msg = "We didn't get any essentials! Needs come first!"
            color = (200, 100, 100)
        
        summary = self.font_medium.render(msg, True, color)
        self.screen.blit(summary, summary.get_rect(centerx=SCREEN_WIDTH//2, top=y))
        
        # Continue
        prompt = self.font_medium.render("Press ENTER to continue", True, (100, 100, 100))
        self.screen.blit(prompt, prompt.get_rect(centerx=SCREEN_WIDTH//2, bottom=SCREEN_HEIGHT-30))
    
    def draw_day_end(self):
        """Draw end of day summary"""
        self.screen.fill((40, 50, 80))
        
        result = self.day_results[-1]
        
        # Header
        header = self.font_large.render(f"🌙 Day {self.current_day} Complete! 🌙", True, GOLD)
        self.screen.blit(header, header.get_rect(centerx=SCREEN_WIDTH//2, top=50))
        
        # Score
        score_text = self.font_large.render(f"Day Score: {result['score']} points", True, WHITE)
        self.screen.blit(score_text, score_text.get_rect(centerx=SCREEN_WIDTH//2, top=130))
        
        total = self.font_medium.render(f"Total Score: {self.total_score}", True, GOLD)
        self.screen.blit(total, total.get_rect(centerx=SCREEN_WIDTH//2, top=180))
        
        # Stats
        stats_y = 250
        stats = [
            f"Tasks completed: {result['correct']}/{len(result['tasks'])}",
            f"Wants bought: {result['wrong_wants']}",
            f"Coins remaining: {self.coins}",
        ]
        
        for stat in stats:
            text = self.font_medium.render(stat, True, WHITE)
            self.screen.blit(text, text.get_rect(centerx=SCREEN_WIDTH//2, top=stats_y))
            stats_y += 40
        
        # Lesson
        lesson_y = 420
        pygame.draw.rect(self.screen, (60, 70, 100),
                        (100, lesson_y, SCREEN_WIDTH - 200, 100), border_radius=15)
        
        lesson_title = self.font_medium.render("💡 Today's Lesson:", True, GOLD)
        self.screen.blit(lesson_title, (120, lesson_y + 15))
        
        if result['correct'] == len(result['tasks']) and result['wrong_wants'] == 0:
            lesson = "Perfect! Always prioritize NEEDS over WANTS."
        elif result['wrong_wants'] > 0:
            lesson = "WANTS are tempting, but NEEDS keep us healthy and safe!"
        else:
            lesson = "Remember: Food, shelter, and health come before fun items."
        
        lesson_text = self.font_medium.render(lesson, True, WHITE)
        self.screen.blit(lesson_text, (120, lesson_y + 55))
        
        # Continue
        if self.current_day < TOTAL_DAYS:
            prompt = self.font_medium.render("Press ENTER for next day", True, (180, 180, 180))
        else:
            prompt = self.font_medium.render("Press ENTER for final results", True, GOLD)
        self.screen.blit(prompt, prompt.get_rect(centerx=SCREEN_WIDTH//2, bottom=SCREEN_HEIGHT-30))
    
    def draw_final_score(self):
        """Draw final score screen"""
        # Background gradient
        for y in range(SCREEN_HEIGHT):
            ratio = y / SCREEN_HEIGHT
            color = (int(30 + 20*ratio), int(40 + 30*ratio), int(80 - 20*ratio))
            pygame.draw.line(self.screen, color, (0, y), (SCREEN_WIDTH, y))
        
        # Title
        title = self.font_title.render("🏆 GAME COMPLETE! 🏆", True, GOLD)
        self.screen.blit(title, title.get_rect(centerx=SCREEN_WIDTH//2, top=50))
        
        # Final score
        score = self.font_title.render(f"{self.total_score} Points", True, WHITE)
        self.screen.blit(score, score.get_rect(centerx=SCREEN_WIDTH//2, top=130))
        
        # Grade
        if self.total_score >= 250:
            grade = "🌟 FINANCE CHAMPION! 🌟"
            grade_color = GOLD
        elif self.total_score >= 150:
            grade = "Great Job! You understand needs!"
            grade_color = (100, 200, 100)
        elif self.total_score >= 50:
            grade = "Good effort! Keep practicing!"
            grade_color = (200, 200, 100)
        else:
            grade = "Remember: NEEDS before WANTS!"
            grade_color = (200, 100, 100)
        
        grade_text = self.font_large.render(grade, True, grade_color)
        self.screen.blit(grade_text, grade_text.get_rect(centerx=SCREEN_WIDTH//2, top=210))
        
        # Day breakdown
        y = 300
        for result in self.day_results:
            day_text = self.font_medium.render(
                f"Day {result['day']}: {result['correct']}/{len(result['tasks'])} needs, "
                f"{result['wrong_wants']} wants → {result['score']} pts",
                True, WHITE)
            self.screen.blit(day_text, day_text.get_rect(centerx=SCREEN_WIDTH//2, top=y))
            y += 40
        
        # Final lesson
        lesson_y = 480
        pygame.draw.rect(self.screen, (50, 60, 90),
                        (100, lesson_y, SCREEN_WIDTH - 200, 120), border_radius=15)
        
        lessons = [
            "📚 What You Learned:",
            "• NEEDS are essential: food, health, warmth, shelter",
            "• WANTS are nice but not necessary",
            "• Always budget for NEEDS first!"
        ]
        
        for i, lesson in enumerate(lessons):
            color = GOLD if i == 0 else WHITE
            text = self.font_small.render(lesson, True, color)
            self.screen.blit(text, (120, lesson_y + 10 + i * 28))
        
        # Restart
        prompt = self.font_medium.render("Press ENTER to play again", True, (180, 180, 180))
        self.screen.blit(prompt, prompt.get_rect(centerx=SCREEN_WIDTH//2, bottom=SCREEN_HEIGHT-30))


def main():
    game = FinanceQuest()
    game.run()


if __name__ == "__main__":
    main()
