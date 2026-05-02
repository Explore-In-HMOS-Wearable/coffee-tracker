export const CATEGORY_COFFEE = 'COFFEE';
export const CATEGORY_TEA = 'TEA';
export const CATEGORY_ENERGY_DRINK = 'ENERGY_DRINK';
export const CATEGORY_OTHER = 'OTHER';

export class PresetDrink {
  name: string;
  amount: number;
  category: string;
  emoji: string;

  constructor(name: string, amount: number, category: string, emoji: string) {
    this.name = name;
    this.amount = amount;
    this.category = category;
    this.emoji = emoji;
  }

  getInfo(): string {
    return `${this.emoji} ${this.name} - ${this.amount}mg`;
  }

  isCoffee(): boolean {
    return this.category === CATEGORY_COFFEE;
  }

  isTea(): boolean {
    return this.category === CATEGORY_TEA;
  }

  isEnergyDrink(): boolean {
    return this.category === CATEGORY_ENERGY_DRINK;
  }
}

export const PRESET_DRINKS: PresetDrink[] = [
  new PresetDrink('Espresso', 80, CATEGORY_COFFEE, '☕'),
  new PresetDrink('Latte', 120, CATEGORY_COFFEE, '☕'),
  new PresetDrink('Americano', 95, CATEGORY_COFFEE, '☕'),
  new PresetDrink('Cappuccino', 110, CATEGORY_COFFEE, '☕'),
  new PresetDrink('Turkish Coffee', 65, CATEGORY_COFFEE, '☕'),
  new PresetDrink('Filter Coffee', 140, CATEGORY_COFFEE, '☕'),
  new PresetDrink('Flat White', 130, CATEGORY_COFFEE, '☕'),
  new PresetDrink('Mocha', 105, CATEGORY_COFFEE, '☕'),
  
  new PresetDrink('Black Tea', 47, CATEGORY_TEA, '🍵'),
  new PresetDrink('Green Tea', 28, CATEGORY_TEA, '🍵'),
  new PresetDrink('Oolong Tea', 37, CATEGORY_TEA, '🍵'),
  new PresetDrink('White Tea', 15, CATEGORY_TEA, '🍵'),
  new PresetDrink('Matcha', 70, CATEGORY_TEA, '🍵'),
  
  new PresetDrink('Red Bull (250ml)', 80, CATEGORY_ENERGY_DRINK, '⚡'),
  new PresetDrink('Monster (500ml)', 160, CATEGORY_ENERGY_DRINK, '⚡'),
  new PresetDrink('Burn (250ml)', 80, CATEGORY_ENERGY_DRINK, '⚡'),
  new PresetDrink('Hell (250ml)', 80, CATEGORY_ENERGY_DRINK, '⚡'),
  
  new PresetDrink('Cola (330ml)', 34, CATEGORY_OTHER, '🥤'),
  new PresetDrink('Chocolate (100g)', 43, CATEGORY_OTHER, '🍫'),
  new PresetDrink('Cocoa', 25, CATEGORY_OTHER, '🍫')
];

export const DAILY_LIMIT = 400;
export const WARNING_LIMIT = 300;

export function getCategoryLabel(category: string): string {
  if (category === CATEGORY_COFFEE) {
    return 'Coffee';
  } else if (category === CATEGORY_TEA) {
    return 'Tea';
  } else if (category === CATEGORY_ENERGY_DRINK) {
    return 'Energy Drink';
  } else if (category === CATEGORY_OTHER) {
    return 'Other';
  }
  return 'Unknown';
}

export function getCategoryEmoji(category: string): string {
  if (category === CATEGORY_COFFEE) {
    return '☕';
  } else if (category === CATEGORY_TEA) {
    return '🍵';
  } else if (category === CATEGORY_ENERGY_DRINK) {
    return '⚡';
  } else if (category === CATEGORY_OTHER) {
    return '🥤';
  }
  return '📊';
}

export function getDrinksByCategory(category: string): PresetDrink[] {
  return PRESET_DRINKS.filter((drink: PresetDrink) => drink.category === category);
}

export function findDrinkByName(name: string): PresetDrink | null {
  const found = PRESET_DRINKS.find((drink: PresetDrink) => drink.name === name);
  return found || null;
}

export function getTotalDrinksCount(): number {
  return PRESET_DRINKS.length;
}

export function getDrinkCountByCategory(): Map<string, number> {
  const countMap = new Map<string, number>();
  
  PRESET_DRINKS.forEach((drink: PresetDrink) => {
    const currentCount = countMap.get(drink.category) || 0;
    countMap.set(drink.category, currentCount + 1);
  });
  
  return countMap;
}
