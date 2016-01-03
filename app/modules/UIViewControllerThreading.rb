module UIViewControllerThreading

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
  # puts "animated={animated ? 'YES' : 'NO'}"

  #   UIWindow *window = GetApp().window;
  #   [MBProgressHUD showHUDAddedTo:window animated:YES];
  # end

  # def hideProgress:(BOOL)animated {
  # puts "animated={animated ? 'YES' : 'NO'}"

  #   UIWindow *window = GetApp().window;
  #   [MBProgressHUD hideHUDForView:window animated:YES];
  # end

  # def hideAllProgresses:(BOOL)animated {
  # puts "animated={animated ? 'YES' : 'NO'}"

  #   UIWindow *window = GetApp().window;
  #   [MBProgressHUD hideAllHUDsForView:window animated:animated];
  # end

  # - (void)showProgress:(BOOL)animated whileExecutingBlock:(void (^)(MBProgressHUD *progressView))block {
  # ↑を↓にした
  def showProgressWhileExecutingBlock(animated, &block)
    puts "animated={animated ? 'YES' : 'NO'}"

    # 進捗表示用のビューを作成します。
    # @author hasumi ```UIWindow *window = GetApp().window;``` を↓のように書いてみた
    window = UIApplication.sharedApplication.windows[0]
    progressHUD = MBProgressHUD.alloc.initWithWindow(window)
    progressHUD.removeFromSuperViewOnHide = true

    # ビューを最前面に表示して処理ブロックを実行開始します。
    progressBlock = -> {
      block.call(progressHUD) if block
    }
    window.addSubview(progressHUD)
    progressHUD.showAnimated(true, whileExecutingBlock:progressBlock)
  end

end
