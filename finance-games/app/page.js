import GameCard from '@/components/GameCard';
import styles from './page.module.css';

// Game data for all 7 mini-games
const games = [
  {
    id: 'rupee-saver',
    title: 'Rupee Saver',
    description: 'Learn to save money daily! Drag items into Save or Spend baskets.',
    emoji: '🏺',
    color: '#4caf50',
  },
  {
    id: 'interest-magic',
    title: 'Interest Magic',
    description: 'Watch your money grow like a tree with compound interest!',
    emoji: '🌳',
    color: '#2196f3',
  },
  {
    id: 'shop-simulator',
    title: 'Shop Simulator',
    description: 'Run your own tea shop! Set prices and learn profit & loss.',
    emoji: '☕',
    color: '#ff9800',
  },
  {
    id: 'scheme-matcher',
    title: 'Scheme Matcher',
    description: 'Match government schemes with their benefits!',
    emoji: '🃏',
    color: '#9c27b0',
  },
  {
    id: 'scheme-flip',
    title: 'Scheme Flip',
    description: 'Flip identical cards to discover government schemes!',
    emoji: '🎴',
    color: '#e91e63',
  },
  {
    id: 'budget-builder',
    title: 'Budget Builder',
    description: 'Create a monthly budget and handle surprise expenses!',
    emoji: '🧾',
    color: '#00bcd4',
  },
  {
    id: 'credit-score-hero',
    title: 'Credit Score Hero',
    description: 'Make smart choices to build your credit score to 750!',
    emoji: '📊',
    color: '#ff5722',
  },
];

/**
 * HomePage - Main landing page with game selection
 */
export default function HomePage() {
  return (
    <div className={styles.page}>
      {/* Hero Section */}
      <section className={styles.hero}>
        <div className={styles.heroContent}>
          <h1 className={styles.title}>
            <span className={styles.titleEmoji}>🎮</span>
            Finance Quest
          </h1>
          <p className={styles.subtitle}>
            Learn Financial Literacy Through Fun Mini-Games!
          </p>
          <p className={styles.description}>
            Play 7 exciting games, earn points, and unlock rewards.
            Perfect for students and beginners learning about money! 💰
          </p>
        </div>
      </section>

      {/* Games Grid */}
      <section className={styles.gamesSection}>
        <h2 className={styles.sectionTitle}>Choose Your Adventure</h2>
        <p className={styles.sectionSubtitle}>
          Complete games to earn <span className={styles.highlight}>190 total points</span> and unlock rewards!
        </p>

        <div className={styles.gamesGrid}>
          {games.map((game) => (
            <GameCard
              key={game.id}
              id={game.id}
              title={game.title}
              description={game.description}
              emoji={game.emoji}
              color={game.color}
            />
          ))}
        </div>
      </section>

      {/* Learning Goals */}
      <section className={styles.learningSection}>
        <h2 className={styles.sectionTitle}>What You&apos;ll Learn</h2>
        <div className={styles.learningGrid}>
          <div className={styles.learningCard}>
            <span className={styles.learningEmoji}>💰</span>
            <h3>Needs vs Wants</h3>
            <p>Essential needs vs optional wants</p>
          </div>
          <div className={styles.learningCard}>
            <span className={styles.learningEmoji}>📈</span>
            <h3>Compound Interest</h3>
            <p>How savings grow over time</p>
          </div>
          <div className={styles.learningCard}>
            <span className={styles.learningEmoji}>📊</span>
            <h3>Business Basics</h3>
            <p>Profit, loss, and pricing</p>
          </div>
          <div className={styles.learningCard}>
            <span className={styles.learningEmoji}>📋</span>
            <h3>Government Schemes</h3>
            <p>PM-KISAN, Mudra, and more</p>
          </div>
          <div className={styles.learningCard}>
            <span className={styles.learningEmoji}>🧾</span>
            <h3>Budgeting</h3>
            <p>Monthly planning & emergencies</p>
          </div>
          <div className={styles.learningCard}>
            <span className={styles.learningEmoji}>📊</span>
            <h3>Credit Score</h3>
            <p>Building good credit habits</p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className={styles.footer}>
        <p>Made with ❤️ for Financial Literacy Education</p>
      </footer>
    </div>
  );
}
