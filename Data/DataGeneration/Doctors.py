#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate synthetic Egyptian doctor data in English according to the Doctors table schema:

Table Doctors {
  doctor_id           int           [pk, increment]
  national_id         varchar(14)   [unique, not null]
  first_name          nvarchar(50)  [not null]
  last_name           nvarchar(50)  [not null]
  specialization      nvarchar(100) [not null]
  license_number      varchar(50)   [unique, not null]
  phone               varchar(15)   [not null]
  years_of_experience int           [default: 0]
  consultation_fee    decimal(10,2) [default: 0]
  is_active           bit           [default: 1]
  registration_date   datetime      [default: now()]
}
"""

import random
from datetime import datetime, date, timedelta
from typing import Dict, List

import pandas as pd
from faker import Faker

# Initialize Faker (Standard English)
fake = Faker()
Faker.seed(456)
random.seed(456)

# -------------------------------------------------------------------
# Shared / Contextual Data (names, phones, specializations)
# -------------------------------------------------------------------

egyptian_male_first_names: List[str] = [
    "Mohamed", "Ahmed", "Mahmoud", "Mostafa", "Hassan", "Hussein", "Ibrahim", "Ali", "Khaled", "Omar",
    "Youssef", "Yasser", "Tarek", "Amr", "Sherif", "Karim", "Wael", "Ramy", "Sameh", "Fares",
    "Islam", "Ehab", "Ashraf", "Samy", "Saeed", "Gamal", "Medhat", "Haitham", "Tamer",
    "Marwan", "Adel", "Bilal", "Hamza", "Abdelrahman", "Abdullah", "Abdelaziz",
]

egyptian_female_first_names: List[str] = [
    "Fatma", "Maryam", "Sarah", "Aya", "Noha", "Heba", "Reem",
    "Mona", "Hala", "Dina", "Iman", "Safaa", "Rehab", "Rasha", "Lobna",
    "Yasmine", "Shaimaa", "Abeer", "Naglaa", "Hoda", "Samar", "Ghada", "Hanan",
    "Nour", "Malak", "Laila", "Salma", "Yara", "Habiba", "Farida", "Hagar", "Rahma",
]

egyptian_last_names: List[str] = [
    "El-Masry", "El-Qahery", "El-Saeedi", "El-Aswany", "El-Iskandarany",
    "El-Alawy", "El-Sherif", "El-Qurashi", "El-Araby",
    "Osman", "Abdelaziz", "Abdelhamid", "Abdelfattah", "Abdullah",
    "Kamel", "Hussein", "Mahmoud", "Ali", "Saad", "Amin", "Farag", "Saber", "Mohsen",
    "El-Khouly", "Gad", "Wahba", "Bakr", "Nassar", "Afifi", "El-Shennawy", "Abo El-Naga",
    "Ramadan", "Shawky", "Morsi", "Mansour", "Fahmy", "Helmy", "Shehata",
    "Sarhan", "Salem", "Salama", "Sobhy", "Mokhtar", "El-Sherbiny", "Zayed", "Ghoneim",
    "Hegazy", "El-Omda", "Metwally", "Shalaby",
]

egyptian_phone_prefixes: List[str] = ["010", "011", "012", "015"]

# Common medical specializations in English
doctor_specializations: List[str] = [
    "Internal Medicine", "Cardiology", "Pediatrics", "Obstetrics and Gynecology", "Orthopedics",
    "ENT (Otolaryngology)", "Dermatology", "Dentistry", "Oncology", "General Surgery",
    "Neurology", "Urology", "Psychiatry", "Ophthalmology",
    "Clinical Nutrition", "Endocrinology", "Pulmonology", "Obesity Management",
    "Immunology", "Family Medicine", "Emergency Medicine",
]


# -------------------------------------------------------------------
# Helper: Egyptian National ID Generator
# -------------------------------------------------------------------

def generate_egyptian_national_id(dob_year: int, dob_month: int, dob_day: int, gender: str) -> str:
    """
    Generate a 14-digit Egyptian National ID.

    Structure:
        [0]       Century code: '2' for 1900s, '3' for 2000s
        [1-2]     Year (YY)
        [3-4]     Month (MM)
        [5-6]     Day (DD)
        [7-8]     Governorate code (01–88)
        [9-12]    Sequence (4 digits), last digit encodes gender:
                    - Odd  -> Male
                    - Even -> Female
        [13]      Check digit (random)
    """
    century_code = "2" if dob_year < 2000 else "3"

    year_digits = str(dob_year % 100).zfill(2)
    month_digits = str(dob_month).zfill(2)
    day_digits = str(dob_day).zfill(2)

    governorate_code = str(random.randint(1, 88)).zfill(2)

    sequence_prefix = str(random.randint(0, 999)).zfill(3)

    # Last digit of sequence determines gender
    if gender == "Male":
        gender_digit = str(random.choice([1, 3, 5, 7, 9]))
    else:
        gender_digit = str(random.choice([0, 2, 4, 6, 8]))

    sequence_gender_part = sequence_prefix + gender_digit
    check_digit = str(random.randint(0, 9))

    return (
        f"{century_code}{year_digits}{month_digits}"
        f"{day_digits}{governorate_code}{sequence_gender_part}{check_digit}"
    )


# -------------------------------------------------------------------
# Helper: License number generator
# -------------------------------------------------------------------

def generate_license_number(specialization: str) -> str:
    """
    Generate a synthetic license number like:
      'MOH-INT-123456' (Ministry of Health - Code - Serial).
    """
    # Create a short code from the specialization (first 3 letters, uppercase)
    spec_code = "".join(ch for ch in specialization if ch.isalpha())[:3].upper()
    if not spec_code:
        spec_code = "GEN"

    serial = random.randint(100000, 999999)
    return f"MOH-{spec_code}-{serial}"


# -------------------------------------------------------------------
# Core: Single doctor generator
# -------------------------------------------------------------------

def generate_single_doctor(doctor_id_counter: int) -> Dict[str, object]:
    """
    Generate a single doctor record matching the Doctors table schema.
    """

    gender = random.choice(["Male", "Female"])

    # Name
    if gender == "Male":
        first_name = random.choice(egyptian_male_first_names)
    else:
        first_name = random.choice(egyptian_female_first_names)
    last_name = random.choice(egyptian_last_names)

    # Age: Assuming doctors are roughly between 25 and 70 years old
    today = date.today()
    max_age_years = 70
    min_age_years = 25

    dob_start_date = today - timedelta(days=max_age_years * 365)
    dob_end_date = today - timedelta(days=min_age_years * 365)
    date_of_birth: date = fake.date_between(start_date=dob_start_date, end_date=dob_end_date)

    # National ID
    national_id = generate_egyptian_national_id(
        date_of_birth.year, date_of_birth.month, date_of_birth.day, gender
    )

    # Specialization
    specialization = random.choice(doctor_specializations)

    # License number
    license_number = generate_license_number(specialization)

    # Phone
    phone_prefix = random.choice(egyptian_phone_prefixes)
    phone = f"{phone_prefix}{fake.numerify('#######')}"  # 7 random digits

    # Years of experience: 0 to 45 years, logic constrained by age
    # Assume graduation/practice starts around age 24
    age_years = (today - date_of_birth).days // 365
    max_possible_experience = max(age_years - 24, 0)
    years_of_experience = random.randint(0, min(max_possible_experience, 45))

    # Consultation fee: 100 to 800 EGP
    consultation_fee = round(random.uniform(100, 800), 2)

    # is_active
    is_active = random.choice([0, 1])

    # Registration date within the last 5 years
    registration_date = fake.date_time_between(start_date="-5y", end_date="now")

    return {
        "doctor_id": doctor_id_counter,
        "national_id": national_id,
        "first_name": first_name,
        "last_name": last_name,
        "specialization": specialization,
        "license_number": license_number,
        "phone": phone,
        "years_of_experience": years_of_experience,
        "consultation_fee": consultation_fee,
        "is_active": is_active,
        "registration_date": registration_date,
    }


# -------------------------------------------------------------------
# List generator
# -------------------------------------------------------------------

def generate_doctors_data(num_doctors: int) -> List[Dict[str, object]]:
    """
    Generate a list of doctor records.
    """
    doctors = []
    used_license_numbers = set()
    used_national_ids = set()

    for i in range(1, num_doctors + 1):
        while True:
            record = generate_single_doctor(i)

            # Ensure uniqueness for national_id and license_number in memory
            if record["national_id"] in used_national_ids:
                continue
            if record["license_number"] in used_license_numbers:
                continue

            used_national_ids.add(record["national_id"])
            used_license_numbers.add(record["license_number"])
            doctors.append(record)
            break

    return doctors


# -------------------------------------------------------------------
# Example Usage
# -------------------------------------------------------------------

if __name__ == "__main__":
    num_records_to_generate = 1000

    print(f"Generating {num_records_to_generate} doctor records (English)...")
    generated_doctors = generate_doctors_data(num_records_to_generate)

    df = pd.DataFrame(generated_doctors)

    print("\nGenerated Doctors Data (first 5 rows):")
    print(df.head())

    # Save to CSV (UTF-8)
    csv_filename = "doctors.csv"
    df.to_csv(csv_filename, index=False, encoding="utf-8")
    print(f"\nData successfully saved to '{csv_filename}'")