require "./webcam-capture/*"

module WebcamCapture
  def self.logger
    Logger.new(STDOUT)
  end

  def self.state
    HashFile.config({ "base_dir" => "/tmp/cache" })
    HashFile
  end
end
