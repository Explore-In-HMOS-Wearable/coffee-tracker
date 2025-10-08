import router from '@ohos.router';
import { storeCaffeine } from '../CaffeineStorage';
import emitter from '@ohos.events.emitter';

@Entry
@Component
struct CustomCaffeine {
  @State caffeine: number = 100; // initial value

  build() {
    Column() {
      Button("< Back")
        .backgroundColor('#cfab71')
        .fontColor('#4f351c')
        .height(15)
        .onClick(() => {
          router.back();
        })

      Text("Custom Caffeine")
        .fontSize(16)
        .fontColor('#4f351c')
        .margin({ bottom: 5, top: 20 })

      Row() {
        Button("-")
          .width(40)
          .height(40)
          .fontSize(16)
          .backgroundColor('#713105')
          .fontColor('#fff7e8')
          .onClick(() => {
            if (this.caffeine > 0) {
              this.caffeine -= 10;
            }
          })

        Text(this.caffeine + " mg")
          .fontSize(20)
          .fontColor('#4f351c')
          .margin(25)

        Button("+")
          .width(40)
          .height(40)
          .fontSize(16)
          .backgroundColor('#713105')
          .fontColor('#fff7e8')
          .onClick(() => {
            this.caffeine += 10;
          })
      }

      Button("Add")
        .width('50%')
        .height(40)
        .fontSize(12)
        .backgroundColor('#4f351c')
        .fontColor('#cfab71')
        .onClick(async () => {
          await storeCaffeine(getContext(this), this.caffeine);
          emitter.emit({ eventId: 1 });
          router.back();
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff7e8')
    .padding(20)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}
