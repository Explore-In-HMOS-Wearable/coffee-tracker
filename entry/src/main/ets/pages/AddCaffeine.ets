import emitter from '@ohos.events.emitter';
import { CaffeineViewModel } from '../viewmodels/CaffeineViewModel';
import {
  PresetDrink,
  PRESET_DRINKS,
  CATEGORY_COFFEE,
  CATEGORY_TEA,
  CATEGORY_ENERGY_DRINK,
  CATEGORY_OTHER,
  getDrinksByCategory
} from '../models/CaffeineModels';

interface DrinkWithFavorite {
  drink: PresetDrink;
  isFavorite: boolean;
}

@Builder
export function AddCaffeineBuilder() {
  AddCaffeine();
}

@Entry
@Component
struct AddCaffeine {
  pathStack: NavPathStack = new NavPathStack();
  private viewModel: CaffeineViewModel | null = null;

  @State selectedCategory: string = CATEGORY_COFFEE;
  private allDrinks: PresetDrink[] = [];
  @State filteredDrinks: DrinkWithFavorite[] = [];
  @State favorites: string[] = [];

  async aboutToAppear() {
    const ctx = this.getUIContext().getHostContext() as Context;
    this.viewModel = new CaffeineViewModel(ctx);
    
    this.allDrinks = PRESET_DRINKS;
    
    await this.loadDrinks();
  }

  private async loadDrinks() {
    if (!this.viewModel) {
      return;
    }
    
    this.favorites = await this.viewModel.getFavorites();
    this.filterDrinks();
  }

  private filterDrinks() {
    const categoryDrinks: PresetDrink[] = getDrinksByCategory(this.selectedCategory);
    
    this.filteredDrinks = categoryDrinks
      .map((drink: PresetDrink): DrinkWithFavorite => ({
        drink: drink,
        isFavorite: this.favorites.includes(drink.name)
      }))
      .sort((a: DrinkWithFavorite, b: DrinkWithFavorite): number => {
        if (a.isFavorite && !b.isFavorite) {
          return -1;
        }
        if (!a.isFavorite && b.isFavorite) {
          return 1;
        }
        return 0;
      });
  }

  private async addDrink(drink: PresetDrink) {
    if (!this.viewModel) {
      return;
    }
    
    await this.viewModel.addCaffeine(drink.name, drink.amount, drink.category);
    emitter.emit({ eventId: 1 });
    this.pathStack.pop();
  }

  private async toggleFavorite(drinkName: string) {
    if (!this.viewModel) {
      return;
    }
    
    await this.viewModel.toggleFavorite(drinkName);
    await this.loadDrinks();
  }

  @Builder
  CategoryTab(category: string, label: string, emoji: string) {
    Column() {
      Text(emoji)
        .fontSize(18)
      Text(label)
        .fontSize(9)
        .fontColor(this.selectedCategory === category ? '#4f351c' : '#8b6f47')
    }
    .width('25%')
    .padding(8)
    .backgroundColor(this.selectedCategory === category ? '#cfab71' : '#fff7e8')
    .borderRadius(8)
    .onClick(() => {
      this.selectedCategory = category;
      this.filterDrinks();
    })
  }

  @Builder
  DrinkButton(drinkData: DrinkWithFavorite) {
    Row() {
      Column() {
        Row() {
          Text(drinkData.drink.emoji)
            .fontSize(16)
            .margin({ right: 8 })
          
          Column() {
            Text(drinkData.drink.name)
              .fontSize(12)
              .fontColor('#cfab71')
              .fontWeight(FontWeight.Medium)
            
            Text(`${drinkData.drink.amount} mg`)
              .fontSize(10)
              .fontColor('#cfab71')
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .flexGrow(1)

      Button(drinkData.isFavorite ? '⭐' : '☆')
        .fontSize(16)
        .backgroundColor('transparent')
        .fontColor(drinkData.isFavorite ? '#ffd700' : '#cfab71')
        .width(30)
        .height(30)
        .onClick(() => {
          this.toggleFavorite(drinkData.drink.name);
        })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#4f351c')
    .borderRadius(8)
    .margin({ bottom: 6 })
    .onClick(() => {
      this.addDrink(drinkData.drink);
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Button('←')
              .backgroundColor('#cfab71')
              .fontColor('#4f351c')
              .fontSize(10)
              .height(14)
              .onClick(() => {
                this.pathStack.pop();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 6 })

          Text('Add Caffeine')
            .fontSize(14)
            .fontColor('#4f351c')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 6 })

          Row() {
            this.CategoryTab(CATEGORY_COFFEE, 'Coffee', '☕')
            this.CategoryTab(CATEGORY_TEA, 'Tea', '🍵')
            this.CategoryTab(CATEGORY_ENERGY_DRINK, 'Energy', '⚡')
            this.CategoryTab(CATEGORY_OTHER, 'Other', '🥤')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 12 })

          Column() {
            if (this.filteredDrinks.length === 0) {
              Text('No drinks in this category')
                .fontSize(11)
                .fontColor('#8b6f47')
                .margin({ top: 20 })
            } else {
              ForEach(this.filteredDrinks, (drinkData: DrinkWithFavorite) => {
                this.DrinkButton(drinkData);
              }, (drinkData: DrinkWithFavorite) => drinkData.drink.name)
            }
          }
          .width('100%')

          Button('✏️ Custom Amount')
            .width('70%')
            .height(26)
            .fontSize(10)
            .margin({ top: 10, bottom: 20 })
            .backgroundColor('#713105')
            .fontColor('#fff7e8')
            .onClick(() => {
              this.pathStack.pushPathByName('CustomCaffeine', null);
            })
        }
        .backgroundColor('#fff7e8')
        .padding(15)
      }.width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
