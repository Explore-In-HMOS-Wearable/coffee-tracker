import { storeCaffeine } from '../CaffeineStorage';
import emitter from '@ohos.events.emitter';

@Builder
export function CustomCaffeineBuilder() {
  CustomCaffeine();
}

@Entry
@Component
struct CustomCaffeine {
  @State caffeine: number = 100; // initial value
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Button('< Back')
          .backgroundColor('#cfab71')
          .fontColor('#4f351c')
          .height(15)
          .onClick(() => {
            this.pathStack.pop();
          })

        Text('Custom Caffeine')
          .fontSize(16)
          .fontColor('#4f351c')
          .margin({ bottom: 5, top: 20 })

        Row() {
          Button('-')
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

          Text(`${this.caffeine} mg`)
            .fontSize(20)
            .fontColor('#4f351c')
            .margin(25)

          Button('+')
            .width(40)
            .height(40)
            .fontSize(16)
            .backgroundColor('#713105')
            .fontColor('#fff7e8')
            .onClick(() => {
              this.caffeine += 10;
            })
        }

        Button('Add')
          .width('50%')
          .height(40)
          .fontSize(12)
          .backgroundColor('#4f351c')
          .fontColor('#cfab71')
          .onClick(async () => {
            await storeCaffeine(this.getUIContext().getHostContext() as Context, this.caffeine);
            emitter.emit({ eventId: 1 });
            this.pathStack.pop();
            this.pathStack.pop();
          })
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
