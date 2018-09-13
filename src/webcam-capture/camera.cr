module WebcamCapture
  abstract class Camera
    abstract def authorize
    abstract def take_snapshot
  end
end

require "./cameras/*"
