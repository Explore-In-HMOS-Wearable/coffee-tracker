import emitter from '@ohos.events.emitter';
import { CaffeineViewModel } from '../viewmodels/CaffeineViewModel';
import { DAILY_LIMIT } from '../models/CaffeineModels';
import { StatisticsPageBuilder } from './StatisticsPage';
import { AddCaffeineBuilder } from './AddCaffeine';
import { CustomCaffeineBuilder } from './CustomCaffeine';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();
  private viewModel: CaffeineViewModel | null = null;

  @State data: number[] = [0, 0, 0, 0, 0, 0, 0];
  @State todayTotal: number = 0;
  @State limitStatus: string = '';
  @State limitPercentage: number = 0;
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ctx: CanvasRenderingContext2D | null = null;

  async aboutToAppear() {
    const ctx = this.getUIContext().getHostContext() as Context;
    this.viewModel = new CaffeineViewModel(ctx);
    
    await this.loadData();

    emitter.on({ eventId: 1 }, async () => {
      await this.loadData();
    });
  }

  private async loadData() {
    if (!this.viewModel) {
      return;
    }

    this.data = await this.viewModel.getLast7DaysData();
    
    this.todayTotal = await this.viewModel.getTodayTotal();
    
    this.limitStatus = await this.viewModel.getLimitStatusMessage();
    
    this.limitPercentage = await this.viewModel.getDailyLimitPercentage();
    
    if (this.ctx) {
      this.drawGraph();
    }
  }

  private drawGraph() {
    if (!this.ctx) {
      return;
    }

    const w: number = this.context.width;
    const h: number = this.context.height;

    this.context.clearRect(0, 0, w, h);

    const maxVal: number = Math.max(...this.data, DAILY_LIMIT);
    const stepX: number = (w - 60) / (this.data.length - 1);

    const limitY: number = h - 30 - (DAILY_LIMIT / maxVal) * (h - 60);
    this.context.strokeStyle = '#ff6b6b';
    this.context.setLineDash([5, 5]);
    this.context.lineWidth = 1;
    this.context.beginPath();
    this.context.moveTo(25, limitY);
    this.context.lineTo(w - 15, limitY);
    this.context.stroke();
    this.context.setLineDash([]);

    this.context.fillStyle = '#ff6b6b';
    this.context.font = '10px sans-serif';
    this.context.textAlign = 'right';
    this.context.fillText('Limit', 22, limitY - 3);

    for (let i: number = 0; i < 4; i++) {
      const y: number = h - 30 - i * (h - 60) / 3;
      
      this.context.strokeStyle = i === 0 ? '#341100' : '#cfab71';
      this.context.lineWidth = i === 0 ? 2 : 1;
      this.context.beginPath();
      this.context.moveTo(25, y);
      this.context.lineTo(w - 15, y);
      this.context.stroke();

      const value: number = Math.round((i / 3) * maxVal);
      this.context.fillStyle = '#4f351c';
      this.context.font = '10px sans-serif';
      this.context.textAlign = 'right';
      this.context.textBaseline = 'middle';
      this.context.fillText(value.toString(), 22, y);
    }

    this.context.strokeStyle = '#4f351c';
    this.context.lineWidth = 2.5;
    this.context.beginPath();
    
    this.data.forEach((v: number, i: number) => {
      const x: number = 25 + i * stepX;
      const y: number = maxVal > 0 ? h - 30 - (v / maxVal) * (h - 60) : h - 30;

      if (i === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
    });
    this.context.stroke();

    this.data.forEach((v: number, i: number) => {
      const x: number = 25 + i * stepX;
      const y: number = maxVal > 0 ? h - 30 - (v / maxVal) * (h - 60) : h - 30;
      
      if (v >= DAILY_LIMIT) {
        this.context.fillStyle = '#ff6b6b';
      } else if (v >= DAILY_LIMIT * 0.75) {
        this.context.fillStyle = '#ffa726';
      } else {
        this.context.fillStyle = '#713105';
      }
      
      this.context.beginPath();
      this.context.arc(x, y, 4, 0, Math.PI * 2);
      this.context.fill();
    });

    const dayLabels: string[] = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const today: number = new Date().getDay();
    
    this.data.forEach((v: number, i: number) => {
      const x: number = 25 + i * stepX;
      const dayIndex: number = (today - 6 + i + 7) % 7;
      
      this.context.fillStyle = '#4f351c';
      this.context.font = '9px sans-serif';
      this.context.textAlign = 'center';
      this.context.fillText(dayLabels[dayIndex], x, h - 10);
    });
  }

  @Builder
  LimitIndicator() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .backgroundColor('#cfab71')
          .borderRadius(4)
        
        Row()
          .width(`${this.limitPercentage}%`)
          .height(8)
          .backgroundColor(
            this.limitPercentage >= 100 ? '#ff6b6b' :
            this.limitPercentage >= 75 ? '#ffa726' : '#4f351c'
          )
          .borderRadius(4)
      }
      .width('100%')
      .margin({ top: 5, bottom: 5 })

      Text(this.limitStatus)
        .fontSize(10)
        .fontColor(
          this.todayTotal >= DAILY_LIMIT ? '#ff6b6b' :
          this.todayTotal >= DAILY_LIMIT * 0.75 ? '#ffa726' : '#4f351c'
        )
        .textAlign(TextAlign.Center)
    }
    .width('100%')
  }

  @Builder
  PageMap(name: string) {
    if (name === 'StatisticsPage') {
      StatisticsPageBuilder();
    } else if (name === 'AddCaffeine') {
      AddCaffeineBuilder()
    } else if (name === 'CustomCaffeine') {
      CustomCaffeineBuilder()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Scroll() {
        Column() {
          Text('Caffeine Tracker')
            .fontSize(18)
            .fontColor('#4f351c')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })

          Text(`${this.todayTotal} mg`)
            .fontSize(32)
            .fontColor('#4f351c')
            .fontWeight(FontWeight.Bold)

          Text('Today')
            .fontSize(12)
            .fontColor('#4f351c')
            .margin({ bottom: 5 })

          this.LimitIndicator()

          Canvas(this.context)
            .width('100%')
            .height('50%')
            .margin({ top: 10, bottom: 10 })
            .onReady(() => {
              this.ctx = this.context;
              this.drawGraph();
            })

          Row() {
            Button('Statistics')
              .fontSize(10)
              .backgroundColor('#cfab71')
              .fontColor('#4f351c')
              .height(24)
              .onClick(() => {
                this.pathStack.pushPathByName('StatisticsPage', null);
              })

            Button('+ Add')
              .fontSize(10)
              .backgroundColor('#4f351c')
              .fontColor('#cfab71')
              .height(24)
              .margin({ left: 4 })
              .onClick(() => {
                this.pathStack.pushPathByName('AddCaffeine', null);
              })
          }
        }
        .backgroundColor('#fff7e8')
        .padding(20)
        .justifyContent(FlexAlign.Center)
      }.width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .navDestination(this.PageMap)
  }
}
