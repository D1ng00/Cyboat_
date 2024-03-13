import os
import picamera
from datetime import datetime
from gpiozero import CPUTemperature, DigitalInputDevice

def read_temperature():
    # Replace '28-xxxxxxxxxxxx' with the actual ID of your DS18B20 sensor
    sensor_id = '28-ef650c1e64ff'
    sensor_path = f'/sys/bus/w1/devices/{sensor_id}/w1_slave'

    try:
        with open(sensor_path, 'r') as sensor_file:
            lines = sensor_file.readlines()
            temperature_line = [line for line in lines if 't=' in line]
            temperature_value = int(temperature_line[0].split('t=')[1]) / 1000.0
            return temperature_value
    except FileNotFoundError:
        print("DS18B20 sensor not found. Please check the sensor connection.")
        return None

def record_video_with_temperature(base_path):
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Set the file path for video recording
    video_file_path = os.path.join(base_path, "output_video_{timestamp}.h264")

    # Set the file path for temperature data
    temperature_file_path = os.path.join(base_path, "temperature_data_{timestamp}.txt")

    # Set the resolution for video recording (you can adjust as needed)
    resolution = (640, 480)

    with picamera.PiCamera() as camera:
        # Set the camera resolution
        camera.resolution = resolution

        # Start recording video
        camera.start_recording(video_file_path, format='h264')

        try:
            # Record temperature data
            while True:
                current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                temperature = read_temperature()

                if temperature is not None:
                    # Append temperature data to the text file
                    with open(temperature_file_path, 'a') as temperature_file:
                        temperature_file.write(f"{current_time}, {temperature} °C\n")

                # Record video for 5 seconds
                camera.wait_recording(5)

        except KeyboardInterrupt:
            # Stop recording when KeyboardInterrupt is received
            pass

        finally:
            # Stop recording video
            camera.stop_recording()

    return video_file_path, temperature_file_path

if __name__ == "__main__":
    # Specify the base path for recording (e.g., desktop)
    base_path = os.path.join("/media/dingo/ESD-USB")

    # Record video and temperature data until manually stopped and get the file paths
    recorded_video, recorded_temperature = record_video_with_temperature(base_path)

    print(f"Video recording completed. File saved at: {recorded_video}")
    print(f"Temperature data recorded. File saved at: {recorded_temperature}")
