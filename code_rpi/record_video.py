import os
import picamera
from datetime import datetime

def record_video(base_path):
    with picamera.PiCamera() as camera:
        # Set the resolution (you can adjust as needed)
        camera.resolution = (640, 480)
        
        # Generate a timestamp for the file name
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Create the file path with the timestamp
        video_file_path = os.path.join(base_path, f"output_video_{timestamp}.h264")
        
        # Start recording in H.264 format
        camera.start_recording(video_file_path, format='h264')
        
        try:
            # Keep recording until a KeyboardInterrupt is received
            while True:
                pass
        except KeyboardInterrupt:
            # Stop recording when KeyboardInterrupt is received
            camera.stop_recording()
        
        return video_file_path

if __name__ == "__main__":
    # Specify the base path for recording (e.g., desktop)
    base_path = os.path.join("/media/dingo/ESD-USB")

    # Record video until manually stopped and get the file path
    recorded_file_path = record_video(base_path)

    print(f"Video recording completed. File saved at: {recorded_file_path}")

