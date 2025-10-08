import router from '@ohos.router';
import { storeCaffeine } from '../CaffeineStorage';
import emitter from '@ohos.events.emitter';

@Entry
@Component
struct AddCaffeine {
  @State customCaffeine: number = 100; // default custom amount

  @Builder
  coffeeButton(name: string, amount: number) {
    Button(`${name} (${amount} mg)`)
      .backgroundColor('#4f351c')
      .fontColor('#cfab71')
      .width('90%')
      .height(20)
      .margin(4)
      .onClick(async () => {
        await storeCaffeine(getContext(this), amount);
        emitter.emit({ eventId: 1 });
        router.back();
      })
  }

  build() {
    Column() {
      Row() {
        Button("< Back")
          .backgroundColor('#cfab71')
          .fontColor('#4f351c')
          .height(15)
          .onClick(() => {
            router.back();
          })
      }
      .justifyContent(FlexAlign.Start)
      .padding({ bottom: 10 })

      // Title
      Text("Add Caffeine")
        .fontSize(16)
        .fontColor('#4f351c')
        .margin({ bottom: 4 })

      Column() {
        this.coffeeButton("Espresso", 80);
        this.coffeeButton("Latte", 120);
        this.coffeeButton("Americano", 95);
        this.coffeeButton("Cappuccino", 110);
        Button("Custom")
          .width('40%')
          .height(40)
          .fontSize(12)
          .margin(4)
          .backgroundColor('#4f351c')
          .fontColor('#cfab71')
          .onClick(() => {
            router.pushUrl({ url: 'pages/CustomCaffeine' });
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
}
