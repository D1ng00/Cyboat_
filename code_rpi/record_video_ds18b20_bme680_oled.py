import os
import picamera
from datetime import datetime
from gpiozero import CPUTemperature
import time
import board
import adafruit_bme680
import Adafruit_SSD1306
from PIL import Image, ImageDraw, ImageFont

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

def read_bme680():
    i2c = board.I2C()
    bme = adafruit_bme680.Adafruit_BME680_I2C(i2c)

    # You can adjust the delay based on your requirements
    time.sleep(2)

    temperature = bme.temperature
    humidity = bme.humidity
    pressure = bme.pressure
    gas = bme.gas

    return temperature, humidity, pressure, gas

def display_oled(temperature_ds18b20):
    # Raspberry Pi pin configuration for the OLED display
    RST = 24
    disp = Adafruit_SSD1306.SSD1306_128_64(rst=RST, i2c_address=0x3C)

    try:
        disp.begin()
        disp.clear()
        disp.display()

        width = disp.width
        height = disp.height
        image = Image.new("1", (width, height))

        draw = ImageDraw.Draw(image)
        font = ImageFont.load_default()

        draw.text((0, 0), f"Temp (DS18B20): {temperature_ds18b20} °C", font=font, fill=255)
        disp.image(image)
        disp.display()
    except Exception as e:
        print(f"Error displaying on OLED: {e}")

def record_video_with_sensors_and_oled(base_path):
    # Set the file path for video recording
    video_file_path = os.path.join(base_path, "output_video.h264")

    # Set the file path for sensor data
    sensor_file_path = os.path.join(base_path, "sensor_data.txt")

    # Set the resolution for video recording (you can adjust as needed)
    resolution = (640, 480)

    with picamera.PiCamera() as camera:
        # Set the camera resolution
        camera.resolution = resolution

        # Start recording video
        camera.start_recording(video_file_path, format='h264')

        try:
            # Record sensor data and update OLED display
            while True:
                current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                temperature_ds18b20 = read_temperature()
                temperature_bme680, humidity, pressure, gas = read_bme680()

                # Append sensor data to the text file
                with open(sensor_file_path, 'a') as sensor_file:
                    sensor_file.write(
                        f"{current_time}, "
                        f"DS18B20 Temperature: {temperature_ds18b20} °C, "
                        f"BME680 Temperature: {temperature_bme680} °C, "
                        f"Humidity: {humidity} %, "
                        f"Pressure: {pressure} hPa, "
                        f"Gas Resistance: {gas} ohms\n"
                    )

                # Display on OLED
                display_oled(temperature_ds18b20)

                # Record video for 5 seconds
                camera.wait_recording(5)

        except KeyboardInterrupt:
            # Stop recording when KeyboardInterrupt is received
            pass

        finally:
            # Stop recording video
            camera.stop_recording()

    return video_file_path, sensor_file_path

if __name__ == "__main__":
    # Specify the base path for recording (e.g., desktop)
    base_path = os.path.join("/media/dingo/ESD-USB")

    # Record video, sensor data, and display on OLED until manually stopped
    recorded_video, recorded_sensor_data = record_video_with_sensors_and_oled(base_path)

    print(f"Video recording completed. File saved at: {recorded_video}")
    print(f"Sensor data recorded. File saved at: {recorded_sensor_data}")