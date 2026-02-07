'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { usePoints, GAME_POINTS } from '@/context/PointsContext';
import styles from './page.module.css';

// Government schemes data with simple descriptions
const SCHEMES = [
    {
        id: 'pmkisan',
        name: 'PM-KISAN',
        benefit: '₹6000/year',
        description: 'Farmers receive ₹6000 every year directly in their bank account. This helps farmers buy seeds and fertilizers!',
    },
    {
        id: 'mudra',
        name: 'Mudra Loan',
        benefit: '₹50,000 loan',
        description: 'Get a loan up to ₹50,000 to start your own small business. No need for collateral!',
    },
    {
        id: 'sukanya',
        name: 'Sukanya',
        benefit: 'Girl education',
        description: 'Save money for your daughter\'s education and marriage. The government gives extra interest!',
    },
    {
        id: 'kcc',
        name: 'KCC',
        benefit: 'Farmer loan',
        description: 'Kisan Credit Card gives farmers easy loans at low interest rates for farming needs.',
    },
    {
        id: 'pmjjby',
        name: 'PMJJBY',
        benefit: 'Life insurance',
        description: 'Pay just ₹436/year and your family gets ₹2 lakh if something happens to you.',
    },
    {
        id: 'pmsby',
        name: 'PMSBY',
        benefit: 'Accident cover',
        description: 'For just ₹20/year, get ₹2 lakh coverage if you have an accident. Very affordable!',
    },
    {
        id: 'apy',
        name: 'APY',
        benefit: 'Pension',
        description: 'Atal Pension Yojana gives you monthly pension after age 60. Start saving small amounts now!',
    },
    {
        id: 'pmmy',
        name: 'PMMY',
        benefit: 'Marine workers',
        description: 'Pradhan Mantri Matsya Sampada Yojana helps fishermen with boats, nets, and insurance.',
    },
];

/**
 * SchemeMatcherGame - Memory card matching game
 * 
 * Learning Outcome:
 * - Learn about government welfare schemes
 * - Understand scheme benefits
 * - Memory and attention skills
 */
export default function SchemeMatcherGame() {
    const { addPoints, hasWonGame } = usePoints();
    const gameId = 'scheme-matcher';

    // Game state
    const [cards, setCards] = useState([]);
    const [flippedCards, setFlippedCards] = useState([]);
    const [matchedPairs, setMatchedPairs] = useState([]);
    const [moves, setMoves] = useState(0);
    const [gameState, setGameState] = useState('playing'); // playing, won
    const [showInfo, setShowInfo] = useState(null);
    const [isChecking, setIsChecking] = useState(false);

    // Initialize cards on mount
    useEffect(() => {
        initializeGame();
    }, []);

    // Initialize/shuffle cards
    const initializeGame = () => {
        // Create pairs of cards (scheme name + benefit)
        const cardPairs = SCHEMES.flatMap(scheme => [
            { id: `${scheme.id}-name`, pairId: scheme.id, type: 'name', content: scheme.name, scheme },
            { id: `${scheme.id}-benefit`, pairId: scheme.id, type: 'benefit', content: scheme.benefit, scheme },
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
        // Ignore if checking, already flipped, or already matched
        if (isChecking) return;
        if (flippedCards.some(c => c.id === clickedCard.id)) return;
        if (matchedPairs.includes(clickedCard.pairId)) return;
        if (flippedCards.length >= 2) return;

        const newFlipped = [...flippedCards, clickedCard];
        setFlippedCards(newFlipped);

        // Check for match when 2 cards are flipped
        if (newFlipped.length === 2) {
            setMoves(prev => prev + 1);
            setIsChecking(true);

            const [first, second] = newFlipped;

            if (first.pairId === second.pairId && first.type !== second.type) {
                // Match found!
                setTimeout(() => {
                    setMatchedPairs(prev => [...prev, first.pairId]);
                    setShowInfo(first.scheme);
                    setFlippedCards([]);
                    setIsChecking(false);

                    // Check win condition
                    if (matchedPairs.length + 1 === SCHEMES.length) {
                        setTimeout(() => {
                            setShowInfo(null);
                            setGameState('won');
                            addPoints(gameId, GAME_POINTS[gameId]);
                        }, 2000);
                    }
                }, 600);
            } else {
                // No match - flip back
                setTimeout(() => {
                    setFlippedCards([]);
                    setIsChecking(false);
                }, 1000);
            }
        }
    }, [flippedCards, matchedPairs, isChecking, addPoints, gameId]);

    // Close info popup
    const closeInfo = () => {
        setShowInfo(null);
    };

    // Reset game
    const resetGame = () => {
        initializeGame();
    };

    // Check if a card is flipped
    const isFlipped = (card) => {
        return flippedCards.some(c => c.id === card.id) || matchedPairs.includes(card.pairId);
    };

    // Check if a card is matched
    const isMatched = (card) => {
        return matchedPairs.includes(card.pairId);
    };

    // Render win screen
    if (gameState === 'won') {
        return (
            <div className={styles.container}>
                <div className={styles.resultScreen}>
                    <div className={styles.resultEmoji}>🎉</div>
                    <h1 className={styles.resultTitle}>Amazing Memory!</h1>
                    <p className={styles.resultMessage}>
                        You matched all {SCHEMES.length} government schemes in {moves} moves!
                    </p>

                    {!hasWonGame(gameId) && (
                        <div className={styles.pointsEarned}>
                            +{GAME_POINTS[gameId]} Points! 🪙
                        </div>
                    )}

                    {/* Schemes Summary */}
                    <div className={styles.schemesSummary}>
                        <h3>📋 Schemes You Learned:</h3>
                        <div className={styles.schemesGrid}>
                            {SCHEMES.map(scheme => (
                                <div key={scheme.id} className={styles.schemeCard}>
                                    <strong>{scheme.name}</strong>
                                    <span>{scheme.benefit}</span>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Lesson Box */}
                    <div className={styles.lessonBox}>
                        <h3>💡 What You Learned:</h3>
                        <ul>
                            <li>Government has many schemes to help citizens</li>
                            <li>Insurance schemes are very affordable (₹20-₹436/year)</li>
                            <li>Farmers have special support through PM-KISAN and KCC</li>
                            <li>You can start a business with Mudra Loan</li>
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
            {/* Header */}
            <div className={styles.header}>
                <Link href="/" className={styles.backBtn}>← Back</Link>
                <h1 className={styles.title}>🃏 Scheme Matcher</h1>
            </div>

            {/* Stats */}
            <div className={styles.stats}>
                <div className={styles.statItem}>
                    <span>Moves:</span>
                    <strong>{moves}</strong>
                </div>
                <div className={styles.statItem}>
                    <span>Matched:</span>
                    <strong>{matchedPairs.length}/{SCHEMES.length}</strong>
                </div>
            </div>

            {/* Instructions */}
            <p className={styles.instructions}>
                Match each government scheme with its benefit! 🎯
            </p>

            {/* Card Grid */}
            <div className={styles.cardGrid}>
                {cards.map(card => (
                    <div
                        key={card.id}
                        className={`${styles.card} ${isFlipped(card) ? styles.flipped : ''} ${isMatched(card) ? styles.matched : ''}`}
                        onClick={() => handleCardClick(card)}
                    >
                        <div className={styles.cardInner}>
                            <div className={styles.cardFront}>
                                <span>❓</span>
                            </div>
                            <div className={styles.cardBack}>
                                <span className={styles.cardContent}>{card.content}</span>
                                <span className={styles.cardType}>
                                    {card.type === 'name' ? '📋' : '💰'}
                                </span>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            {/* Info Popup */}
            {showInfo && (
                <div className={styles.infoOverlay} onClick={closeInfo}>
                    <div className={styles.infoPopup} onClick={e => e.stopPropagation()}>
                        <div className={styles.infoHeader}>
                            <span className={styles.matchEmoji}>✅</span>
                            <h3>Match Found!</h3>
                        </div>
                        <div className={styles.infoContent}>
                            <h4>{showInfo.name} → {showInfo.benefit}</h4>
                            <p>{showInfo.description}</p>
                        </div>
                        <button onClick={closeInfo} className={styles.infoClose}>
                            Continue Playing
                        </button>
                    </div>
                </div>
            )}

            {/* Reset Button */}
            <button onClick={resetGame} className={styles.resetBtn}>
                🔄 Restart Game
            </button>
        </div>
    );
}
