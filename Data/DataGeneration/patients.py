#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate synthetic Egyptian patient data in English according to the Patients table schema:

Table Patients {
  patient_id               int           [pk, increment]
  national_id              varchar(14)   [unique, not null]
  first_name               nvarchar(50)  [not null]
  last_name                nvarchar(50)  [not null]
  date_of_birth            date          [not null]
  gender                   varchar(10)   [not null]  -- 'Male' or 'Female'
  phone                    varchar(15)   [not null]
  address                  nvarchar(200)
  blood_type               varchar(5)
  allergies                nvarchar(500)
  chronic_diseases         nvarchar(500)
  emergency_contact_name   nvarchar(100)
  emergency_contact_phone  varchar(15)
  registration_date        datetime      [default: now()]
  is_active                bit           [default: 1]
}
"""

import random
from datetime import datetime, date, timedelta
from typing import Dict, List, Optional

import pandas as pd
from faker import Faker

# Initialize Faker (Standard English)
fake = Faker()
Faker.seed(123)
random.seed(123)

# -------------------------------------------------------------------
# Custom Data for Egyptian Context (Transliterated to English)
# -------------------------------------------------------------------

egyptian_male_first_names: List[str] = [
    # Common
    "Mohamed", "Ahmed", "Mahmoud", "Mostafa", "Hassan", "Hussein", "Ibrahim", "Ali", "Khaled", "Omar",
    "Youssef", "Yasser", "Tarek", "Amr", "Sherif", "Karim", "Wael", "Ramy", "Sameh", "Fares",
    "Islam", "Ehab", "Ayman", "Ashraf", "Samy", "Saeed", "Saleh", "Salem", "Gamal",
    "Fathy", "Medhat", "Haitham", "Tamer", "Mina", "George", "Shenouda",

    # Younger Generation / Modern
    "Ziad", "Malek", "Adam", "Selim", "Yassin", "Adel", "Mazen", "Bilal", "Zaid",
    "Seif", "Hamza", "Anas", "Raed", "Mohanad", "Marwan", "Nour El-Din",
    "Abdelrahman", "Abdullah", "Abdelaziz", "Eyad", "Abdelrahim", "Adham", "Aws", "Laith",
]

egyptian_female_first_names: List[str] = [
    # Common
    "Fatma", "Fatma El-Zahraa", "Maryam", "Sarah", "Aya", "Doaa", "Radwa", "Noha", "Heba", "Reem",
    "Mona", "Hala", "Hana", "Dina", "Soha", "Iman", "Safaa", "Rehab", "Rasha", "Lobna",
    "Yasmine", "Shaimaa", "Abeer", "Naglaa", "Nora", "Nariman", "Hoda", "Samar", "Ghada", "Hanan",

    # Younger Generation / Modern
    "Nour", "Jana", "Malak", "Laila", "Salma", "Yara", "Habiba", "Farida", "Hagar", "Rahma",
    "Judy", "Rawan", "Zeinab", "Donia", "Rana", "Gehad", "Janna", "Sidra", "Talia", "Jouri",
    "Aline", "Layan", "Talin", "Rodina", "Raghad", "Alaa", "Basmala", "Shahd", "Sondos", "Saga",
]

egyptian_last_names: List[str] = [
    # Tribal / Regional / Famous Families
    "El-Masry", "El-Qahery", "El-Saeedi", "El-Aswany", "El-Iskandarany",
    "El-Alawy", "El-Hashemy", "El-Ansari", "El-Sherif", "El-Qurashi", "El-Araby",

    # Common Surnames
    "Osman", "Abdelaziz", "Abdelhamid", "Abdelfattah", "Abdullah", "Abdelsalam",
    "Kamel", "Hussein", "Mahmoud", "Ali", "Saad", "Amin", "Farag", "Saber", "Mohsen",
    "El-Khouly", "Gad", "Wahba", "Bakr", "Nassar", "Afifi", "El-Shennawy", "Abo El-Naga",
    "Ramadan", "Shawky", "Hassanin", "Morsi", "Mansour", "Fahmy", "Helmy", "Shehata",
    "Sarhan", "Salem", "Salama", "Sobhy", "Mokhtar", "El-Sherbiny", "Zayed", "Ghoneim",
    "Hegazy", "El-Omda", "Ghamrawy", "El-Ghazaly", "El-Sakka", "Zaker", "Metwally", "Shalaby",
]

egyptian_governorates: List[str] = [
    "Cairo", "Giza", "Alexandria", "Port Said", "Suez", "Damietta",
    "Dakahlia", "Sharqia", "Qalyubia", "Kafr El Sheikh", "Gharbia", "Monufia",
    "Beheira", "Ismailia", "Beni Suef", "Faiyum", "Minya", "Asyut",
    "Sohag", "Qena", "Luxor", "Aswan", "Red Sea", "New Valley",
    "Matrouh", "North Sinai", "South Sinai",
]

egyptian_cities_by_governorate: Dict[str, List[str]] = {
    "Cairo": [
        "Nasr City", "Heliopolis", "Maadi", "Shubra", "Zamalek", "Al Rehab",
        "Fifth Settlement", "Helwan", "Ain Shams", "El Marg", "Madinaty", "Mokattam",
        "Abbassia", "Ataba", "Sayeda Zeinab", "New Cairo", "New October",
    ],
    "Giza": [
        "Dokki", "Mohandessin", "Imbaba", "Agouza", "6th of October", "Sheikh Zayed",
        "Haram", "Faisal", "Boulaq El Dakrour", "Mounib", "Ayat", "Manshat El Qanater",
    ],
    "Alexandria": [
        "Smouha", "Montaza", "Agami", "Moharam Bek", "Miami",
        "Bakos", "Sidi Bishr", "Sidi Gaber", "Borg El Arab", "Asafra",
    ],
    "Sharqia": [
        "Zagazig", "Belbeis", "10th of Ramadan", "Minya El Qamh", "Hehia",
        "Abu Hammad", "Abu Kabir", "Faqous", "Al Qarin", "New Salhia",
    ],
    "Gharbia": [
        "Tanta", "El Mahalla El Kubra", "Kafr El Zayat", "Zifta", "Samannoud",
    ],
    "Monufia": [
        "Shebin El Kom", "Menouf", "Sadat City", "Quweisna", "Ashmoun",
    ],
    "Qalyubia": [
        "Benha", "Shubra El Kheima", "Qalyub", "Toukh", "Khanka",
    ],
    "Dakahlia": [
        "Mansoura", "Mit Ghamr", "Belqas", "Senbellawein", "Talkha", "Gamasa",
    ],
    "Beheira": [
        "Damanhour", "Kafr El Dawar", "Rashid", "Kom Hamada", "Itay El Barud",
    ],
    "Port Said": [
        "Port Fuad", "Al Sharq District", "Al Arab District", "Al Zohour District",
    ],
    "Suez": [
        "Suez District", "Arbaeen District", "Faisal District", "Attaka",
    ],
    "Ismailia": [
        "Ismailia City", "Fayed", "Qantara Sharq", "Qantara Gharb",
    ],
    "Red Sea": [
        "Hurghada", "El Gouna", "Ras Gharib", "Safaga", "Quseir", "Marsa Alam",
    ],
    "South Sinai": [
        "Sharm El Sheikh", "Dahab", "Nuweiba", "Taba", "Saint Catherine",
    ],
}

# Fallback list for governorates not explicitly detailed above
all_egyptian_cities: List[str] = list(
    set(
        [city for sublist in egyptian_cities_by_governorate.values() for city in sublist]
        + ["Marsa Matrouh", "Alamein", "Arish", "Luxor City", "Aswan City", "Sohag City"]
    )
)

egyptian_phone_prefixes: List[str] = ["010", "011", "012", "015"]
blood_types: List[str] = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

allergies_list: List[str] = [
    "None",
    "Penicillin allergy",
    "Aspirin allergy",
    "Seafood allergy",
    "Peanut allergy",
    "Dust allergy",
    "Pollen allergy",
    "Latex allergy",
    "Antibiotic allergy",
]

chronic_diseases_list: List[str] = [
    "None",
    "Diabetes mellitus",
    "Hypertension",
    "Heart disease",
    "Chronic kidney disease",
    "Asthma",
    "Thyroid disorders",
    "Arthritis",
    "Viral hepatitis",
    "Epilepsy",
]

# -------------------------------------------------------------------
# Helper: Address Generator
# -------------------------------------------------------------------

street_types: List[str] = ["St.", "Rd.", "Sq.", "Lane", "Ave."]
street_names: List[str] = [
    "El Nile", "El Haram", "El Gomhouria", "El Mahatta", "El Geish", "El Horreya",
    "El Salam", "Misr", "El Tahrir", "El Shohada", "El Orouba", "Airport",
    "El Zohour", "El Mostaqbal", "El Nasr", "El Wahda", "El Galaa", "Ramses",
    "26th of July", "Salah Salem",
]


def generate_english_street_name() -> str:
    """Return a simple Egyptian street name in English format."""
    return f"{random.choice(street_names)} {random.choice(street_types)}"


# -------------------------------------------------------------------
# Helper Functions for Data Generation
# -------------------------------------------------------------------

def generate_egyptian_national_id(dob_year: int, dob_month: int, dob_day: int, gender: str) -> str:
    """
    Generate a 14-digit Egyptian National ID.

    Structure:
        [0]       Century code: '2' for 1900-1999, '3' for 2000-2099
        [1-2]     Year (YY)
        [3-4]     Month (MM)
        [5-6]     Day (DD)
        [7-8]     Governorate code (01–88)
        [9-12]    Sequence (4 digits). Last digit (index 12) encodes gender:
                    - Odd  -> Male
                    - Even -> Female
        [13]      Check digit (random)
    """
    century_code = "3" if dob_year >= 2000 else "2"

    year_digits = str(dob_year % 100).zfill(2)
    month_digits = str(dob_month).zfill(2)
    day_digits = str(dob_day).zfill(2)

    governorate_code = str(random.randint(1, 88)).zfill(2)

    sequence_prefix = str(random.randint(0, 999)).zfill(3)

    # Egyptian NID logic: Index 12 (13th digit) is Odd for Male, Even for Female
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


def generate_single_patient_data(patient_id_counter: int) -> Dict[str, object]:
    """
    Generate one patient record matching the Patients table schema (English values).
    """
    gender = random.choice(["Male", "Female"])

    # Names
    if gender == "Male":
        first_name = random.choice(egyptian_male_first_names)
    else:
        first_name = random.choice(egyptian_female_first_names)
    last_name = random.choice(egyptian_last_names)

    # Date of birth (18–80 years old)
    today = date.today()
    max_age_years = 80
    min_age_years = 18

    dob_start_date = today - timedelta(days=max_age_years * 365)
    dob_end_date = today - timedelta(days=min_age_years * 365)
    date_of_birth: date = fake.date_between(
        start_date=dob_start_date, end_date=dob_end_date
    )

    # National ID
    national_id = generate_egyptian_national_id(
        date_of_birth.year, date_of_birth.month, date_of_birth.day, gender
    )

    # Phone
    phone_prefix = random.choice(egyptian_phone_prefixes)
    phone = f"{phone_prefix}{fake.numerify('#######')}"  # 7 random digits

    # Address
    governorate = random.choice(egyptian_governorates)
    city_options = egyptian_cities_by_governorate.get(governorate, all_egyptian_cities)
    city = random.choice(city_options)
    street = generate_english_street_name()
    # Format: 15 El Tahrir St., Maadi, Cairo
    address_str = f"{fake.building_number()} {street}, {city}, {governorate}"

    # Blood type
    blood_type_val: str = random.choice(blood_types)

    # Allergies (allow nulls)
    allergies = random.choice(allergies_list + [""] * 3)
    allergies_output: Optional[str] = None if allergies in ("None", "") else allergies

    # Chronic diseases (allow nulls)
    chronic_diseases = random.choice(chronic_diseases_list + [""] * 4)
    chronic_diseases_output: Optional[str] = (
        None if chronic_diseases in ("None", "") else chronic_diseases
    )

    # Emergency contact
    emergency_contact_gender = random.choice(["Male", "Female"])
    if emergency_contact_gender == "Male":
        ec_first_name = random.choice(egyptian_male_first_names)
    else:
        ec_first_name = random.choice(egyptian_female_first_names)
    ec_last_name = random.choice(egyptian_last_names)
    emergency_contact_name = f"{ec_first_name} {ec_last_name}"

    ec_phone_prefix = random.choice(egyptian_phone_prefixes)
    emergency_contact_phone = f"{ec_phone_prefix}{fake.numerify('#######')}"

    # Registration date within the last 2 years
    registration_date = fake.date_time_between(start_date="-2y", end_date="now")

    is_active = random.choice([0, 1])

    return {
        "patient_id": patient_id_counter,
        "national_id": national_id,
        "first_name": first_name,
        "last_name": last_name,
        "date_of_birth": date_of_birth,
        "gender": gender,
        "phone": phone,
        "address": address_str,
        "blood_type": blood_type_val,
        "allergies": allergies_output,
        "chronic_diseases": chronic_diseases_output,
        "emergency_contact_name": emergency_contact_name,
        "emergency_contact_phone": emergency_contact_phone,
        "registration_date": registration_date,
        "is_active": is_active,
    }


def generate_patients_data(num_patients: int) -> List[Dict[str, object]]:
    """
    Generate a list of patient records.
    """
    return [generate_single_patient_data(i) for i in range(1, num_patients + 1)]


# -------------------------------------------------------------------
# Example Usage
# -------------------------------------------------------------------

if __name__ == "__main__":
    num_records_to_generate = 10000

    print(f"Generating {num_records_to_generate} patient records (English)...")
    generated_data = generate_patients_data(num_records_to_generate)

    df = pd.DataFrame(generated_data)

    print("\nGenerated Patient Data (first 5 rows):")
    print(df.head())

    # Save to CSV (UTF-8)
    csv_filename = "patients.csv"
    df.to_csv(csv_filename, index=False, encoding="utf-8")
    print(f"\nData successfully saved to '{csv_filename}'")

    # Optional verification of NID gender encoding
    print("\nVerification of National ID format (14 digits) and gender for first 5 records:")
    for _, row in df.head().iterrows():
        nid = row["national_id"]
        gender = row["gender"]

        # Sequence+gender is digits 10–13 -> indices 9–12; last one is index 12
        nid_gender_digit = int(nid[12])
        expected_gender_from_nid = "Male" if nid_gender_digit % 2 != 0 else "Female"

        print(
            f"  Patient {row['patient_id']}: "
            f"NID='{nid}', Reported Gender='{gender}', "
            f"NID Gender Digit='{nid_gender_digit}' -> {expected_gender_from_nid}"
        )

        if gender != expected_gender_from_nid:
            print(
                f"    WARNING: Mismatch found for patient {row['patient_id']} - "
                f"Reported ({gender}) vs NID-derived ({expected_gender_from_nid})"
            )