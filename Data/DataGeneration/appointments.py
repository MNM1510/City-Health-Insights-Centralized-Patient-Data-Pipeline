#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate synthetic Appointment data according to the Appointments table schema:

Table Appointments {
  appointment_id   int           [pk, increment]
  patient_id       int           [ref: > Patients.patient_id, not null]
  doctor_id        int           [ref: > Doctors.doctor_id, not null]
  appointment_date date          [not null]
  appointment_time time          [not null]
  status           varchar(20)   [default: 'Scheduled'] -- 'Scheduled', 'Completed', 'Cancelled', 'No-Show', 'In-Progress'
  reason           nvarchar(500)
  diagnosis        nvarchar(1000)
  prescription     nvarchar(1000)
  notes            nvarchar(1000)
  created_date     datetime      [default: now()]
  updated_date     datetime      [default: now()]
}
"""

import random
from datetime import datetime, date, time, timedelta
from typing import Dict, List, Optional

import pandas as pd
from faker import Faker

# Initialize Faker (Standard English)
fake = Faker()
Faker.seed(789)
random.seed(789)

# -------------------------------------------------------------------
# Constants / Enums
# -------------------------------------------------------------------

APPOINTMENT_STATUSES = [
    "Scheduled",
    "Completed",
    "Cancelled",
    "No-Show",
    "In-Progress",
]

# Common reasons for visiting a doctor
VISIT_REASONS = [
    "Routine check-up",
    "Fever and chills",
    "Severe headache",
    "Stomach pain",
    "Back pain",
    "Skin rash",
    "Follow-up appointment",
    "Consultation for surgery",
    "Annual physical exam",
    "Vaccination",
    "Chronic disease management",
    "Injury assessment",
    "Allergy symptoms",
    "Chest pain",
    "High blood pressure check",
]

# Sample diagnoses (mapped roughly to reasons or generic)
DIAGNOSES = [
    "Common Cold",
    "Influenza",
    "Migraine",
    "Gastritis",
    "Muscle Strain",
    "Eczema",
    "Hypertension",
    "Type 2 Diabetes",
    "Bronchitis",
    "Urinary Tract Infection",
    "Healthy",
    "Seasonal Allergies",
    "Anxiety Disorder",
    "Sprain",
    "Gastroenteritis",
]

# Sample prescriptions
PRESCRIPTIONS = [
    "Paracetamol 500mg",
    "Ibuprofen 400mg",
    "Amoxicillin 500mg",
    "Lisinopril 10mg",
    "Metformin 500mg",
    "Antihistamine",
    "Cough syrup",
    "Topical cream",
    "Vitamin C & Zinc",
    "Rest and hydration",
    "Physical therapy",
    "No medication required",
]

# Sample doctor notes
DOCTOR_NOTES = [
    "Patient advised to rest.",
    "Follow up in 2 weeks.",
    "Patient refused medication.",
    "Symptoms persistent for 3 days.",
    "Referred to specialist.",
    "Vital signs stable.",
    "Blood tests ordered.",
    "Discussed lifestyle changes.",
    "Patient reporting improvement.",
    "Prescription updated.",
]


# -------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------

def generate_single_appointment(
        appointment_id: int,
        patient_ids: List[int],
        doctor_ids: List[int]
) -> Dict[str, object]:
    """
    Generate a single appointment record.
    """
    patient_id = random.choice(patient_ids)
    doctor_id = random.choice(doctor_ids)

    # Date logic: appointments can be past, today, or future
    # Let's say within the last year and up to 3 months in future
    appt_datetime = fake.date_time_between(start_date="-1y", end_date="+3m")
    appointment_date = appt_datetime.date()

    # Time logic: generic work hours (9 AM to 5 PM)
    hour = random.randint(9, 17)
    minute = random.choice([0, 15, 30, 45])
    appointment_time = time(hour, minute)

    # Status logic depends on date
    today = date.today()

    if appointment_date > today:
        # Future appointments are usually 'Scheduled'
        status = "Scheduled"
    elif appointment_date == today:
        # Today could be any status
        status = random.choice(APPOINTMENT_STATUSES)
    else:
        # Past appointments unlikely to be 'Scheduled' (unless stale data)
        # We'll pick from final statuses
        status = random.choice(["Completed", "Cancelled", "No-Show"])

    # Content fields based on status
    reason = random.choice(VISIT_REASONS)

    diagnosis = None
    prescription = None
    notes = None

    if status == "Completed":
        diagnosis = random.choice(DIAGNOSES)
        prescription = random.choice(PRESCRIPTIONS)
        notes = random.choice(DOCTOR_NOTES)
    elif status == "In-Progress":
        # Might have initial notes but maybe no diagnosis/prescription yet
        notes = "Patient currently in examination room."

    # Created date: usually before the appointment date
    # Randomly 1 to 30 days before appointment
    days_before = random.randint(1, 30)
    created_date = datetime.combine(appointment_date, appointment_time) - timedelta(days=days_before)

    # Updated date: usually same as created or changed later
    if status == "Scheduled":
        updated_date = created_date
    else:
        # Updated around the appointment time or slightly after
        updated_date = datetime.combine(appointment_date, appointment_time) + timedelta(minutes=random.randint(30, 120))

    return {
        "appointment_id": appointment_id,
        "patient_id": patient_id,
        "doctor_id": doctor_id,
        "appointment_date": appointment_date,
        "appointment_time": appointment_time,
        "status": status,
        "reason": reason,
        "diagnosis": diagnosis,
        "prescription": prescription,
        "notes": notes,
        "created_date": created_date,
        "updated_date": updated_date,
    }


def generate_appointments_data(
        num_appointments: int,
        patient_ids: List[int],
        doctor_ids: List[int]
) -> List[Dict[str, object]]:
    """
    Generate a list of appointment records using existing patient/doctor IDs.
    """
    appointments = []
    for i in range(1, num_appointments + 1):
        appointments.append(generate_single_appointment(i, patient_ids, doctor_ids))

    return appointments


# -------------------------------------------------------------------
# Example Usage
# -------------------------------------------------------------------

if __name__ == "__main__":
    # Configuration
    NUM_APPOINTMENTS = 20000  # Number of appointments to generate

    # Define ID ranges explicitly as requested
    patient_ids = list(range(1, 10001))  # Patients 1 to 10000
    doctor_ids = list(range(1, 1002))  # Doctors 1 to 1001

    print(f"Generating {NUM_APPOINTMENTS} appointment records...")
    print(f"Using {len(patient_ids)} patients and {len(doctor_ids)} doctors.")

    data = generate_appointments_data(NUM_APPOINTMENTS, patient_ids, doctor_ids)

    df = pd.DataFrame(data)

    print("\nGenerated Appointments Data (first 5 rows):")
    print(df.head())

    # Save to CSV
    csv_filename = "appointments.csv"
    df.to_csv(csv_filename, index=False, encoding="utf-8")
    print(f"\nData successfully saved to '{csv_filename}'")