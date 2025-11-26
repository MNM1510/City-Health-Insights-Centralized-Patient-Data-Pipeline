#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate synthetic System Alerts data according to the System_Alerts table schema:

Table System_Alerts {
  alert_id       int           [pk, increment]
  patient_id     int           [ref: > Patients.patient_id, note: 'Optional']
  doctor_id      int           [ref: > Doctors.doctor_id, note: 'Optional']
  alert_type     varchar(50)   [not null]
  alert_message  nvarchar(500) [not null]
  severity       varchar(20)   [default: 'Medium']
  is_read        bit           [default: 0]
  created_date   datetime      [default: now()]
}
"""

import random
from datetime import datetime, timedelta
from typing import Dict, List, Optional

import pandas as pd
from faker import Faker

# Initialize Faker (Standard English)
fake = Faker()
Faker.seed(131415)
random.seed(131415)

# -------------------------------------------------------------------
# Constants / Reference Data
# -------------------------------------------------------------------

ALERT_TYPES = [
    "Critical_Reading",
    "Appointment_Reminder",
    "Lab_Result",
    "Medication_Reminder",
    "Emergency"
]

SEVERITY_LEVELS = ["Low", "Medium", "High", "Critical"]

# Mapping types to potential messages and typical severity
ALERT_TEMPLATES = {
    "Critical_Reading": {
        "messages": [
            "Patient BP extremely high.",
            "Blood oxygen level dropped below threshold.",
            "Abnormal heart rate detected.",
            "Glucose level critically low.",
            "High temperature alert detected."
        ],
        "severity_weights": [0.0, 0.0, 0.3, 0.7]  # Mostly High/Critical
    },
    "Appointment_Reminder": {
        "messages": [
            "Upcoming appointment tomorrow at 10:00 AM.",
            "Reminder: Follow-up visit scheduled.",
            "You have a consultation in 2 hours.",
            "Please confirm your attendance for the next appointment.",
            "Doctor availability confirmed for your slot."
        ],
        "severity_weights": [0.6, 0.4, 0.0, 0.0]  # Low/Medium
    },
    "Lab_Result": {
        "messages": [
            "New lab results available for viewing.",
            "Pathology report is ready.",
            "Blood test results uploaded.",
            "Urinalysis report completed.",
            "Please review recent X-Ray results."
        ],
        "severity_weights": [0.2, 0.6, 0.2, 0.0]  # Mixed
    },
    "Medication_Reminder": {
        "messages": [
            "Time to take your evening medication.",
            "Missed dose alert.",
            "Prescription refill reminder.",
            "Daily vitamin reminder.",
            "Please adhere to antibiotic schedule."
        ],
        "severity_weights": [0.3, 0.5, 0.2, 0.0]  # Low to High
    },
    "Emergency": {
        "messages": [
            "SOS alert triggered by patient app.",
            "Fall detected!",
            "Patient called for immediate assistance.",
            "Emergency button pressed.",
            "System detected prolonged inactivity."
        ],
        "severity_weights": [0.0, 0.0, 0.1, 0.9]  # Mostly Critical
    }
}


# -------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------

def generate_single_alert(
        alert_id: int,
        patient_ids: List[int],
        doctor_ids: List[int]
) -> Dict[str, object]:
    """
    Generate a single system alert record.
    """
    alert_type = random.choice(ALERT_TYPES)
    template = ALERT_TEMPLATES[alert_type]

    message = random.choice(template["messages"])
    severity = random.choices(SEVERITY_LEVELS, weights=template["severity_weights"], k=1)[0]

    # Logic for target audience (Patient vs Doctor)
    # Critical readings/Emergency usually target doctors or both
    # Reminders usually target patients
    if alert_type in ["Appointment_Reminder", "Medication_Reminder"]:
        patient_id = random.choice(patient_ids)
        doctor_id = None  # Often just for patient
    elif alert_type in ["Critical_Reading", "Emergency"]:
        patient_id = random.choice(patient_ids)
        doctor_id = random.choice(doctor_ids)  # Alert sent to doc about patient
    else:  # Lab Result etc
        patient_id = random.choice(patient_ids)
        doctor_id = random.choice(doctor_ids) if random.random() > 0.5 else None

    # Is Read status
    is_read = random.choice([0, 1])

    # Date (Recent history)
    created_date = fake.date_time_between(start_date="-3m", end_date="now")

    return {
        "alert_id": alert_id,
        "patient_id": patient_id,
        "doctor_id": doctor_id,
        "alert_type": alert_type,
        "alert_message": message,
        "severity": severity,
        "is_read": is_read,
        "created_date": created_date
    }


def generate_alerts_data(
        num_alerts: int,
        patient_ids: List[int],
        doctor_ids: List[int]
) -> List[Dict[str, object]]:
    """
    Generate a list of alert records.
    """
    alerts = []
    for i in range(1, num_alerts + 1):
        alerts.append(generate_single_alert(i, patient_ids, doctor_ids))
    return alerts


# -------------------------------------------------------------------
# Example Usage
# -------------------------------------------------------------------

if __name__ == "__main__":
    # Configuration
    NUM_ALERTS = 15000

    # ID Ranges
    patient_ids = list(range(1, 10001))
    doctor_ids = list(range(1, 1002))

    print(f"Generating {NUM_ALERTS} system alert records...")
    data = generate_alerts_data(NUM_ALERTS, patient_ids, doctor_ids)

    df = pd.DataFrame(data)

    print("\nGenerated System Alerts Data (first 5 rows):")
    # Handling NaN for CSV export (integers with None become floats in pandas default, convert to Int64 for display if needed)
    # But for raw CSV dump, empty strings or floats are fine.
    # Let's keep it simple.
    print(df.head())

    # Save to CSV
    csv_filename = "system_alerts_en.csv"
    df.to_csv(csv_filename, index=False, encoding="utf-8")
    print(f"\nData successfully saved to '{csv_filename}'")