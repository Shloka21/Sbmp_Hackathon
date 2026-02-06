"""
Player Status system for Finance Quest
Handles hunger, stamina, warmth, and health with consequences
"""
import pygame
from settings import MAX_HEALTH


class PlayerStatus:
    """Manages player's vital stats: hunger, stamina, warmth, health"""
    
    def __init__(self):
        # Health (hearts)
        self.health = MAX_HEALTH
        self.max_health = MAX_HEALTH
        
        # Hunger (0-100, depletes over time)
        self.hunger = 100
        self.max_hunger = 100
        self.hunger_drain_rate = 2  # Per second
        
        # Stamina (0-100, used for tasks, regenerates)
        self.stamina = 100
        self.max_stamina = 100
        self.stamina_regen_rate = 5  # Per second
        
        # Warmth (0-100, important for winter)
        self.warmth = 100
        self.max_warmth = 100
        self.warmth_drain_rate = 1  # Per second
        
        # Happiness (0-100, affects XP gain)
        self.happiness = 50
        self.max_happiness = 100
        
        # Timers for damage from low stats
        self.hunger_damage_timer = 0
        self.warmth_damage_timer = 0
        self.damage_interval = 3.0  # Seconds between damage ticks
        
        # Day tracking
        self.current_day = 1
        self.days_survived = 0
        
        # Alert flags
        self.hunger_warning = False
        self.warmth_warning = False
        self.stamina_warning = False
    
    def update(self, dt):
        """Update stats over time, return list of events"""
        events = []
        
        # Drain hunger
        self.hunger -= self.hunger_drain_rate * dt
        if self.hunger < 0:
            self.hunger = 0
        
        # Drain warmth
        self.warmth -= self.warmth_drain_rate * dt
        if self.warmth < 0:
            self.warmth = 0
        
        # Regenerate stamina (if not starving)
        if self.hunger > 20:
            self.stamina += self.stamina_regen_rate * dt
            if self.stamina > self.max_stamina:
                self.stamina = self.max_stamina
        
        # Check for warnings
        self.hunger_warning = self.hunger < 30
        self.warmth_warning = self.warmth < 30
        self.stamina_warning = self.stamina < 20
        
        # Damage from starvation
        if self.hunger <= 0:
            self.hunger_damage_timer += dt
            if self.hunger_damage_timer >= self.damage_interval:
                self.hunger_damage_timer = 0
                self.health -= 1
                events.append('hunger_damage')
        else:
            self.hunger_damage_timer = 0
        
        # Damage from cold
        if self.warmth <= 0:
            self.warmth_damage_timer += dt
            if self.warmth_damage_timer >= self.damage_interval:
                self.warmth_damage_timer = 0
                self.health -= 1
                events.append('cold_damage')
        else:
            self.warmth_damage_timer = 0
        
        # Check for death
        if self.health <= 0:
            events.append('death')
        
        return events
    
    def add_hunger(self, amount):
        """Add hunger (eating)"""
        self.hunger += amount
        if self.hunger > self.max_hunger:
            self.hunger = self.max_hunger
    
    def add_health(self, amount):
        """Add health"""
        self.health += amount
        if self.health > self.max_health:
            self.health = self.max_health
    
    def add_warmth(self, amount):
        """Add warmth"""
        self.warmth += amount
        if self.warmth > self.max_warmth:
            self.warmth = self.max_warmth
    
    def add_happiness(self, amount):
        """Add happiness"""
        self.happiness += amount
        if self.happiness > self.max_happiness:
            self.happiness = self.max_happiness
    
    def use_stamina(self, amount):
        """Use stamina for task, returns True if enough"""
        if self.stamina >= amount:
            self.stamina -= amount
            return True
        return False
    
    def can_work(self, stamina_cost):
        """Check if player can do a task"""
        return self.stamina >= stamina_cost
    
    def new_day(self):
        """Handle new day - some stats reset/change"""
        self.current_day += 1
        self.days_survived += 1
        
        # Morning: slight warmth recovery, hunger decrease
        self.warmth = min(100, self.warmth + 20)
        self.hunger = max(0, self.hunger - 30)
        
        # Happiness slightly decreases if needs not met
        if self.hunger < 50 or self.warmth < 50:
            self.happiness = max(0, self.happiness - 10)
    
    def get_status_text(self):
        """Get status summary text"""
        statuses = []
        if self.hunger < 30:
            statuses.append("HUNGRY!")
        if self.warmth < 30:
            statuses.append("COLD!")
        if self.stamina < 20:
            statuses.append("TIRED!")
        if self.health < 3:
            statuses.append("LOW HEALTH!")
        return ' | '.join(statuses) if statuses else "Feeling good!"
    
    def get_xp_multiplier(self):
        """Get XP multiplier based on happiness"""
        if self.happiness >= 80:
            return 1.5
        elif self.happiness >= 50:
            return 1.0
        else:
            return 0.75


class StatusUI:
    """UI for displaying player status bars"""
    
    def __init__(self):
        self.font = pygame.font.Font(None, 20)
    
    def draw(self, screen, status):
        """Draw status bars on screen"""
        bar_width = 100
        bar_height = 12
        start_x = 10
        start_y = 80  # Below health hearts
        spacing = 20
        
        stats = [
            ('Hunger', status.hunger, status.max_hunger, (200, 150, 50), status.hunger_warning),
            ('Stamina', status.stamina, status.max_stamina, (50, 200, 50), status.stamina_warning),
            ('Warmth', status.warmth, status.max_warmth, (200, 100, 50), status.warmth_warning),
        ]
        
        for i, (name, value, max_val, color, warning) in enumerate(stats):
            y = start_y + i * spacing
            
            # Label
            label = self.font.render(name[:3], True, (255, 255, 255))
            screen.blit(label, (start_x, y))
            
            # Background
            bg_rect = pygame.Rect(start_x + 30, y, bar_width, bar_height)
            pygame.draw.rect(screen, (40, 40, 40), bg_rect, border_radius=3)
            
            # Fill
            fill_width = int((value / max_val) * bar_width)
            if fill_width > 0:
                fill_color = (200, 50, 50) if warning else color
                fill_rect = pygame.Rect(start_x + 30, y, fill_width, bar_height)
                pygame.draw.rect(screen, fill_color, fill_rect, border_radius=3)
            
            # Border
            pygame.draw.rect(screen, (80, 80, 80), bg_rect, 1, border_radius=3)
            
            # Value text
            val_text = self.font.render(f"{int(value)}", True, (255, 255, 255))
            screen.blit(val_text, (start_x + 35 + bar_width, y))
        
        # Warning message
        if status.hunger_warning or status.warmth_warning:
            warning_text = status.get_status_text()
            warning = self.font.render(warning_text, True, (255, 100, 100))
            screen.blit(warning, (start_x, start_y + len(stats) * spacing + 5))
        
        # Day counter
        day_text = self.font.render(f"Day {status.current_day}", True, (255, 255, 255))
        screen.blit(day_text, (start_x, start_y + len(stats) * spacing + 25))
