'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePoints, GAME_POINTS } from '@/context/PointsContext';
import styles from './page.module.css';

const INTEREST_RATE = 0.08; // 8% annual interest
const INITIAL_AMOUNT = 100;
const TOTAL_YEARS = 5;

// Tree growth stages with emojis
const TREE_STAGES = ['🌱', '🌿', '🌳', '🌲', '🌲'];

// Comparison scenarios
const SCENARIOS = {
    bank: { name: 'Bank Savings', emoji: '🏦', rate: INTEREST_RATE },
    home: { name: 'Home Storage', emoji: '🏠', rate: 0 },
    moneylender: { name: 'Moneylender', emoji: '💸', rate: -0.15 }, // 15% loss per year
};

/**
 * InterestMagicGame - Visual compound interest simulator
 * 
 * Learning Outcome:
 * - Understand how compound interest grows money
 * - See why banks are better than keeping cash at home
 * - Learn dangers of moneylenders
 */
export default function InterestMagicGame() {
    const { addPoints, hasWonGame } = usePoints();
    const gameId = 'interest-magic';

    // Game state
    const [currentYear, setCurrentYear] = useState(0);
    const [amounts, setAmounts] = useState({
        bank: INITIAL_AMOUNT,
        home: INITIAL_AMOUNT,
        moneylender: INITIAL_AMOUNT,
    });
    const [gameState, setGameState] = useState('intro'); // intro, playing, won
    const [animating, setAnimating] = useState(false);

    // Calculate compound interest for a given scenario
    const calculateGrowth = (principal, rate, years) => {
        return Math.round(principal * Math.pow(1 + rate, years));
    };

    // Start the game
    const startGame = () => {
        setGameState('playing');
        setCurrentYear(0);
        setAmounts({
            bank: INITIAL_AMOUNT,
            home: INITIAL_AMOUNT,
            moneylender: INITIAL_AMOUNT,
        });
    };

    // Progress to next year
    const nextYear = () => {
        if (animating) return;

        setAnimating(true);

        setTimeout(() => {
            const newYear = currentYear + 1;
            setCurrentYear(newYear);

            // Calculate new amounts
            setAmounts({
                bank: calculateGrowth(INITIAL_AMOUNT, SCENARIOS.bank.rate, newYear),
                home: calculateGrowth(INITIAL_AMOUNT, SCENARIOS.home.rate, newYear),
                moneylender: Math.max(0, calculateGrowth(INITIAL_AMOUNT, SCENARIOS.moneylender.rate, newYear)),
            });

            if (newYear >= TOTAL_YEARS) {
                setGameState('won');
                addPoints(gameId, GAME_POINTS[gameId]);
            }

            setAnimating(false);
        }, 500);
    };

    // Reset game
    const resetGame = () => {
        setGameState('intro');
        setCurrentYear(0);
        setAmounts({
            bank: INITIAL_AMOUNT,
            home: INITIAL_AMOUNT,
            moneylender: INITIAL_AMOUNT,
        });
    };

    // Get tree stage based on current year
    const getTreeStage = (year) => TREE_STAGES[Math.min(year, TREE_STAGES.length - 1)];

    // Render intro screen
    if (gameState === 'intro') {
        return (
            <div className={styles.container}>
                <div className={styles.header}>
                    <Link href="/" className={styles.backBtn}>← Back</Link>
                    <h1 className={styles.title}>🌳 Interest Magic</h1>
                </div>

                <div className={styles.introScreen}>
                    <div className={styles.introEmoji}>🌱</div>
                    <h2>Watch Your Money Grow!</h2>
                    <p>You have ₹100 to save. Let&apos;s see what happens over 5 years with different choices:</p>

                    <div className={styles.scenarioCards}>
                        <div className={styles.scenarioIntro}>
                            <span>🏦</span>
                            <h3>Bank</h3>
                            <p>8% interest per year</p>
                        </div>
                        <div className={styles.scenarioIntro}>
                            <span>🏠</span>
                            <h3>Home</h3>
                            <p>Stays the same</p>
                        </div>
                        <div className={styles.scenarioIntro}>
                            <span>💸</span>
                            <h3>Moneylender</h3>
                            <p>15% lost per year!</p>
                        </div>
                    </div>

                    <button onClick={startGame} className={styles.startBtn}>
                        Plant Your Money Seed! 🌱
                    </button>
                </div>
            </div>
        );
    }

    // Render win screen
    if (gameState === 'won') {
        return (
            <div className={styles.container}>
                <div className={styles.resultScreen}>
                    <div className={styles.resultEmoji}>🎉</div>
                    <h1 className={styles.resultTitle}>Amazing!</h1>
                    <p className={styles.resultMessage}>
                        You watched your money grow for {TOTAL_YEARS} years!
                    </p>

                    {!hasWonGame(gameId) && (
                        <div className={styles.pointsEarned}>
                            +{GAME_POINTS[gameId]} Points! 🪙
                        </div>
                    )}

                    {/* Final Comparison */}
                    <div className={styles.finalComparison}>
                        <h3>After {TOTAL_YEARS} Years, ₹100 became:</h3>
                        <div className={styles.finalResults}>
                            <div className={styles.finalCard + ' ' + styles.bankCard}>
                                <span className={styles.finalEmoji}>🏦🌲</span>
                                <span className={styles.finalAmount}>₹{amounts.bank}</span>
                                <span className={styles.finalLabel}>Bank (+₹{amounts.bank - INITIAL_AMOUNT})</span>
                            </div>
                            <div className={styles.finalCard + ' ' + styles.homeCard}>
                                <span className={styles.finalEmoji}>🏠</span>
                                <span className={styles.finalAmount}>₹{amounts.home}</span>
                                <span className={styles.finalLabel}>Home (No change)</span>
                            </div>
                            <div className={styles.finalCard + ' ' + styles.lenderCard}>
                                <span className={styles.finalEmoji}>💸😢</span>
                                <span className={styles.finalAmount}>₹{amounts.moneylender}</span>
                                <span className={styles.finalLabel}>Moneylender (-₹{INITIAL_AMOUNT - amounts.moneylender})</span>
                            </div>
                        </div>
                    </div>

                    {/* Lesson Box */}
                    <div className={styles.lessonBox}>
                        <h3>💡 What You Learned:</h3>
                        <ul>
                            <li><strong>Banks grow your money</strong> with compound interest</li>
                            <li><strong>Money at home</strong> doesn&apos;t grow and may lose value</li>
                            <li><strong>Moneylenders</strong> can make you lose everything!</li>
                            <li><strong>Start early</strong> - the longer you save, the more it grows</li>
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

    // Render playing screen
    return (
        <div className={styles.container}>
            {/* Header */}
            <div className={styles.header}>
                <Link href="/" className={styles.backBtn}>← Back</Link>
                <h1 className={styles.title}>🌳 Interest Magic</h1>
            </div>

            {/* Year Progress */}
            <div className={styles.yearProgress}>
                <div className={styles.yearBadge}>Year {currentYear} of {TOTAL_YEARS}</div>
                <div className={styles.progressBar}>
                    <div
                        className={styles.progressFill}
                        style={{ width: `${(currentYear / TOTAL_YEARS) * 100}%` }}
                    />
                </div>
            </div>

            {/* Tree Growth Visual */}
            <div className={styles.treeGrowth}>
                <div className={styles.treeContainer}>
                    <span className={styles.tree}>{getTreeStage(currentYear)}</span>
                    <span className={styles.treeLabel}>Your Bank Savings</span>
                </div>
            </div>

            {/* Comparison Cards */}
            <div className={styles.comparisonGrid}>
                {/* Bank Card */}
                <div className={`${styles.comparisonCard} ${styles.bankCompare}`}>
                    <div className={styles.cardHeader}>
                        <span>🏦</span>
                        <h3>Bank Savings</h3>
                    </div>
                    <div className={styles.amountDisplay}>
                        <span className={styles.amount}>₹{amounts.bank}</span>
                        {currentYear > 0 && (
                            <span className={styles.gain}>+₹{amounts.bank - INITIAL_AMOUNT}</span>
                        )}
                    </div>
                    <div className={styles.rateInfo}>+8% interest/year</div>
                    <div className={styles.growthBar}>
                        <div
                            className={styles.growthFill}
                            style={{ width: `${Math.min((amounts.bank / 200) * 100, 100)}%` }}
                        />
                    </div>
                </div>

                {/* Home Card */}
                <div className={`${styles.comparisonCard} ${styles.homeCompare}`}>
                    <div className={styles.cardHeader}>
                        <span>🏠</span>
                        <h3>Home Storage</h3>
                    </div>
                    <div className={styles.amountDisplay}>
                        <span className={styles.amount}>₹{amounts.home}</span>
                        <span className={styles.neutral}>No change</span>
                    </div>
                    <div className={styles.rateInfo}>0% growth</div>
                    <div className={styles.growthBar}>
                        <div
                            className={styles.growthFillNeutral}
                            style={{ width: `${(amounts.home / 200) * 100}%` }}
                        />
                    </div>
                </div>

                {/* Moneylender Card */}
                <div className={`${styles.comparisonCard} ${styles.lenderCompare}`}>
                    <div className={styles.cardHeader}>
                        <span>💸</span>
                        <h3>Moneylender</h3>
                    </div>
                    <div className={styles.amountDisplay}>
                        <span className={styles.amount}>₹{amounts.moneylender}</span>
                        {currentYear > 0 && (
                            <span className={styles.loss}>-₹{INITIAL_AMOUNT - amounts.moneylender}</span>
                        )}
                    </div>
                    <div className={styles.rateInfo}>-15% lost/year!</div>
                    <div className={styles.growthBar}>
                        <div
                            className={styles.growthFillLoss}
                            style={{ width: `${(amounts.moneylender / 200) * 100}%` }}
                        />
                    </div>
                </div>
            </div>

            {/* Next Year Button */}
            <button
                onClick={nextYear}
                className={`${styles.nextBtn} ${animating ? styles.disabled : ''}`}
                disabled={animating}
            >
                {animating ? 'Growing...' : `Go to Year ${currentYear + 1} →`}
            </button>

            {/* Compound Interest Explanation */}
            <div className={styles.explainer}>
                <h4>📚 How Compound Interest Works:</h4>
                <p>
                    Each year, the bank adds 8% of your <strong>current balance</strong> (not just the original ₹100).
                    This means your money grows faster and faster each year - like a snowball rolling downhill! ❄️
                </p>
            </div>
        </div>
    );
}
