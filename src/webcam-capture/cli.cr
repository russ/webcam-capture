require "option_parser"
require "yaml"
require "tasker"

module WebcamCapture
  class CLI
    def self.run(args)
      config_file = "config.yml"

      OptionParser.parse(args) do |parser|
        parser.on("-c CONFIG", "--config=CONFIG", "Configuration File") do |val|
          config_file = val
        end

        parser.on("-v", "--version", "Show version") do
          puts WebcamCapture::VERSION
          exit
        end

        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end
      end

      WebcamCapture.logger.info("Webcam Capture Starting ...")

      configuration = YAML.parse(File.read(config_file))
      schedule = Tasker.instance

      camera = WebcamCapture::Cameras::Nest.new(configuration)
      camera.authorize

      schedule.cron(configuration["cameras"]["schedule"].as_s) do
        camera.take_snapshot
      end
    end
  end
end
