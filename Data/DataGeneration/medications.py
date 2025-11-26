#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate synthetic Medications data according to the Medications table schema:

Table Medications {
  medication_id    int           [pk, increment]
  appointment_id   int           [ref: > Appointments.appointment_id, not null]
  patient_id       int           [ref: > Patients.patient_id, not null]
  medication_name  nvarchar(200) [not null]
  dosage           nvarchar(100) [not null]
  frequency        nvarchar(100) [not null]
  duration         nvarchar(100)
  start_date       date          [default: now()]
  end_date         date
  instructions     nvarchar(500)
}
"""

import random
from datetime import datetime, date, timedelta
from typing import Dict, List, Optional

import pandas as pd
from faker import Faker

# Initialize Faker (Standard English)
fake = Faker()
Faker.seed(101112)
random.seed(101112)

# -------------------------------------------------------------------
# Constants / Reference Data
# -------------------------------------------------------------------

COMMON_MEDICATIONS = [
    "Paracetamol (Panadol)",
    "Ibuprofen (Brufen)",
    "Amoxicillin (Augmentin)",
    "Metformin (Glucophage)",
    "Atorvastatin (Lipitor)",
    "Omeprazole (Losec)",
    "Amlodipine (Norvasc)",
    "Lisinopril (Zestril)",
    "Azithromycin (Zithromax)",
    "Ciprofloxacin (Ciprobay)",
    "Pantoprazole (Controloc)",
    "Bisoprolol (Concor)",
    "Clopidogrel (Plavix)",
    "Acetylsalicylic acid (Aspirin)",
    "Levothyroxine (Eltroxin)",
    "Prednisolone (Solupred)",
    "Cetirizine (Zyrtec)",
    "Loratadine (Claritin)",
    "Vitamin D3",
    "Multivitamins",
]

DOSAGES = [
    "500mg", "1000mg", "20mg", "40mg", "5mg", "10mg", "875mg", "1 tablet",
    "1 capsule", "5ml", "10ml", "1 puff", "2 drops"
]

FREQUENCIES = [
    "Once daily",
    "Twice daily",
    "Three times a day",
    "Every 8 hours",
    "Every 12 hours",
    "Before sleep",
    "As needed (PRN)",
    "Every 4 to 6 hours",
    "Once a week"
]

DURATIONS = [
    "3 days", "5 days", "7 days", "10 days", "2 weeks", "1 month", "3 months", "Chronic/Ongoing"
]

INSTRUCTIONS_LIST = [
    "Take after meals.",
    "Take on an empty stomach.",
    "Take with a full glass of water.",
    "Do not crush or chew.",
    "Shake well before use.",
    "Store in a cool, dry place.",
    "Avoid driving after taking this medication.",
    "Take in the morning.",
    "Take before bedtime.",
    "Finish the full course.",
]


# -------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------

def parse_duration_days(duration_str: str) -> int:
    """Helper to estimate days from duration string for end_date calculation."""
    if "day" in duration_str:
        return int(''.join(filter(str.isdigit, duration_str)) or 3)
    elif "week" in duration_str:
        return int(''.join(filter(str.isdigit, duration_str)) or 1) * 7
    elif "month" in duration_str:
        return int(''.join(filter(str.isdigit, duration_str)) or 1) * 30
    else:
        return 90  # Default for Chronic/Ongoing


def generate_single_medication(
        medication_id: int,
        appointment_ids: List[int],
        patient_ids: List[int]
) -> Dict[str, object]:
    """
    Generate a single medication record.
    """
    # Note: In a production environment, you would ensure patient_id matches
    # the patient associated with the appointment_id. Here, we select randomly
    # from the provided valid ranges for synthetic generation.
    appointment_id = random.choice(appointment_ids)
    patient_id = random.choice(patient_ids)

    med_name = random.choice(COMMON_MEDICATIONS)
    dosage = random.choice(DOSAGES)
    frequency = random.choice(FREQUENCIES)
    duration_str = random.choice(DURATIONS)
    instructions = random.choice(INSTRUCTIONS_LIST)

    # Start date usually matches appointment date (simulated here as recent past)
    start_date = fake.date_between(start_date="-1y", end_date="today")

    # End date calculation based on duration
    days_to_add = parse_duration_days(duration_str)
    end_date = start_date + timedelta(days=days_to_add)

    return {
        "medication_id": medication_id,
        "appointment_id": appointment_id,
        "patient_id": patient_id,
        "medication_name": med_name,
        "dosage": dosage,
        "frequency": frequency,
        "duration": duration_str,
        "start_date": start_date,
        "end_date": end_date,
        "instructions": instructions,
    }


def generate_medications_data(
        num_records: int,
        appointment_ids: List[int],
        patient_ids: List[int]
) -> List[Dict[str, object]]:
    """
    Generate a list of medication records.
    """
    medications = []
    for i in range(1, num_records + 1):
        medications.append(generate_single_medication(i, appointment_ids, patient_ids))
    return medications


# -------------------------------------------------------------------
# Example Usage
# -------------------------------------------------------------------

if __name__ == "__main__":
    # Configuration
    # We'll generate 25,000 medication records (assuming some appointments have multiple meds)
    NUM_MEDICATIONS = 25000

    # ID Ranges based on previous contexts
    # Appointments: 1 to 20,000
    # Patients: 1 to 10,000
    appointment_ids = list(range(1, 20001))
    patient_ids = list(range(1, 10001))

    print(f"Generating {NUM_MEDICATIONS} medication records...")
    data = generate_medications_data(NUM_MEDICATIONS, appointment_ids, patient_ids)

    df = pd.DataFrame(data)

    print("\nGenerated Medications Data (first 5 rows):")
    print(df.head())

    # Save to CSV
    csv_filename = "medications.csv"
    df.to_csv(csv_filename, index=False, encoding="utf-8")
    print(f"\nData successfully saved to '{csv_filename}'")