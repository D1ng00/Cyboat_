import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Read data from CSV file with semicolon delimiter
file_path = 'speed_thrust.csv'  # Replace with the path to your CSV file
data = pd.read_csv(file_path, delimiter=';')

# Convert the 'time' column to numerical values and microseconds to seconds
#data['time'] = pd.to_numeric(data['time']) / 1_000

# Extract x and y data from the dataframe
x_data = data['Speed'].values
y_data = data['Thrust'].values

# Make time start at 0
x_data -= x_data.min()

# Fit a polynomial of degree 3 to the data
coefficients = np.polyfit(x_data, y_data, deg=2)

# Generate the fitted curve using the coefficients
fitted_curve = np.poly1d(coefficients)

# Generate the x values for the fitted curve
x_fit = np.linspace(min(x_data), max(x_data), 100)

# Evaluate the fitted curve at the x values
y_fit = fitted_curve(x_fit)

# Plot the original data and the fitted curve
plt.scatter(x_data, y_data, label='Original Data')
plt.plot(x_fit, y_fit, label='Fitted Curve', color='red')
plt.legend()
plt.xlabel('Time (s)')
plt.ylabel('Velocity (m/s)')
plt.show()

# Print the expression of the fitted curve
print(f"Fitted Curve Expression: {coefficients[0]} * x^3 + {coefficients[1]} * x^2 + {coefficients[2]} * x + {coefficients[3]}")
