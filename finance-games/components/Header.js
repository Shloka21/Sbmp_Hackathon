'use client';

import Link from 'next/link';
import { usePoints } from '@/context/PointsContext';
import styles from './Header.module.css';

/**
 * Header - Main navigation bar with points display
 * Shows:
 * - App title with link to home
 * - Current points with coin emoji
 * - Progress bar toward voucher unlock
 */
export default function Header() {
    const { points, VOUCHER_THRESHOLD, isVoucherUnlocked } = usePoints();

    // Calculate progress percentage (capped at 100%)
    const progress = Math.min((points / VOUCHER_THRESHOLD) * 100, 100);

    return (
        <header className={styles.header}>
            <div className={styles.container}>
                {/* Logo and Title */}
                <Link href="/" className={styles.logo}>
                    <span className={styles.logoEmoji}>💰</span>
                    <span className={styles.logoText}>Finance Quest</span>
                </Link>

                {/* Points Display */}
                <div className={styles.pointsContainer}>
                    <div className={styles.pointsDisplay}>
                        <span className={styles.coinEmoji}>🪙</span>
                        <span className={styles.pointsText}>{points} Points</span>
                        {isVoucherUnlocked && (
                            <span className={styles.voucherBadge}>🎉 Voucher Unlocked!</span>
                        )}
                    </div>

                    {/* Progress Bar */}
                    <div className={styles.progressContainer}>
                        <div
                            className={styles.progressBar}
                            style={{ width: `${progress}%` }}
                        />
                        <span className={styles.progressText}>
                            {points}/{VOUCHER_THRESHOLD} for Reward
                        </span>
                    </div>
                </div>
            </div>
        </header>
    );
}
