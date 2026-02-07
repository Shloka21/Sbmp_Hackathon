'use client';

import { useState, useCallback } from 'react';
import Link from 'next/link';
import { usePoints, GAME_POINTS } from '@/context/PointsContext';
import styles from './page.module.css';

// Cost of ingredients
const COSTS = {
    teaLeaves: 50,
    milk: 40,
    sugar: 20,
};
const TOTAL_INVESTMENT = COSTS.teaLeaves + COSTS.milk + COSTS.sugar; // ₹110
const MAX_CUPS = 50;
const PROFIT_TARGET = 50;

// Price vs Customer demand (price-sensitive customers)
const PRICE_DEMAND = {
    5: { customers: 45, label: 'Very Cheap - Maximum Demand' },
    6: { customers: 40, label: 'Cheap - High Demand' },
    7: { customers: 35, label: 'Budget - Good Demand' },
    8: { customers: 30, label: 'Fair - Moderate Demand' },
    9: { customers: 25, label: 'Moderate - Lower Demand' },
    10: { customers: 20, label: 'Standard - Some Demand' },
    12: { customers: 15, label: 'Expensive - Low Demand' },
    15: { customers: 8, label: 'Very Expensive - Few Customers' },
};

// Random events that can happen
const EVENTS = [
    { id: 'rain', name: 'Rainy Day ☔', effect: 'bonus', description: 'More customers want hot tea!', modifier: 1.3 },
    { id: 'sunny', name: 'Hot Day ☀️', effect: 'penalty', description: 'Fewer people want hot drinks', modifier: 0.7 },
    { id: 'spoiled', name: 'Milk Spoiled 🥛❌', effect: 'waste', description: 'Lost ₹40 in milk!', wastage: 40 },
    { id: 'festival', name: 'Festival Day 🎉', effect: 'bonus', description: 'Everyone is celebrating!', modifier: 1.5 },
    { id: 'normal', name: 'Normal Day 📅', effect: 'none', description: 'Regular business day', modifier: 1 },
];

/**
 * ShopSimulatorGame - Small business profit/loss game
 * 
 * Learning Outcome:
 * - Understand pricing strategy
 * - Learn about profit and loss calculations
 * - Basic business economics
 */
export default function ShopSimulatorGame() {
    const { addPoints, hasWonGame } = usePoints();
    const gameId = 'shop-simulator';

    // Game state
    const [currentRound, setCurrentRound] = useState(1);
    const [totalProfit, setTotalProfit] = useState(0);
    const [selectedPrice, setSelectedPrice] = useState(10);
    const [gameState, setGameState] = useState('setup'); // setup, result, won, lost
    const [roundResult, setRoundResult] = useState(null);
    const [roundHistory, setRoundHistory] = useState([]);

    // Run the day's simulation
    const runDay = useCallback(() => {
        // Get random event
        const event = EVENTS[Math.floor(Math.random() * EVENTS.length)];

        // Base demand from price
        const baseDemand = PRICE_DEMAND[selectedPrice]?.customers || 20;

        // Apply event modifier
        let actualCustomers = Math.round(baseDemand * (event.modifier || 1));
        actualCustomers = Math.min(actualCustomers, MAX_CUPS); // Can't exceed cups available

        // Calculate revenue and profit
        const revenue = actualCustomers * selectedPrice;
        let investment = TOTAL_INVESTMENT;

        // Handle wastage events
        if (event.effect === 'waste') {
            investment += event.wastage;
        }

        const profit = revenue - investment;

        // Update state
        const result = {
            round: currentRound,
            price: selectedPrice,
            customers: actualCustomers,
            revenue,
            investment,
            profit,
            event,
        };

        setRoundResult(result);
        setRoundHistory(prev => [...prev, result]);
        setTotalProfit(prev => prev + profit);
        setGameState('result');
    }, [selectedPrice, currentRound]);

    // Continue to next round or end game
    const nextRound = useCallback(() => {
        if (currentRound >= 3) {
            // Game over after 3 rounds
            if (totalProfit >= PROFIT_TARGET) {
                setGameState('won');
                addPoints(gameId, GAME_POINTS[gameId]);
            } else {
                setGameState('lost');
            }
        } else {
            setCurrentRound(prev => prev + 1);
            setRoundResult(null);
            setGameState('setup');
        }
    }, [currentRound, totalProfit, addPoints, gameId]);

    // Reset game
    const resetGame = () => {
        setCurrentRound(1);
        setTotalProfit(0);
        setSelectedPrice(10);
        setGameState('setup');
        setRoundResult(null);
        setRoundHistory([]);
    };

    // Render setup screen
    const renderSetup = () => (
        <>
            {/* Investment Info */}
            <div className={styles.investmentCard}>
                <h3>☕ Today&apos;s Investment</h3>
                <div className={styles.ingredients}>
                    <div className={styles.ingredient}>
                        <span>🍵 Tea Leaves</span>
                        <span>₹{COSTS.teaLeaves}</span>
                    </div>
                    <div className={styles.ingredient}>
                        <span>🥛 Milk</span>
                        <span>₹{COSTS.milk}</span>
                    </div>
                    <div className={styles.ingredient}>
                        <span>🍬 Sugar</span>
                        <span>₹{COSTS.sugar}</span>
                    </div>
                    <div className={`${styles.ingredient} ${styles.total}`}>
                        <span>💰 Total Investment</span>
                        <span>₹{TOTAL_INVESTMENT}</span>
                    </div>
                </div>
                <p className={styles.capacityNote}>You can make up to {MAX_CUPS} cups of tea</p>
            </div>

            {/* Price Selection */}
            <div className={styles.priceSection}>
                <h3>Set Your Price Per Cup:</h3>
                <div className={styles.priceSlider}>
                    <input
                        type="range"
                        min="5"
                        max="15"
                        value={selectedPrice}
                        onChange={(e) => setSelectedPrice(parseInt(e.target.value))}
                        className={styles.slider}
                    />
                    <div className={styles.priceDisplay}>₹{selectedPrice}</div>
                </div>
                <p className={styles.demandHint}>
                    Expected customers: ~{PRICE_DEMAND[selectedPrice]?.customers || 20} people
                    <br />
                    <span className={styles.demandLabel}>{PRICE_DEMAND[selectedPrice]?.label}</span>
                </p>
            </div>

            {/* Prediction */}
            <div className={styles.prediction}>
                <h4>📊 If things go well:</h4>
                <div className={styles.predictionGrid}>
                    <div>Revenue: ₹{(PRICE_DEMAND[selectedPrice]?.customers || 20) * selectedPrice}</div>
                    <div>Cost: ₹{TOTAL_INVESTMENT}</div>
                    <div className={styles.predProfit}>
                        Expected Profit: ₹{((PRICE_DEMAND[selectedPrice]?.customers || 20) * selectedPrice) - TOTAL_INVESTMENT}
                    </div>
                </div>
            </div>

            {/* Open Shop Button */}
            <button onClick={runDay} className={styles.openShopBtn}>
                Open Shop! ☕📢
            </button>
        </>
    );

    // Render result screen
    const renderResult = () => {
        if (!roundResult) return null;
        const isProfit = roundResult.profit > 0;

        return (
            <>
                {/* Event Banner */}
                <div className={`${styles.eventBanner} ${styles[roundResult.event.effect]}`}>
                    <span className={styles.eventIcon}>{roundResult.event.name}</span>
                    <span>{roundResult.event.description}</span>
                </div>

                {/* Results Grid */}
                <div className={styles.resultsGrid}>
                    <div className={styles.resultCard}>
                        <span className={styles.resultLabel}>Price</span>
                        <span className={styles.resultValue}>₹{roundResult.price}/cup</span>
                    </div>
                    <div className={styles.resultCard}>
                        <span className={styles.resultLabel}>Customers</span>
                        <span className={styles.resultValue}>{roundResult.customers} 👥</span>
                    </div>
                    <div className={styles.resultCard}>
                        <span className={styles.resultLabel}>Revenue</span>
                        <span className={styles.resultValue}>₹{roundResult.revenue}</span>
                    </div>
                    <div className={styles.resultCard}>
                        <span className={styles.resultLabel}>Cost</span>
                        <span className={styles.resultValue}>₹{roundResult.investment}</span>
                    </div>
                </div>

                {/* Profit/Loss Display */}
                <div className={`${styles.profitDisplay} ${isProfit ? styles.profit : styles.loss}`}>
                    <span className={styles.profitLabel}>{isProfit ? '✅ PROFIT' : '❌ LOSS'}</span>
                    <span className={styles.profitAmount}>
                        {isProfit ? '+' : ''}₹{roundResult.profit}
                    </span>
                </div>

                {/* Continue Button */}
                <button onClick={nextRound} className={styles.continueBtn}>
                    {currentRound >= 3 ? 'See Final Results' : `Continue to Day ${currentRound + 1}`} →
                </button>
            </>
        );
    };

    // Render win/lose screen
    if (gameState === 'won' || gameState === 'lost') {
        const isWon = gameState === 'won';

        return (
            <div className={styles.container}>
                <div className={styles.resultScreen}>
                    <div className={styles.resultEmoji}>{isWon ? '🎉' : '😔'}</div>
                    <h1 className={styles.resultTitle}>
                        {isWon ? 'Great Business!' : 'Need More Practice'}
                    </h1>
                    <p className={styles.resultMessage}>
                        {isWon
                            ? `You made a total profit of ₹${totalProfit}!`
                            : `Your total profit was ₹${totalProfit}. Target was ₹${PROFIT_TARGET}.`
                        }
                    </p>

                    {isWon && !hasWonGame(gameId) && (
                        <div className={styles.pointsEarned}>
                            +{GAME_POINTS[gameId]} Points! 🪙
                        </div>
                    )}

                    {/* Round Summary */}
                    <div className={styles.roundSummary}>
                        <h3>📊 Business Report:</h3>
                        {roundHistory.map((round) => (
                            <div key={round.round} className={styles.roundRow}>
                                <span>Day {round.round}</span>
                                <span>₹{round.price}/cup</span>
                                <span>{round.customers} customers</span>
                                <span className={round.profit > 0 ? styles.profitText : styles.lossText}>
                                    {round.profit > 0 ? '+' : ''}₹{round.profit}
                                </span>
                            </div>
                        ))}
                    </div>

                    {/* Lesson Box */}
                    <div className={styles.lessonBox}>
                        <h3>💡 What You Learned:</h3>
                        <ul>
                            <li><strong>Lower prices</strong> = more customers but less per sale</li>
                            <li><strong>Higher prices</strong> = fewer customers but more per sale</li>
                            <li><strong>Unexpected events</strong> can affect your business</li>
                            <li><strong>Profit = Revenue - Costs</strong></li>
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
                <h1 className={styles.title}>☕ Shop Simulator</h1>
            </div>

            {/* Day & Progress */}
            <div className={styles.dayInfo}>
                <div className={styles.dayBadge}>Day {currentRound} of 3</div>
                <div className={styles.totalProfit}>
                    Total Profit:
                    <span className={totalProfit >= 0 ? styles.positive : styles.negative}>
                        ₹{totalProfit}
                    </span>
                    <span className={styles.target}> (Target: ₹{PROFIT_TARGET})</span>
                </div>
            </div>

            {gameState === 'setup' && renderSetup()}
            {gameState === 'result' && renderResult()}
        </div>
    );
}
