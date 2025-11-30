-- ===================================================================
--          HEALTHCARE VIEWS - FIXED VERSION
-- ===================================================================

-- Drop existing views if they exist
IF OBJECT_ID('healthcare.vw_Patient_Health_Dashboard', 'V') IS NOT NULL DROP VIEW healthcare.vw_Patient_Health_Dashboard;
IF OBJECT_ID('healthcare.vw_Doctor_Performance', 'V') IS NOT NULL DROP VIEW healthcare.vw_Doctor_Performance;
IF OBJECT_ID('healthcare.vw_Alert_Analysis', 'V') IS NOT NULL DROP VIEW healthcare.vw_Alert_Analysis;
IF OBJECT_ID('healthcare.vw_Patients_Report', 'V') IS NOT NULL DROP VIEW healthcare.vw_Patients_Report;
IF OBJECT_ID('healthcare.vw_Doctors_Report', 'V') IS NOT NULL DROP VIEW healthcare.vw_Doctors_Report;
IF OBJECT_ID('healthcare.vw_Appointments_Report', 'V') IS NOT NULL DROP VIEW healthcare.vw_Appointments_Report;
IF OBJECT_ID('healthcare.vw_Summary_Stats', 'V') IS NOT NULL DROP VIEW healthcare.vw_Summary_Stats;
GO

-- 1. Patient Health Dashboard View
CREATE VIEW healthcare.vw_Patient_Health_Dashboard AS
SELECT 
    p.patient_id,
    p.first_name + ' ' + p.last_name AS PatientName,
    p.gender,
    p.blood_type,
    DATEDIFF(YEAR, p.date_of_birth, GETDATE()) AS Age,
    p.chronic_diseases,
    COUNT(DISTINCT a.appointment_id) AS TotalAppointments,
    COUNT(DISTINCT m.medication_id) AS TotalMedications,
    COUNT(DISTINCT mr.reading_id) AS TotalReadings,
    MAX(mr.reading_timestamp) AS LastReadingDate
FROM healthcare.Patients p
LEFT JOIN healthcare.Appointments a ON p.patient_id = a.patient_id
LEFT JOIN healthcare.Medications m ON p.patient_id = m.patient_id
LEFT JOIN healthcare.Medical_Readings mr ON p.patient_id = mr.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.gender, p.blood_type, 
         p.date_of_birth, p.chronic_diseases;
GO

-- 2. Doctor Performance View
CREATE VIEW healthcare.vw_Doctor_Performance AS
SELECT 
    d.doctor_id,
    d.first_name + ' ' + d.last_name AS DoctorName,
    d.specialization,
    d.years_of_experience,
    COUNT(a.appointment_id) AS TotalAppointments,
    AVG(DATEDIFF(MINUTE, a.created_date, a.updated_date)) AS AvgAppointmentDuration,
    COUNT(DISTINCT a.patient_id) AS UniquePatients
FROM healthcare.Doctors d
LEFT JOIN healthcare.Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization, d.years_of_experience;
GO

-- 3. Medical Alert Analysis View (Removed 'governorate')
CREATE VIEW healthcare.vw_Alert_Analysis AS
SELECT 
    sa.alert_type,
    sa.severity,
    COUNT(*) AS AlertCount,
    AVG(CASE WHEN sa.is_read = 1 THEN 1 ELSE 0 END) * 100 AS ReadPercentage
FROM healthcare.System_Alerts sa
JOIN healthcare.Patients p ON sa.patient_id = p.patient_id
GROUP BY sa.alert_type, sa.severity;
GO

-- 4. Simple Patients Report
CREATE VIEW healthcare.vw_Patients_Report AS
SELECT 
    patient_id,
    first_name + ' ' + last_name AS PatientName,
    gender,
    blood_type,
    address
FROM healthcare.Patients;
GO

-- 5. Simple Doctors Report
CREATE VIEW healthcare.vw_Doctors_Report AS
SELECT 
    doctor_id,
    first_name + ' ' + last_name AS DoctorName,
    phone AS ContactPhone
FROM healthcare.Doctors;
GO

-- 6. Simple Appointments Report
CREATE VIEW healthcare.vw_Appointments_Report AS
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    p.first_name + ' ' + p.last_name AS PatientName,
    d.first_name + ' ' + d.last_name AS DoctorName,
    a.reason AS AppointmentReason
FROM healthcare.Appointments a
JOIN healthcare.Patients p ON a.patient_id = p.patient_id
JOIN healthcare.Doctors d ON a.doctor_id = d.doctor_id;
GO

-- 7. Simple Summary Stats
CREATE VIEW healthcare.vw_Summary_Stats AS
SELECT 
    (SELECT COUNT(*) FROM healthcare.Patients) AS TotalPatients,
    (SELECT COUNT(*) FROM healthcare.Doctors) AS TotalDoctors,
    (SELECT COUNT(*) FROM healthcare.Appointments) AS TotalAppointments;
GO

-- Test the views
SELECT TOP 3 * FROM healthcare.vw_Patients_Report;
SELECT TOP 3 * FROM healthcare.vw_Doctors_Report;
SELECT TOP 3 * FROM healthcare.vw_Appointments_Report;
SELECT * FROM healthcare.vw_Summary_Stats;
GO
