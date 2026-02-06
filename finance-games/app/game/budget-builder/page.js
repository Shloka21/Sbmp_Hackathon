'use client';

import { useState, useCallback } from 'react';
import Link from 'next/link';
import { usePoints, GAME_POINTS } from '@/context/PointsContext';
import styles from './page.module.css';

const MONTHLY_INCOME = 10000;
const SAVINGS_GOAL = 1000;

// Fixed needs that MUST be paid
const NEEDS = [
    { id: 'rent', name: 'Rent', emoji: '🏠', amount: 3000 },
    { id: 'food', name: 'Food', emoji: '🍚', amount: 2000 },
    { id: 'electricity', name: 'Electricity', emoji: '💡', amount: 500 },
    { id: 'school', name: 'School Fees', emoji: '📚', amount: 1500 },
];

// Optional wants - user can choose
const WANTS = [
    { id: 'movie', name: 'Movie', emoji: '🎬', amount: 300 },
    { id: 'mobile', name: 'Mobile Recharge', emoji: '📱', amount: 500 },
    { id: 'eating', name: 'Eating Outside', emoji: '🍕', amount: 600 },
    { id: 'clothes', name: 'New Clothes', emoji: '👕', amount: 1200 },
];

// Surprise events that may occur
const EVENTS = [
    { id: 'medical', name: 'Medical Emergency', emoji: '🏥', amount: 800 },
    { id: 'phone', name: 'Phone Repair', emoji: '📱🔧', amount: 600 },
    { id: 'none', name: 'No Emergency', emoji: '✨', amount: 0 },
];

/**
 * BudgetBuilderGame - Monthly budgeting & emergency planning
 * Learning: Budgeting and emergency fund importance
 */
export default function BudgetBuilderGame() {
    const { addPoints, hasWonGame } = usePoints();
    const gameId = 'budget-builder';

    const [selectedWants, setSelectedWants] = useState([]);
    const [event, setEvent] = useState(null);
    const [gameState, setGameState] = useState('planning'); // planning, event, result

    const totalNeeds = NEEDS.reduce((sum, n) => sum + n.amount, 0); // 7000
    const totalSelectedWants = selectedWants.reduce((sum, id) => {
        const want = WANTS.find(w => w.id === id);
        return sum + (want?.amount || 0);
    }, 0);
    const emergencyAmount = event?.amount || 0;
    const totalSpent = totalNeeds + totalSelectedWants + emergencyAmount;
    const remaining = MONTHLY_INCOME - totalSpent;

    // Toggle want selection
    const toggleWant = useCallback((wantId) => {
        setSelectedWants(prev =>
            prev.includes(wantId)
                ? prev.filter(id => id !== wantId)
                : [...prev, wantId]
        );
    }, []);

    // Submit budget and trigger random event
    const submitBudget = () => {
        const randomEvent = EVENTS[Math.floor(Math.random() * EVENTS.length)];
        setEvent(randomEvent);
        setGameState('event');
    };

    // Continue after event
    const showResults = () => {
        setGameState('result');
        if (remaining >= SAVINGS_GOAL) {
            addPoints(gameId, GAME_POINTS[gameId]);
        }
    };

    // Reset game
    const resetGame = () => {
        setSelectedWants([]);
        setEvent(null);
        setGameState('planning');
    };

    const isWon = remaining >= SAVINGS_GOAL;

    // Result screen
    if (gameState === 'result') {
        return (
            <div className={styles.container}>
                <div className={styles.resultScreen}>
                    <div className={styles.resultEmoji}>{isWon ? '🎉' : '😔'}</div>
                    <h1 className={styles.resultTitle}>
                        {isWon ? 'Budget Master!' : 'Try Again!'}
                    </h1>
                    <p className={styles.resultMessage}>
                        {isWon
                            ? `Great! You saved ₹${remaining} this month!`
                            : `You only have ₹${remaining}. Goal was ₹${SAVINGS_GOAL}+ savings.`
                        }
                    </p>

                    {isWon && !hasWonGame(gameId) && (
                        <div className={styles.pointsEarned}>+{GAME_POINTS[gameId]} Points! 🪙</div>
                    )}

                    <div className={styles.summary}>
                        <h3>📊 Your Budget:</h3>
                        <div className={styles.summaryRow}><span>Income</span><span>₹{MONTHLY_INCOME}</span></div>
                        <div className={styles.summaryRow}><span>Needs</span><span>-₹{totalNeeds}</span></div>
                        <div className={styles.summaryRow}><span>Wants</span><span>-₹{totalSelectedWants}</span></div>
                        {event && event.amount > 0 && (
                            <div className={styles.summaryRow}><span>{event.emoji} Emergency</span><span>-₹{event.amount}</span></div>
                        )}
                        <div className={`${styles.summaryRow} ${styles.total}`}>
                            <span>Savings</span><span className={isWon ? styles.positive : styles.negative}>₹{remaining}</span>
                        </div>
                    </div>

                    <div className={styles.lessonBox}>
                        <h3>💡 What You Learned:</h3>
                        <ul>
                            <li>Pay needs first, then consider wants</li>
                            <li>Always keep emergency fund ready</li>
                            <li>Save at least 10% of income (₹1000)</li>
                            <li>Budgeting = Income - Expenses = Savings</li>
                        </ul>
                    </div>

                    <div className={styles.resultActions}>
                        <button onClick={resetGame} className={styles.playAgainBtn}>Play Again</button>
                        <Link href="/" className={styles.homeBtn}>Back to Home</Link>
                    </div>
                </div>
            </div>
        );
    }

    // Event screen
    if (gameState === 'event') {
        return (
            <div className={styles.container}>
                <div className={styles.eventScreen}>
                    <div className={styles.eventEmoji}>{event?.emoji}</div>
                    <h2>{event?.name || 'Surprise Event!'}</h2>
                    {event?.amount > 0 ? (
                        <p>Unexpected expense: <strong>₹{event.amount}</strong></p>
                    ) : (
                        <p>No emergency this month! Lucky! 🍀</p>
                    )}
                    <button onClick={showResults} className={styles.continueBtn}>See Results →</button>
                </div>
            </div>
        );
    }

    // Planning screen
    return (
        <div className={styles.container}>
            <div className={styles.header}>
                <Link href="/" className={styles.backBtn}>← Back</Link>
                <h1 className={styles.title}>🧾 Budget Builder</h1>
            </div>

            <div className={styles.incomeCard}>
                <h3>Monthly Income</h3>
                <div className={styles.incomeAmount}>₹{MONTHLY_INCOME}</div>
            </div>

            {/* Fixed Needs */}
            <div className={styles.section}>
                <h3>📌 Fixed Needs (Must Pay)</h3>
                <div className={styles.itemsGrid}>
                    {NEEDS.map(need => (
                        <div key={need.id} className={styles.needItem}>
                            <span className={styles.itemEmoji}>{need.emoji}</span>
                            <span className={styles.itemName}>{need.name}</span>
                            <span className={styles.itemAmount}>₹{need.amount}</span>
                        </div>
                    ))}
                </div>
                <div className={styles.subtotal}>Total Needs: ₹{totalNeeds}</div>
            </div>

            {/* Optional Wants */}
            <div className={styles.section}>
                <h3>🎯 Optional Wants (Your Choice)</h3>
                <div className={styles.itemsGrid}>
                    {WANTS.map(want => (
                        <div
                            key={want.id}
                            className={`${styles.wantItem} ${selectedWants.includes(want.id) ? styles.selected : ''}`}
                            onClick={() => toggleWant(want.id)}
                        >
                            <span className={styles.itemEmoji}>{want.emoji}</span>
                            <span className={styles.itemName}>{want.name}</span>
                            <span className={styles.itemAmount}>₹{want.amount}</span>
                            <span className={styles.checkbox}>{selectedWants.includes(want.id) ? '✅' : '⬜'}</span>
                        </div>
                    ))}
                </div>
                <div className={styles.subtotal}>Selected Wants: ₹{totalSelectedWants}</div>
            </div>

            {/* Balance Preview */}
            <div className={styles.balanceCard}>
                <div className={styles.balanceRow}>
                    <span>Income</span><span>₹{MONTHLY_INCOME}</span>
                </div>
                <div className={styles.balanceRow}>
                    <span>- Needs</span><span>₹{totalNeeds}</span>
                </div>
                <div className={styles.balanceRow}>
                    <span>- Wants</span><span>₹{totalSelectedWants}</span>
                </div>
                <div className={`${styles.balanceRow} ${styles.remaining}`}>
                    <span>Remaining</span>
                    <span className={(MONTHLY_INCOME - totalNeeds - totalSelectedWants) >= SAVINGS_GOAL ? styles.good : styles.warning}>
                        ₹{MONTHLY_INCOME - totalNeeds - totalSelectedWants}
                    </span>
                </div>
                <p className={styles.goalHint}>⚠️ Keep ₹{SAVINGS_GOAL}+ for emergencies!</p>
            </div>

            <button onClick={submitBudget} className={styles.submitBtn}>
                Submit Budget 📤
            </button>
        </div>
    );
}
