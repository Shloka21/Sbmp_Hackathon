"""
Economy and XP system for Finance Quest
Handles coins, XP, levels, and scoring
"""
import json
import os
from settings import (
    STARTING_COINS, STARTING_XP, STARTING_HEALTH, MAX_HEALTH,
    LEVEL_THRESHOLDS, LEVEL_TITLES, BASE_DIR
)


class Economy:
    """Manages player's coins, XP, and level"""
    
    def __init__(self):
        self.coins = STARTING_COINS
        self.xp = STARTING_XP
        self.level = 1
        self.health = STARTING_HEALTH
        self.max_health = MAX_HEALTH
        
        # Tracking
        self.total_spent = 0
        self.needs_bought = 0
        self.wants_bought = 0
        self.correct_choices = 0
        self.wrong_choices = 0
    
    def add_coins(self, amount):
        """Add coins"""
        self.coins += amount
    
    def spend_coins(self, amount):
        """Spend coins, returns True if successful"""
        if self.coins >= amount:
            self.coins -= amount
            self.total_spent += amount
            return True
        return False
    
    def can_afford(self, amount):
        """Check if can afford amount"""
        return self.coins >= amount
    
    def add_xp(self, amount):
        """Add XP and check for level up"""
        self.xp += amount
        if self.xp < 0:
            self.xp = 0
        self.check_level_up()
    
    def check_level_up(self):
        """Check and handle level up"""
        for lvl in sorted(LEVEL_THRESHOLDS.keys(), reverse=True):
            if self.xp >= LEVEL_THRESHOLDS[lvl] and lvl > self.level:
                self.level = lvl
                return True
        return False
    
    def get_level_title(self):
        """Get current level title"""
        return LEVEL_TITLES.get(self.level, "Beginner")
    
    def get_xp_progress(self):
        """Get XP progress to next level (0-1)"""
        current_threshold = LEVEL_THRESHOLDS.get(self.level, 0)
        next_threshold = LEVEL_THRESHOLDS.get(self.level + 1)
        
        if next_threshold is None:
            return 1.0  # Max level
        
        progress = (self.xp - current_threshold) / (next_threshold - current_threshold)
        return min(1.0, max(0.0, progress))
    
    def get_xp_to_next_level(self):
        """Get XP needed for next level"""
        next_threshold = LEVEL_THRESHOLDS.get(self.level + 1)
        if next_threshold is None:
            return 0
        return next_threshold - self.xp
    
    def record_purchase(self, item, was_correct):
        """Record a purchase decision"""
        if item.is_need:
            self.needs_bought += 1
        else:
            self.wants_bought += 1
        
        if was_correct:
            self.correct_choices += 1
        else:
            self.wrong_choices += 1
    
    def take_damage(self, amount=1):
        """Reduce health"""
        self.health -= amount
        if self.health < 0:
            self.health = 0
    
    def heal(self, amount=1):
        """Restore health"""
        self.health += amount
        if self.health > self.max_health:
            self.health = self.max_health
    
    def calculate_final_score(self):
        """Calculate final score for leaderboard"""
        score = self.xp
        score += self.coins * 5  # Saved coins bonus
        score += self.correct_choices * 10
        score -= self.wrong_choices * 5
        return max(0, score)
    
    def get_ending_type(self):
        """Determine ending based on choices"""
        if self.needs_bought >= 5 and self.coins > 0:
            return 'perfect'
        elif self.needs_bought >= 5:
            return 'good'
        elif self.needs_bought >= 3:
            return 'warning'
        else:
            return 'failure'


class Leaderboard:
    """Manages high scores"""
    
    def __init__(self):
        self.scores_file = os.path.join(BASE_DIR, "leaderboard.json")
        self.scores = self.load_scores()
    
    def load_scores(self):
        """Load scores from file"""
        if os.path.exists(self.scores_file):
            try:
                with open(self.scores_file, 'r') as f:
                    return json.load(f)
            except:
                return []
        return []
    
    def save_scores(self):
        """Save scores to file"""
        with open(self.scores_file, 'w') as f:
            json.dump(self.scores, f, indent=2)
    
    def add_score(self, name, score, level, ending):
        """Add a new score"""
        from datetime import datetime
        
        entry = {
            'name': name[:12],  # Limit name length
            'score': score,
            'level': level,
            'ending': ending,
            'date': datetime.now().strftime("%Y-%m-%d")
        }
        
        self.scores.append(entry)
        self.scores.sort(key=lambda x: x['score'], reverse=True)
        self.scores = self.scores[:10]  # Keep top 10
        self.save_scores()
        
        return self.get_rank(score)
    
    def get_rank(self, score):
        """Get rank for a score"""
        for i, entry in enumerate(self.scores):
            if entry['score'] == score:
                return i + 1
        return len(self.scores)
    
    def get_top_scores(self, count=10):
        """Get top scores"""
        return self.scores[:count]
    
    def is_high_score(self, score):
        """Check if score qualifies for leaderboard"""
        if len(self.scores) < 10:
            return True
        return score > self.scores[-1]['score']
