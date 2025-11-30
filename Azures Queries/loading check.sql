-- Counts
SELECT COUNT(*) AS PatientCount FROM healthcare.Patients;
SELECT COUNT(*) AS DoctorCount FROM healthcare.Doctors;
SELECT COUNT(*) AS AppointmentCount FROM healthcare.Appointments;
SELECT COUNT(*) AS MedicationCount FROM healthcare.Medications;
SELECT COUNT(*) AS ReadingCount FROM healthcare.Medical_Readings;
SELECT COUNT(*) AS AlertCount FROM healthcare.System_Alerts;
SELECT COUNT(*) AS ServiceProviderCount FROM healthcare.Service_Providers;

-- Sample rows
SELECT TOP 2 * FROM healthcare.Patients;
SELECT TOP 2 * FROM healthcare.Doctors;
SELECT TOP 2 * FROM healthcare.Appointments;
SELECT TOP 2 * FROM healthcare.Medications;
SELECT TOP 2 * FROM healthcare.Medical_Readings;
SELECT TOP 2 * FROM healthcare.System_Alerts;
SELECT TOP 2 * FROM healthcare.Service_Providers;

-- Counts again
SELECT COUNT(*) AS PatientCount FROM healthcare.Patients;
SELECT COUNT(*) AS DoctorCount FROM healthcare.Doctors;
SELECT COUNT(*) AS AppointmentCount FROM healthcare.Appointments;
SELECT COUNT(*) AS MedicationCount FROM healthcare.Medications;
SELECT COUNT(*) AS ReadingCount FROM healthcare.Medical_Readings;
SELECT COUNT(*) AS AlertCount FROM healthcare.System_Alerts;
SELECT COUNT(*) AS ServiceProviderCount FROM healthcare.Service_Providers;
