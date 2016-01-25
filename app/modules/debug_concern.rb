module DebugConcern
  extend MotionSupport::Concern

  def dp(text)
    case App::ENV['MOTION_ENV']
    when 'simulator'
      puts text
    when 'device'
      NSLog text
    when 'release'
    else
    end
  end

  def alertOnMainThreadWithMessage(message, title:title)
    Dispatch::Queue.main.async {
      App.alert(title, message: message)
    }
  end

end
