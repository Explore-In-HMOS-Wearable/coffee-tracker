import preferences from '@ohos.data.preferences';

const PREFERENCE_NAME = 'caffeine_tracker_v2';
const ENTRIES_KEY = 'caffeine_entries';
const FAVORITES_KEY = 'favorite_drinks';

export interface CaffeineEntry {
  id: string;
  name: string;
  amount: number;
  category: string;
  timestamp: number;
  isFavorite: boolean;
}

export interface DailyStats {
  date: string;
  totalCaffeine: number;
  entryCount: number;
  entries: CaffeineEntry[];
}

export interface WeeklyStats {
  totalCaffeine: number;
  averageDaily: number;
  maxDaily: number;
  minDaily: number;
  days: DailyStats[];
  mostUsedCategory: string;
  topDrink: string;
}

let pref: preferences.Preferences | null = null;

async function getPreferences(context: Context): Promise<preferences.Preferences> {
  if (!pref) {
    pref = await preferences.getPreferences(context, PREFERENCE_NAME);
  }
  return pref;
}

function getDateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function getDateKeyFromTimestamp(timestamp: number): string {
  const MS_PER_DAY: number = 86400000;
  const MS_PER_HOUR: number = 3600000;
  const MS_PER_MINUTE: number = 60000;

  const days: number = Math.floor(timestamp / MS_PER_DAY);
  const remainingMs: number = timestamp % MS_PER_DAY;
  const hours: number = Math.floor(remainingMs / MS_PER_HOUR);
  const minutes: number = Math.floor((remainingMs % MS_PER_HOUR) / MS_PER_MINUTE);

  let year: number = 1970;
  let daysSinceEpoch: number = days;

  while (true) {
    const isLeap: boolean = (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
    const daysInYear: number = isLeap ? 366 : 365;

    if (daysSinceEpoch >= daysInYear) {
      daysSinceEpoch -= daysInYear;
      year++;
    } else {
      break;
    }
  }

  const isLeap: boolean = (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
  const monthDays: number[] = [31, isLeap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  let month: number = 1;
  let day: number = daysSinceEpoch + 1;

  for (let i: number = 0; i < 12; i++) {
    if (day > monthDays[i]) {
      day -= monthDays[i];
      month++;
    } else {
      break;
    }
  }

  const yearStr: string = year.toString();
  const monthStr: string = month < 10 ? `0 ${month}` : month.toString();
  const dayStr: string = day < 10 ? `0 ${day}` : day.toString();

  return `${yearStr} - ${monthStr} - ${dayStr}`;
}

export async function getAllEntries(context: Context): Promise<CaffeineEntry[]> {
  const preferences = await getPreferences(context);
  const entriesJson = await preferences.get(ENTRIES_KEY, '[]');
  const entries: CaffeineEntry[] = JSON.parse(entriesJson as string);
  return entries.sort((a: CaffeineEntry, b: CaffeineEntry) => b.timestamp - a.timestamp);
}

export async function addEntry(
  context: Context,
  name: string,
  amount: number,
  category: string
): Promise<void> {
  const entries: CaffeineEntry[] = await getAllEntries(context);

  const now: number = Date.now();
  const newEntry: CaffeineEntry = {
    id: now.toString(),
    name,
    amount,
    category,
    timestamp: now,
    isFavorite: false
  };

  entries.push(newEntry);
  await saveEntries(context, entries);
}

export async function deleteEntry(context: Context, entryId: string): Promise<void> {
  let entries: CaffeineEntry[] = await getAllEntries(context);
  entries = entries.filter((e: CaffeineEntry) => e.id !== entryId);
  await saveEntries(context, entries);
}

export async function getEntriesForDate(context: Context, date: Date): Promise<CaffeineEntry[]> {
  const allEntries: CaffeineEntry[] = await getAllEntries(context);
  const targetDateKey: string = getDateKey(date);

  return allEntries.filter((entry: CaffeineEntry) => {
    return getDateKeyFromTimestamp(entry.timestamp) === targetDateKey;
  });
}

export async function getDailyStats(context: Context, date: Date): Promise<DailyStats> {
  const entries: CaffeineEntry[] = await getEntriesForDate(context, date);
  const totalCaffeine: number = entries.reduce((sum: number, e: CaffeineEntry) => sum + e.amount, 0);

  return {
    date: getDateKey(date),
    totalCaffeine,
    entryCount: entries.length,
    entries
  };
}

export async function getLast7DaysStats(context: Context): Promise<number[]> {
  const today: Date = new Date();
  const todayTime: number = today.getTime();
  const oneDayMs: number = 24 * 60 * 60 * 1000;
  const result: number[] = [];

  const timestamps: number[] = [];
  for (let i = 6; i >= 0; i--) {
    timestamps.push(todayTime - (i * oneDayMs));
  }

  const allEntries: CaffeineEntry[] = await getAllEntries(context);

  for (let j = 0; j < timestamps.length; j++) {
    const targetDateKey: string = getDateKeyFromTimestamp(timestamps[j]);

    const dayEntries: CaffeineEntry[] = allEntries.filter((entry: CaffeineEntry) => {
      return getDateKeyFromTimestamp(entry.timestamp) === targetDateKey;
    });

    const totalCaffeine: number = dayEntries.reduce((sum: number, e: CaffeineEntry) => sum + e.amount, 0);
    result.push(totalCaffeine);
  }

  return result;
}

export async function getWeeklyStats(context: Context): Promise<WeeklyStats> {
  const today: Date = new Date();
  const todayTime: number = today.getTime();
  const oneDayMs: number = 24 * 60 * 60 * 1000;

  const timestamps: number[] = [];
  for (let i = 6; i >= 0; i--) {
    timestamps.push(todayTime - (i * oneDayMs));
  }

  const allEntries: CaffeineEntry[] = await getAllEntries(context);

  const days: DailyStats[] = [];
  for (let j = 0; j < timestamps.length; j++) {
    const targetDateKey: string = getDateKeyFromTimestamp(timestamps[j]);

    const dayEntries: CaffeineEntry[] = allEntries.filter((entry: CaffeineEntry) => {
      return getDateKeyFromTimestamp(entry.timestamp) === targetDateKey;
    });

    const totalCaffeine: number = dayEntries.reduce((sum: number, e: CaffeineEntry) => sum + e.amount, 0);

    days.push({
      date: targetDateKey,
      totalCaffeine,
      entryCount: dayEntries.length,
      entries: dayEntries
    });
  }

  const totalCaffeine: number = days.reduce((sum: number, day: DailyStats) => sum + day.totalCaffeine, 0);
  const averageDaily: number = totalCaffeine / 7;
  const caffeineValues: number[] = days.map((d: DailyStats) => d.totalCaffeine);
  const maxDaily: number = Math.max(...caffeineValues);
  const minDaily: number = Math.min(...caffeineValues);

  const categoryCount = new Map<string, number>();
  days.forEach((day: DailyStats) => {
    day.entries.forEach((entry: CaffeineEntry) => {
      const current: number = categoryCount.get(entry.category) || 0;
      categoryCount.set(entry.category, current + 1);
    });
  });

  let mostUsedCategory: string = 'COFFEE';
  let maxCount: number = 0;
  categoryCount.forEach((count: number, category: string) => {
    if (count > maxCount) {
      maxCount = count;
      mostUsedCategory = category;
    }
  });

  const drinkCount = new Map<string, number>();
  days.forEach((day: DailyStats) => {
    day.entries.forEach((entry: CaffeineEntry) => {
      const current: number = drinkCount.get(entry.name) || 0;
      drinkCount.set(entry.name, current + 1);
    });
  });

  let topDrink: string = 'N/A';
  let maxDrinkCount: number = 0;
  drinkCount.forEach((count: number, drink: string) => {
    if (count > maxDrinkCount) {
      maxDrinkCount = count;
      topDrink = drink;
    }
  });

  return {
    totalCaffeine,
    averageDaily,
    maxDaily,
    minDaily,
    days,
    mostUsedCategory,
    topDrink
  };
}

export async function getFavorites(context: Context): Promise<string[]> {
  const preferences = await getPreferences(context);
  const favoritesJson = await preferences.get(FAVORITES_KEY, '[]');
  return JSON.parse(favoritesJson as string);
}

export async function addFavorite(context: Context, drinkName: string): Promise<void> {
  const favorites: string[] = await getFavorites(context);
  if (!favorites.includes(drinkName)) {
    favorites.push(drinkName);
    await saveFavorites(context, favorites);
  }
}

export async function removeFavorite(context: Context, drinkName: string): Promise<void> {
  let favorites: string[] = await getFavorites(context);
  favorites = favorites.filter((f: string) => f !== drinkName);
  await saveFavorites(context, favorites);
}

export async function toggleFavorite(context: Context, drinkName: string): Promise<boolean> {
  const favorites: string[] = await getFavorites(context);
  const isFavorite: boolean = favorites.includes(drinkName);

  if (isFavorite) {
    await removeFavorite(context, drinkName);
    return false;
  } else {
    await addFavorite(context, drinkName);
    return true;
  }
}

async function saveEntries(context: Context, entries: CaffeineEntry[]): Promise<void> {
  const preferences = await getPreferences(context);
  await preferences.put(ENTRIES_KEY, JSON.stringify(entries));
  await preferences.flush();
}

async function saveFavorites(context: Context, favorites: string[]): Promise<void> {
  const preferences = await getPreferences(context);
  await preferences.put(FAVORITES_KEY, JSON.stringify(favorites));
  await preferences.flush();
}
