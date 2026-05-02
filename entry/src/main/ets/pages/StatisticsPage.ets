import emitter from '@ohos.events.emitter';
import { CaffeineViewModel } from '../viewmodels/CaffeineViewModel';
import type { CaffeineEntry, WeeklyStats, DailyStats } from '../repositories/CaffeineRepository';
import { getCategoryLabel, getCategoryEmoji } from '../models/CaffeineModels';

@Builder
export function StatisticsPageBuilder() {
  StatisticsPage();
}

@Entry
@Component
struct StatisticsPage {
  pathStack: NavPathStack = new NavPathStack();
  private viewModel: CaffeineViewModel | null = null;

  @State stats: WeeklyStats | null = null;
  @State todayEntries: CaffeineEntry[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear() {
    const ctx = this.getUIContext().getHostContext() as Context;
    this.viewModel = new CaffeineViewModel(ctx);
    await this.loadStats();

    emitter.on({ eventId: 1 }, async () => {
      await this.loadStats();
    });
  }

  private async loadStats() {
    if (!this.viewModel) {
      return;
    }

    this.isLoading = true;
    this.stats = await this.viewModel.getWeeklyStats();
    this.todayEntries = await this.viewModel.getTodayEntries();
    this.isLoading = false;
  }

  private async deleteEntry(entryId: string) {
    if (!this.viewModel) {
      return;
    }

    await this.viewModel.deleteEntry(entryId);
    await this.loadStats();
    emitter.emit({ eventId: 1 });
  }

  @Builder
  StatCard(title: string, value: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(24)
        .margin({ bottom: 5 })

      Text(value)
        .fontSize(18)
        .fontColor('#4f351c')
        .fontWeight(FontWeight.Bold)

      Text(title)
        .fontSize(9)
        .fontColor('#8b6f47')
    }
    .width('48%')
    .padding(12)
    .backgroundColor('#ffffff')
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  TodayEntryItem(entry: CaffeineEntry) {
    Row() {
      Column() {
        Row() {
          Text(getCategoryEmoji(entry.category))
            .fontSize(16)
            .margin({ right: 8 })

          Column() {
            Text(entry.name)
              .fontSize(11)
              .fontColor('#4f351c')
              .fontWeight(FontWeight.Medium)

            Text(new Date(entry.timestamp).toLocaleTimeString('tr-TR', {
              hour: '2-digit',
              minute: '2-digit'
            }))
              .fontSize(9)
              .fontColor('#8b6f47')
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .flexGrow(1)

      Text(`${entry.amount} mg`)
        .fontSize(12)
        .fontColor('#4f351c')
        .fontWeight(FontWeight.Bold)
        .margin({ right: 10 })

      Button('🗑️')
        .fontSize(14)
        .backgroundColor('transparent')
        .fontColor('#ff6b6b')
        .width(30)
        .height(30)
        .onClick(() => {
          this.deleteEntry(entry.id);
        })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .margin({ bottom: 6 })
  }

  @Builder
  DayBreakdownItem(day: DailyStats) {
    Row() {
      Column() {
        Text(new Date(day.date).toLocaleDateString('tr-TR', {
          weekday: 'short',
          month: 'short',
          day: 'numeric'
        }))
          .fontSize(10)
          .fontColor('#4f351c')

        Text(`${day.entryCount} entries`)
          .fontSize(8)
          .fontColor('#8b6f47')
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)

      Text(`${day.totalCaffeine} mg`)
        .fontSize(12)
        .fontColor('#4f351c')
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .margin({ bottom: 6 })
  }

  build() {
    NavDestination() {
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

        Text('Statistics')
          .fontSize(14)
          .fontColor('#4f351c')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 6 })

        if (this.isLoading || !this.stats) {
          Text('Loading...')
            .fontSize(10)
            .fontColor('#8b6f47')
            .margin({ top: 50 })
        } else {
          Scroll() {
            Column() {
              Text('Weekly Summary')
                .fontSize(10)
                .fontColor('#4f351c')
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              Row() {
                this.StatCard('Total', `${this.stats.totalCaffeine} mg`, '📊')
                this.StatCard('Average', `${Math.round(this.stats.averageDaily)} mg`, '📈')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 8 })

              Row() {
                this.StatCard('Highest', `${this.stats.maxDaily} mg`, '⬆️')
                this.StatCard('Lowest', `${this.stats.minDaily} mg`, '⬇️')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 15 })

              Column() {
                Text('Favorite Info')
                  .fontSize(12)
                  .fontColor('#4f351c')
                  .fontWeight(FontWeight.Bold)
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })

                Row() {
                  Column() {
                    Text(getCategoryEmoji(this.stats.mostUsedCategory))
                      .fontSize(24)
                    Text(getCategoryLabel(this.stats.mostUsedCategory))
                      .fontSize(10)
                      .fontColor('#8b6f47')
                  }
                  .width('48%')
                  .padding(12)
                  .backgroundColor('#ffffff')
                  .borderRadius(10)

                  Column() {
                    Text('🏆')
                      .fontSize(24)
                    Text(this.stats.topDrink)
                      .fontSize(9)
                      .fontColor('#8b6f47')
                      .textAlign(TextAlign.Center)
                  }
                  .width('48%')
                  .padding(12)
                  .backgroundColor('#ffffff')
                  .borderRadius(10)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .margin({ bottom: 15 })

              if (this.todayEntries.length > 0) {
                Column() {
                  Text('Today\'s Entries')
                    .fontSize(12)
                    .fontColor('#4f351c')
                    .fontWeight(FontWeight.Bold)
                    .alignSelf(ItemAlign.Start)
                    .margin({ bottom: 8 })

                  Column() {
                    ForEach(this.todayEntries, (entry: CaffeineEntry) => {
                      this.TodayEntryItem(entry);
                    }, (entry: CaffeineEntry) => entry.id)
                  }
                  .width('100%')
                }
                .width('100%')
                .margin({ bottom: 15 })
              }

              Column() {
                Text('Daily Breakdown (Last 7 Days)')
                  .fontSize(12)
                  .fontColor('#4f351c')
                  .fontWeight(FontWeight.Bold)
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })

                Column() {
                  ForEach(this.stats.days.slice().reverse(), (day: DailyStats) => {
                    this.DayBreakdownItem(day);
                  }, (day: DailyStats) => day.date)
                }
                .width('100%')
              }
              .width('100%')
              .padding({ bottom: 80 })
            }
            .width('100%')
          }
          .flexGrow(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#fff7e8')
      .padding(15)
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
