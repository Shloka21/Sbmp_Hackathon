'use client';

import { usePoints } from '@/context/PointsContext';
import Link from 'next/link';
import styles from './VoucherModal.module.css';

/**
 * VoucherModal - Celebration screen when user unlocks the reward
 * Shows:
 * - Confetti animation
 * - Congratulations message
 * - Dummy voucher
 * - Option to reset and play again
 */
export default function VoucherModal() {
    const { isVoucherUnlocked, points, resetPoints } = usePoints();

    if (!isVoucherUnlocked) return null;

    return (
        <div className={styles.overlay}>
            <div className={styles.modal}>
                {/* Confetti Animation */}
                <div className={styles.confetti}>
                    <span>🎊</span>
                    <span>🎉</span>
                    <span>🎊</span>
                    <span>🎉</span>
                    <span>🎊</span>
                </div>

                {/* Trophy */}
                <div className={styles.trophy}>🏆</div>

                {/* Message */}
                <h1 className={styles.title}>Congratulations!</h1>
                <p className={styles.subtitle}>
                    You&apos;re a Financial Literacy Champion!
                </p>

                {/* Voucher Card */}
                <div className={styles.voucher}>
                    <div className={styles.voucherHeader}>
                        <span className={styles.voucherEmoji}>🎫</span>
                        <span>LEARNING REWARD VOUCHER</span>
                    </div>
                    <div className={styles.voucherAmount}>₹100</div>
                    <div className={styles.voucherText}>
                        Smart Saver Certificate
                    </div>
                    <div className={styles.voucherFooter}>
                        You earned {points} points by mastering financial skills!
                    </div>
                </div>

                {/* Educational Message */}
                <div className={styles.message}>
                    <p>🌟 You learned about:</p>
                    <ul>
                        <li>💰 Saving money daily</li>
                        <li>📈 Power of compound interest</li>
                        <li>📊 Business profit & loss</li>
                        <li>📋 Government schemes for you</li>
                    </ul>
                </div>

                {/* Actions */}
                <div className={styles.actions}>
                    <Link href="/" className={styles.homeButton}>
                        Back to Home
                    </Link>
                    <button onClick={resetPoints} className={styles.resetButton}>
                        Play Again
                    </button>
                </div>
            </div>
        </div>
    );
}
