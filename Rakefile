# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'OlyMotion'

  app.vendor_project(
    'vendor/OLYCameraKit.framework',
    :static,
    :products => %w(OLYCameraKit),
    :headers_dir => 'Headers'
    )
end
