import { storeCaffeine } from '../CaffeineStorage';
import emitter from '@ohos.events.emitter';

@Builder
export function AddCaffeineBuilder() {
  AddCaffeine();
}

@Entry
@Component
struct AddCaffeine {
  @State customCaffeine: number = 100; // default custom amount
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  coffeeButton(name: string, amount: number) {
    Button(`${name} (${amount} mg)`)
      .backgroundColor('#4f351c')
      .fontColor('#cfab71')
      .width('90%')
      .height(20)
      .margin(4)
      .onClick(async () => {
        await storeCaffeine(this.getUIContext().getHostContext() as Context, amount);
        emitter.emit({ eventId: 1 });
        this.pathStack.pop();
      })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Button('< Back')
            .backgroundColor('#cfab71')
            .fontColor('#4f351c')
            .height(15)
            .onClick(() => {
              this.pathStack.pop();
            })
        }
        .justifyContent(FlexAlign.Start)
        .padding({ bottom: 10 })

        // Title
        Text('Add Caffeine')
          .fontSize(16)
          .fontColor('#4f351c')
          .margin({ bottom: 4 })

        Column() {
          this.coffeeButton('Espresso', 80);
          this.coffeeButton('Latte', 120);
          this.coffeeButton('Americano', 95);
          this.coffeeButton('Cappuccino', 110);
          Button('Custom')
            .width('40%')
            .height(40)
            .fontSize(12)
            .margin(4)
            .backgroundColor('#4f351c')
            .fontColor('#cfab71')
            .onClick(() => {
              this.pathStack.pushPathByName('CustomCaffeine', null);
            })
        }

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#fff7e8')
      .padding(20)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}
