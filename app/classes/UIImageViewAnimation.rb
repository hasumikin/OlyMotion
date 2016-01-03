class UIImageViewAnimation < UIImageView

  def setAnimationTemplateImages(images)
    puts "images=%#{images}"

    templateImages = NSMutableArray.alloc.initWithCapacity(images.count)
    images.each do |image|
      # 指定されたイメージから、描画モードがテンプレート画像になるようなイメージを作成します。
      UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
      context = UIGraphicsGetCurrentContext()
      CGContextTranslateCTM(context, 0, image.size.height)
      CGContextScaleCTM(context, 1.0, -1.0)
      CGContextSetBlendMode(context, KCGBlendModeNormal) # kCGBlendModeNormal
      rect = CGRectMake(0, 0, image.size.width, image.size.height)
      CGContextClipToMask(context, rect, image.CGImage)
      self.tintColor.setFill
      CGContextFillRect(context, rect)
      templateImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      templateImages.addObject(templateImage)
    end
    self.animationImages = templateImages
  end

end
