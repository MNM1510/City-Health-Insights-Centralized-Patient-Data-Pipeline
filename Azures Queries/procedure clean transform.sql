-- ========================================================
-- Stored Procedure: Clean & Transform All Staging Tables
-- ========================================================
IF OBJECT_ID('staging.sp_CleanTransformAll', 'P') IS NOT NULL
    DROP PROCEDURE staging.sp_CleanTransformAll;
GO

CREATE PROCEDURE staging.sp_CleanTransformAll
AS
BEGIN
    SET NOCOUNT ON;

    -- ==================== Patients_Stg ====================
    PRINT 'Cleaning & transforming Patients_Stg...';
    DELETE FROM staging.Patients_Stg WHERE patient_id IS NULL;

    ;WITH RankedPatients AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY patient_id) AS rn
        FROM staging.Patients_Stg
    )
    SELECT * INTO #TempPatients FROM RankedPatients;

    DELETE FROM staging.Patients_Stg;

    INSERT INTO staging.Patients_Stg
    (
        patient_id, national_id, first_name, last_name, date_of_birth, gender, phone, address,
        blood_type, allergies, chronic_diseases, emergency_contact_name, emergency_contact_phone,
        registration_date, is_active
    )
    SELECT
        patient_id, national_id, first_name, last_name, date_of_birth, gender, phone, address,
        blood_type, allergies, chronic_diseases, emergency_contact_name, emergency_contact_phone,
        registration_date, is_active
    FROM #TempPatients
    WHERE rn = 1;

    DROP TABLE #TempPatients;

    -- ==================== Doctors_Stg ====================
    PRINT 'Cleaning & transforming Doctors_Stg...';
    DELETE FROM staging.Doctors_Stg WHERE doctor_id IS NULL;

    ;WITH RankedDoctors AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY doctor_id ORDER BY doctor_id) AS rn
        FROM staging.Doctors_Stg
    )
    SELECT * INTO #TempDoctors FROM RankedDoctors;

    DELETE FROM staging.Doctors_Stg;

    INSERT INTO staging.Doctors_Stg
    (
        doctor_id, national_id, first_name, last_name, specialization, license_number, phone,
        years_of_experience, consultation_fee, is_active, registration_date
    )
    SELECT
        doctor_id, national_id, first_name, last_name, specialization, license_number, phone,
        years_of_experience, consultation_fee, is_active, registration_date
    FROM #TempDoctors
    WHERE rn = 1;

    DROP TABLE #TempDoctors;

    -- ==================== Appointments_Stg ====================
    PRINT 'Cleaning Appointments_Stg...';
    DELETE FROM staging.Appointments_Stg
    WHERE patient_id NOT IN (SELECT patient_id FROM staging.Patients_Stg)
       OR doctor_id NOT IN (SELECT doctor_id FROM staging.Doctors_Stg);

    -- ==================== Medications_Stg ====================
    PRINT 'Cleaning Medications_Stg...';
    DELETE FROM staging.Medications_Stg
    WHERE patient_id NOT IN (SELECT patient_id FROM staging.Patients_Stg)
       OR appointment_id NOT IN (SELECT appointment_id FROM staging.Appointments_Stg);

    -- ==================== Medical_Readings_Stg ====================
    PRINT 'Cleaning Medical_Readings_Stg...';
    DELETE FROM staging.Medical_Readings_Stg
    WHERE patient_id NOT IN (SELECT patient_id FROM staging.Patients_Stg);

    -- ==================== System_Alerts_Stg ====================
    PRINT 'Cleaning System_Alerts_Stg...';
    DELETE FROM staging.System_Alerts_Stg
    WHERE patient_id NOT IN (SELECT patient_id FROM staging.Patients_Stg)
       OR doctor_id NOT IN (SELECT doctor_id FROM staging.Doctors_Stg);

    -- ==================== Service_Providers_Stg ====================
    PRINT 'Cleaning Service_Providers_Stg...';
    UPDATE staging.Service_Providers_Stg
    SET Governorate = ISNULL(Governorate, 'Unknown'),
        City = ISNULL(City, 'Unknown'),
        Service_Provider = ISNULL(Service_Provider, 'Unknown');

    PRINT '✅ All staging tables cleaned and transformed successfully.';
END;
GO

-- ========================================================
-- Execute unified cleaning & transformation
-- ========================================================
EXEC staging.sp_CleanTransformAll;

-- ==================== Verification ====================
SELECT COUNT(*) AS PatientCount FROM staging.Patients_Stg;
SELECT COUNT(*) AS DoctorCount FROM staging.Doctors_Stg;
SELECT COUNT(*) AS AppointmentCount FROM staging.Appointments_Stg;
SELECT COUNT(*) AS MedicationCount FROM staging.Medications_Stg;
SELECT COUNT(*) AS ReadingCount FROM staging.Medical_Readings_Stg;
SELECT COUNT(*) AS AlertCount FROM staging.System_Alerts_Stg;
SELECT COUNT(*) AS ServiceProviderCount FROM staging.Service_Providers_Stg;
