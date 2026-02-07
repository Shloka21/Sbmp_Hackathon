'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { usePoints, GAME_POINTS } from '@/context/PointsContext';
import styles from './page.module.css';

// Government schemes with identical pairs
const SCHEMES = [
    {
        id: 'pmkisan',
        name: 'PM-KISAN',
        description: 'Farmers receive ₹6000 every year directly in their bank account to buy seeds and fertilizers.',
    },
    {
        id: 'mudra',
        name: 'Mudra Loan',
        description: 'Get a loan up to ₹50,000 to start your own small business without collateral.',
    },
    {
        id: 'sukanya',
        name: 'Sukanya Samriddhi',
        description: 'Save money for your daughter\'s education and marriage with extra government interest.',
    },
    {
        id: 'kcc',
        name: 'KCC',
        description: 'Kisan Credit Card gives farmers easy loans at low interest rates for farming needs.',
    },
    {
        id: 'pmjjby',
        name: 'PMJJBY',
        description: 'Pay ₹436/year and your family gets ₹2 lakh life insurance coverage.',
    },
    {
        id: 'pmsby',
        name: 'PMSBY',
        description: 'For just ₹20/year, get ₹2 lakh coverage if you have an accident.',
    },
    {
        id: 'apy',
        name: 'APY',
        description: 'Atal Pension Yojana gives you monthly pension after age 60. Start early!',
    },
    {
        id: 'pmmy',
        name: 'PMMY',
        description: 'Pradhan Mantri Matsya Sampada Yojana helps fishermen with boats and insurance.',
    },
];

/**
 * SchemeFlipGame - Identical pair matching game
 * Learning: Government scheme awareness through discovery
 */
export default function SchemeFlipGame() {
    const { addPoints, hasWonGame } = usePoints();
    const gameId = 'scheme-flip';

    const [cards, setCards] = useState([]);
    const [flippedCards, setFlippedCards] = useState([]);
    const [matchedPairs, setMatchedPairs] = useState([]);
    const [moves, setMoves] = useState(0);
    const [gameState, setGameState] = useState('playing');
    const [showInfo, setShowInfo] = useState(null);
    const [isChecking, setIsChecking] = useState(false);

    // Initialize cards - each scheme appears TWICE (identical pairs)
    useEffect(() => {
        initializeGame();
    }, []);

    const initializeGame = () => {
        // Create two identical cards for each scheme
        const cardPairs = SCHEMES.flatMap(scheme => [
            { id: `${scheme.id}-1`, pairId: scheme.id, name: scheme.name, scheme },
            { id: `${scheme.id}-2`, pairId: scheme.id, name: scheme.name, scheme },
        ]);

        // Shuffle cards
        const shuffled = cardPairs.sort(() => Math.random() - 0.5);
        setCards(shuffled);
        setFlippedCards([]);
        setMatchedPairs([]);
        setMoves(0);
        setGameState('playing');
        setShowInfo(null);
    };

    // Handle card click
    const handleCardClick = useCallback((clickedCard) => {
        if (isChecking) return;
        if (flippedCards.some(c => c.id === clickedCard.id)) return;
        if (matchedPairs.includes(clickedCard.pairId)) return;
        if (flippedCards.length >= 2) return;

        const newFlipped = [...flippedCards, clickedCard];
        setFlippedCards(newFlipped);

        if (newFlipped.length === 2) {
            setMoves(prev => prev + 1);
            setIsChecking(true);

            const [first, second] = newFlipped;

            // Check if same scheme (identical pair)
            if (first.pairId === second.pairId && first.id !== second.id) {
                // Match found!
                setTimeout(() => {
                    setMatchedPairs(prev => [...prev, first.pairId]);
                    setShowInfo(first.scheme); // Show explanation
                    setFlippedCards([]);
                    setIsChecking(false);

                    // Check win
                    if (matchedPairs.length + 1 === SCHEMES.length) {
                        setTimeout(() => {
                            setShowInfo(null);
                            setGameState('won');
                            addPoints(gameId, GAME_POINTS[gameId]);
                        }, 2000);
                    }
                }, 600);
            } else {
                // No match
                setTimeout(() => {
                    setFlippedCards([]);
                    setIsChecking(false);
                }, 1000);
            }
        }
    }, [flippedCards, matchedPairs, isChecking, addPoints, gameId]);

    const closeInfo = () => setShowInfo(null);
    const resetGame = () => initializeGame();

    const isFlipped = (card) => flippedCards.some(c => c.id === card.id) || matchedPairs.includes(card.pairId);
    const isMatched = (card) => matchedPairs.includes(card.pairId);

    // Win screen
    if (gameState === 'won') {
        return (
            <div className={styles.container}>
                <div className={styles.resultScreen}>
                    <div className={styles.resultEmoji}>🎉</div>
                    <h1 className={styles.resultTitle}>Excellent Discovery!</h1>
                    <p className={styles.resultMessage}>
                        You discovered all {SCHEMES.length} government schemes in {moves} moves!
                    </p>

                    {!hasWonGame(gameId) && (
                        <div className={styles.pointsEarned}>+{GAME_POINTS[gameId]} Points! 🪙</div>
                    )}

                    <div className={styles.schemesSummary}>
                        <h3>📋 Schemes You Discovered:</h3>
                        <div className={styles.schemesGrid}>
                            {SCHEMES.map(s => (
                                <div key={s.id} className={styles.schemeCard}>
                                    <strong>{s.name}</strong>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className={styles.lessonBox}>
                        <h3>💡 What You Learned:</h3>
                        <ul>
                            <li>India has many schemes to help citizens</li>
                            <li>Insurance can be very affordable (₹20-₹436/year)</li>
                            <li>Farmers have special support programs</li>
                            <li>You can start a business with Mudra Loan</li>
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

    return (
        <div className={styles.container}>
            <div className={styles.header}>
                <Link href="/" className={styles.backBtn}>← Back</Link>
                <h1 className={styles.title}>🎴 Scheme Flip</h1>
            </div>

            <div className={styles.stats}>
                <div className={styles.statItem}><span>Moves:</span><strong>{moves}</strong></div>
                <div className={styles.statItem}><span>Matched:</span><strong>{matchedPairs.length}/{SCHEMES.length}</strong></div>
            </div>

            <p className={styles.instructions}>Find identical scheme pairs! 🎯</p>

            <div className={styles.cardGrid}>
                {cards.map(card => (
                    <div
                        key={card.id}
                        className={`${styles.card} ${isFlipped(card) ? styles.flipped : ''} ${isMatched(card) ? styles.matched : ''}`}
                        onClick={() => handleCardClick(card)}
                    >
                        <div className={styles.cardInner}>
                            <div className={styles.cardFront}><span>❓</span></div>
                            <div className={styles.cardBack}>
                                <span className={styles.cardContent}>{card.name}</span>
                                <span className={styles.cardType}>📋</span>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            {/* Info Popup on Match */}
            {showInfo && (
                <div className={styles.infoOverlay} onClick={closeInfo}>
                    <div className={styles.infoPopup} onClick={e => e.stopPropagation()}>
                        <div className={styles.infoHeader}>
                            <span className={styles.matchEmoji}>✅</span>
                            <h3>Scheme Discovered!</h3>
                        </div>
                        <div className={styles.infoContent}>
                            <h4>{showInfo.name}</h4>
                            <p>{showInfo.description}</p>
                        </div>
                        <button onClick={closeInfo} className={styles.infoClose}>Continue</button>
                    </div>
                </div>
            )}

            <button onClick={resetGame} className={styles.resetBtn}>🔄 Restart</button>
        </div>
    );
}
