# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

# gem dotenvを有効にする
environment_variables = Dotenv.load

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'OlyMotion'
  app.identifier           = ENV['APP_IDENTIFIER']
  app.codesign_certificate = ENV['APP_CODESIGN_CERTIFICATE']
  app.provisioning_profile = ENV['APP_PROVISIONING_PROFILE']
  # ↓Olympus謹製のOA.Centralを呼び出せるようにplist設定する
  app.info_plist['LSApplicationQueriesSchemes'] = %w(jp.olympus-imaging.oacentral)
  # ↓この設定によって、OA.Centralから呼び出してもらえるようになる。
  # Xcodeでは Info > URL Types のなかに書かれているものです
  app.info_plist['CFBundleURLTypes'] = [
    {
      'CFBundleTypeRole'   => 'Viewer',
      'CFBundleURLSchemes' => ["#{ENV['APP_IDENTIFIER']}.GetFromOacentral"]
    }
  ]
  # 非TSLで通信できるように
  app.info_plist['NSAppTransportSecurity'] = { 'NSAllowsArbitraryLoads' => true }
  # app/env.rbとセットで効く
  environment_variables.each { |key, value| app.info_plist["ENV_#{key}"] = value }

  app.pods do
    pod 'AFNetworking'
    pod 'Reachability'
    pod 'MBProgressHUD'
  end

  app.frameworks += %w(CoreBluetooth)
  app.vendor_project(
    'vendor/OLYCameraKit.framework',
    :static,
    :products => %w(OLYCameraKit),
    :headers_dir => 'Headers'
    )
  app.bridgesupport_files << '/Users/hasumi/Library/RubyMotion/build/Users/hasumi/work/OlyMotion/vendor/OLYCameraKit.framework/OLYCameraKit.framework.bridgesupport'
  # app.embedded_frameworks += ['/path/to/framework.framework'
end
