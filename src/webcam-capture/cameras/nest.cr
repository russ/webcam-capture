require "json"
require "halite"
require "hash_file"
require "awscr-s3"

module WebcamCapture
  module Cameras
    class Nest < WebcamCapture::Camera
      AUTHORIZATION_URL = "https://home.nest.com/login/oauth2?client_id=%s&state=%s"
      ACCESS_TOKEN_URL = "https://api.home.nest.com/oauth2/access_token"

      def initialize(@configuration : YAML::Any)
      end

      def authorize
        return unless WebcamCapture.state.expired?("nest-access-token")

        authorization_url = AUTHORIZATION_URL % [@configuration["cameras"]["nest"]["client_id"], Random::Secure.hex]

        puts "Visit the following url and paste the given code in here to authorize your cameras:"
        puts authorization_url
        if input = gets
          code = input
        end

        response = Halite.post(ACCESS_TOKEN_URL, headers: { "Content-Type" => "application/x-www-form-urlencoded" }, params: { "code" => code, "client_id" => @configuration["cameras"]["nest"]["client_id"].as_s, "client_secret" => @configuration["cameras"]["nest"]["client_secret"].as_s, "grant_type" => "authorization_code" })
        WebcamCapture.state.store("nest-access-token", JSON.parse(response.body)["access_token"].as_s, { "expire" => (Time.now + 5.year) })
      end

      def take_snapshot
        token = WebcamCapture.state["nest-access-token"].as(String)
        response = Halite.follow.get("https://developer-api.nest.com/", headers: { "Authorization" => "Bearer #{token}" })

        cameras = JSON.parse(response.body)["devices"]["cameras"]

        cameras.as_h.each do |id, camera|
          if @configuration["cameras"]["nest"]["to_capture"].as_a.includes?(camera["name"])
            WebcamCapture.logger.info("Downloading file at #{camera["snapshot_url"]}")
            response = Halite.get(camera["snapshot_url"].as_s)
            s3_client.put_object(
              bucket: @configuration["aws"]["bucket"].as_s,
              object: "#{camera["name"]}/#{Time.now.to_s(@configuration["cameras"]["format"].as_s)}",
              body: response.to_s
            )
          end
        end
      end

      private def s3_client
        Awscr::S3::Client.new(
          region: @configuration["aws"]["region"].as_s,
          aws_access_key: @configuration["aws"]["key"].as_s,
          aws_secret_key: @configuration["aws"]["secret"].as_s
        )
      end
    end
  end
end
