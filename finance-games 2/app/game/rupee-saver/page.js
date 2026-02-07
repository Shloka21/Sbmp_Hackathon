'use client';

import { useState, useCallback } from 'react';
import Link from 'next/link';
import { usePoints, GAME_POINTS } from '@/context/PointsContext';
import styles from './page.module.css';

// Daily items that appear for the player to categorize
const DAILY_ITEMS = [
    { id: 'tea', name: 'Tea', emoji: '☕', price: 10, type: 'need' },
    { id: 'vegetables', name: 'Vegetables', emoji: '🥬', price: 50, type: 'need' },
    { id: 'cigarettes', name: 'Cigarettes', emoji: '🚬', price: 20, type: 'want' },
    { id: 'biscuits', name: 'Biscuits', emoji: '🍪', price: 15, type: 'want' },
    { id: 'transport', name: 'Transport', emoji: '🚌', price: 30, type: 'need' },
    { id: 'samosa', name: 'Samosa', emoji: '🥟', price: 15, type: 'want' },
    { id: 'medicine', name: 'Medicine', emoji: '💊', price: 40, type: 'need' },
    { id: 'chips', name: 'Chips', emoji: '🍟', price: 20, type: 'want' },
];

const DAILY_INCOME = 300;
const MIN_SAVINGS_GOAL = 50;
const TOTAL_DAYS = 7; // Shortened for faster gameplay

/**
 * RupeeSaverGame - Drag & Drop daily expense game
 * 
 * Learning Outcome:
 * - Understand the difference between NEEDS and WANTS
 * - Develop daily saving habits
 * - See how small savings accumulate over time
 */
export default function RupeeSaverGame() {
    const { addPoints, hasWonGame } = usePoints();
    const gameId = 'rupee-saver';

    // Game state
    const [currentDay, setCurrentDay] = useState(1);
    const [totalSavings, setTotalSavings] = useState(0);
    const [dailySpent, setDailySpent] = useState(0);
    const [availableItems, setAvailableItems] = useState(getRandomItems());
    const [spendBasket, setSpendBasket] = useState([]);
    const [saveJar, setSaveJar] = useState([]);
    const [gameState, setGameState] = useState('playing'); // playing, won, lost
    const [draggedItem, setDraggedItem] = useState(null);
    const [dailyHistory, setDailyHistory] = useState([]);

    // Get random subset of items for each day
    function getRandomItems() {
        const shuffled = [...DAILY_ITEMS].sort(() => Math.random() - 0.5);
        return shuffled.slice(0, 5);
    }

    // Calculate daily savings
    const dailySaved = DAILY_INCOME - dailySpent;
    const canEndDay = availableItems.length === 0;
    const metGoal = dailySaved >= MIN_SAVINGS_GOAL;

    // Handle drag start
    const handleDragStart = (e, item) => {
        setDraggedItem(item);
        e.dataTransfer.effectAllowed = 'move';
    };

    // Handle drop on spend basket
    const handleDropSpend = (e) => {
        e.preventDefault();
        if (draggedItem) {
            setSpendBasket([...spendBasket, draggedItem]);
            setDailySpent(prev => prev + draggedItem.price);
            setAvailableItems(items => items.filter(i => i.id !== draggedItem.id));
            setDraggedItem(null);
        }
    };

    // Handle drop on save jar
    const handleDropSave = (e) => {
        e.preventDefault();
        if (draggedItem) {
            setSaveJar([...saveJar, draggedItem]);
            setAvailableItems(items => items.filter(i => i.id !== draggedItem.id));
            setDraggedItem(null);
        }
    };

    // Allow drop
    const handleDragOver = (e) => {
        e.preventDefault();
    };

    // End day and move to next
    const endDay = useCallback(() => {
        const saved = DAILY_INCOME - dailySpent;
        setDailyHistory(prev => [...prev, { day: currentDay, saved, spent: dailySpent }]);
        setTotalSavings(prev => prev + saved);

        if (currentDay >= TOTAL_DAYS) {
            // Game over - check if won
            const avgSavings = (totalSavings + saved) / TOTAL_DAYS;
            if (avgSavings >= MIN_SAVINGS_GOAL) {
                setGameState('won');
                addPoints(gameId, GAME_POINTS[gameId]);
            } else {
                setGameState('lost');
            }
        } else {
            // Next day
            setCurrentDay(prev => prev + 1);
            setDailySpent(0);
            setSpendBasket([]);
            setSaveJar([]);
            setAvailableItems(getRandomItems());
        }
    }, [currentDay, dailySpent, totalSavings, addPoints, gameId]);

    // Reset game
    const resetGame = () => {
        setCurrentDay(1);
        setTotalSavings(0);
        setDailySpent(0);
        setAvailableItems(getRandomItems());
        setSpendBasket([]);
        setSaveJar([]);
        setGameState('playing');
        setDailyHistory([]);
    };

    // Render win/lose screen
    if (gameState !== 'playing') {
        const isWon = gameState === 'won';
        const avgSavings = totalSavings / TOTAL_DAYS;

        return (
            <div className={styles.container}>
                <div className={styles.resultScreen}>
                    <div className={styles.resultEmoji}>
                        {isWon ? '🎉' : '😔'}
                    </div>
                    <h1 className={styles.resultTitle}>
                        {isWon ? 'Congratulations!' : 'Try Again!'}
                    </h1>
                    <p className={styles.resultMessage}>
                        {isWon
                            ? `You saved an average of ₹${Math.round(avgSavings)} per day!`
                            : `You saved only ₹${Math.round(avgSavings)} per day. Goal was ₹${MIN_SAVINGS_GOAL}.`
                        }
                    </p>

                    {isWon && !hasWonGame(gameId) && (
                        <div className={styles.pointsEarned}>
                            +{GAME_POINTS[gameId]} Points! 🪙
                        </div>
                    )}

                    <div className={styles.savingsJar}>
                        <span className={styles.jarEmoji}>🏺</span>
                        <span className={styles.jarAmount}>₹{totalSavings} Total Saved!</span>
                    </div>

                    <div className={styles.lessonBox}>
                        <h3>💡 What You Learned:</h3>
                        <ul>
                            <li>Needs are essential (food, transport, medicine)</li>
                            <li>Wants can wait (snacks, treats)</li>
                            <li>Small daily savings add up quickly!</li>
                        </ul>
                    </div>

                    <div className={styles.resultActions}>
                        <button onClick={resetGame} className={styles.playAgainBtn}>
                            Play Again
                        </button>
                        <Link href="/" className={styles.homeBtn}>
                            Back to Home
                        </Link>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={styles.container}>
            {/* Game Header */}
            <div className={styles.header}>
                <Link href="/" className={styles.backBtn}>← Back</Link>
                <h1 className={styles.title}>🏺 Rupee Saver</h1>
            </div>

            {/* Day Info */}
            <div className={styles.dayInfo}>
                <div className={styles.dayBadge}>Day {currentDay} of {TOTAL_DAYS}</div>
                <div className={styles.income}>
                    Daily Income: <span>₹{DAILY_INCOME}</span>
                </div>
            </div>

            {/* Stats Row */}
            <div className={styles.statsRow}>
                <div className={styles.statCard}>
                    <span className={styles.statLabel}>Spent Today</span>
                    <span className={styles.statValue + ' ' + styles.spent}>₹{dailySpent}</span>
                </div>
                <div className={styles.statCard}>
                    <span className={styles.statLabel}>Saving Today</span>
                    <span className={`${styles.statValue} ${metGoal ? styles.goalMet : styles.goalNotMet}`}>
                        ₹{dailySaved}
                    </span>
                </div>
                <div className={styles.statCard}>
                    <span className={styles.statLabel}>Total Savings</span>
                    <span className={styles.statValue + ' ' + styles.total}>₹{totalSavings}</span>
                </div>
            </div>

            {/* Goal Indicator */}
            <div className={`${styles.goalIndicator} ${metGoal ? styles.goalMetBg : ''}`}>
                {metGoal
                    ? `✅ Great! You're saving ₹${dailySaved} today (Goal: ₹${MIN_SAVINGS_GOAL}+)`
                    : `⚠️ Save at least ₹${MIN_SAVINGS_GOAL} today! Currently: ₹${dailySaved}`
                }
            </div>

            {/* Items to Categorize */}
            <div className={styles.itemsSection}>
                <h3>Drag items to SPEND or SAVE:</h3>
                <div className={styles.itemsGrid}>
                    {availableItems.map(item => (
                        <div
                            key={item.id}
                            className={styles.itemCard}
                            draggable
                            onDragStart={(e) => handleDragStart(e, item)}
                        >
                            <span className={styles.itemEmoji}>{item.emoji}</span>
                            <span className={styles.itemName}>{item.name}</span>
                            <span className={styles.itemPrice}>₹{item.price}</span>
                        </div>
                    ))}
                    {availableItems.length === 0 && (
                        <p className={styles.allDone}>All items categorized! Click &quot;End Day&quot; to continue.</p>
                    )}
                </div>
            </div>

            {/* Drop Zones */}
            <div className={styles.dropZones}>
                {/* Spend Basket */}
                <div
                    className={styles.dropZone + ' ' + styles.spendZone}
                    onDrop={handleDropSpend}
                    onDragOver={handleDragOver}
                >
                    <div className={styles.zoneHeader}>
                        <span>🧺 SPEND</span>
                    </div>
                    <div className={styles.zoneItems}>
                        {spendBasket.map(item => (
                            <div key={item.id} className={styles.droppedItem}>
                                <span>{item.emoji}</span>
                                <span>₹{item.price}</span>
                            </div>
                        ))}
                    </div>
                    <div className={styles.zoneTotal}>Total: ₹{dailySpent}</div>
                </div>

                {/* Save Jar */}
                <div
                    className={styles.dropZone + ' ' + styles.saveZone}
                    onDrop={handleDropSave}
                    onDragOver={handleDragOver}
                >
                    <div className={styles.zoneHeader}>
                        <span>🏺 SAVE</span>
                    </div>
                    <div className={styles.zoneItems}>
                        {saveJar.map(item => (
                            <div key={item.id} className={styles.droppedItem}>
                                <span>{item.emoji}</span>
                                <span>Skip!</span>
                            </div>
                        ))}
                    </div>
                    <div className={styles.zoneTotal}>Saved: ₹{dailySaved}</div>
                </div>
            </div>

            {/* End Day Button */}
            {canEndDay && (
                <button
                    onClick={endDay}
                    className={styles.endDayBtn}
                >
                    End Day {currentDay} →
                </button>
            )}

            {/* Daily History */}
            {dailyHistory.length > 0 && (
                <div className={styles.history}>
                    <h4>📊 Your Progress:</h4>
                    <div className={styles.historyBars}>
                        {dailyHistory.map(day => (
                            <div key={day.day} className={styles.historyBar}>
                                <div
                                    className={styles.barFill}
                                    style={{ height: `${(day.saved / DAILY_INCOME) * 100}%` }}
                                />
                                <span>D{day.day}</span>
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}
