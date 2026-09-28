-- Table names 
/* 
1.  DEPARTMENT
2.  DOCTOR
3.  PATIENT
4.  MEDICINE
5.  ROOM
6.  APPOINTMENT
7.  PRESCRIPTION
8.  PRESCRIPTION_ITEM
9.  ADMISSION
10. BILL
11. PAYMENT                                                 
*/

--display username
SELECT USER FROM DUAL;

--display service name
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS CONTAINER
FROM DUAL;

--checking the already table exits
SELECT table_name
FROM user_tables;

-- creating the tables structures
create table department(
department_id number primary key,
department_name varchar2(50) not null,
location varchar2(100),
phone varchar2(15)
);

create table doctor(
doctor_id number primary key,
department_id number not null,
doctor_name varchar2(100) not null,
specialization varchar2(100),
phone varchar2(15),
email varchar2(100) unique,
joining_date DATE,
salary number(10,2),

CONSTRAINT fk_doctor_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id)
);

create table patient(
patient_id number primary key,
patient_name varchar2(100) not null,
gender varchar2(10),
dob date,
phone varchar2(15) unique,
email varchar2(100) unique,
address varchar2(200),
blood_group varchar2(5),
registration_date date,

constraint chk_gender
    check (gender in ('Male','Female', 'Other')),
    
constraint chk_blood_group
    check (blood_group in ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
    
);

CREATE table medicine(
medicine_id number primary key,
medicine_name varchar2(100) not null,
category varchar2(50),
manufacturer varchar2(100),
unit_price number(10,2),
stock_quantity number,
expiry_date date,

constraint chk_medicine_price
    check (unit_price >=0),
    
constraint chk_medicine_stock
    check(stock_quantity >=0)
);


create table room(
room_id number primary key,
room_number varchar2(10) unique not null,
room_type varchar2(30) not null,
floor_number number,
daily_charge number(10,2),
status VARCHAR2(20) default 'Available',

constraint chk_room_type
    check (room_type in ('General','Semi-Private','Private','ICU','Emergency')),
    
constraint chk_room_status
    check (status in ('Available', 'Occupied','Maintenance'))
);

create table appointment(
appoint_id number primary key,
patient_id number not null,
doctor_id number not null,
appoint_date date not null,
appont_time varchar2(10),
reason varchar2(200),
status varchar2(20) default 'Scheduled',

constraint fk_appoint_patient
    foreign key (patient_id)
    references patient(patient_id),
    
constraint fk_appoint_doctor
    foreign key (doctor_id)
    references doctor(doctor_id),
    
constraint chk_appoint_status
    check (status in ('Scheduled','Completed','Cancelled'))
);

CREATE TABLE prescription (
    prescription_id NUMBER PRIMARY KEY,
    patient_id NUMBER NOT NULL,
    doctor_id NUMBER NOT NULL,
    prescription_date DATE DEFAULT SYSDATE,
    notes VARCHAR2(500),

    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),

    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctor(doctor_id)
);


CREATE TABLE prescription_item (
    prescription_item_id NUMBER PRIMARY KEY,
    prescription_id NUMBER NOT NULL,
    medicine_id NUMBER NOT NULL,
    dosage VARCHAR2(50),
    frequency VARCHAR2(50),
    duration_days NUMBER,
    quantity NUMBER,

    CONSTRAINT fk_prescription_item_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescription(prescription_id),

    CONSTRAINT fk_prescription_item_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicine(medicine_id),

    CONSTRAINT chk_duration_days
        CHECK (duration_days > 0),

    CONSTRAINT chk_medicine_quantity
        CHECK (quantity > 0)
);


CREATE TABLE admission (
    admission_id NUMBER PRIMARY KEY,
    patient_id NUMBER NOT NULL,
    room_id NUMBER NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_reason VARCHAR2(200),
    status VARCHAR2(20) DEFAULT 'Admitted',

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),

    CONSTRAINT fk_admission_room
        FOREIGN KEY (room_id)
        REFERENCES room(room_id),

    CONSTRAINT chk_admission_status
        CHECK (status IN (
            'Admitted',
            'Discharged'
        )),

    CONSTRAINT chk_discharge_date
        CHECK (discharge_date IS NULL OR discharge_date >= admission_date)
);

CREATE TABLE bill (
    bill_id NUMBER PRIMARY KEY,
    patient_id NUMBER NOT NULL,
    appointment_id NUMBER,
    bill_date DATE DEFAULT SYSDATE,

    consultation_charge NUMBER(10,2) DEFAULT 0,
    medicine_charge NUMBER(10,2) DEFAULT 0,
    room_charge NUMBER(10,2) DEFAULT 0,
    other_charge NUMBER(10,2) DEFAULT 0,

    total_amount NUMBER(10,2),

    bill_status VARCHAR2(20) DEFAULT 'Pending',

    CONSTRAINT fk_bill_patient
        FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),

    CONSTRAINT fk_bill_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointment(appoint_id),

    CONSTRAINT chk_bill_consultation
        CHECK (consultation_charge >= 0),

    CONSTRAINT chk_bill_medicine
        CHECK (medicine_charge >= 0),

    CONSTRAINT chk_bill_room
        CHECK (room_charge >= 0),

    CONSTRAINT chk_bill_other
        CHECK (other_charge >= 0),

    CONSTRAINT chk_bill_total
        CHECK (total_amount >= 0),

    CONSTRAINT chk_bill_status
        CHECK (bill_status IN (
            'Pending',
            'Paid',
            'Cancelled'
        ))
);

CREATE TABLE payment (
    payment_id NUMBER PRIMARY KEY,
    bill_id NUMBER NOT NULL,
    payment_date DATE DEFAULT SYSDATE,
    amount_paid NUMBER(10,2) NOT NULL,
    payment_method VARCHAR2(30),
    payment_status VARCHAR2(20) DEFAULT 'Successful',

    CONSTRAINT fk_payment_bill
        FOREIGN KEY (bill_id)
        REFERENCES bill(bill_id),

    CONSTRAINT chk_payment_amount
        CHECK (amount_paid > 0),

    CONSTRAINT chk_payment_method
        CHECK (payment_method IN (
            'Cash',
            'Card',
            'UPI',
            'Insurance'
        )),

    CONSTRAINT chk_payment_status
        CHECK (payment_status IN (
            'Successful',
            'Pending',
            'Failed'
        ))
);


--verification for all table name creation
SELECT table_name
FROM user_tables
ORDER BY table_name;

--Verify the relationships
SELECT
    table_name,
    constraint_name,
    r_constraint_name
FROM user_constraints
WHERE constraint_type = 'R'
ORDER BY table_name;

SELECT
    table_name,
    constraint_name,
    constraint_type
FROM user_constraints
ORDER BY table_name, constraint_type;


--imported the data from local D drive
select * from department;

INSERT INTO department (department_id, department_name, location, phone)
VALUES  (7, 'ENT', 'Block D', '9876543207');

INSERT INTO department (department_id, department_name, location, phone)
VALUES  (8, 'Ophthalmology', 'Block D', '9876543208');

INSERT INTO department (department_id, department_name, location, phone)
VALUES  (9, 'Gynecology', 'Block E', '9876543209');

INSERT INTO department (department_id, department_name, location, phone)
VALUES  (10, 'Pulmonology', 'Block E', '9876543210');

COMMIT;

--importing all other data from new d drive file
select * from doctor;
select * from patient;
select * from medicine;
select * from room;
select * from appointment;
select * from prescription;
select * from prescription_item;
select * from admission;
select * from bill;
select * from payment;

commit;

/*=========================================================
  PHASE 1 — BASIC SQL
=========================================================*/
--1.1 SELECT
select * from patient;
--1.2 Select specific columns
select patient_id,patient_name,gender,dob from patient;
--1.3 DISTINCT
SELECT distinct blood_group from patient;
select distinct gender from patient;
--1.4 Column aliases
select patient_id as id,patient_name as Name,dob as date_of_Birth from patient;
--1.5 ORDER BY
select patient_id,patient_name,gender from patient order by patient_name;
select patient_id,patient_name,gender from patient order by patient_name DESC;
--1.6 WHERE
select patient_id,patient_name,gender from patient where gender ='Male';

select patient_id,patient_name,gender,blood_group from patient where blood_group='O+';
select patient_id,patient_name,gender from patient where gender ='Female' order by patient_name;
select patient_id,patient_name,phone,blood_group from patient where blood_group='A+' order by patient_name;

/*=========================================================
  PHASE 2 — FILTERING
=========================================================*/
--2.1 AND Operator
select patient_id,patient_name ,gender, blood_group from patient where gender ='Male' and blood_group='A+';
select patient_id,patient_name ,gender, blood_group from patient where gender ='Female' and blood_group='B+';
select patient_id,patient_name ,gender, blood_group,registration_date from patient where gender ='Female' and registration_date > date '2026-01-01' order by registration_date;
--2.2 OR Operator
select patient_id,patient_name ,gender, blood_group from patient where blood_group ='AB+' OR blood_group='B+';
select patient_id,patient_name ,gender, blood_group from patient where gender ='Male' OR blood_group='O-';
--2.3 NOT
select patient_id,patient_name ,gender from patient where NOT gender ='Female';
select patient_id,patient_name ,blood_group from patient where not blood_group='O+';
--2.4 BETWEEN
select patient_Id,patient_name,registration_date,gender from patient where registration_date between date '2026-01-01' and date '2026-03-31';
select doctor_Id,doctor_name,salary from doctor where salary between 70000 and 100000;
--2.5 IN
SELECT patient_Id,patient_name,blood_group,gender from patient where blood_group in ('A+', 'B+', 'O+') order by blood_group;
select appoint_id,patient_id,doctor_id from appointment where status in ('Scheduled' , 'Completed');
--2.6 NOT IN
SELECT patient_Id,patient_name,blood_group,gender from patient where blood_group not in ('A+', 'O+') order by blood_group;
select appoint_id,patient_id,doctor_id from appointment where status not in ('Cancelled');
--2.7 LIKE
select patient_id,patient_name from patient WHERE patient_name like 'A%';
select patient_id,patient_name from patient WHERE patient_name like '%an%';
select doctor_id,doctor_name,specialization from doctor where specialization like '%Cardio%';
--2.8 IS NULL
select admission_id,patient_id,admission_date,discharge_date,status from admission where discharge_date is null ;
--2.9 IS NOT NULL
select patient_id,patient_name,email from patient where email is not null;
select * from admission where discharge_date is not NULL;
--2.10 Combination of operators
select patient_id,patient_name,gender,blood_group from patient where gender ='Female' and blood_group in ('A+','O+');
select * from appointment where status ='Completed' and doctor_id in (101,105,110);
select * from bill where bill_status in ('Paid','Pending') and total_amount > 5000;

/*=========================================================
  PHASE 3 — SQL FUNCTIONS
=========================================================*/
--3.1 String Functions  upper(),lower(),initcap(),length(),substr(),concat||
select patient_id,patient_name,upper(patient_name) as capital_name from patient;
select doctor_id,doctor_name,lower(doctor_name) as lower_doc_name from doctor;
select doctor_id,doctor_name,initcap(doctor_name) as lower_doc_name,specialization from doctor;
select patient_name,length(patient_name) as words_in_name from patient where length(patient_name) > 10;
select doctor_name,substr(doctor_name,5,4) from doctor;
select patient_name || ' - ' || gender || ' - ' || blood_group as concat_details from patient;
--3.2 NUMERIC FUNCTIONS     round(),trunc(),mod()
select doctor_id,doctor_name,salary,round(salary,-3) as rounded_salary from doctor;
select medicine_name,unit_price,trunc(unit_price,1) as truncated_price from medicine;
select medicine_id,medicine_name,stock_quantity from medicine where mod(stock_quantity,2)=0; 
/*=============================================================================================
  3.3 DATE FUNCTIONS       (SYSDATE, EXTRACT(), MONTHS_BETWEEN(), ADD_MONTHS(), LAST_DAY() )
===============================================================================================*/
--3.3.1 SYSDATE
select patient_id, patient_name, registration_date,sysdate as current_date from patient;
--3.3.2 EXTRACT()
select doctor_id,doctor_name,joining_date,extract(day from joining_date)as join_date,extract(month from joining_date)as join_month,extract(year from joining_date)as join_year from doctor;
--3.3.3 MONTHS_BETWEEN()
select doctor_id, doctor_name, joining_date, round(months_between(sysdate,joining_date)) || ' months' as months_worked from doctor;
SELECT doctor_id, doctor_name, joining_date, ROUND(MONTHS_BETWEEN(SYSDATE, joining_date) / 12, 1)||' years' AS years_worked FROM doctor;
--3.3.4 ADD_MONTHS()
select patient_id,patient_name,registration_date, add_months(registration_date, 12) as after_12month from patient;
--3.3.5 LAST_DAY()
select appoint_id,appoint_date, last_day(appoint_date) from appointment;

--3.4 NULL Functions    ( NVL(), NVL2(), COALESCE() )
--3.4.1 NVL()
select patient_id,patient_name, NVL(email,'not provided') from patient;
select admission_id,patient_id, admission_date, discharge_date, nvl(discharge_date,sysdate) from admission;
--3.4.2 NVL2()
select admission_id, patient_id, discharge_date, NVL2(discharge_date,'discharged','Currently Admitted') as status from admission;
--3.4.3 COALESCE()
SELECT COALESCE(NULL, NULL, 'No Contact') AS contact
FROM dual;
SELECT COALESCE(NULL, '9876543210', 'No Contact') AS contact
FROM dual;


/*=========================================================
  PHASE 4 — AGGREGATE FUNCTIONS
=========================================================*/
-- 4.1 COUNT()
select count(patient_id) as no_of_patient from patient;
select count(doctor_id) as no_of_doctor from doctor;
select count(medicine_id) as no_of_medicine from medicine;
select count(room_id) as no_of_rooms from room;
SELECT COUNT(*) AS total_admissions, COUNT(CASE WHEN STATUS = 'Discharged' THEN 1 END) AS total_discharged FROM admission;
select count(email) as Total_email from patient; 
-- 4.2 SUM()
select sum(stock_quantity) as total_stock from medicine;
select sum(total_amount) as Total_bill from bill;
select sum(total_amount) as Total_bill from bill where bill_status = 'Paid';
-- 4.3 AVG()
select avg(salary) as doctor_avg_salary from doctor;
select avg(unit_price) as avg_medicine_price from medicine;
select avg(daily_charge) as avg_price from room;
-- 4.4 MIN()
select min(salary) as min_of_doctor_salary from doctor;
select min(unit_price) as min_medicine_price from medicine;
select min(daily_charge) as minimum_room_charge from room;
-- 4.5 MAX()
select max(salary) as max_of_doctor_salary from doctor;
select max(unit_price) as max_medicine_price from medicine;
select max(daily_charge) as max_room_charge from room;


/*=========================================================
  PHASE 5 — GROUP BY & HAVING
=========================================================*/
-- 5.1 GROUP BY
-- 5.2 GROUP BY with COUNT()
select gender, count(gender) as total_count from patient group by gender;
select status, count(status ) as total_appoinment from appointment group by status;
-- 5.3 GROUP BY with SUM()
select payment_method, sum(amount_paid) as total_paid from payment group by payment_method;
-- 5.4 GROUP BY with AVG()
select category , round(avg(unit_price),2) from medicine group by category;
-- 5.5 GROUP BY multiple columns
select count(patient_id) , gender, blood_group from patient group by gender,blood_group;
-- 5.6 HAVING
select status, count(status) as tptal_appintments from appointment group by status having count(status) > 10;
select category, avg(unit_price) as average_price from medicine group by category having avg(unit_price) > 50;
-- 5.7 WHERE vs HAVING
select doctor_id ,count(doctor_id) as count_completion from appointment where status = 'Completed' group by doctor_id having count(doctor_id) > 1 ;


/*=========================================================
  PHASE 6 — JOINS 
=========================================================*/
--6.1 INNER JOIN — Doctor & Department
select a.doctor_id , a.doctor_name, a.department_id,b.department_name from doctor a  join department b 
on a.department_id = b.department_id;
--6.2 INNER JOIN — Appointment & Patient
select a.appoint_id, b.patient_name, a.appoint_date, a.appont_time, a.status from appointment a join patient b 
on a.patient_id = b.patient_id;
--6.3 INNER JOIN — Appointment & Doctor
select a.appoint_id, b.doctor_name, b.specialization, a.appoint_date, a.appont_time, a.status from appointment a join doctor b 
on a.doctor_id = b.doctor_id;
--6.4 Three-Table JOIN — Patient + Appointment + Doctor
select a.patient_name,c.doctor_name,b.appoint_date,b.appont_time from patient a join appointment b 
on a.patient_id = b.patient_id join doctor c 
on c.doctor_id = b.doctor_id;
--6.5 Four-Table JOIN — Patient + Doctor + Department + Appointment
select a.patient_name,a.blood_group,a.gender, b.appoint_date, b.appont_time, c.doctor_name, d.department_name
from patient a join appointment b on a.patient_id = b.patient_id
join doctor c on b.doctor_id = c.doctor_id
join department d on c.department_id = d.department_id;
--6.6 Prescription JOIN
select d.doctor_name, p.patient_name, a.prescription_id, a.prescription_date,a.notes 
from doctor d join Prescription a
on d.doctor_id = a.doctor_id join patient p 
on p.patient_id = a.patient_id;
--6.7 Prescription + Medicine   What medicines were prescribed and in what dosage?
select m.medicine_id ,m.medicine_name, m.category, p.dosage,p.frequency, p.duration_days,p.quantity from medicine m join Prescription_item p
on m.medicine_id = p.medicine_id;
--6.8 Complete Prescription Report      Show complete prescription details.
select a.prescription_id, b.patient_name, c.doctor_name, d.medicine_name, a.prescription_date, e.dosage, e.frequency, e.quantity, e.duration_days
from prescription a join patient b on a.patient_id = b.patient_id
join doctor c on c.doctor_id = a.doctor_id 
join prescription_item e on a.prescription_id = e.prescription_id
join medicine d on d.medicine_id = e.medicine_id;
--6.9 Admission + Patient + Room    Which patient was admitted to which room?
select a.admission_id, b.patient_name, a.admission_date, a.discharge_date,a.status,c.room_number,c.room_type
from admission a join patient b 
on a.patient_id = b.patient_id join room c
on c.room_id = a.room_id;
--6.10 Bill + Patient           Show each patient's billing information.
select a.patient_id, a.patient_name, b.bill_date,b.consultation_charge,b.medicine_charge,b.room_charge,b.other_charge,b.total_amount,b.bill_status
from patient a join bill b on a.patient_id = b.patient_id;
--6.11 Bill + Payment           Which payments were made against which bills?
SELECT b.bill_id, p.payment_id, p.payment_date, p.amount_paid, p.payment_method, p.payment_status
FROM bill b JOIN payment p ON b.bill_id = p.bill_id;
--6.12 Patient + Bill + Payment     Show the patient, bill amount and payment details
select a.patient_name , b.bill_id,b.total_amount, b.bill_status, c.payment_date,c.amount_paid,c.payment_method,c.payment_status 
from patient a join bill b on a.patient_id = b.patient_id
join payment c on b.bill_id = c.bill_id;
--6.13 LEFT JOIN — Departments Without Doctors 
SELECT d.department_id, d.department_name, a.doctor_id, a.doctor_name
FROM department d LEFT JOIN doctor a
ON d.department_id = a.department_id
ORDER BY d.department_id;
--6.14 LEFT JOIN + COUNT    How many doctors are working in each department, including departments with zero doctors?
select a.department_id, a.department_name, count(b.doctor_id) as total_doctor 
from department a left join doctor b on a.department_id = b.department_id
group by a.department_id,a.department_name
order by a.department_id;
--6.15 JOIN + WHERE     Show all completed appointments with patient and doctor names.
select * from appointment;
select a.patient_name, b.doctor_name, c.appoint_date,c.appont_time,c.status
from patient a join appointment c on a.patient_id = c.patient_id
join doctor b on b.doctor_id = c.doctor_id
where c.status = 'Completed';
--6.16 JOIN + GROUP BY      How many appointments has each doctor handled?
SELECT d.doctor_id, d.doctor_name, COUNT(a.appoint_id) AS total_appointments
FROM doctor d LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name;
--6.17 JOIN + GROUP BY + HAVING     Which doctors have more than 2 appointments?
SELECT d.doctor_id, d.doctor_name, COUNT(a.appoint_id) AS total_appointments
FROM doctor d LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name
having count(a.appoint_id) > 2;


/*=========================================================
  Phase 7 — Hospital Analysis
=========================================================*/
--7.1 Patient Analysis
--1 Find the total number of registered patients.
select count(patient_id) as total_patient from patient;
--2 Find the number of patients in each gender.
select gender,count(patient_id)as total_patient from patient group by gender;
--3 Find how many patients belong to each blood group.
select blood_group, count(patient_id) from patient group by blood_group;
--4 Display patients who registered after 01-JAN-2026, showing patient name, gender, blood group and registration date.
select patient_name, gender, blood_group, registration_date from patient where registration_date >  DATE '2026-01-01' ;
--5 Display each patient's name and age based on their date of birth.
select patient_name, extract(year from sysdate) - extract(year from dob) as age from patient;
select patient_name, trunc(MONTHS_BETWEEN(SYSDATE, dob) / 12, 1) as age from patient;

--7.2 Doctor & Department Analysis
--6 Display each department and the number of doctors working in it.
select d.department_name, count(b.doctor_id)as no_of_doctors from department d left join doctor b on d.department_id = b.department_id 
group by d.department_name;
--7 Find the average salary of doctors in each department.
select a.department_id,b.department_name, avg(a.salary) as avg_salary from doctor a join department b
on a.department_id = b.department_id group by a.department_id, b.department_name;
--8 Display the top 5 highest-paid doctors with their specialization.
select doctor_id, doctor_name, specialization, salary from doctor order by salary desc fetch first 5 rows only ;
--9 Display department name, number of doctors, and average doctor salary.
select a.department_name, count(b.doctor_name)as no_of_doctor , avg(b.salary)as avg_salary from department a join doctor b
on a.department_id = b.department_id 
group by b.department_id, a.department_name;
--10 Display each doctor's name, joining date, and years of experience.
select doctor_name, joining_date , round(months_between(sysdate,joining_date) /12,1) as experience from doctor;

--7.3 Appointment Analysis
-- 11 Find the total number of appointments for each status.
select status, count(appoint_id)as total_no_of_appointments from appointment group by status;
--12 Find the number of appointments handled by each doctor, along with the doctor's name.
select a.doctor_name, count(b.doctor_id)as total_appointments from appointment b left join doctor a
on a.doctor_id = b.doctor_id 
group by b.doctor_id, a.doctor_name;
--13 Find the number of completed appointments for each doctor.
select a.doctor_name, count(b.doctor_id)as completed_appointments from appointment b join doctor a
on a.doctor_id = b.doctor_id 
where b.status = 'Completed' 
group by b.doctor_id, a.doctor_name;
--14 Find the total number of appointments handled by each department.
select a.department_name, b.doctor_name, count(c.doctor_id) as  total_no_of_appointment from
appointment c join doctor b on c.doctor_id= b.doctor_id
join department a on a.department_id = b.department_id
group by c.doctor_id, b.doctor_name,a.department_name;

SELECT d.department_id, d.department_name, COUNT(a.appoint_id) AS total_appointments
FROM department d JOIN doctor doc
ON d.department_id = doc.department_id JOIN appointment a
ON doc.doctor_id = a.doctor_id
GROUP BY d.department_id, d.department_name
ORDER BY total_appointments DESC;
--15 Display patient name, doctor name, department name, appointment date and appointment status for all appointments.
select a.patient_name, b.doctor_name, c.department_name , d.appoint_date, d.status from
appointment d join patient a on d.patient_id = a.patient_id
join doctor b on b.doctor_id = d.doctor_id 
join department c on c.department_id = b.department_id
order by d.status;

--7.4 Admission & Room Analysis
--16 Find the number of admitted and discharged patients.
select status,count(admission_id) as no_of_patient from admission group by status;
--17 Find the number of rooms for each room status.
select status, count(room_id)as room_details from room group by status;
--18 Find the number of rooms and average daily charge for each room type.
select room_type, avg(daily_charge)as avg_charge,count(room_id)as room_details  from room group by room_type;
--19 Display patients who are currently admitted
select a.patient_name,b.admission_id,b.admission_date,b.status from admission b join patient a
on a.patient_id = b.patient_id where b.discharge_date is null;
--20 Display patient name, room number, room type, admission date, discharge date and admission status.
select c.patient_name, b.room_number, b.room_type, a.admission_date, a.discharge_date, a.status from admission a
join room b on b.room_id = a.room_id 
join patient c on c.patient_id = a.patient_id;

--7.5 Medicine Analysis
--21 Find the number of medicines in each category.
select category, count(medicine_id) as no_of_medicine from medicine group by category;
--22 Find the total stock quantity for each medicine category.
select category, sum(stock_quantity) as total_stock from medicine group by category;
--23 Display medicines whose unit price is greater than ₹100.
select medicine_name, unit_price from medicine where unit_price > 100;
--24 Find medicines where stock quantity is less than 50.
select medicine_name, stock_quantity from medicine where stock_quantity <50;
--25 Display each medicine category with its minimum, maximum and average unit price.
select category, min(unit_price), max(unit_price), round(avg(unit_price),1) from medicine group by category;

--7.6 Billing & Payment Analysis
--26 Find the total billing amount generated by the hospital.
select sum(total_amount) as tot_bill_by_hostipal from bill;
--27 Find the total bill amount for each bill status.
select bill_status, sum(total_amount) as tot_bill_by_hostipal from bill group by bill_status;
--28 Find the total amount collected through each payment method.
select a.payment_method, sum(a.amount_paid) as total_amount from payment a join bill b on a.bill_id = b.bill_id
group by payment_method;
--29 Display patient name, bill ID, total amount and bill status.
select b.patient_name, a.bill_ID, a.total_amount, a.bill_status from bill a join patient b
on a.patient_id = b.patient_id;
--30 Display patient name, bill ID, total bill amount, amount paid and payment method.
select b.patient_name, a.bill_ID, a.total_amount, c.amount_paid, c.payment_method, (a.total_amount) - (c.amount_paid) as balance_to_pay from bill a join patient b
on a.patient_id = b.patient_id
join payment c on c.bill_id = a.bill_id;

--7.7 Management Analysis
--31 Which department has the highest number of doctors?
select a.department_name, d.department_id , count(d.department_id) as total_doctors  from doctor d 
join department a on a.department_id = d.department_id 
group by d.department_id, a.department_name
order by count(d.department_id) desc fetch first 1 rows only;
--32 Which doctor has handled the highest number of appointments?
select * from appointment;
select a.doctor_id,b.doctor_name,count(a.appoint_id) from appointment a join doctor b
on a.doctor_id = b.doctor_id group by a.doctor_id,b.doctor_name
order by count(a.appoint_id) desc
FETCH FIRST 1 ROW ONLY;
--33 Which medicine category has the highest average price?
select category , avg(unit_price)as avg_price from medicine group by category
order by avg(unit_price) desc 
fetch first 1 rows only;
--34 Which room type has the highest average daily charge?
select room_type , avg(daily_charge)as avg_price from room group by room_type
order by avg_price desc 
fetch first 1 rows only;
--35 What percentage of appointments are Completed, Cancelled, and Scheduled?
SELECT status, COUNT(status) AS status_count,
ROUND(COUNT(status) * 100.0 / (SELECT COUNT(*) FROM appointment), 2) AS percentage
FROM appointment
GROUP BY status;
--36 What is the total amount paid through each payment method?
select payment_method, sum(amount_paid)as total_paid from payment group by payment_method;
--37 How many patients are currently admitted?
select count(patient_id) as currently_admitted from admission where status='Admitted';
--38 What is the total amount of pending bills?
select sum(total_amount) as sum_total from bill where bill_status = 'Pending' ;
--39 Which doctors have prescribed the most medicines?
SELECT d.doctor_id, d.doctor_name, 
       COUNT(pi.prescription_item_id) AS total_medicines_prescribed
FROM doctor d
JOIN prescription p ON p.doctor_id = d.doctor_id
JOIN prescription_item pi ON pi.prescription_id = p.prescription_id
GROUP BY d.doctor_id, d.doctor_name
ORDER BY COUNT(pi.prescription_item_id) DESC
FETCH FIRST 1 ROW ONLY;
--40 Display the top 5 medicines based on unit price.
SELECT medicine_name, unit_price
FROM medicine
ORDER BY unit_price DESC
FETCH FIRST 5 ROWS only;


/*=========================================================
  PHASE 8 — SUBQUERIES
=========================================================*/

--8.1 Single-Row Subqueries
--Q1 Find the doctor(s) whose salary is equal to the highest doctor salary.
select doctor_id, doctor_name, salary from doctor
where salary = (select max(salary) from doctor);

--Q2 Find doctors whose salary is greater than the average doctor salary.
select doctor_id, doctor_name, salary from doctor
where salary > (select avg(salary) from doctor);

--Q3 Find the medicine(s) whose unit price is equal to the highest medicine price.
select medicine_id, medicine_name, unit_price from medicine
where unit_price = (select max(unit_price) from medicine);

--Q4 Find the patient(s) whose registration date is the latest registration date.
select patient_id, patient_name, registration_date from patient
where registration_date = (select max(registration_date) from patient);

--Q5 Find the room(s) whose daily charge is equal to the highest daily room charge.
select room_id, room_type, daily_charge from room
where daily_charge = (select max(daily_charge) from room);


--8.2 Multi-Row Subqueries
--Q6 Find doctors who work in the Cardiology department using a subquery.
select doctor_id, doctor_name, specialization from doctor
where department_id in (select department_id from department where department_name = 'Cardiology');

--Q7 Find patients who have at least one appointment.
select patient_id, patient_name from patient
where patient_id in (select patient_id from appointment);

--Q8 Find doctors who have written at least one prescription.
select doctor_id, doctor_name from doctor
where doctor_id in (select doctor_id from prescription);

--Q9 Find medicines that appear in PRESCRIPTION_ITEM.
select medicine_id, medicine_name from medicine
where medicine_id in (select medicine_id from prescription_item);

--Q10 Find patients who have at least one admission record.
select patient_id, patient_name from patient
where patient_id in (select patient_id from admission);


--8.3 Subquery with NOT IN
--Q11 Find doctors who have never had an appointment.
select doctor_id, doctor_name from doctor
where doctor_id not in (select doctor_id from appointment where doctor_id is not null);

--Q12 Find patients who have never booked an appointment.
select patient_id, patient_name from patient
where patient_id not in (select patient_id from appointment where patient_id is not null);

--Q13 Find medicines that have never been prescribed.
select medicine_id, medicine_name from medicine
where medicine_id not in (select medicine_id from prescription_item where medicine_id is not null);


--8.4 Subquery in SELECT
--Q14 Display doctor name, salary, and average doctor salary.
select doctor_name, salary,
(select round(avg(salary),2) from doctor) as average_salary
from doctor;

--Q15 Display bill_id, total_amount, and total amount of all bills.
select bill_id, total_amount,
(select sum(total_amount) from bill) as total_hospital_billing
from bill;


--8.5 EXISTS Subqueries
--Q16 Find doctors who have at least one appointment using EXISTS.
select doctor_id, doctor_name from doctor d
where exists (select 1 from appointment a where a.doctor_id = d.doctor_id);

--Q17 Find patients who have at least one prescription using EXISTS.
select patient_id, patient_name from patient p
where exists (select 1 from prescription pr where pr.patient_id = p.patient_id);

--Q18 Find patients who have at least one admission using EXISTS.
select patient_id, patient_name from patient p
where exists (select 1 from admission a where a.patient_id = p.patient_id);


--8.6 Advanced Subqueries
--Q19 Find doctors whose salary is greater than the average salary of their own department.
select d1.doctor_id, d1.doctor_name, d1.department_id, d1.salary
from doctor d1
where d1.salary > (select avg(d2.salary) from doctor d2 where d2.department_id = d1.department_id);

--Q20 Find the doctor(s) having the highest salary within each department.
select d1.doctor_id, d1.doctor_name, d1.department_id, d1.salary
from doctor d1
where d1.salary = (select max(d2.salary) from doctor d2 where d2.department_id = d1.department_id);

--Q21 Find medicines whose unit price is greater than the average medicine price.
select medicine_id, medicine_name, unit_price from medicine
where unit_price > (select avg(unit_price) from medicine);

--Q22 Find bills whose total_amount is greater than the average bill amount.
select bill_id, total_amount from bill
where total_amount > (select avg(total_amount) from bill);

--Q23 Find doctors whose appointment count is greater than the average appointment count per doctor.
select doctor_id, count(appoint_id) as total_appointments
from appointment
group by doctor_id
having count(appoint_id) > (
    select avg(cnt) from (
        select count(appoint_id) as cnt from appointment group by doctor_id
    )
);

--Q24 Find patients who have more than one appointment.
select patient_id, count(appoint_id) as total_appointments
from appointment
group by patient_id
having count(appoint_id) > 1;

--Q25 Find the second-highest distinct doctor salary using a subquery.
select max(salary) as second_highest_salary
from doctor
where salary < (select max(salary) from doctor);


/*=========================================================
  PHASE 9 — CTE (COMMON TABLE EXPRESSIONS)
=========================================================*/

--9.1 Basic CTE
--Q1 Using a CTE, find the total number of patients.
with patient_count as (
    select count(patient_id) as total_patients from patient
)
select total_patients from patient_count;

--Q2 Using a CTE, calculate the average salary of doctors.
with avg_sal as (
    select avg(salary) as avg_salary from doctor
)
select round(avg_salary, 2) as avg_salary from avg_sal;

--Q3 Using a CTE, calculate the total amount of all bills.
with total_bill as (
    select sum(total_amount) as total_billing from bill
)
select total_billing from total_bill;

--Q4 Create a CTE containing only completed appointments.
with completed_appt as (
    select appoint_id, patient_id, doctor_id, appoint_date
    from appointment
    where status = 'Completed'
)
select appoint_id, patient_id, doctor_id, appoint_date from completed_appt;

--Q5 Create a CTE containing medicines whose unit_price > 100.
with expensive_med as (
    select medicine_id, medicine_name, unit_price
    from medicine
    where unit_price > 100
)
select medicine_id, medicine_name, unit_price from expensive_med;


--9.2 CTE with GROUP BY
--Q6 Using a CTE, calculate the number of appointments for each status.
with status_count as (
    select status, count(appoint_id) as total_appointments
    from appointment
    group by status
)
select status, total_appointments from status_count;

--Q7 Using a CTE, calculate the number of doctors in each department.
with dept_doctors as (
    select a.department_id, a.department_name, count(b.doctor_id) as total_doctors
    from department a left join doctor b on a.department_id = b.department_id
    group by a.department_id, a.department_name
)
select department_id, department_name, total_doctors from dept_doctors;

--Q8 Using a CTE, calculate the total medicine stock for each category.
with category_stock as (
    select category, sum(stock_quantity) as total_stock
    from medicine
    group by category
)
select category, total_stock from category_stock;

--Q9 Using a CTE, calculate the total bill amount for each bill status.
with bill_status_total as (
    select bill_status, sum(total_amount) as total_bill_amount
    from bill
    group by bill_status
)
select bill_status, total_bill_amount from bill_status_total;

--Q10 Using a CTE, calculate the average daily charge for each room type.
with room_avg as (
    select room_type, round(avg(daily_charge), 2) as average_daily_charge
    from room
    group by room_type
)
select room_type, average_daily_charge from room_avg;


--9.3 CTE with JOIN
--Q11 Create a CTE joining DOCTOR and DEPARTMENT.
with doctor_dept as (
    select a.doctor_name, a.specialization, b.department_name, a.salary
    from doctor a join department b on a.department_id = b.department_id
)
select doctor_name, specialization, department_name, salary from doctor_dept;

--Q12 Create a CTE joining PATIENT and APPOINTMENT.
with patient_appt as (
    select a.patient_name, b.appoint_date, b.status
    from patient a join appointment b on a.patient_id = b.patient_id
)
select patient_name, appoint_date, status from patient_appt;

--Q13 Create a CTE joining PATIENT and BILL.
with patient_bill as (
    select a.patient_name, b.bill_id, b.total_amount, b.bill_status
    from patient a join bill b on a.patient_id = b.patient_id
)
select patient_name, bill_id, total_amount, bill_status from patient_bill;

--Q14 Create a CTE joining PRESCRIPTION, PRESCRIPTION_ITEM and MEDICINE.
with prescription_details as (
    select a.prescription_id, c.medicine_name, b.dosage, b.frequency, b.quantity
    from prescription a
    join prescription_item b on a.prescription_id = b.prescription_id
    join medicine c on b.medicine_id = c.medicine_id
)
select prescription_id, medicine_name, dosage, frequency, quantity from prescription_details;

--Q15 Create a CTE joining PATIENT, ADMISSION and ROOM.
with admission_details as (
    select a.patient_name, c.room_number, c.room_type, b.admission_date, b.discharge_date, b.status
    from patient a
    join admission b on a.patient_id = b.patient_id
    join room c on b.room_id = c.room_id
)
select patient_name, room_number, room_type, admission_date, discharge_date, status from admission_details;


--9.4 CTE for Hospital Analysis
--Q16 Create a CTE with the average doctor salary, then find doctors earning above it.
with avg_salary as (
    select avg(salary) as avg_sal from doctor
)
select d.doctor_id, d.doctor_name, d.salary
from doctor d, avg_salary a
where d.salary > a.avg_sal;

--Q17 Create a CTE for appointments per doctor, then display the top 5 doctors.
with doctor_appt as (
    select d.doctor_id, d.doctor_name, count(a.appoint_id) as total_appointments
    from doctor d join appointment a on d.doctor_id = a.doctor_id
    group by d.doctor_id, d.doctor_name
)
select doctor_id, doctor_name, total_appointments
from doctor_appt
order by total_appointments desc
fetch first 5 rows only;

--Q18 Create a CTE counting appointments per patient, then show patients with more than 1.
with patient_appt as (
    select p.patient_id, p.patient_name, count(a.appoint_id) as total_appointments
    from patient p join appointment a on p.patient_id = a.patient_id
    group by p.patient_id, p.patient_name
)
select patient_id, patient_name, total_appointments
from patient_appt
where total_appointments > 1;

--Q19 Create a CTE for total appointments per department, ordered by count descending.
with dept_appt as (
    select d.department_id, d.department_name, count(a.appoint_id) as total_appointments
    from department d
    join doctor doc on d.department_id = doc.department_id
    join appointment a on doc.doctor_id = a.doctor_id
    group by d.department_id, d.department_name
)
select department_id, department_name, total_appointments
from dept_appt
order by total_appointments desc;

--Q20 Create CTEs for total billing and total payment, then show the outstanding amount.
with billed as (
    select sum(total_amount) as total_billed from bill
),
paid as (
    select sum(amount_paid) as total_paid from payment
)
select b.total_billed,
       p.total_paid,
       b.total_billed - p.total_paid as outstanding_amount
from billed b, paid p;



/*=========================================================
  PHASE 10 — WINDOW FUNCTIONS
=========================================================*/

--10.1 ROW_NUMBER()
--Q1 Rank doctors by salary (highest to lowest) using ROW_NUMBER().
select doctor_id, doctor_name, salary,
row_number() over (order by salary desc) as row_num
from doctor;

--Q2 Number patients by registration date (oldest = 1).
select patient_id, patient_name, registration_date,
row_number() over (order by registration_date asc) as row_num
from patient;

--Q3 Number appointments by date (latest = 1).
select appoint_id, appoint_date, status,
row_number() over (order by appoint_date desc) as row_num
from appointment;


--10.2 RANK()
--Q4 Rank doctors by salary (highest = 1).
select doctor_id, doctor_name, salary,
rank() over (order by salary desc) as salary_rank
from doctor;

--Q5 Rank medicines by price (highest = 1).
select medicine_name, unit_price,
rank() over (order by unit_price desc) as price_rank
from medicine;

--Q6 Rank rooms by daily charge (highest = 1).
select room_number, room_type, daily_charge,
rank() over (order by daily_charge desc) as charge_rank
from room;


--10.3 DENSE_RANK()
--Q7 Dense rank doctors by salary.
select doctor_id, doctor_name, salary,
dense_rank() over (order by salary desc) as dense_salary_rank
from doctor;

--Q8 Dense rank medicines by price.
select medicine_name, unit_price,
dense_rank() over (order by unit_price desc) as dense_price_rank
from medicine;


--10.4 PARTITION BY
--Q9 Rank doctors within each department by salary.
select doctor_id, doctor_name, department_id, salary,
rank() over (partition by department_id order by salary desc) as dept_salary_rank
from doctor;

--Q10 Rank medicines within each category by price.
select medicine_id, medicine_name, category, unit_price,
rank() over (partition by category order by unit_price desc) as category_price_rank
from medicine;

--Q11 Number each doctor's appointments by appointment date.
select doctor_id, appoint_id, appoint_date,
row_number() over (partition by doctor_id order by appoint_date) as appointment_no
from appointment;

--Q12 Number each patient's bills by bill date.
select patient_id, bill_id, bill_date, total_amount,
row_number() over (partition by patient_id order by bill_date) as bill_no
from bill;


--10.5 Top-N Using Window Functions
--Q13 Top 3 highest-paid doctors.
select doctor_id, doctor_name, salary, salary_rank
from (
    select doctor_id, doctor_name, salary,
    rank() over (order by salary desc) as salary_rank
    from doctor
)
where salary_rank <= 3;

--Q14 Top 2 highest-paid doctors within every department.
select department_id, doctor_name, salary, dept_salary_rank
from (
    select department_id, doctor_name, salary,
    dense_rank() over (partition by department_id order by salary desc) as dept_salary_rank
    from doctor
)
where dept_salary_rank <= 2;

--Q15 Most expensive medicine in each category.
select category, medicine_name, unit_price, price_rank
from (
    select category, medicine_name, unit_price,
    rank() over (partition by category order by unit_price desc) as price_rank
    from medicine
)
where price_rank = 1;


--10.6 LAG() and LEAD()
--Q16 Show each doctor's salary and the previous salary.
select doctor_name, salary,
lag(salary) over (order by salary) as previous_salary
from doctor;

--Q17 Show the salary difference between current and previous salary.
select doctor_name, salary,
lag(salary) over (order by salary) as previous_salary,
salary - lag(salary) over (order by salary) as salary_difference
from doctor;

--Q18 Show each appointment with the next appointment date.
select appoint_id, patient_id, appoint_date,
lead(appoint_date) over (order by appoint_date) as next_appoint_date
from appointment;


--10.7 Advanced Window Analysis
--Q19 Running total of bills by bill date.
select bill_id, bill_date, total_amount,
sum(total_amount) over (order by bill_date, bill_id) as running_total
from bill;

--Q20 Doctor salary compared with department average.
select doctor_id, doctor_name, department_id, salary,
round(avg(salary) over (partition by department_id), 2) as dept_avg_salary,
round(salary - avg(salary) over (partition by department_id), 2) as diff_from_dept_avg
from doctor;


/*=========================================================
  PHASE 11 — VIEWS
=========================================================*/

--11.1 Basic Views
--Q1 Patient information view.
create or replace view vw_patient_details as
select patient_id, patient_name, gender, dob, blood_group, registration_date
from patient;
select * from vw_patient_details;

--Q2 Doctor information view.
create or replace view vw_doctor_details as
select doctor_id, doctor_name, specialization, salary, joining_date
from doctor;
select * from vw_doctor_details;

--Q3 Medicine information view.
--(assumes the expiry column is named expiry_date; adjust if yours differs)
create or replace view vw_medicine_details as
select medicine_id, medicine_name, category, unit_price, stock_quantity, expiry_date
from medicine;
select * from vw_medicine_details;


--11.2 Views with JOIN
--Q4 Doctor + Department view.
create or replace view vw_doctor_department as
select a.doctor_id, a.doctor_name, a.specialization, b.department_name, a.salary
from doctor a join department b on a.department_id = b.department_id;
select * from vw_doctor_department;

--Q5 Patient + Appointment view.
create or replace view vw_patient_appointments as
select a.patient_id, a.patient_name, b.appoint_id, b.appoint_date, b.appont_time, b.status
from patient a join appointment b on a.patient_id = b.patient_id;
select * from vw_patient_appointments;

--Q6 Doctor + Appointment view.
create or replace view vw_doctor_appointments as
select a.doctor_id, a.doctor_name, a.specialization, b.appoint_id, b.appoint_date, b.status
from doctor a join appointment b on a.doctor_id = b.doctor_id;
select * from vw_doctor_appointments;

--Q7 Prescription details view.
create or replace view vw_prescription_details as
select a.prescription_id, a.prescription_date, c.medicine_name,
       b.dosage, b.frequency, b.duration_days, b.quantity
from prescription a
join prescription_item b on a.prescription_id = b.prescription_id
join medicine c on b.medicine_id = c.medicine_id;
select * from vw_prescription_details;

--Q8 Patient admission view.
create or replace view vw_patient_admissions as
select a.patient_id, a.patient_name, b.admission_id, c.room_number, c.room_type,
       b.admission_date, b.discharge_date, b.status
from patient a
join admission b on a.patient_id = b.patient_id
join room c on b.room_id = c.room_id;
select * from vw_patient_admissions;


--11.3 Billing Views
--Q9 Patient billing view.
create or replace view vw_patient_bills as
select a.patient_id, a.patient_name, b.bill_id, b.bill_date, b.total_amount, b.bill_status
from patient a join bill b on a.patient_id = b.patient_id;
select * from vw_patient_bills;

--Q10 Payment details view.
create or replace view vw_payment_details as
select b.bill_id, p.payment_id, p.payment_date, p.amount_paid, p.payment_method, p.payment_status
from bill b join payment p on b.bill_id = p.bill_id;
select * from vw_payment_details;

--Q11 Patient payment view.
create or replace view vw_patient_payments as
select a.patient_name, b.bill_id, b.total_amount, c.amount_paid, c.payment_method, c.payment_status
from patient a
join bill b on a.patient_id = b.patient_id
join payment c on b.bill_id = c.bill_id;
select * from vw_patient_payments;


--11.4 Analytical Views
--Q12 Doctor appointment summary.
create or replace view vw_doctor_appointment_summary as
select d.doctor_id, d.doctor_name, count(a.appoint_id) as total_appointments
from doctor d left join appointment a on d.doctor_id = a.doctor_id
group by d.doctor_id, d.doctor_name;
select * from vw_doctor_appointment_summary;

--Q13 Department doctor summary.
create or replace view vw_department_doctor_summary as
select a.department_id, a.department_name,
       count(b.doctor_id) as total_doctors,
       round(avg(b.salary), 2) as avg_doctor_salary
from department a left join doctor b on a.department_id = b.department_id
group by a.department_id, a.department_name;
select * from vw_department_doctor_summary;

--Q14 Medicine category summary.
create or replace view vw_medicine_category_summary as
select category,
       count(medicine_id) as total_medicines,
       sum(stock_quantity) as total_stock,
       round(avg(unit_price), 2) as avg_unit_price
from medicine
group by category;
select * from vw_medicine_category_summary;

--Q15 Appointment status summary with percentage.
create or replace view vw_appointment_status_summary as
select status,
       count(appoint_id) as total_appointments,
       round(count(appoint_id) * 100.0 / (select count(*) from appointment), 2) as percentage
from appointment
group by status;
select * from vw_appointment_status_summary;


--11.5 Advanced Views
--Q16 Hospital revenue summary.
create or replace view vw_hospital_revenue as
with billed as (
    select sum(total_amount) as total_billed from bill
),
paid as (
    select sum(amount_paid) as total_paid from payment
)
select b.total_billed,
       p.total_paid,
       b.total_billed - p.total_paid as outstanding_amount
from billed b, paid p;
select * from vw_hospital_revenue;

--Q17 Patient outstanding bills (aggregate payments first to avoid duplicate rows).
create or replace view vw_patient_outstanding as
select a.patient_id, a.patient_name, b.bill_id, b.total_amount,
       nvl(p.total_paid, 0) as total_paid,
       b.total_amount - nvl(p.total_paid, 0) as outstanding_amount
from patient a
join bill b on a.patient_id = b.patient_id
left join (
    select bill_id, sum(amount_paid) as total_paid
    from payment
    group by bill_id
) p on b.bill_id = p.bill_id;
select * from vw_patient_outstanding;

--Q18 Doctor performance view.
create or replace view vw_doctor_performance as
select d.doctor_id, d.doctor_name, dp.department_name,
       count(a.appoint_id) as total_appointments,
       count(case when a.status = 'Completed' then 1 end) as completed_appointments
from doctor d
join department dp on d.department_id = dp.department_id
left join appointment a on d.doctor_id = a.doctor_id
group by d.doctor_id, d.doctor_name, dp.department_name;
select * from vw_doctor_performance;

--Q19 Patient appointment summary (conditional aggregation).
create or replace view vw_patient_appointment_summary as
select p.patient_id, p.patient_name,
       count(a.appoint_id) as total_appointments,
       count(case when a.status = 'Completed' then 1 end) as completed_appointments,
       count(case when a.status = 'Cancelled' then 1 end) as cancelled_appointments,
       count(case when a.status = 'Scheduled' then 1 end) as scheduled_appointments
from patient p left join appointment a on p.patient_id = a.patient_id
group by p.patient_id, p.patient_name;
select * from vw_patient_appointment_summary;

--Q20 Hospital dashboard view.
create or replace view vw_hospital_dashboard as
with pat as (select count(patient_id) as total_patients from patient),
     doc as (select count(doctor_id) as total_doctors from doctor),
     appt as (select count(appoint_id) as total_appointments from appointment),
     adm as (select count(admission_id) as total_admissions from admission),
     billed as (select sum(total_amount) as total_billed from bill),
     paid as (select sum(amount_paid) as total_paid from payment)
select pat.total_patients,
       doc.total_doctors,
       appt.total_appointments,
       adm.total_admissions,
       billed.total_billed,
       paid.total_paid,
       billed.total_billed - paid.total_paid as outstanding_amount
from pat, doc, appt, adm, billed, paid;
select * from vw_hospital_dashboard;




-- selecting all tables
select * from doctor;
select * from patient;
select * from medicine;
select * from room;
select * from appointment;
select * from prescription;
select * from prescription_item;
select * from admission;
select * from bill;
select * from payment;





/*
Hospital Management System
│
├── Database Design
│   ├── 11 Tables                  ✅
│   ├── Primary Keys               ✅
│   ├── Foreign Keys               ✅
│   └── Constraints                ✅
│
├── Data Loading
│   ├── Department                 ✅ 10
│   ├── Doctor                     ✅ 20
│   ├── Patient                    ✅ 30
│   ├── Medicine                   ✅ 25
│   ├── Room                       ✅ 20
│   ├── Appointment                ✅ 40
│   ├── Prescription               ✅ 25
│   ├── Prescription Item          ✅ 50
│   ├── Admission                  ✅ 20
│   ├── Bill                       ✅ 30
│   └── Payment                    ✅ 35
│
└── SQL Analysis
    ├── Phase 1 — Basic SQL             ✅
    ├── Phase 2 — Filtering             ✅
    ├── Phase 3 — Functions             ✅
    ├── Phase 4 — Aggregation           ✅
    ├── Phase 5 — GROUP BY              ✅ 
    ├── Phase 6 — JOINs                 ✅
    ├── Phase 7 — Hospital Analysis     ✅
    ├── Phase 8 — Subqueries            ✅ 
    ├── Phase 9 — CTE                   ✅
    ├── Phase 10 — Window Functions     ✅
    ├── Phase 11 — Views                ← YOU ARE HERE
    ├── Phase 12 — Advanced SQL
    └── Power BI Dashboard


*/





-- creating the tbles
/*

                       DEPARTMENT
                           │
                           │ 1:N
                           ▼
                        DOCTOR
                       /      \
                    1:N        1:N
                     /          \
                    ▼            ▼
               APPOINTMENT   PRESCRIPTION
                  ▲  │           │
                  │  │           │ 1:N
                  │  │           ▼
                  │  │     PRESCRIPTION_ITEM
                  │  │          ▲
                  │  │          │ N:1
                  │  │          │
               PATIENT        MEDICINE
                  │
                  │ 1:N
                  ▼
                 BILL
                  │
                  │ 1:N
                  ▼
               PAYMENT


                 ROOM
                  │
                  │
             [used for
              hospital
              room data]

*/