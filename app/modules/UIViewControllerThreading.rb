module UIViewControllerThreading

  include DebugConcern

  # def executeSynchronousBlock:(void (^)())block {
  #   DEBUG_DETAIL_LOG(@"");

  #   # メインスレッド以外で処理ブロックを実行して呼び出したスレッドで実行完了を待ち合わせします。
  #   dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
  #     DEBUG_DETAIL_LOG(@"");
  #     block();
  #   });
  # end

  # def executeAsynchronousBlock:(void (^)())block {
  #   DEBUG_DETAIL_LOG(@"");

  #   # メインスレッド以外で非同期に処理ブロックを実行します。
  #   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
  #     DEBUG_DETAIL_LOG(@"");
  #     block();
  #   });
  # end

  # def executeAsynchronousBlockOnMainThread:(void (^)())block {
  #   DEBUG_DETAIL_LOG(@"");

  #   # メインスレッドで非同期に処理ブロックを実行します。
  #   dispatch_async(dispatch_get_main_queue(), ^{
  #     DEBUG_DETAIL_LOG(@"");
  #     block();
  #   });
  # end

  # def showProgress:(BOOL)animated {
  # dp "animated={animated ? 'YES' : 'NO'}"

  #   window = UIApplication.sharedApplication.windows[0]
  #   [MBProgressHUD showHUDAddedTo:window animated:YES];
  # end

  # def hideProgress:(BOOL)animated {
  # dp "animated={animated ? 'YES' : 'NO'}"

  #   window = UIApplication.sharedApplication.windows[0]
  #   [MBProgressHUD hideHUDForView:window animated:YES];
  # end

  def hideAllProgresses(animated)
    window = UIApplication.sharedApplication.windows[0]
    MBProgressHUD.hideAllHUDsForView(window, animated:animated)
  end

  # - (void)showProgress:(BOOL)animated whileExecutingBlock:(void (^)(MBProgressHUD *progressView))block {
  # ↑を↓にした
  def showProgressWhileExecutingBlock(animated, &block)
    dp "animated={animated ? 'YES' : 'NO'}"

    # 進捗表示用のビューを作成します。
    # @author hasumi ```UIWindow *window = GetApp().window;``` を↓のように書いてみた
    window = UIApplication.sharedApplication.windows[0]
    progressHUD = MBProgressHUD.alloc.initWithWindow(window)
    progressHUD.removeFromSuperViewOnHide = true

    dp "ビューを最前面に表示して処理ブロックを実行開始します（はじまり）"
    progressBlock = -> { block.call(progressHUD) if block }
    window.addSubview(progressHUD)
    progressHUD.showAnimated(true, whileExecutingBlock:progressBlock)
    dp "ビューを最前面に表示して処理ブロックを実行開始します（おわり）"
  end

end
