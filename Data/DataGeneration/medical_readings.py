#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate synthetic Medical Readings data according to the Medical_Readings table schema:

Table Medical_Readings {
  reading_id        int           [pk, increment]
  patient_id        int           [ref: > Patients.patient_id, not null]
  device_type       varchar(50)   [not null] -- 'Blood_Pressure', 'Blood_Sugar', 'Heart_Rate', 'Temperature', 'Oxygen_Level', 'Weight'
  reading_value     decimal(10,2) [not null]
  unit              varchar(20)   [not null] -- (mg/dL, mmHg, bpm, etc.)
  reading_timestamp datetime      [default: now()]
  is_critical       bit           [default: 0]
  alert_sent        bit           [default: 0]
  notes             nvarchar(500)
}
"""

import random
from datetime import datetime, timedelta
from typing import Dict, List, Tuple

import pandas as pd
from faker import Faker

# Initialize Faker (Standard English)
fake = Faker()
Faker.seed(999)
random.seed(999)

# -------------------------------------------------------------------
# Constants & Logic for Devices
# -------------------------------------------------------------------

# Maps Device Type -> (Unit, Normal Range Min, Normal Range Max, Critical Min, Critical Max)
# Note: Blood Pressure is complex (systolic/diastolic), simplified here to Systolic for general simulation
# or handled specifically in logic. Let's assume 'reading_value' represents the primary metric.
# For BP, we might simulate Systolic here, or assume the system logs them separately.
# We'll treat reading_value as the main number (e.g. Systolic for BP).

DEVICE_CONFIG = {
    "Blood_Pressure": {
        "unit": "mmHg",
        "normal_range": (90, 120),
        "critical_low": 80,
        "critical_high": 180
    },
    "Blood_Sugar": {
        "unit": "mg/dL",
        "normal_range": (70, 140),
        "critical_low": 50,
        "critical_high": 200
    },
    "Heart_Rate": {
        "unit": "bpm",
        "normal_range": (60, 100),
        "critical_low": 40,
        "critical_high": 120
    },
    "Temperature": {
        "unit": "°C",
        "normal_range": (36.1, 37.2),
        "critical_low": 35.0,
        "critical_high": 39.0
    },
    "Oxygen_Level": {
        "unit": "%",
        "normal_range": (95, 100),
        "critical_low": 85,
        "critical_high": 100  # Can't go above 100 really
    },
    "Weight": {
        "unit": "kg",
        "normal_range": (50, 100),  # Very variable, hard to define "critical" generally without height
        "critical_low": 30,
        "critical_high": 200
    }
}

DEVICE_TYPES = list(DEVICE_CONFIG.keys())

# Sample notes
NORMAL_NOTES = [
    "Reading within normal range.",
    "Patient feeling well.",
    "Routine automated log.",
    "Daily check.",
    None, None, None  # weighting towards empty
]

CRITICAL_NOTES = [
    "Reading critically high!",
    "Reading critically low - alert triggered.",
    "Patient advised to seek emergency care.",
    "Abnormal reading detected.",
    "Follow-up required immediately.",
]


# -------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------

def generate_reading_value(device_type: str) -> Tuple[float, bool]:
    """
    Generates a reading value and determines if it is critical.
    Returns (value, is_critical).
    """
    config = DEVICE_CONFIG[device_type]

    # 90% chance of normal-ish reading, 10% chance of critical/abnormal
    is_abnormal = random.random() < 0.10

    if not is_abnormal:
        # Generate value within normal range (mostly)
        min_val, max_val = config["normal_range"]
        # Add slight noise to go just outside "perfect" normal but not critical
        val = random.uniform(min_val - (min_val * 0.05), max_val + (max_val * 0.05))
        return round(val, 2), False
    else:
        # Generate critical value
        # 50/50 chance of being too low or too high
        if random.random() < 0.5:
            # Too low: go below critical_low
            crit_low = config["critical_low"]
            val = random.uniform(crit_low - (crit_low * 0.2), crit_low)
        else:
            # Too high: go above critical_high
            crit_high = config["critical_high"]
            val = random.uniform(crit_high, crit_high + (crit_high * 0.2))

        # Cap Oxygen at 100
        if device_type == "Oxygen_Level" and val > 100:
            val = 100.0

        return round(val, 2), True


def generate_single_reading(
        reading_id: int,
        patient_ids: List[int]
) -> Dict[str, object]:
    """
    Generate a single medical reading record.
    """
    patient_id = random.choice(patient_ids)
    device_type = random.choice(DEVICE_TYPES)
    config = DEVICE_CONFIG[device_type]

    reading_value, is_critical = generate_reading_value(device_type)

    # Alert logic: if critical, high chance alert was sent
    alert_sent = 0
    if is_critical:
        alert_sent = 1 if random.random() < 0.9 else 0
        notes = random.choice(CRITICAL_NOTES)
    else:
        notes = random.choice(NORMAL_NOTES)

    # Timestamp: within last 3 months
    reading_timestamp = fake.date_time_between(start_date="-3m", end_date="now")

    return {
        "reading_id": reading_id,
        "patient_id": patient_id,
        "device_type": device_type,
        "reading_value": reading_value,
        "unit": config["unit"],
        "reading_timestamp": reading_timestamp,
        "is_critical": 1 if is_critical else 0,
        "alert_sent": alert_sent,
        "notes": notes,
    }


def generate_medical_readings_data(
        num_readings: int,
        patient_ids: List[int]
) -> List[Dict[str, object]]:
    """
    Generate a list of medical reading records.
    """
    readings = []
    for i in range(1, num_readings + 1):
        readings.append(generate_single_reading(i, patient_ids))

    return readings


# -------------------------------------------------------------------
# Example Usage
# -------------------------------------------------------------------

if __name__ == "__main__":
    # Configuration
    NUM_READINGS = 50000

    # Using the previously defined range for patients
    patient_ids = list(range(1, 10001))

    print(f"Generating {NUM_READINGS} medical reading records...")
    data = generate_medical_readings_data(NUM_READINGS, patient_ids)

    df = pd.DataFrame(data)

    print("\nGenerated Medical Readings Data (first 5 rows):")
    print(df.head())

    # Save to CSV
    csv_filename = "medical_readings.csv"
    df.to_csv(csv_filename, index=False, encoding="utf-8")
    print(f"\nData successfully saved to '{csv_filename}'")