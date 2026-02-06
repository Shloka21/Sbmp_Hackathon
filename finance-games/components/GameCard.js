'use client';

import Link from 'next/link';
import styles from './GameCard.module.css';
import { usePoints } from '@/context/PointsContext';
import { GAME_POINTS } from '@/context/PointsContext';

/**
 * GameCard - Displays a game option on the homepage
 * Props:
 * - id: unique game identifier for routing
 * - title: game name
 * - description: short game description
 * - emoji: icon for the game
 * - color: accent color for the card
 */
export default function GameCard({ id, title, description, emoji, color }) {
    const { hasWonGame } = usePoints();
    const isCompleted = hasWonGame(id);
    const pointsValue = GAME_POINTS[id] || 0;

    return (
        <Link href={`/game/${id}`} className={styles.cardLink}>
            <div
                className={`${styles.card} ${isCompleted ? styles.completed : ''}`}
                style={{ '--accent-color': color }}
            >
                {/* Completion Badge */}
                {isCompleted && (
                    <div className={styles.completedBadge}>
                        ✅ Completed
                    </div>
                )}

                {/* Game Icon */}
                <div className={styles.emojiContainer}>
                    <span className={styles.emoji}>{emoji}</span>
                </div>

                {/* Game Info */}
                <h3 className={styles.title}>{title}</h3>
                <p className={styles.description}>{description}</p>

                {/* Points & Play Button */}
                <div className={styles.footer}>
                    <span className={styles.points}>+{pointsValue} 🪙</span>
                    <span className={styles.playButton}>
                        {isCompleted ? 'Play Again' : 'Play Now'} →
                    </span>
                </div>
            </div>
        </Link>
    );
}
