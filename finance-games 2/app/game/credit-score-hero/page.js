'use client';

import { useState, useCallback } from 'react';
import Link from 'next/link';
import { usePoints, GAME_POINTS } from '@/context/PointsContext';
import styles from './page.module.css';

const START_SCORE = 650;
const WIN_SCORE = 750;
const MIN_SCORE = 300;
const MAX_SCORE = 900;

// Financial choices and their impact on credit score
const SCENARIOS = [
    {
        id: 1,
        situation: 'Your EMI payment of ₹2,000 is due today.',
        choices: [
            { text: '✅ Pay on time', impact: +20, feedback: 'Great! On-time payments boost your score.' },
            { text: '❌ Skip this month', impact: -40, feedback: 'Missed payments hurt your credit badly!' },
        ],
    },
    {
        id: 2,
        situation: 'You have a credit card with ₹50,000 limit.',
        choices: [
            { text: '💳 Use only ₹15,000 (30%)', impact: +15, feedback: 'Low utilization shows discipline!' },
            { text: '💥 Max it out (100%)', impact: -30, feedback: 'High credit usage lowers your score.' },
        ],
    },
    {
        id: 3,
        situation: 'Bank offers you a small personal loan of ₹20,000.',
        choices: [
            { text: '✅ Take and repay on time', impact: +25, feedback: 'Successful loan repayment builds credit!' },
            { text: '❌ Take but delay payments', impact: -35, feedback: 'Delayed payments damage your trust.' },
        ],
    },
    {
        id: 4,
        situation: 'You want to buy a phone. Two options:',
        choices: [
            { text: '💰 Save and pay cash', impact: +10, feedback: 'No new debt = healthy finances!' },
            { text: '📱 Take another loan', impact: -20, feedback: 'Too many loans can hurt your score.' },
        ],
    },
    {
        id: 5,
        situation: 'Credit card bill of ₹8,000 is due.',
        choices: [
            { text: '✅ Pay full amount', impact: +20, feedback: 'Paying in full avoids interest!' },
            { text: '⚠️ Pay only minimum', impact: -10, feedback: 'Minimum payments add interest debt.' },
        ],
    },
    {
        id: 6,
        situation: 'Three different banks are offering loans.',
        choices: [
            { text: '🔍 Compare rates, choose one', impact: +15, feedback: 'Smart comparison = better rates!' },
            { text: '✅ Apply to all three', impact: -25, feedback: 'Multiple inquiries lower score!' },
        ],
    },
    {
        id: 7,
        situation: 'You receive a ₹10,000 bonus at work.',
        choices: [
            { text: '💰 Pay off pending dues', impact: +20, feedback: 'Reducing debt improves credit!' },
            { text: '🛍️ Go shopping', impact: 0, feedback: 'No impact on credit directly.' },
        ],
    },
    {
        id: 8,
        situation: 'Your old credit card has zero fees.',
        choices: [
            { text: '📇 Keep it active', impact: +10, feedback: 'Long credit history helps!' },
            { text: '✂️ Close the account', impact: -15, feedback: 'Closing old cards shortens history.' },
        ],
    },
];

/**
 * CreditScoreHeroGame - Credit score simulation
 * Learning: Credit score basics and responsible borrowing
 */
export default function CreditScoreHeroGame() {
    const { addPoints, hasWonGame } = usePoints();
    const gameId = 'credit-score-hero';

    const [score, setScore] = useState(START_SCORE);
    const [currentScenario, setCurrentScenario] = useState(0);
    const [feedback, setFeedback] = useState(null);
    const [choices, setChoices] = useState([]);
    const [gameState, setGameState] = useState('playing');

    // Make a choice
    const makeChoice = useCallback((choice) => {
        const newScore = Math.min(MAX_SCORE, Math.max(MIN_SCORE, score + choice.impact));
        setScore(newScore);
        setFeedback({ text: choice.feedback, impact: choice.impact });
        setChoices(prev => [...prev, { scenario: currentScenario + 1, choice: choice.text, impact: choice.impact }]);

        // Check for win/lose conditions
        setTimeout(() => {
            if (newScore >= WIN_SCORE) {
                setGameState('won');
                addPoints(gameId, GAME_POINTS[gameId]);
            } else if (currentScenario >= SCENARIOS.length - 1) {
                setGameState(newScore >= WIN_SCORE ? 'won' : 'lost');
                if (newScore >= WIN_SCORE) {
                    addPoints(gameId, GAME_POINTS[gameId]);
                }
            } else {
                setFeedback(null);
                setCurrentScenario(prev => prev + 1);
            }
        }, 1500);
    }, [score, currentScenario, addPoints, gameId]);

    // Reset game
    const resetGame = () => {
        setScore(START_SCORE);
        setCurrentScenario(0);
        setFeedback(null);
        setChoices([]);
        setGameState('playing');
    };

    // Get score zone
    const getScoreZone = (s) => {
        if (s >= 750) return { color: '#4caf50', label: 'Excellent' };
        if (s >= 650) return { color: '#ff9800', label: 'Fair' };
        return { color: '#f44336', label: 'Poor' };
    };

    const zone = getScoreZone(score);
    const progress = ((score - MIN_SCORE) / (MAX_SCORE - MIN_SCORE)) * 100;

    // Result screen
    if (gameState !== 'playing') {
        const isWon = gameState === 'won';
        return (
            <div className={styles.container}>
                <div className={styles.resultScreen}>
                    <div className={styles.resultEmoji}>{isWon ? '🏆' : '📉'}</div>
                    <h1 className={styles.resultTitle}>
                        {isWon ? 'Credit Hero!' : 'Keep Learning!'}
                    </h1>

                    <div className={styles.finalScore} style={{ borderColor: zone.color }}>
                        <span className={styles.scoreLabel}>Final Score</span>
                        <span className={styles.scoreValue} style={{ color: zone.color }}>{score}</span>
                        <span className={styles.scoreZone} style={{ color: zone.color }}>{zone.label}</span>
                    </div>

                    {isWon && !hasWonGame(gameId) && (
                        <div className={styles.pointsEarned}>+{GAME_POINTS[gameId]} Points! 🪙</div>
                    )}

                    <div className={styles.summary}>
                        <h3>📋 Your Choices:</h3>
                        {choices.map((c, i) => (
                            <div key={i} className={styles.choiceItem}>
                                <span>#{c.scenario}: {c.choice}</span>
                                <span style={{ color: c.impact >= 0 ? '#4caf50' : '#f44336' }}>
                                    {c.impact >= 0 ? '+' : ''}{c.impact}
                                </span>
                            </div>
                        ))}
                    </div>

                    <div className={styles.lessonBox}>
                        <h3>💡 Credit Score Tips:</h3>
                        <ul>
                            <li>Pay all EMIs and bills on time ✅</li>
                            <li>Keep credit usage below 30% 📊</li>
                            <li>Avoid too many loan applications 🚫</li>
                            <li>Keep old accounts open for history 📇</li>
                            <li>Target 750+ for best loan rates 🎯</li>
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

    const scenario = SCENARIOS[currentScenario];

    return (
        <div className={styles.container}>
            <div className={styles.header}>
                <Link href="/" className={styles.backBtn}>← Back</Link>
                <h1 className={styles.title}>📊 Credit Score Hero</h1>
            </div>

            {/* Score Meter */}
            <div className={styles.scoreMeter}>
                <div className={styles.meterLabels}>
                    <span>300</span>
                    <span style={{ color: zone.color }}>{score}</span>
                    <span>900</span>
                </div>
                <div className={styles.meterTrack}>
                    <div className={styles.meterFill} style={{ width: `${progress}%`, background: zone.color }}></div>
                    <div className={styles.meterMarker} style={{ left: `${progress}%`, background: zone.color }}></div>
                </div>
                <div className={styles.meterZone}>
                    <span>Poor</span>
                    <span>Fair</span>
                    <span>Good</span>
                    <span>Excellent</span>
                </div>
                <p className={styles.goalHint}>🎯 Goal: Reach {WIN_SCORE}!</p>
            </div>

            {/* Scenario */}
            <div className={styles.scenarioCard}>
                <div className={styles.scenarioNumber}>Scenario {currentScenario + 1}/{SCENARIOS.length}</div>
                <p className={styles.situation}>{scenario.situation}</p>

                <div className={styles.choicesContainer}>
                    {scenario.choices.map((choice, idx) => (
                        <button
                            key={idx}
                            className={styles.choiceBtn}
                            onClick={() => makeChoice(choice)}
                            disabled={!!feedback}
                        >
                            {choice.text}
                        </button>
                    ))}
                </div>
            </div>

            {/* Feedback */}
            {feedback && (
                <div className={`${styles.feedbackCard} ${feedback.impact >= 0 ? styles.positive : styles.negative}`}>
                    <p>{feedback.text}</p>
                    <span className={styles.impactValue}>
                        {feedback.impact >= 0 ? '+' : ''}{feedback.impact} points
                    </span>
                </div>
            )}
        </div>
    );
}
