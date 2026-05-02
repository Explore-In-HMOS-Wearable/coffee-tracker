import {
  addEntry,
  CaffeineEntry,
  DailyStats,
  deleteEntry,
  getDailyStats,
  getEntriesForDate,
  getFavorites,
  getLast7DaysStats,
  getWeeklyStats,
  toggleFavorite,
  WeeklyStats
} from '../repositories/CaffeineRepository';

const DAILY_LIMIT: number = 400;
const WARNING_LIMIT: number = 300;

export interface LimitStatus {
  isOverLimit: boolean;
  isNearLimit: boolean;
  currentAmount: number;
  limitAmount: number;
}

export class CaffeineViewModel {
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  async addCaffeine(name: string, amount: number, category: string): Promise<void> {
    await addEntry(this.context, name, amount, category);
  }

  async getTodayTotal(): Promise<number> {
    const stats: DailyStats = await getDailyStats(this.context, new Date());
    return stats.totalCaffeine;
  }

  async getTodayEntries(): Promise<CaffeineEntry[]> {
    return await getEntriesForDate(this.context, new Date());
  }

  async getLast7DaysData(): Promise<number[]> {
    return await getLast7DaysStats(this.context);
  }

  async getWeeklyStats(): Promise<WeeklyStats> {
    return await getWeeklyStats(this.context);
  }

  async deleteEntry(entryId: string): Promise<void> {
    await deleteEntry(this.context, entryId);
  }

  async checkDailyLimit(): Promise<LimitStatus> {
    const currentAmount: number = await this.getTodayTotal();

    return {
      isOverLimit: currentAmount >= DAILY_LIMIT,
      isNearLimit: currentAmount >= WARNING_LIMIT,
      currentAmount,
      limitAmount: DAILY_LIMIT
    };
  }

  async getLimitStatusMessage(): Promise<string> {
    const status: LimitStatus = await this.checkDailyLimit();

    if (status.isOverLimit) {
      return `⚠️ Daily limit exceeded! (${status.currentAmount}/${DAILY_LIMIT} mg)`;
    } else if (status.isNearLimit) {
      const remaining: number = DAILY_LIMIT - status.currentAmount;
      return `⚡ Approaching limit! (Remaining: ${remaining} mg)`;
    } else {
      const remaining: number = DAILY_LIMIT - status.currentAmount;
      return `✅ Looking good (Remaining: ${remaining} mg)`;
    }
  }

  async toggleFavorite(drinkName: string): Promise<boolean> {
    return await toggleFavorite(this.context, drinkName);
  }

  async getFavorites(): Promise<string[]> {
    return await getFavorites(this.context);
  }

  async getDailyLimitPercentage(): Promise<number> {
    const total: number = await this.getTodayTotal();
    return Math.min((total / DAILY_LIMIT) * 100, 100);
  }
}
