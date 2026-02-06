"""
Task system for Finance Quest
Jobs that player can do to earn coins
"""
import pygame
import random
from settings import TILE_SIZE


class Task:
    """A task/job the player can do to earn coins"""
    
    TASK_TYPES = {
        'farm_work': {
            'name': 'Farm Work',
            'description': 'Help Farmer Tom harvest crops',
            'duration': 3.0,  # seconds
            'reward': 15,
            'xp': 10,
            'stamina_cost': 20,
        },
        'mining': {
            'name': 'Mining',
            'description': 'Mine for valuable minerals',
            'duration': 4.0,
            'reward': 25,
            'xp': 15,
            'stamina_cost': 30,
        },
        'delivery': {
            'name': 'Delivery',
            'description': 'Deliver packages around the village',
            'duration': 2.0,
            'reward': 10,
            'xp': 5,
            'stamina_cost': 15,
        },
        'cleaning': {
            'name': 'Cleaning',
            'description': 'Help clean up the village',
            'duration': 2.5,
            'reward': 12,
            'xp': 8,
            'stamina_cost': 10,
        }
    }
    
    def __init__(self, task_type, x, y):
        self.task_type = task_type
        self.config = self.TASK_TYPES.get(task_type, self.TASK_TYPES['farm_work'])
        self.x = x
        self.y = y
        self.rect = pygame.Rect(x, y, TILE_SIZE * 2, TILE_SIZE * 2)
        
        # Task state
        self.is_active = False
        self.progress = 0.0
        self.completed_today = False
        self.available = True
    
    @property
    def name(self):
        return self.config['name']
    
    @property
    def reward(self):
        return self.config['reward']
    
    @property
    def duration(self):
        return self.config['duration']
    
    @property
    def stamina_cost(self):
        return self.config['stamina_cost']
    
    @property
    def xp_reward(self):
        return self.config['xp']
    
    def start(self):
        """Start the task"""
        self.is_active = True
        self.progress = 0.0
    
    def update(self, dt):
        """Update task progress"""
        if self.is_active:
            self.progress += dt / self.duration
            if self.progress >= 1.0:
                self.progress = 1.0
                self.is_active = False
                self.completed_today = True
                return True  # Task complete
        return False
    
    def reset_daily(self):
        """Reset task for new day"""
        self.completed_today = False
        self.available = True
    
    def is_player_nearby(self, player):
        """Check if player is close enough to start task"""
        return self.rect.colliderect(player.rect.inflate(TILE_SIZE, TILE_SIZE))


class TaskManager:
    """Manages all tasks in the game"""
    
    def __init__(self):
        self.tasks = []
        self.active_task = None
    
    def spawn_task_locations(self):
        """Create task locations in the level"""
        # These positions match the buildings in level1.txt
        task_positions = [
            ('farm_work', 350, 352),   # Near Farm building
            ('mining', 520, 352),      # Near Mine building
        ]
        
        for task_type, x, y in task_positions:
            task = Task(task_type, x, y)
            self.tasks.append(task)
    
    def check_nearby_task(self, player):
        """Check if player is near any available task"""
        for task in self.tasks:
            if task.available and not task.completed_today and task.is_player_nearby(player):
                return task
        return None
    
    def start_task(self, task, player_stamina):
        """Start a task if player has enough stamina"""
        if player_stamina >= task.stamina_cost:
            task.start()
            self.active_task = task
            return True
        return False
    
    def update(self, dt):
        """Update active task"""
        if self.active_task:
            complete = self.active_task.update(dt)
            if complete:
                completed_task = self.active_task
                self.active_task = None
                return completed_task
        return None
    
    def get_progress(self):
        """Get current task progress (0-1)"""
        if self.active_task:
            return self.active_task.progress
        return 0.0
    
    def is_working(self):
        """Check if player is currently working"""
        return self.active_task is not None
    
    def reset_daily(self):
        """Reset all tasks for new day"""
        for task in self.tasks:
            task.reset_daily()
        self.active_task = None
    
    def draw_task_areas(self, screen, camera_offset):
        """Draw task interaction areas (debug)"""
        for task in self.tasks:
            if task.available and not task.completed_today:
                rect = pygame.Rect(
                    task.x - camera_offset[0],
                    task.y - camera_offset[1],
                    task.rect.width,
                    task.rect.height
                )
                pygame.draw.rect(screen, (100, 200, 100), rect, 2)
