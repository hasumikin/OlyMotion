class AppDelegate

  include DebugConcern

  AppUrlSchemeGetFromOacentral = "com.hasumikin.ipa.OlyMotion.GetFromOacentral"
  AppOACentralConfigurationDidGetNotification = "AppOACentralConfigurationDidGetNotification"
  AppOACentralConfigurationDidGetNotificationUserInfo = "AppOACentralConfigurationDidGetNotificationUserInfo"

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rootViewController = SettingsViewController.alloc.init
    rootViewController.title = 'OlyMotion'
    rootViewController.view.backgroundColor = UIColor.whiteColor

    navigationController = UINavigationController.alloc.initWithRootViewController(rootViewController)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = navigationController
    @window.makeKeyAndVisible

    true
  end

  def application(application, openURL:url, sourceApplication:sourceApplication, annotation:annotation)
    dp "url=#{url}, sourceApplication=#{sourceApplication}, annotation=#{annotation}"

    if url.scheme == AppUrlSchemeGetFromOacentral
      # OA.Centralから呼び出されました。
      # OA.Centralが保持している設定情報を送り返してきています。
      configuration = OACentralConfiguration.alloc.initWithConfigurationURL(url)
      dp "configuration.bleName=#{configuration.bleName}"
      dp "configuration.bleCode=#{configuration.bleCode}"

      # OA.Centralから接続設定を取得したことをお知らせします。
      # この設定情報を欲しがっているビューコントローラーは、このインスタンスから遠いところにいるので、通知を使って届けます。
      notificationCenter = NSNotificationCenter.defaultCenter
      userInfo = { 'AppOACentralConfigurationDidGetNotificationUserInfo' => configuration }
      notificationCenter.postNotificationName(AppOACentralConfigurationDidGetNotification, object:self, userInfo:userInfo)
    end

    true
  end

end
