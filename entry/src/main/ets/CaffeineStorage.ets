import preferences from '@ohos.data.preferences';

const PREFERENCE_NAME = 'caffeine_usage';
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

export async function getLast7Days(context: Context): Promise<number[]> {
  const preferences = await getPreferences(context);
  const today = new Date();
  let result: number[] = [];


  for (let i = 6; i >= 0; i--) {
    let d = new Date(today);
    d.setDate(today.getDate() - i);
    const key = getDateKey(d);

    const value = await preferences.get(key, 0);
    result.push(value as number);
  }
  return result;
}

export async function storeCaffeine(context: Context, amount: number): Promise<void> {
  const preferences = await getPreferences(context);
  const todayKey = getDateKey(new Date());

  const currentValue = await preferences.get(todayKey, 0);
  const newValue = (currentValue as number) + amount;

  await preferences.put(todayKey, newValue);
  await preferences.flush();
}