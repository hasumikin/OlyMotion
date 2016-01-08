class AppDelegate

  include DebugConcern

  AppUrlSchemeGetFromOacentral = "com.hasumikin.ipa.OlyMotion.GetFromOacentral"
  AppOACentralConfigurationDidGetNotification = "AppOACentralConfigurationDidGetNotification"
  AppOACentralConfigurationDidGetNotificationUserInfo = "AppOACentralConfigurationDidGetNotificationUserInfo"

  attr_accessor :camera, :setting

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @setting = AppSetting.instance
    @calmeraLog = AppCameraLog.instance
    @camera = AppCamera.new
    # @camera.setConnectionDelegate(self)

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
