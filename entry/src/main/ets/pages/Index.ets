import { getLast7Days } from '../CaffeineStorage';
import router from '@ohos.router';
import emitter from '@ohos.events.emitter';

@Entry
@Component
struct Index {
  @State data: number[] = [0, 0, 0, 0, 0, 0];
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ctx: CanvasRenderingContext2D | null = null;

  private drawGraph() {
    if (!this.ctx) {
      return;
    }
    const w: number = this.context.width;
    const h: number = this.context.height;

    this.context.clearRect(0, 0, w, h);

    // Scale data
    const maxVal: number = Math.max(...this.data);
    const stepX: number = (w - 60) / (this.data.length - 1);

    // Draw axes + labels
    for (let i = 0; i < 4; i++) {
      if (i == 0) {
        this.context.strokeStyle = '#341100';
      } else {
        this.context.strokeStyle = '#cfab71';
      }

      const y = h - 30 - i * 20;

      // draw line
      this.context.beginPath();
      this.context.moveTo(15, y); // start a bit to the right (leave room for labels)
      this.context.lineTo(w - 15, y);
      this.context.stroke();

      // compute value for this line (relative to maxVal)
      const value = Math.round((i / 3) * maxVal);

      // draw text
      this.context.fillStyle = '#4f351c';
      this.context.font = '12px sans-serif';
      this.context.textAlign = 'right';
      this.context.textBaseline = 'middle';
      this.context.fillText(value.toString(), 15, y);
    }


    // Plot line
    this.context.strokeStyle = '#4f351c';
    this.context.lineWidth = 2;
    this.context.beginPath();
    this.data.forEach((v: number, i: number) => {
      const x = 25 + i * stepX;
      const y = maxVal > 0 ? h - 30 - (v / maxVal) * (h - 60) : h - 30;

      if (i === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
    });
    this.context.stroke();

    // Points
    this.context.fillStyle = '#713105';
    this.data.forEach((v: number, i: number) => {
      const x = 25 + i * stepX;
      const y = maxVal > 0 ? h - 30 - (v / maxVal) * (h - 60) : h - 30;
      this.context.beginPath();
      this.context.arc(x, y, 3, 0, Math.PI * 2);
      this.context.fill();
    });

  }

  async aboutToAppear() {
    console.log("aboutToAppear");
    this.data = await getLast7Days(getContext(this));
    console.log("Data: ", this.data)
    if (this.ctx) {
      this.drawGraph();
    }
    emitter.on({ eventId: 1 }, async () => {
      this.data = await getLast7Days(getContext(this));
      this.drawGraph();
    });
  }

  build() {
    Column() {
      Text((this.data[this.data.length - 1] ?? 0) + ' mg')
        .fontSize(20)
        .fontColor('#4f351c')
      Text('caffeine today')
        .fontSize(10)
        .margin({ bottom: 10 })
        .fontColor('#4f351c')

      Canvas(this.context)
        .width('100%')
        .height('60%')
        .onReady(() => {
          this.ctx = this.context
        })
      Button('+')
        .backgroundColor('#4f351c')
        .fontColor('#cfab71')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/AddCaffeine'
          });
        });
    }
    .backgroundColor('#fff7e8')
    .padding(20)
    .justifyContent(FlexAlign.Center)
  }
}