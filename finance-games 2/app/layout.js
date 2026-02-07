import './globals.css';
import { PointsProvider } from '@/context/PointsContext';
import Header from '@/components/Header';
import VoucherModal from '@/components/VoucherModal';

export const metadata = {
  title: 'Finance Quest - Learn Financial Literacy Through Games',
  description: 'A beginner-friendly platform teaching financial literacy through fun, interactive mini-games. Learn about saving, compound interest, business, and government schemes!',
};

/**
 * RootLayout - Main layout wrapper for the entire app
 * Provides:
 * - Global styles
 * - Points context provider
 * - Header navigation
 * - Voucher modal (shows when unlocked)
 */
export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <PointsProvider>
          <Header />
          <main>{children}</main>
          <VoucherModal />
        </PointsProvider>
      </body>
    </html>
  );
}
