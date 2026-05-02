import emitter from '@ohos.events.emitter';
import { CaffeineViewModel } from '../viewmodels/CaffeineViewModel';
import {
  CATEGORY_COFFEE,
  CATEGORY_TEA,
  CATEGORY_ENERGY_DRINK,
  CATEGORY_OTHER
} from '../models/CaffeineModels';

@Builder
export function CustomCaffeineBuilder() {
  CustomCaffeine();
}

@Entry
@Component
struct CustomCaffeine {
  pathStack: NavPathStack = new NavPathStack();
  private viewModel: CaffeineViewModel | null = null;

  @State caffeine: number = 100;
  @State customName: string = 'Custom Drink';
  @State selectedCategory: string = CATEGORY_COFFEE;

  async aboutToAppear() {
    const ctx = this.getUIContext().getHostContext() as Context;
    this.viewModel = new CaffeineViewModel(ctx);
  }

  private async addCustom() {
    if (!this.viewModel) {
      return;
    }
    
    await this.viewModel.addCaffeine(this.customName, this.caffeine, this.selectedCategory);
    emitter.emit({ eventId: 1 });
    this.pathStack.pop();
    this.pathStack.pop();
  }

  @Builder
  CategoryButton(category: string, label: string, emoji: string) {
    Column() {
      Text(emoji)
        .fontSize(20)
      Text(label)
        .fontSize(9)
        .fontColor(this.selectedCategory === category ? '#cfab71' : '#4f351c')
    }
    .width('23%')
    .padding(8)
    .backgroundColor(this.selectedCategory === category ? '#4f351c' : '#cfab71')
    .borderRadius(8)
    .onClick(() => {
      this.selectedCategory = category;
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

          Text('Custom Amount')
            .fontSize(16)
            .fontColor('#4f351c')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 15, bottom: 15 })

          Text('Category')
            .fontSize(11)
            .fontColor('#4f351c')
            .margin({ bottom: 8 })

          Row() {
            this.CategoryButton(CATEGORY_COFFEE, 'Coffee', '☕')
            this.CategoryButton(CATEGORY_TEA, 'Tea', '🍵')
            this.CategoryButton(CATEGORY_ENERGY_DRINK, 'Energy', '⚡')
            this.CategoryButton(CATEGORY_OTHER, 'Other', '🥤')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 20 })

          Text('Name')
            .fontSize(11)
            .fontColor('#4f351c')
            .margin({ bottom: 8 })

          TextInput({ text: this.customName })
            .width('100%')
            .height(40)
            .fontSize(12)
            .backgroundColor('#fff5e2bd')
            .borderRadius(8)
            .margin({ bottom: 20 })
            .onChange((value: string) => {
              this.customName = value;
            })

          Text('Amount')
            .fontSize(11)
            .fontColor('#4f351c')
            .margin({ bottom: 8 })

          Row() {
            Button('-')
              .width(40)
              .height(40)
              .fontSize(12)
              .backgroundColor('#713105')
              .fontColor('#fff7e8')
              .onClick(() => {
                if (this.caffeine > 10) {
                  this.caffeine -= 10;
                }
              })

            Column() {
              Text(`${this.caffeine}`)
                .fontSize(28)
                .fontColor('#4f351c')
                .fontWeight(FontWeight.Bold)

              Text('mg')
                .fontSize(12)
                .fontColor('#4f351c')
            }
            .justifyContent(FlexAlign.Center)
            .flexGrow(1)

            Button('+')
              .width(40)
              .height(40)
              .fontSize(12)
              .backgroundColor('#713105')
              .fontColor('#fff7e8')
              .onClick(() => {
                this.caffeine += 10;
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 20 })

          Row() {
            Button('50')
              .fontSize(8)
              .height(22)
              .backgroundColor('#cfab71')
              .fontColor('#4f351c')
              .margin({ right: 2 })
              .onClick(() => this.caffeine = 50)

            Button('100')
              .fontSize(8)
              .height(22)
              .backgroundColor('#cfab71')
              .fontColor('#4f351c')
              .margin({ right: 2 })
              .onClick(() => this.caffeine = 100)

            Button('150')
              .fontSize(8)
              .height(22)
              .backgroundColor('#cfab71')
              .fontColor('#4f351c')
              .margin({ right: 2 })
              .onClick(() => this.caffeine = 150)

            Button('200')
              .fontSize(8)
              .height(22)
              .backgroundColor('#cfab71')
              .fontColor('#4f351c')
              .onClick(() => this.caffeine = 200)
          }
          .width('90%')
          .margin({ bottom: 30 })

          Button('Add')
            .width('70%')
            .height(26)
            .fontSize(10)
            .margin({ top: 10, bottom: 20 })
            .backgroundColor('#4f351c')
            .fontColor('#cfab71')
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.addCustom();
            })
        }
        .backgroundColor('#fff7e8')
        .padding(15)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
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
