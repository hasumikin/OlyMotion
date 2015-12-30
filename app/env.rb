# このファイルにより、アプリ内の任意のクラスから
# App::ENV['XXXX']
# のようにして環境変数（.env内に記述）が読み出せる
module App; module ENV
  class << self
    def [](key)
      vars["ENV_#{key}"]
    end
 
    def vars
      @vars ||= info_dictionary.select { |key, value| key.start_with? 'ENV_' }
    end
 
    def info_dictionary
      NSBundle.mainBundle.infoDictionary
    end
  end
end; end
