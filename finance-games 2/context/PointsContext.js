'use client';

import { createContext, useContext, useState, useCallback } from 'react';

// Create context for global points management
const PointsContext = createContext();

// Points required to unlock the voucher reward
const VOUCHER_THRESHOLD = 100;

// Points awarded by each game
export const GAME_POINTS = {
    'rupee-saver': 20,
    'interest-magic': 20,
    'shop-simulator': 30,
    'scheme-matcher': 30,
    'scheme-flip': 25,
    'budget-builder': 30,
    'credit-score-hero': 35,
};

/**
 * PointsProvider - Wraps the app to provide global points state
 * Features:
 * - Track total points across all games
 * - Add points when games are won
 * - Check if voucher is unlocked
 * - Reset points for new session
 */
export function PointsProvider({ children }) {
    const [points, setPoints] = useState(0);
    const [gamesWon, setGamesWon] = useState([]);

    // Add points from winning a game
    const addPoints = useCallback((gameId, amount) => {
        // Prevent adding points for same game twice
        if (gamesWon.includes(gameId)) {
            return false;
        }

        setPoints(prev => prev + amount);
        setGamesWon(prev => [...prev, gameId]);
        return true;
    }, [gamesWon]);

    // Check if voucher is unlocked
    const isVoucherUnlocked = points >= VOUCHER_THRESHOLD;

    // Reset all progress
    const resetPoints = useCallback(() => {
        setPoints(0);
        setGamesWon([]);
    }, []);

    // Check if a specific game has been won
    const hasWonGame = useCallback((gameId) => {
        return gamesWon.includes(gameId);
    }, [gamesWon]);

    const value = {
        points,
        addPoints,
        resetPoints,
        isVoucherUnlocked,
        hasWonGame,
        gamesWon,
        VOUCHER_THRESHOLD,
    };

    return (
        <PointsContext.Provider value={value}>
            {children}
        </PointsContext.Provider>
    );
}

/**
 * usePoints - Hook to access points state and actions
 * Usage: const { points, addPoints } = usePoints();
 */
export function usePoints() {
    const context = useContext(PointsContext);
    if (!context) {
        throw new Error('usePoints must be used within a PointsProvider');
    }
    return context;
}
