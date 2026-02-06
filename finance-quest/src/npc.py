"""
NPC system for Finance Quest
Handles NPCs, dialogue, and interactions
"""
import pygame
import os
from settings import TILE_SIZE, NPC_PATH, XP_TALK_NPC


class NPC(pygame.sprite.Sprite):
    """Non-player character with dialogue"""
    
    DIALOGUES = {
        'elder_martha': [
            "Welcome, young Alex!",
            "Winter is coming soon...",
            "Remember: a full stomach is worth more than a fancy hat when the snow falls!",
            "Buy what you NEED first, then consider your WANTS.",
        ],
        'merchant_pete': [
            "Psst! Over here, friend!",
            "I have the finest goods in all the land!",
            "This golden crown is RARE! Only 35 coins!",
            "You'll regret not buying it... or will you?",
        ],
        'farmer_tom': [
            "Howdy there, young one!",
            "Vegetables might not be exciting...",
            "But they'll keep you strong through the cold winter.",
            "A warm coat and food - that's what you really need!",
        ],
        'mom': [
            "How's the shopping going, dear?",
            "Remember what I told you:",
            "NEEDS first, WANTS later - if there's money left!",
            "I believe in you, Alex. Make wise choices!",
        ],
    }
    
    def __init__(self, x, y, npc_type):
        super().__init__()
        self.npc_type = npc_type
        self.name = self.get_display_name()
        
        # Load image
        self.image = self.load_image()
        self.rect = self.image.get_rect()
        self.rect.x = x
        self.rect.y = y
        
        # Dialogue
        self.dialogues = self.DIALOGUES.get(npc_type, ["Hello!"])
        self.current_dialogue_index = 0
        self.has_been_talked_to = False
        
        # Interaction range
        self.interaction_range = TILE_SIZE * 2
    
    def get_display_name(self):
        """Get formatted display name"""
        names = {
            'elder_martha': 'Elder Martha',
            'merchant_pete': 'Merchant Pete',
            'farmer_tom': 'Farmer Tom',
            'mom': 'Mom',
        }
        return names.get(self.npc_type, 'Villager')
    
    def load_image(self):
        """Load NPC image"""
        path = os.path.join(NPC_PATH, f"{self.npc_type}.png")
        
        if os.path.exists(path):
            img = pygame.image.load(path).convert_alpha()
            return pygame.transform.scale(img, (TILE_SIZE, TILE_SIZE))
        else:
            return self.create_placeholder()
    
    def create_placeholder(self):
        """Create placeholder NPC sprite"""
        surface = pygame.Surface((TILE_SIZE, TILE_SIZE), pygame.SRCALPHA)
        
        colors = {
            'elder_martha': (128, 70, 128),
            'merchant_pete': (60, 120, 60),
            'farmer_tom': (100, 140, 180),
            'mom': (180, 80, 80),
        }
        
        color = colors.get(self.npc_type, (100, 100, 100))
        
        # Body
        pygame.draw.rect(surface, color, (10, 12, 12, 14))
        # Head
        pygame.draw.ellipse(surface, (255, 200, 150), (9, 2, 14, 12))
        # Eyes
        pygame.draw.circle(surface, (50, 50, 50), (14, 7), 1)
        pygame.draw.circle(surface, (50, 50, 50), (18, 7), 1)
        
        return surface
    
    def is_player_in_range(self, player):
        """Check if player is close enough to interact"""
        distance = ((self.rect.centerx - player.rect.centerx) ** 2 + 
                   (self.rect.centery - player.rect.centery) ** 2) ** 0.5
        return distance < self.interaction_range
    
    def get_current_dialogue(self):
        """Get current dialogue line"""
        if self.current_dialogue_index < len(self.dialogues):
            return self.dialogues[self.current_dialogue_index]
        return None
    
    def advance_dialogue(self):
        """Move to next dialogue line"""
        self.current_dialogue_index += 1
        if self.current_dialogue_index >= len(self.dialogues):
            self.current_dialogue_index = 0
            return True  # Dialogue complete
        return False
    
    def start_conversation(self):
        """Start or restart conversation"""
        first_time = not self.has_been_talked_to
        self.has_been_talked_to = True
        self.current_dialogue_index = 0
        return first_time  # Returns True if first time (for XP)
    
    def get_xp_reward(self):
        """Get XP for first conversation"""
        return XP_TALK_NPC


class NPCManager:
    """Manages all NPCs in the level"""
    
    def __init__(self):
        self.npcs = pygame.sprite.Group()
        self.active_npc = None
        self.in_dialogue = False
    
    def spawn_npc(self, x, y, npc_type):
        """Spawn an NPC"""
        npc = NPC(x, y, npc_type)
        self.npcs.add(npc)
        return npc
    
    def spawn_level_npcs(self):
        """Spawn NPCs for the level"""
        npc_positions = [
            (100, 432, 'mom'),
            (350, 432, 'elder_martha'),
            (550, 400, 'merchant_pete'),
            (750, 432, 'farmer_tom'),
        ]
        
        for x, y, npc_type in npc_positions:
            self.spawn_npc(x, y - TILE_SIZE, npc_type)
    
    def check_interaction(self, player):
        """Check if player can interact with any NPC"""
        for npc in self.npcs:
            if npc.is_player_in_range(player):
                return npc
        return None
    
    def start_dialogue(self, npc):
        """Start dialogue with NPC"""
        self.active_npc = npc
        self.in_dialogue = True
        return npc.start_conversation()
    
    def advance_dialogue(self):
        """Advance current dialogue"""
        if self.active_npc:
            complete = self.active_npc.advance_dialogue()
            if complete:
                self.end_dialogue()
            return complete
        return True
    
    def end_dialogue(self):
        """End current dialogue"""
        self.active_npc = None
        self.in_dialogue = False
    
    def get_current_dialogue_text(self):
        """Get current dialogue text"""
        if self.active_npc:
            return self.active_npc.get_current_dialogue()
        return None
    
    def get_current_npc_name(self):
        """Get current NPC name"""
        if self.active_npc:
            return self.active_npc.name
        return None
    
    def draw(self, screen, camera_offset=(0, 0)):
        """Draw all NPCs"""
        for npc in self.npcs:
            screen.blit(npc.image,
                       (npc.rect.x - camera_offset[0],
                        npc.rect.y - camera_offset[1]))
            
            # Draw interaction indicator if player nearby
            # (This would need player reference - handled in main game)
