
import pandas as pd
import numpy as np

# Load dataset
df = pd.read_csv('supply_chain.csv')

# Display basic info
print("Initial Data Overview:")
print(df.head())
print(df.info())

# Convert date columns to datetime format
df['order_date'] = pd.to_datetime(df['order_date'], errors='coerce')
df['delivery_date'] = pd.to_datetime(df['delivery_date'], errors='coerce')

# Remove invalid or missing dates
df = df.dropna(subset=['order_date', 'delivery_date'])

# Calculate delivery time in days
df['delivery_days'] = (df['delivery_date'] - df['order_date']).dt.days

# Replace negative or unrealistic delivery days (e.g., -1, 0) with median
median_days = df['delivery_days'].median()
df.loc[df['delivery_days'] <= 0, 'delivery_days'] = median_days

# Handle missing values in numeric columns
num_cols = ['cost_price', 'selling_price', 'quantity']
for col in num_cols:
    df[col] = df[col].fillna(df[col].median())

# Create profit column
df['profit'] = (df['selling_price'] - df['cost_price']) * df['quantity']

# Drop duplicates if any
df = df.drop_duplicates()

# Save cleaned data
df.to_csv('supply_chain_cleaned.csv', index=False)
