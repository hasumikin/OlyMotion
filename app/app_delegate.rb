class AppDelegate
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
end
