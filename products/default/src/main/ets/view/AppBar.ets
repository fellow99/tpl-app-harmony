/**
 * 顶部应用栏：显示当前页面标题，二级页面支持返回按钮。
 * 参考父工程 specs/002-user-auth/spec.md §9.2「App 典型布局」。
 */
@Component
export struct AppBar {
  /** 当前页面标题 */
  @Prop title: ResourceStr = '';
  /** 是否显示返回按钮（二级页面） */
  @Prop showBack: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Row() {
          Text('←')
            .fontSize(22)
            .fontColor('#292522')
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })
      }
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#292522')
        .margin({ left: this.showBack ? 4 : 20 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#EEECE6' })
  }
}
