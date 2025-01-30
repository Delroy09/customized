-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 28, 2025 at 03:29 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `timely_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Damodar` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_class VARCHAR(50);
    DECLARE v_classDiv VARCHAR(10);
    DECLARE v_lab VARCHAR(10);
    DECLARE v_subjectCode VARCHAR(20);
    DECLARE v_teacherInitial VARCHAR(20);
    DECLARE v_count INT;
    DECLARE v_dayIndex INT;
    DECLARE v_timeSlot INT;
    DECLARE v_dayName VARCHAR(20);
    DECLARE i INT;

    -- Cursor to fetch required data
    DECLARE cur CURSOR FOR
        SELECT className, classDiv, lab, courseinitial, teacherInitial, COUNT(*)
        FROM test
        GROUP BY className, classDiv, lab, courseinitial, teacherInitial;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_class, v_classDiv, v_lab, v_subjectCode, v_teacherInitial, v_count;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Reset day and time slot for each class and division
        SET v_dayIndex = 1;
        SET v_timeSlot = 1;

        -- Insert based on count
        SET i = 0; -- Initialize within the loop
        WHILE i < v_count DO
            -- Determine the day of the week based on index
            SET v_dayName = CASE (v_dayIndex - 1) % 6 + 1
                WHEN 1 THEN 'Monday'
                WHEN 2 THEN 'Tuesday'
                WHEN 3 THEN 'Wednesday'
                WHEN 4 THEN 'Thursday'
                WHEN 5 THEN 'Friday'
                WHEN 6 THEN 'Saturday'
            END;

            -- Check if entry already exists
            IF NOT EXISTS (
                SELECT 1 FROM timetable 
                WHERE Class = v_class AND ClassDivision = v_classDiv AND DayOfWeek = v_dayName AND TimeSlot = v_timeSlot
            ) THEN
                IF v_lab = '' THEN
                    -- Non-lab entry
                    INSERT INTO timetable (Class, ClassDivision, DayOfWeek, TimeSlot, SubjectCode, TeacherInitial)
                    VALUES (
                        v_class,
                        v_classDiv,
                        v_dayName,
                        v_timeSlot,
                        v_subjectCode,
                        v_teacherInitial
                    );

                    -- Increment counters
                    SET i = i + 1;
                ELSE
                    -- Lab entry
                    INSERT INTO timetable (Class, ClassDivision, DayOfWeek, TimeSlot, SubjectCode, TeacherInitial)
                    VALUES (
                        v_class,
                        v_classDiv,
                        v_dayName,
                        v_timeSlot,
                        CONCAT(v_subjectCode, ' ', v_lab),
                        v_teacherInitial
                    );
                    INSERT INTO timetable (Class, ClassDivision, DayOfWeek, TimeSlot, SubjectCode, TeacherInitial)
                    VALUES (
                        v_class,
                        v_classDiv,
                        v_dayName,
                        v_timeSlot + 1,
                        CONCAT(v_subjectCode, ' ', v_lab),
                        v_teacherInitial
                    );

                    -- Increment counters
                    SET i = i + 2;
                END IF;

                -- Increment day and time slot
                SET v_dayIndex = v_dayIndex + 1;
                IF v_dayIndex > 6 THEN
                    SET v_dayIndex = 1; -- Reset day to Monday after Saturday
                    SET v_timeSlot = v_timeSlot + 1; -- Move to next timeslot after a week
                END IF;
            ELSE
                -- Increment day index if entry already exists
                SET v_dayIndex = v_dayIndex + 1;
                IF v_dayIndex > 6 THEN
                    SET v_dayIndex = 1;
                    SET v_timeSlot = v_timeSlot + 1;
                END IF;
            END IF;
        END WHILE;
    END LOOP;

    CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertEvenData` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_courseInitial VARCHAR(50);
    DECLARE v_teacherInitial VARCHAR(50);
    DECLARE v_lab VARCHAR(10);
    DECLARE v_programmeID INT;
    DECLARE v_semesterID INT;
    DECLARE v_className VARCHAR(50);
    DECLARE v_classDiv VARCHAR(10);
    DECLARE v_theoryHrs INT;
    DECLARE v_prachrs INT;
    DECLARE i INT;

    -- Declare cursor
    DECLARE cur CURSOR FOR
        SELECT a.courseInitial, b.teacherInitial, b.lab, a.programmeID, a.semesterID, c.className, c.classDiv, a.theoryHrs, a.prachrs
        FROM course a
        JOIN coursealloc b 
            ON a.programmeID = b.programmeID 
            AND a.semesterID = b.semesterID 
            AND a.courseID = b.CourseID
        JOIN class c 
            ON b.classNo = c.classNo
        WHERE a.courseInitial NOT LIKE 'NCC%' 
         -- AND b.lab = ''
          AND a.semesterID IN (2, 4, 6);

    -- Declare exit handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open cursor
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_courseInitial, v_teacherInitial, v_lab, v_programmeID, v_semesterID, v_className, v_classDiv, v_theoryHrs, v_prachrs;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insert based on theoryHrs
        SET i = 1;
        WHILE i <= v_theoryHrs DO
            INSERT INTO test (courseInitial, teacherInitial, lab, programmeID, semesterID, className, classDiv)
            VALUES (v_courseInitial, v_teacherInitial, v_lab, v_programmeID, v_semesterID, v_className, v_classDiv);
            SET i = i + 1;
        END WHILE;

        -- Insert based on prachrs
        SET i = 1;
        WHILE i <= v_prachrs DO
            INSERT INTO test (courseInitial, teacherInitial, lab, programmeID, semesterID, className, classDiv)
            VALUES (v_courseInitial, v_teacherInitial, v_lab, v_programmeID, v_semesterID, v_className, v_classDiv);
            SET i = i + 1;
        END WHILE;

    END LOOP;

    -- Close cursor
    CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertOddData` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_courseInitial VARCHAR(50);
    DECLARE v_teacherInitial VARCHAR(50);
    DECLARE v_lab VARCHAR(10);
    DECLARE v_programmeID INT;
    DECLARE v_semesterID INT;
    DECLARE v_className VARCHAR(50);
    DECLARE v_classDiv VARCHAR(10);
    DECLARE v_theoryHrs INT;
    DECLARE v_prachrs INT;
    DECLARE i INT;

    -- Declare cursor
    DECLARE cur CURSOR FOR
        SELECT a.courseInitial, b.teacherInitial, b.lab, a.programmeID, a.semesterID, c.className, c.classDiv, a.theoryHrs, a.prachrs
        FROM course a
        JOIN coursealloc b 
            ON a.programmeID = b.programmeID 
            AND a.semesterID = b.semesterID 
            AND a.courseID = b.CourseID
        JOIN class c 
            ON b.classNo = c.classNo
        WHERE a.courseInitial NOT LIKE 'NCC%' 
         -- AND b.lab = ''
          AND a.semesterID IN (1, 3, 5);

    -- Declare exit handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open cursor
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_courseInitial, v_teacherInitial, v_lab, v_programmeID, v_semesterID, v_className, v_classDiv, v_theoryHrs, v_prachrs;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insert based on theoryHrs
        SET i = 1;
        WHILE i <= v_theoryHrs DO
            INSERT INTO test (courseInitial, teacherInitial, lab, programmeID, semesterID, className, classDiv)
            VALUES (v_courseInitial, v_teacherInitial, v_lab, v_programmeID, v_semesterID, v_className, v_classDiv);
            SET i = i + 1;
        END WHILE;

        -- Insert based on prachrs
        SET i = 1;
        WHILE i <= v_prachrs DO
            INSERT INTO test (courseInitial, teacherInitial, lab, programmeID, semesterID, className, classDiv)
            VALUES (v_courseInitial, v_teacherInitial, v_lab, v_programmeID, v_semesterID, v_className, v_classDiv);
            SET i = i + 1;
        END WHILE;

    END LOOP;

    -- Close cursor
    CLOSE cur;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `username` varchar(30) NOT NULL,
  `password` varchar(30) NOT NULL,
  `role` varchar(5) NOT NULL,
  `google_id` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`username`, `password`, `role`, `google_id`, `email`) VALUES
('Bca', 'admin', 'bca', '', ''),
('Bvoc', 'admin', 'bvoc', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `class`
--

CREATE TABLE `class` (
  `classNo` varchar(30) NOT NULL,
  `className` varchar(30) NOT NULL,
  `classDiv` varchar(30) DEFAULT NULL,
  `programmeID` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `class`
--

INSERT INTO `class` (`classNo`, `className`, `classDiv`, `programmeID`) VALUES
('F-101', 'FY BVOC', '', 2),
('F-102', 'SY BVOC', '', 2),
('F-105', 'TY BVOC', '', 2),
('S-201', 'FY BCA', 'A', 1),
('S-202', 'FY BCA', 'B', 1),
('S-203', 'SY BCA', 'A', 1),
('S-204', 'SY BCA', 'B', 1),
('S-206', 'TY BCA', 'B', 1),
('S-207', 'TY BCA', 'A', 1);

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `courseID` varchar(10) NOT NULL,
  `courseName` varchar(70) NOT NULL,
  `courseInitial` varchar(20) DEFAULT NULL,
  `courseType` varchar(40) DEFAULT NULL,
  `isPracIncluded` tinyint(1) NOT NULL,
  `theoryHrs` int(11) DEFAULT 0,
  `pracHrs` int(11) DEFAULT 0,
  `theoryCredits` int(11) DEFAULT 0,
  `pracCredits` int(11) DEFAULT 0,
  `semesterID` int(11) NOT NULL,
  `programmeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`courseID`, `courseName`, `courseInitial`, `courseType`, `isPracIncluded`, `theoryHrs`, `pracHrs`, `theoryCredits`, `pracCredits`, `semesterID`, `programmeID`) VALUES
('CAC-117', 'Web Technology', 'WT', 'Core', 0, 4, 0, 4, 0, 5, 1),
('CAC-118', 'Information System', 'IS', 'Core', 0, 4, 0, 4, 0, 5, 1),
('CAC-119', 'Web Technology Laboratory', 'WT lab', 'Core', 1, 0, 4, 0, 2, 5, 1),
('CAC-120', 'Multimedia Technology', 'CAC', 'Core Course', 0, 4, 0, 4, 0, 6, 1),
('CAC-121', 'E-Commerce Applications', 'CAC', 'Core Course', 0, 4, 0, 4, 0, 6, 1),
('CAC-122', 'Multimedia Technology Laboratory', 'CAC', 'Core Course', 1, 0, 4, 0, 2, 6, 1),
('CAD-103', 'Mobile Application Development', 'MAD', 'Discipline Specific Electives', 0, 4, 0, 4, 0, 5, 1),
('CAD-104', 'Computer Animation', 'CA', 'Discipline Specific Electives', 0, 4, 0, 4, 0, 5, 1),
('CAD-110', 'Data Science Concepts', 'CAD', 'Discipline Specific Elective', 0, 4, 0, 4, 0, 6, 1),
('CAD-113', 'Search Engine Optimisation', 'CAD', 'Discipline Specific Elective', 0, 4, 0, 4, 0, 6, 1),
('CAP-101', 'Project', 'Project', 'Project', 0, 4, 0, 4, 0, 5, 1),
('COM-132', 'Fundamentals of Stock Market', 'Stock Market', 'Multidisciplinary Course', 0, 3, 0, 3, 0, 1, 1),
('COM-133', 'Marketing for Beginners', 'Market for Beginners', 'Multidisciplinary Course', 0, 3, 0, 3, 0, 1, 1),
('COM-140c', 'Economics of Financial Investments', 'EFI', 'Multidisciplinary Course', 0, 3, 0, 3, 0, 2, 1),
('COM-231', 'Event Management', 'COM', 'Multidisciplinary', 0, 3, 0, 3, 0, 3, 1),
('CSA-100', 'Problem solving and programming', 'PSP', 'Major', 1, 3, 2, 3, 1, 1, 1),
('CSA-142', 'Python Programming', 'PY', 'Skill Enchantment Course', 1, 1, 4, 1, 2, 1, 1),
('CSA-143', 'Data Analytics using Spreadsheets', 'DAS', 'Skill Enhancement Course', 1, 0, 8, 0, 0, 2, 1),
('CSA-144', '2D Animation', '2D Animation', 'Skill Enhancement Course', 1, 1, 4, 3, 0, 2, 1),
('CSA-200', 'Data Structures', 'CSA', 'Major', 0, 4, 0, 4, 0, 3, 1),
('CSA-201', 'Database Management Systems', 'CSA', 'Major', 0, 4, 0, 4, 0, 3, 1),
('CSA-202', 'Web App Development', 'WD', 'Major', 1, 2, 6, 1, 3, 4, 1),
('CSA-203', 'Agile Methodologies', 'AM', 'Major', 1, 3, 2, 3, 1, 4, 1),
('CSA-204', 'Object Oriented Concepts', 'OOC', 'Major', 1, 3, 2, 3, 1, 4, 1),
('CSA-205', 'Web Technology', 'WT', 'Major', 0, 2, 0, 2, 0, 4, 1),
('CSA-211', 'Reasoning Techniques', 'CSA', 'Minor', 0, 4, 0, 4, 0, 3, 1),
('CSA-212', 'Techpreunership Development', 'CSA', 'Minor', 0, 4, 0, 4, 0, 3, 1),
('CSA-222', 'Data Analysis', 'DA', 'Minor', 1, 3, 2, 3, 1, 4, 1),
('CSA-223', 'Advance Javascript', 'AJS', 'Minor', 1, 3, 2, 3, 1, 4, 1),
('CSA-241', 'Multimedia Applications', 'CSA', 'Skill Enhancement', 0, 3, 0, 3, 0, 3, 1),
('CSA-242', 'Search Engine Optimization', 'CSA', 'Skill Enhancement', 0, 3, 0, 3, 0, 3, 1),
('CSC-112', 'Computer Software Fundamentals', 'CSF', 'Minor', 0, 4, 0, 4, 0, 2, 1),
('ENG-151', 'Communicative English - Spoken and Written', 'Com Eng', 'Ability Enhancement Course', 0, 2, 0, 2, 0, 1, 1),
('ENG-152', 'Digital Content creation in English', 'DCC', 'Ability Enhancement Course', 0, 2, 0, 2, 0, 2, 1),
('HIN-251', 'Hindi', 'HIN', 'Ability Enhancement', 0, 2, 0, 2, 0, 3, 1),
('HIN-252', 'Hindi', 'Hindi', 'Ability Enhancement', 0, 2, 0, 2, 0, 4, 1),
('KON-251', 'Konkani', 'KON', 'Ability Enhancement', 0, 2, 0, 2, 0, 3, 1),
('KON-252', 'Konkani', 'Konkani', 'Ability Enhancement', 0, 2, 0, 2, 0, 4, 1),
('MAG-132', 'Marketing management', 'MM', 'Multidisciplinary Course', 0, 3, 0, 3, 0, 2, 1),
('MAT-100', 'Foundational Mathematics', 'FM', 'Major', 1, 3, 4, 4, 0, 2, 1),
('MAT-112', 'Elementary Statistics', 'ES', 'Minor', 0, 4, 0, 4, 0, 1, 1),
('MGF-231', 'Fintech', 'MGF', 'Multidisciplinary', 0, 3, 0, 3, 0, 3, 1),
('STG-101', 'Fundamentals of Computers and Programming', 'FCP', 'General Education', 0, 3, 0, 3, 0, 1, 2),
('STG-102', 'Web Designing Concepts', 'WDC', 'General Education', 0, 3, 0, 3, 0, 1, 2),
('STG-103', 'Quantitative Techniques', 'QT', 'General Education', 0, 2, 0, 2, 0, 1, 2),
('STG-104', 'Environmental Studies - I', 'EVS', 'General Education', 0, 2, 0, 2, 0, 1, 2),
('STG-301', 'Data Structures', 'DS', 'General Education', 0, 3, 0, 3, 0, 3, 2),
('STG-302', 'Audio and Visual Media', 'AVM', 'General Education', 0, 3, 0, 3, 0, 3, 2),
('STG-303', 'Reasoning Techniques', 'RT', 'General Education', 0, 4, 0, 4, 0, 3, 2),
('STG-401', 'Python Programming ', 'PY', 'General Theory', 0, 3, 0, 3, 0, 4, 2),
('STG-402', 'Software Engineering and Testing ', 'SE & T', 'General Theory', 0, 3, 0, 3, 0, 4, 2),
('STG-403', 'Creative Thinking', 'CT', 'General Theory', 0, 4, 0, 4, 0, 4, 2),
('STG-501', 'Mobile Application Development', 'MAD', 'General Education', 0, 3, 0, 3, 0, 5, 2),
('STG-502', 'Human Computer Interaction', 'HCI', 'General education', 0, 3, 0, 3, 0, 5, 2),
('STG-503', 'Advanced Quantitative Techniques', 'AQT', 'General Education', 0, 4, 0, 4, 0, 5, 2),
('STG-601', 'Relational Database Management System', 'RDBMS', 'General Theory', 0, 3, 0, 3, 0, 6, 2),
('STG-602', 'Computer Networks', 'CN', 'General Theory', 0, 3, 0, 3, 0, 6, 2),
('STG-603', 'Entrepreneurship Development', 'ED', 'General Theory', 0, 4, 0, 4, 0, 6, 2),
('STP-101', 'Software Laboratory - I', 'SL-1', 'General Education', 0, 0, 2, 0, 2, 1, 2),
('STP-301', 'Software Laboratory - III', 'SL-3', 'General Education', 1, 0, 4, 0, 2, 3, 2),
('STP-401', 'Software Laboratory-IV', 'SL-4', 'General Practical', 0, 2, 0, 2, 0, 4, 2),
('STP-501', 'Software laboratory V', 'SL V', 'General Education', 1, 0, 4, 0, 2, 5, 2),
('STP-601', 'Software Laboratory - VI', 'SL-VI', 'General Practical', 1, 0, 4, 0, 2, 6, 2),
('STS-101', 'Junior Software Developer (SSC/Q0508)', 'JSD', 'SDQP', 1, 3, 2, 7, 3, 1, 2),
('STS-301', 'Associate-Desktop Publishing - (SSC/Q2702)', 'ADP', 'Skill Development Qualification Pack', 1, 7, 10, 7, 5, 3, 2),
('STS-401 ', 'Associate Desktop Publishing', 'DTP', 'SDQP', 1, 0, 4, 6, 6, 4, 2),
('STS-501', 'Software Developer', 'SD', 'Skill Development Qualification Pack', 0, 4, 0, 9, 0, 5, 2),
('STS-601', 'Software Developer - (SSC/Q0501)', 'SD', 'Skill (Theory, Practical & Project/OJT)', 1, 6, 12, 6, 6, 6, 2),
('VAC-102', 'Environmental Practices in Goa', 'EVS', 'Value Added Course', 0, 2, 0, 2, 0, 1, 1),
('VAC-104', 'Constitutional Values and Obligations', 'CVO', 'Value Added Course', 0, 2, 0, 2, 0, 1, 1),
('VAC-106', 'NCC and Nation Building (Army)', 'NCC ARMY', 'Value Added Course', 1, 1, 1, 1, 1, 1, 1),
('VAC-107', 'NCC and Nation Building (Navy)', 'NCC NAVY', 'Value Added Course', 1, 1, 1, 1, 1, 1, 1),
('VAC-108', 'Introduction to the Folktales of India', 'FT', 'Value Added Course', 0, 2, 0, 2, 0, 1, 1),
('VAC-111', 'E-Waste Management', 'E-Waste', 'Value Added Course', 0, 2, 0, 2, 0, 2, 1),
('VAC-116', 'Life Skills', 'Life Skill', 'Value Added Course', 0, 2, 0, 2, 0, 2, 1),
('VAC-117', 'Youth Empowerment using Mind Management', 'YEMM', 'Value Added Course', 0, 2, 0, 2, 0, 2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `coursealloc`
--

CREATE TABLE `coursealloc` (
  `id` int(11) NOT NULL,
  `teacherInitial` varchar(14) DEFAULT NULL,
  `courseID` varchar(8) DEFAULT NULL,
  `classNo` varchar(7) DEFAULT NULL,
  `lab` varchar(10) NOT NULL,
  `semesterID` varchar(10) DEFAULT NULL,
  `programmeID` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `coursealloc`
--

INSERT INTO `coursealloc` (`id`, `teacherInitial`, `courseID`, `classNo`, `lab`, `semesterID`, `programmeID`) VALUES
(1, 'SPP', 'CAD-103', 'S-206', '', '5', '1'),
(2, 'SPP', 'CAD-103', 'S-206', 'LAB-4', '5', '1'),
(3, 'SRV', 'CAC-117', 'S-206', '', '5', '1'),
(4, 'SV', 'CAC-118', 'S-206', '', '5', '1'),
(5, 'SAK', 'CAD-104', 'S-206', '', '5', '1'),
(6, 'SRV', 'CAC-119', 'S-206', 'LAB-1', '5', '1'),
(7, 'SAK', 'CAD-104', 'S-206', 'LAB-4', '5', '1'),
(8, 'RR', 'CAC-119', 'S-207', 'LAB-1', '5', '1'),
(9, 'RR', 'CAC-117', 'S-207', '', '5', '1'),
(10, 'RRD', 'CAD-103', 'S-207', 'LAB-4', '5', '1'),
(11, 'RRD', 'CAD-103', 'S-207', '', '5', '1'),
(12, 'AR', 'CAD-104', 'S-206', 'LAB-4', '5', '1'),
(13, 'AR', 'CAD-104', 'S-207', '', '5', '1'),
(14, 'AP', 'CAC-118', 'S-207', '', '5', '1'),
(15, 'NK', 'STG-204', 'F-101', '', '2', '2'),
(16, 'AN', 'STG-203', 'F-101', '', '2', '2'),
(17, 'AR', 'STG-202', 'F-101', '', '2', '2'),
(18, 'RB', 'STG-201', 'F-101', '', '2', '2'),
(19, 'RRD', 'STS-201', 'F-101', 'LAB-5', '2', '2'),
(20, 'SRV', 'STS-201', 'F-101', 'LAB-5', '2', '2'),
(21, 'RR', 'STP-201', 'F-101', 'LAB-5', '2', '2'),
(22, 'SK', 'STS-201', 'F-101', 'LAB-5', '2', '2'),
(23, 'RB', 'STP-201', 'F-101', 'LAB-5', '2', '2'),
(24, 'SRV', 'CSA-223', 'S-204', 'LAB-4', '4', '1'),
(25, 'SP', 'CSA-203', 'S-204', '', '4', '1'),
(26, 'GG', 'CSA-204', 'S-204', '', '4', '1'),
(27, 'SPP', 'CSA-202', 'S-204', '', '4', '1'),
(28, 'CPV', 'KON-252', 'S-204', '', '4', '1'),
(29, 'DK', 'CSA-205', 'S-204', '', '4', '1'),
(30, 'GG', 'CSA-204', 'S-204', 'LAB-3', '4', '1'),
(31, 'SPP', 'CSA-202', 'S-204', 'LAB-1', '4', '1'),
(32, 'RRD', 'CSA-202', 'S-204', 'LAB-2', '4', '1'),
(33, 'SP', 'CSA-203', 'S-204', 'LAB-5', '4', '1'),
(34, 'AA', 'CSA-202', 'S-203', 'LAB-1', '4', '1'),
(35, 'RR', 'CSA-202', 'S-203', 'LAB-2', '4', '1'),
(36, 'DK', 'CSA-222', 'S-203', '', '4', '1'),
(37, 'AN', 'CSA-204', 'S-203', 'LAB-5', '4', '1'),
(38, 'AN', 'CSA-204', 'S-203', '', '4', '1'),
(39, 'SUP', 'HIN-252', 'S-203', '', '4', '1'),
(40, 'AR', 'CSA-203', 'S-203', '', '4', '1'),
(41, 'DK', 'CSA-222', 'S-203', 'LAB-5', '4', '1'),
(42, 'AP', 'CSA-205', 'S-203', '', '4', '1'),
(43, 'DK', 'STG-302', 'F-102', '', '3', '2'),
(44, 'RB', 'STG-301', 'F-102', '', '3', '2'),
(45, 'YJ', 'STG-303', 'F-102', '', '3', '2'),
(46, 'SG', 'STS-301', 'F-102', 'PROJ', '3', '2'),
(47, 'RB', 'STP-301', 'F-102', 'LAB-1', '3', '2'),
(48, 'SP', 'STP-301', 'F-102', '', '3', '2'),
(49, 'YJ', 'MAT-100', 'S-201', '', '2', '1'),
(50, 'SAK', 'CSA-144', 'S-201', 'LAB-3', '2', '1'),
(51, 'SV', 'CSC-112', 'S-201', '', '2', '1'),
(52, 'NK', 'VAC-111', 'S-201', '', '2', '1'),
(53, 'VK', 'VAC-116', 'S-201', '', '2', '1'),
(54, 'VK', 'COM-140', 'S-202', '', '2', '1'),
(55, 'AR', 'CSC-112', 'S-202', '', '2', '1'),
(56, 'NK', 'VAC-111', 'S-202', '', '2', '1'),
(57, 'YJ', 'MAT-100', 'S-202', '', '2', '1'),
(58, ' SAK', 'CSA-144', 'S-201', 'LAB-1', '2', '1'),
(59, 'JP', 'ENG-152', 'S-201', '', '2', '1'),
(60, 'VK', 'VAC-116', 'S-202', '', '2', '1'),
(61, 'JP', 'ENG-152', 'S-202', '', '2', '1'),
(62, 'GG', 'CSA-143', 'S-202', 'LAB-3', '2', '1'),
(63, 'SAK', 'CSA-144', 'S-201', '', '2', '1'),
(64, 'VK', 'MAG-132', 'S-202', '', '2', '1'),
(65, 'SAK', 'CSA-144', 'S-201', 'LAB-1', '2', '1'),
(66, 'GG', 'CAS-143', 'S-202', 'LAB-2', '2', '1'),
(67, 'JP', 'ENG-152', 'S-201', '', '2', '1'),
(68, 'DK', 'CAC-121', 'S-207', '', '6', '1'),
(69, 'AES', 'CAC-122', 'S-207', 'LAB-3', '6', '1'),
(70, 'RB', 'CAD-113', 'S-207', 'LAB-4', '6', '1'),
(71, 'SPP', 'CAD-110', 'S-207', 'LAB-2', '6', '1'),
(72, 'SK', 'CAD-110', 'S-206', '', '6', '1'),
(73, 'AES', 'CAC-121', 'S-206', '', '6', '1'),
(74, 'RRD', 'CAC-120', 'S-206', '', '6', '1'),
(75, 'AP', 'CAD-113', 'S-206', '', '6', '1'),
(76, 'SPP', 'CAD-110', 'S-207', 'LAB-4', '6', '1'),
(77, 'RB', 'CAD-113', 'S-207', '', '6', '1'),
(78, 'SAK', 'CAC-120', 'S-207', '', '6', '1'),
(79, 'AN', 'CAC-122', 'S-206', 'LAB-3', '6', '1'),
(80, 'SK', 'CAD-110', 'S-206', 'LAB-4', '6', '1'),
(81, 'AP', 'CAD-113', 'S-206', 'LAB-4', '6', '1'),
(82, 'SPP', 'CAD-110', 'S-207', '', '6', '1'),
(83, 'SRV', 'STS-501', 'F-105', '', '5', '2'),
(84, 'YJ', 'STG-503', 'F-105', '', '5', '2'),
(85, 'SPP', 'STG-501', 'F-105', '', '5', '2'),
(86, 'SAK', 'STG-502', 'F-105', '', '5', '2'),
(87, 'RR', 'STS-501', 'F-105', '', '5', '2'),
(88, 'SPP', 'STP-501', 'F-105', 'LAB-4', '5', '2'),
(89, 'CR', 'STS-501', 'F-105', 'LAB-4', '5', '2'),
(90, 'CR', 'STS-501', 'F-105', '', '5', '2'),
(91, 'AR', 'STG-102', 'F-101', '', '1', '2'),
(92, 'AES', 'STS-101', 'F-101', '', '1', '2'),
(93, 'NK', 'STG-104', 'F-101', '', '1', '2'),
(94, 'AN', 'STS-101', 'F-101', '', '1', '2'),
(95, 'SK', 'STS-101', 'F-101', '', '1', '2'),
(96, 'YJ', 'STG-103', 'F-101', '', '1', '2'),
(97, 'AVM', 'STG-103', 'F-101', '', '1', '2'),
(98, 'SV', 'STG-101', 'F-101', '', '1', '2'),
(99, 'SP', 'STP-101', 'F-101', '', '1', '2'),
(100, 'AR', 'STP-101', 'F-101', 'LAB-3', '1', '2'),
(101, 'AN', 'STS-101', 'F-101', 'LAB-1', '1', '2'),
(102, 'SK', 'STS-101', 'F-101', 'LAB-3', '1', '2'),
(103, 'AN', 'CSA-200', 'S-203', '', '3', '1'),
(104, 'ANP', 'CSA-211', 'S-203', '', '3', '1'),
(105, 'SK', 'CSA-201', 'S-203', '', '3', '1'),
(106, 'AP', 'CSA-242', 'S-203', 'LAB-3', '3', '1'),
(107, 'SAK', 'CSA-201', 'S-204', 'LAB-3', '3', '1'),
(108, 'SP', 'CSA-200', 'S-204', 'LAB-2', '3', '1'),
(109, 'VK', 'CSA-212', 'S-204', '', '3', '1'),
(110, 'SAK', 'CSA-201', 'S-204', '', '3', '1'),
(111, 'VK', 'MGF-231', 'S-203', '', '3', '1'),
(112, 'NU', 'COM-231', 'S-204', '', '3', '1'),
(113, 'AN', 'CSA-200', 'S-203', 'LAB-2', '3', '1'),
(114, 'SK', 'CSA-201', 'S-203', 'LAB-3', '3', '1'),
(115, 'SP', 'CSA-200', 'S-204', '', '3', '1'),
(116, 'AES', 'CSA-241', 'S-204', '', '3', '1'),
(117, 'AES', 'CSA-241', 'S-204', 'LAB-3', '3', '1'),
(118, 'AP', 'CSA-242', 'S-203', '', '3', '1'),
(119, 'CPV', 'HIN-251', 'S-203', '', '3', '1'),
(120, 'SUP', 'KON-251', 'S-204', '', '3', '1'),
(121, 'SP', 'STG-401', 'F-102', '', '4', '2'),
(122, 'SG', 'STS-401', 'F-102', '', '4', '2'),
(123, 'SG', 'STS-401', 'F-102', 'LAB-4', '4', '2'),
(124, 'AR', 'STG-403', 'F-102', '', '4', '2'),
(125, 'AES', 'STP-401', 'F-102', 'LAB-1', '4', '2'),
(126, 'SP', 'STP-401', 'F-102', 'LAB-2', '4', '2'),
(127, 'SAK', 'STG-402', 'F-102', '', '4', '2'),
(128, 'AP', 'STS-401', 'F-102', '', '4', '2'),
(133, 'NK', 'VAC-102', 'S-201', '', '1', '1'),
(134, 'YK', 'MAT-112', 'S-201', '', '1', '1'),
(135, 'SP', 'CSA-142', 'S-201', '', '1', '1'),
(136, 'YJ', 'MAT-112', 'S-202', '', '1', '1'),
(137, 'SV', 'CSA-100', 'S-201', 'LAB-2', '1', '1'),
(138, 'VK', 'COM-133', 'S-202', '', '1', '1'),
(139, 'RRD', 'CSA-100', 'S-202', '', '1', '1'),
(140, 'GG', 'CSA-142', 'S-201', 'LAB-1', '1', '1'),
(141, 'VK', 'COM-132', 'S-201', '', '1', '1'),
(142, 'GG', 'CSA-142', 'S-201', '', '1', '1'),
(143, 'ZT', 'ENG-151', 'S-201', '', '1', '1'),
(144, 'RB', 'CSA-142', 'S-202', '', '1', '1'),
(145, 'GG', 'CSA-142', 'S-201', 'LAB-1', '1', '1'),
(146, 'MF', 'VAC-104', 'S-201', '', '1', '1'),
(147, 'SV', 'CSA-100', 'S-201', '', '1', '1'),
(148, 'ZT', 'VAC-108', 'S-202', '', '1', '1'),
(149, 'ZT', 'ENG-151', 'S-202', '', '1', '1'),
(150, 'RRD', 'CSA-100', 'S-202', 'LAB-2', '1', '1'),
(151, 'RB', 'CSA-142', 'S-202', 'LAB-1', '1', '1'),
(152, 'NK', 'VAC-102', 'S-202', '', '1', '1');

-- --------------------------------------------------------

--
-- Table structure for table `programme`
--

CREATE TABLE `programme` (
  `programmeID` int(5) NOT NULL,
  `programmeName` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `programme`
--

INSERT INTO `programme` (`programmeID`, `programmeName`) VALUES
(1, 'BCA'),
(2, 'Bvoc');

-- --------------------------------------------------------

--
-- Table structure for table `semester`
--

CREATE TABLE `semester` (
  `semesterID` int(11) NOT NULL,
  `semesterName` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `semester`
--

INSERT INTO `semester` (`semesterID`, `semesterName`) VALUES
(1, 'First Semester'),
(2, 'Second Semester'),
(3, 'Third Semester'),
(4, 'Fourth Semester'),
(5, 'Fifth Semester'),
(6, 'Sixth Semester');

-- --------------------------------------------------------

--
-- Table structure for table `teacher`
--

CREATE TABLE `teacher` (
  `teacherID` int(11) NOT NULL,
  `teacherInitial` varchar(40) NOT NULL,
  `teacherName` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teacher`
--

INSERT INTO `teacher` (`teacherID`, `teacherInitial`, `teacherName`) VALUES
(1, 'SK', 'Sumit Kumar'),
(2, 'SV', 'Sweta Verenkar'),
(3, 'RR', 'Ramkrishna Reddy'),
(4, 'AP', 'Andre Pacheco'),
(5, 'AN', 'Ankita Naik'),
(6, 'SAK', 'Shruti Kunkolienkar'),
(7, 'RB', 'Rama Borkar'),
(8, 'SPP', 'Sameer Patil'),
(9, 'SP', 'Sneha Prabhudesai'),
(10, 'GG', 'Girija Gaonkar'),
(11, 'AR', 'Amogh Pai Raiturkar'),
(12, 'VK', 'Vinaya Kirloskar'),
(13, 'AES', 'Annette Santimano'),
(14, 'RRD', 'Rakshavi Dessai'),
(15, 'SRV', 'Samira Vengurlekar'),
(16, 'DK', 'Deepti Kulkarni'),
(17, 'SG', 'Sandesh Gundalkar'),
(18, 'YJ', 'Yugandhara Joshi'),
(19, 'ZT', 'Zakiya M Tahir'),
(20, 'NK', 'Nikita Verenkar'),
(21, 'ANP', 'Anupama Patil'),
(22, 'MF', 'Muriel Fernandes'),
(23, 'NU', 'Namrata Ugevkar'),
(24, 'CPV', 'Chaya Velip'),
(25, 'SUP', 'Supriya Kankonkar'),
(26, 'CR', 'Chetan Rane'),
(27, 'AR', 'Arshita Ranjit');

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `courseInitial` varchar(50) DEFAULT NULL,
  `teacherInitial` varchar(50) DEFAULT NULL,
  `lab` varchar(10) DEFAULT NULL,
  `programmeID` int(11) DEFAULT NULL,
  `semesterID` int(11) DEFAULT NULL,
  `className` varchar(50) DEFAULT NULL,
  `classDiv` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `test`
--

INSERT INTO `test` (`courseInitial`, `teacherInitial`, `lab`, `programmeID`, `semesterID`, `className`, `classDiv`) VALUES
('PY', 'SP', '', 2, 4, 'SY BVOC', ''),
('PY', 'SP', '', 2, 4, 'SY BVOC', ''),
('PY', 'SP', '', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', '', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', '', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', '', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', '', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', 'LAB-4', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', 'LAB-4', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', 'LAB-4', 2, 4, 'SY BVOC', ''),
('DTP', 'SG', 'LAB-4', 2, 4, 'SY BVOC', ''),
('CT', 'AR', '', 2, 4, 'SY BVOC', ''),
('CT', 'AR', '', 2, 4, 'SY BVOC', ''),
('CT', 'AR', '', 2, 4, 'SY BVOC', ''),
('CT', 'AR', '', 2, 4, 'SY BVOC', ''),
('SL-4', 'AES', 'LAB-1', 2, 4, 'SY BVOC', ''),
('SL-4', 'AES', 'LAB-1', 2, 4, 'SY BVOC', ''),
('SL-4', 'SP', 'LAB-2', 2, 4, 'SY BVOC', ''),
('SL-4', 'SP', 'LAB-2', 2, 4, 'SY BVOC', ''),
('SE & T', 'SAK', '', 2, 4, 'SY BVOC', ''),
('SE & T', 'SAK', '', 2, 4, 'SY BVOC', ''),
('SE & T', 'SAK', '', 2, 4, 'SY BVOC', ''),
('DTP', 'AP', '', 2, 4, 'SY BVOC', ''),
('DTP', 'AP', '', 2, 4, 'SY BVOC', ''),
('DTP', 'AP', '', 2, 4, 'SY BVOC', ''),
('DTP', 'AP', '', 2, 4, 'SY BVOC', ''),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'A'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'A'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'A'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'A'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'A'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'A'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-3', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-3', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-3', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-3', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-3', 1, 2, 'FY BCA', 'A'),
('CSF', 'SV', '', 1, 2, 'FY BCA', 'A'),
('CSF', 'SV', '', 1, 2, 'FY BCA', 'A'),
('CSF', 'SV', '', 1, 2, 'FY BCA', 'A'),
('CSF', 'SV', '', 1, 2, 'FY BCA', 'A'),
('E-Waste', 'NK', '', 1, 2, 'FY BCA', 'A'),
('E-Waste', 'NK', '', 1, 2, 'FY BCA', 'A'),
('Life Skill', 'VK', '', 1, 2, 'FY BCA', 'A'),
('Life Skill', 'VK', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', ' SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', ' SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', ' SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', ' SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', ' SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('DCC', 'JP', '', 1, 2, 'FY BCA', 'A'),
('DCC', 'JP', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', '', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('2D Animation', 'SAK', 'LAB-1', 1, 2, 'FY BCA', 'A'),
('DCC', 'JP', '', 1, 2, 'FY BCA', 'A'),
('DCC', 'JP', '', 1, 2, 'FY BCA', 'A'),
('CSF', 'AR', '', 1, 2, 'FY BCA', 'B'),
('CSF', 'AR', '', 1, 2, 'FY BCA', 'B'),
('CSF', 'AR', '', 1, 2, 'FY BCA', 'B'),
('CSF', 'AR', '', 1, 2, 'FY BCA', 'B'),
('E-Waste', 'NK', '', 1, 2, 'FY BCA', 'B'),
('E-Waste', 'NK', '', 1, 2, 'FY BCA', 'B'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'B'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'B'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'B'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'B'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'B'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'B'),
('FM', 'YJ', '', 1, 2, 'FY BCA', 'B'),
('Life Skill', 'VK', '', 1, 2, 'FY BCA', 'B'),
('Life Skill', 'VK', '', 1, 2, 'FY BCA', 'B'),
('DCC', 'JP', '', 1, 2, 'FY BCA', 'B'),
('DCC', 'JP', '', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('DAS', 'GG', 'LAB-3', 1, 2, 'FY BCA', 'B'),
('MM', 'VK', '', 1, 2, 'FY BCA', 'B'),
('MM', 'VK', '', 1, 2, 'FY BCA', 'B'),
('MM', 'VK', '', 1, 2, 'FY BCA', 'B'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'AA', 'LAB-1', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('WD', 'RR', 'LAB-2', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', '', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', '', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', '', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', '', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', '', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', '', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', '', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', '', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', '', 1, 4, 'SY BCA', 'A'),
('OOC', 'AN', '', 1, 4, 'SY BCA', 'A'),
('Hindi', 'SUP', '', 1, 4, 'SY BCA', 'A'),
('Hindi', 'SUP', '', 1, 4, 'SY BCA', 'A'),
('AM', 'AR', '', 1, 4, 'SY BCA', 'A'),
('AM', 'AR', '', 1, 4, 'SY BCA', 'A'),
('AM', 'AR', '', 1, 4, 'SY BCA', 'A'),
('AM', 'AR', '', 1, 4, 'SY BCA', 'A'),
('AM', 'AR', '', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('DA', 'DK', 'LAB-5', 1, 4, 'SY BCA', 'A'),
('WT', 'AP', '', 1, 4, 'SY BCA', 'A'),
('WT', 'AP', '', 1, 4, 'SY BCA', 'A'),
('AJS', 'SRV', 'LAB-4', 1, 4, 'SY BCA', 'B'),
('AJS', 'SRV', 'LAB-4', 1, 4, 'SY BCA', 'B'),
('AJS', 'SRV', 'LAB-4', 1, 4, 'SY BCA', 'B'),
('AJS', 'SRV', 'LAB-4', 1, 4, 'SY BCA', 'B'),
('AJS', 'SRV', 'LAB-4', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', '', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', '', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', '', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', '', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', '', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', '', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', '', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', '', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', '', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', '', 1, 4, 'SY BCA', 'B'),
('Konkani', 'CPV', '', 1, 4, 'SY BCA', 'B'),
('Konkani', 'CPV', '', 1, 4, 'SY BCA', 'B'),
('WT', 'DK', '', 1, 4, 'SY BCA', 'B'),
('WT', 'DK', '', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', 'LAB-3', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', 'LAB-3', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', 'LAB-3', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', 'LAB-3', 1, 4, 'SY BCA', 'B'),
('OOC', 'GG', 'LAB-3', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'SPP', 'LAB-1', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('WD', 'RRD', 'LAB-2', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', 'LAB-5', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', 'LAB-5', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', 'LAB-5', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', 'LAB-5', 1, 4, 'SY BCA', 'B'),
('AM', 'SP', 'LAB-5', 1, 4, 'SY BCA', 'B'),
('CAD', 'SK', '', 1, 6, 'TY BCA', 'B'),
('CAD', 'SK', '', 1, 6, 'TY BCA', 'B'),
('CAD', 'SK', '', 1, 6, 'TY BCA', 'B'),
('CAD', 'SK', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'AES', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'AES', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'AES', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'AES', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'RRD', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'RRD', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'RRD', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'RRD', '', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', '', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', '', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', '', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', '', 1, 6, 'TY BCA', 'B'),
('CAC', 'AN', 'LAB-3', 1, 6, 'TY BCA', 'B'),
('CAC', 'AN', 'LAB-3', 1, 6, 'TY BCA', 'B'),
('CAC', 'AN', 'LAB-3', 1, 6, 'TY BCA', 'B'),
('CAC', 'AN', 'LAB-3', 1, 6, 'TY BCA', 'B'),
('CAD', 'SK', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAD', 'SK', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAD', 'SK', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAD', 'SK', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAD', 'AP', 'LAB-4', 1, 6, 'TY BCA', 'B'),
('CAC', 'DK', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'DK', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'DK', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'DK', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'AES', 'LAB-3', 1, 6, 'TY BCA', 'A'),
('CAC', 'AES', 'LAB-3', 1, 6, 'TY BCA', 'A'),
('CAC', 'AES', 'LAB-3', 1, 6, 'TY BCA', 'A'),
('CAC', 'AES', 'LAB-3', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-2', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-2', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-2', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-2', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', 'LAB-4', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', '', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', '', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', '', 1, 6, 'TY BCA', 'A'),
('CAD', 'RB', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'SAK', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'SAK', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'SAK', '', 1, 6, 'TY BCA', 'A'),
('CAC', 'SAK', '', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', '', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', '', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', '', 1, 6, 'TY BCA', 'A'),
('CAD', 'SPP', '', 1, 6, 'TY BCA', 'A');

-- --------------------------------------------------------

--
-- Table structure for table `timeslot`
--

CREATE TABLE `timeslot` (
  `timeslotID` int(11) NOT NULL,
  `timings` varchar(15) NOT NULL,
  `IsBreak` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `timeslot`
--

INSERT INTO `timeslot` (`timeslotID`, `timings`, `IsBreak`) VALUES
(1, '08:15 - 09:15', 0),
(2, '09:15 - 10:15', 0),
(3, '10:15 - 10:45', 1),
(4, '10:45 - 11:45', 0),
(5, '11:45 - 12:45', 0),
(6, '12:45 - 01:45', 0),
(7, '01:45 - 02:45', 0),
(8, '02:45 - 03:45', 0),
(9, '03:45 - 04:45', 0),
(10, '04:45 - 05:45', 0),
(11, '05:45 - 06:45', 0);

-- --------------------------------------------------------

--
-- Table structure for table `timetable`
--

CREATE TABLE `timetable` (
  `ID` int(11) NOT NULL,
  `Class` varchar(50) DEFAULT NULL,
  `ClassDivision` varchar(10) DEFAULT NULL,
  `DayOfWeek` varchar(20) DEFAULT NULL,
  `TimeSlot` int(11) DEFAULT NULL,
  `SubjectCode` varchar(20) DEFAULT NULL,
  `TeacherInitial` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `timetable`
--

INSERT INTO `timetable` (`ID`, `Class`, `ClassDivision`, `DayOfWeek`, `TimeSlot`, `SubjectCode`, `TeacherInitial`) VALUES
(48649, 'FY BCA', 'A', 'Monday', 1, '2D Animation', 'SAK'),
(48650, 'FY BCA', 'A', 'Tuesday', 1, '2D Animation', 'SAK'),
(48651, 'FY BCA', 'A', 'Wednesday', 1, '2D Animation', 'SAK'),
(48652, 'FY BCA', 'A', 'Thursday', 1, '2D Animation', 'SAK'),
(48653, 'FY BCA', 'A', 'Friday', 1, '2D Animation', 'SAK'),
(48654, 'FY BCA', 'A', 'Saturday', 1, 'CSF', 'SV'),
(48655, 'FY BCA', 'A', 'Monday', 2, 'CSF', 'SV'),
(48656, 'FY BCA', 'A', 'Tuesday', 2, 'CSF', 'SV'),
(48657, 'FY BCA', 'A', 'Wednesday', 2, 'CSF', 'SV'),
(48658, 'FY BCA', 'A', 'Thursday', 2, 'DCC', 'JP'),
(48659, 'FY BCA', 'A', 'Friday', 2, 'DCC', 'JP'),
(48660, 'FY BCA', 'A', 'Saturday', 2, 'DCC', 'JP'),
(48661, 'FY BCA', 'A', 'Monday', 3, 'DCC', 'JP'),
(48662, 'FY BCA', 'A', 'Tuesday', 3, 'E-Waste', 'NK'),
(48663, 'FY BCA', 'A', 'Wednesday', 3, 'E-Waste', 'NK'),
(48664, 'FY BCA', 'A', 'Thursday', 3, 'FM', 'YJ'),
(48665, 'FY BCA', 'A', 'Friday', 3, 'FM', 'YJ'),
(48666, 'FY BCA', 'A', 'Saturday', 3, 'FM', 'YJ'),
(48667, 'FY BCA', 'A', 'Monday', 4, 'FM', 'YJ'),
(48668, 'FY BCA', 'A', 'Tuesday', 4, 'FM', 'YJ'),
(48669, 'FY BCA', 'A', 'Wednesday', 4, 'FM', 'YJ'),
(48670, 'FY BCA', 'A', 'Thursday', 4, 'FM', 'YJ'),
(48671, 'FY BCA', 'A', 'Friday', 4, 'Life Skill', 'VK'),
(48672, 'FY BCA', 'A', 'Saturday', 4, 'Life Skill', 'VK'),
(48673, 'FY BCA', 'A', 'Monday', 5, '2D Animation LAB-1', ' SAK'),
(48674, 'FY BCA', 'A', 'Monday', 6, '2D Animation LAB-1', ' SAK'),
(48675, 'FY BCA', 'A', 'Tuesday', 5, '2D Animation LAB-1', ' SAK'),
(48676, 'FY BCA', 'A', 'Tuesday', 6, '2D Animation LAB-1', ' SAK'),
(48677, 'FY BCA', 'A', 'Wednesday', 5, '2D Animation LAB-1', ' SAK'),
(48678, 'FY BCA', 'A', 'Wednesday', 6, '2D Animation LAB-1', ' SAK'),
(48679, 'FY BCA', 'A', 'Thursday', 5, '2D Animation LAB-1', 'SAK'),
(48680, 'FY BCA', 'A', 'Thursday', 6, '2D Animation LAB-1', 'SAK'),
(48681, 'FY BCA', 'A', 'Friday', 5, '2D Animation LAB-1', 'SAK'),
(48682, 'FY BCA', 'A', 'Friday', 6, '2D Animation LAB-1', 'SAK'),
(48683, 'FY BCA', 'A', 'Saturday', 5, '2D Animation LAB-1', 'SAK'),
(48684, 'FY BCA', 'A', 'Saturday', 6, '2D Animation LAB-1', 'SAK'),
(48685, 'FY BCA', 'A', 'Monday', 7, '2D Animation LAB-3', 'SAK'),
(48686, 'FY BCA', 'A', 'Monday', 8, '2D Animation LAB-3', 'SAK'),
(48687, 'FY BCA', 'A', 'Tuesday', 7, '2D Animation LAB-3', 'SAK'),
(48688, 'FY BCA', 'A', 'Tuesday', 8, '2D Animation LAB-3', 'SAK'),
(48689, 'FY BCA', 'A', 'Wednesday', 7, '2D Animation LAB-3', 'SAK'),
(48690, 'FY BCA', 'A', 'Wednesday', 8, '2D Animation LAB-3', 'SAK'),
(48691, 'FY BCA', 'B', 'Monday', 1, 'CSF', 'AR'),
(48692, 'FY BCA', 'B', 'Tuesday', 1, 'CSF', 'AR'),
(48693, 'FY BCA', 'B', 'Wednesday', 1, 'CSF', 'AR'),
(48694, 'FY BCA', 'B', 'Thursday', 1, 'CSF', 'AR'),
(48695, 'FY BCA', 'B', 'Friday', 1, 'DCC', 'JP'),
(48696, 'FY BCA', 'B', 'Saturday', 1, 'DCC', 'JP'),
(48697, 'FY BCA', 'B', 'Monday', 2, 'E-Waste', 'NK'),
(48698, 'FY BCA', 'B', 'Tuesday', 2, 'E-Waste', 'NK'),
(48699, 'FY BCA', 'B', 'Wednesday', 2, 'FM', 'YJ'),
(48700, 'FY BCA', 'B', 'Thursday', 2, 'FM', 'YJ'),
(48701, 'FY BCA', 'B', 'Friday', 2, 'FM', 'YJ'),
(48702, 'FY BCA', 'B', 'Saturday', 2, 'FM', 'YJ'),
(48703, 'FY BCA', 'B', 'Monday', 3, 'FM', 'YJ'),
(48704, 'FY BCA', 'B', 'Tuesday', 3, 'FM', 'YJ'),
(48705, 'FY BCA', 'B', 'Wednesday', 3, 'FM', 'YJ'),
(48706, 'FY BCA', 'B', 'Thursday', 3, 'Life Skill', 'VK'),
(48707, 'FY BCA', 'B', 'Friday', 3, 'Life Skill', 'VK'),
(48708, 'FY BCA', 'B', 'Saturday', 3, 'MM', 'VK'),
(48709, 'FY BCA', 'B', 'Monday', 4, 'MM', 'VK'),
(48710, 'FY BCA', 'B', 'Tuesday', 4, 'MM', 'VK'),
(48711, 'FY BCA', 'B', 'Wednesday', 4, 'DAS LAB-3', 'GG'),
(48712, 'FY BCA', 'B', 'Wednesday', 5, 'DAS LAB-3', 'GG'),
(48713, 'FY BCA', 'B', 'Thursday', 4, 'DAS LAB-3', 'GG'),
(48714, 'FY BCA', 'B', 'Thursday', 5, 'DAS LAB-3', 'GG'),
(48715, 'FY BCA', 'B', 'Friday', 4, 'DAS LAB-3', 'GG'),
(48716, 'FY BCA', 'B', 'Friday', 5, 'DAS LAB-3', 'GG'),
(48717, 'FY BCA', 'B', 'Saturday', 4, 'DAS LAB-3', 'GG'),
(48718, 'FY BCA', 'B', 'Saturday', 5, 'DAS LAB-3', 'GG'),
(48719, 'SY BCA', 'A', 'Monday', 1, 'AM', 'AR'),
(48720, 'SY BCA', 'A', 'Tuesday', 1, 'AM', 'AR'),
(48721, 'SY BCA', 'A', 'Wednesday', 1, 'AM', 'AR'),
(48722, 'SY BCA', 'A', 'Thursday', 1, 'AM', 'AR'),
(48723, 'SY BCA', 'A', 'Friday', 1, 'AM', 'AR'),
(48724, 'SY BCA', 'A', 'Saturday', 1, 'DA', 'DK'),
(48725, 'SY BCA', 'A', 'Monday', 2, 'DA', 'DK'),
(48726, 'SY BCA', 'A', 'Tuesday', 2, 'DA', 'DK'),
(48727, 'SY BCA', 'A', 'Wednesday', 2, 'DA', 'DK'),
(48728, 'SY BCA', 'A', 'Thursday', 2, 'DA', 'DK'),
(48729, 'SY BCA', 'A', 'Friday', 2, 'Hindi', 'SUP'),
(48730, 'SY BCA', 'A', 'Saturday', 2, 'Hindi', 'SUP'),
(48731, 'SY BCA', 'A', 'Monday', 3, 'OOC', 'AN'),
(48732, 'SY BCA', 'A', 'Tuesday', 3, 'OOC', 'AN'),
(48733, 'SY BCA', 'A', 'Wednesday', 3, 'OOC', 'AN'),
(48734, 'SY BCA', 'A', 'Thursday', 3, 'OOC', 'AN'),
(48735, 'SY BCA', 'A', 'Friday', 3, 'OOC', 'AN'),
(48736, 'SY BCA', 'A', 'Saturday', 3, 'WT', 'AP'),
(48737, 'SY BCA', 'A', 'Monday', 4, 'WT', 'AP'),
(48738, 'SY BCA', 'A', 'Tuesday', 4, 'WD LAB-1', 'AA'),
(48739, 'SY BCA', 'A', 'Tuesday', 5, 'WD LAB-1', 'AA'),
(48740, 'SY BCA', 'A', 'Wednesday', 4, 'WD LAB-1', 'AA'),
(48741, 'SY BCA', 'A', 'Wednesday', 5, 'WD LAB-1', 'AA'),
(48742, 'SY BCA', 'A', 'Thursday', 4, 'WD LAB-1', 'AA'),
(48743, 'SY BCA', 'A', 'Thursday', 5, 'WD LAB-1', 'AA'),
(48744, 'SY BCA', 'A', 'Friday', 4, 'WD LAB-1', 'AA'),
(48745, 'SY BCA', 'A', 'Friday', 5, 'WD LAB-1', 'AA'),
(48746, 'SY BCA', 'A', 'Saturday', 4, 'WD LAB-2', 'RR'),
(48747, 'SY BCA', 'A', 'Saturday', 5, 'WD LAB-2', 'RR'),
(48748, 'SY BCA', 'A', 'Monday', 5, 'WD LAB-2', 'RR'),
(48749, 'SY BCA', 'A', 'Monday', 6, 'WD LAB-2', 'RR'),
(48750, 'SY BCA', 'A', 'Tuesday', 6, 'WD LAB-2', 'RR'),
(48751, 'SY BCA', 'A', 'Tuesday', 7, 'WD LAB-2', 'RR'),
(48752, 'SY BCA', 'A', 'Wednesday', 6, 'WD LAB-2', 'RR'),
(48753, 'SY BCA', 'A', 'Wednesday', 7, 'WD LAB-2', 'RR'),
(48754, 'SY BCA', 'A', 'Thursday', 6, 'DA LAB-5', 'DK'),
(48755, 'SY BCA', 'A', 'Thursday', 7, 'DA LAB-5', 'DK'),
(48756, 'SY BCA', 'A', 'Friday', 6, 'DA LAB-5', 'DK'),
(48757, 'SY BCA', 'A', 'Friday', 7, 'DA LAB-5', 'DK'),
(48758, 'SY BCA', 'A', 'Saturday', 6, 'DA LAB-5', 'DK'),
(48759, 'SY BCA', 'A', 'Saturday', 7, 'DA LAB-5', 'DK'),
(48760, 'SY BCA', 'A', 'Monday', 7, 'OOC LAB-5', 'AN'),
(48761, 'SY BCA', 'A', 'Monday', 8, 'OOC LAB-5', 'AN'),
(48762, 'SY BCA', 'A', 'Tuesday', 8, 'OOC LAB-5', 'AN'),
(48763, 'SY BCA', 'A', 'Tuesday', 9, 'OOC LAB-5', 'AN'),
(48764, 'SY BCA', 'A', 'Wednesday', 8, 'OOC LAB-5', 'AN'),
(48765, 'SY BCA', 'A', 'Wednesday', 9, 'OOC LAB-5', 'AN'),
(48766, 'SY BCA', 'B', 'Monday', 1, 'AM', 'SP'),
(48767, 'SY BCA', 'B', 'Tuesday', 1, 'AM', 'SP'),
(48768, 'SY BCA', 'B', 'Wednesday', 1, 'AM', 'SP'),
(48769, 'SY BCA', 'B', 'Thursday', 1, 'AM', 'SP'),
(48770, 'SY BCA', 'B', 'Friday', 1, 'AM', 'SP'),
(48771, 'SY BCA', 'B', 'Saturday', 1, 'Konkani', 'CPV'),
(48772, 'SY BCA', 'B', 'Monday', 2, 'Konkani', 'CPV'),
(48773, 'SY BCA', 'B', 'Tuesday', 2, 'OOC', 'GG'),
(48774, 'SY BCA', 'B', 'Wednesday', 2, 'OOC', 'GG'),
(48775, 'SY BCA', 'B', 'Thursday', 2, 'OOC', 'GG'),
(48776, 'SY BCA', 'B', 'Friday', 2, 'OOC', 'GG'),
(48777, 'SY BCA', 'B', 'Saturday', 2, 'OOC', 'GG'),
(48778, 'SY BCA', 'B', 'Monday', 3, 'WD', 'SPP'),
(48779, 'SY BCA', 'B', 'Tuesday', 3, 'WD', 'SPP'),
(48780, 'SY BCA', 'B', 'Wednesday', 3, 'WD', 'SPP'),
(48781, 'SY BCA', 'B', 'Thursday', 3, 'WD', 'SPP'),
(48782, 'SY BCA', 'B', 'Friday', 3, 'WD', 'SPP'),
(48783, 'SY BCA', 'B', 'Saturday', 3, 'WD', 'SPP'),
(48784, 'SY BCA', 'B', 'Monday', 4, 'WD', 'SPP'),
(48785, 'SY BCA', 'B', 'Tuesday', 4, 'WD', 'SPP'),
(48786, 'SY BCA', 'B', 'Wednesday', 4, 'WT', 'DK'),
(48787, 'SY BCA', 'B', 'Thursday', 4, 'WT', 'DK'),
(48788, 'SY BCA', 'B', 'Friday', 4, 'WD LAB-1', 'SPP'),
(48789, 'SY BCA', 'B', 'Friday', 5, 'WD LAB-1', 'SPP'),
(48790, 'SY BCA', 'B', 'Saturday', 4, 'WD LAB-1', 'SPP'),
(48791, 'SY BCA', 'B', 'Saturday', 5, 'WD LAB-1', 'SPP'),
(48792, 'SY BCA', 'B', 'Monday', 5, 'WD LAB-1', 'SPP'),
(48793, 'SY BCA', 'B', 'Monday', 6, 'WD LAB-1', 'SPP'),
(48794, 'SY BCA', 'B', 'Tuesday', 5, 'WD LAB-1', 'SPP'),
(48795, 'SY BCA', 'B', 'Tuesday', 6, 'WD LAB-1', 'SPP'),
(48796, 'SY BCA', 'B', 'Wednesday', 5, 'WD LAB-2', 'RRD'),
(48797, 'SY BCA', 'B', 'Wednesday', 6, 'WD LAB-2', 'RRD'),
(48798, 'SY BCA', 'B', 'Thursday', 5, 'WD LAB-2', 'RRD'),
(48799, 'SY BCA', 'B', 'Thursday', 6, 'WD LAB-2', 'RRD'),
(48800, 'SY BCA', 'B', 'Friday', 6, 'WD LAB-2', 'RRD'),
(48801, 'SY BCA', 'B', 'Friday', 7, 'WD LAB-2', 'RRD'),
(48802, 'SY BCA', 'B', 'Saturday', 6, 'WD LAB-2', 'RRD'),
(48803, 'SY BCA', 'B', 'Saturday', 7, 'WD LAB-2', 'RRD'),
(48804, 'SY BCA', 'B', 'Monday', 7, 'OOC LAB-3', 'GG'),
(48805, 'SY BCA', 'B', 'Monday', 8, 'OOC LAB-3', 'GG'),
(48806, 'SY BCA', 'B', 'Tuesday', 7, 'OOC LAB-3', 'GG'),
(48807, 'SY BCA', 'B', 'Tuesday', 8, 'OOC LAB-3', 'GG'),
(48808, 'SY BCA', 'B', 'Wednesday', 7, 'OOC LAB-3', 'GG'),
(48809, 'SY BCA', 'B', 'Wednesday', 8, 'OOC LAB-3', 'GG'),
(48810, 'SY BCA', 'B', 'Thursday', 7, 'AJS LAB-4', 'SRV'),
(48811, 'SY BCA', 'B', 'Thursday', 8, 'AJS LAB-4', 'SRV'),
(48812, 'SY BCA', 'B', 'Friday', 8, 'AJS LAB-4', 'SRV'),
(48813, 'SY BCA', 'B', 'Friday', 9, 'AJS LAB-4', 'SRV'),
(48814, 'SY BCA', 'B', 'Saturday', 8, 'AJS LAB-4', 'SRV'),
(48815, 'SY BCA', 'B', 'Saturday', 9, 'AJS LAB-4', 'SRV'),
(48816, 'SY BCA', 'B', 'Monday', 9, 'AM LAB-5', 'SP'),
(48817, 'SY BCA', 'B', 'Monday', 10, 'AM LAB-5', 'SP'),
(48818, 'SY BCA', 'B', 'Tuesday', 9, 'AM LAB-5', 'SP'),
(48819, 'SY BCA', 'B', 'Tuesday', 10, 'AM LAB-5', 'SP'),
(48820, 'SY BCA', 'B', 'Wednesday', 9, 'AM LAB-5', 'SP'),
(48821, 'SY BCA', 'B', 'Wednesday', 10, 'AM LAB-5', 'SP'),
(48822, 'SY BVOC', '', 'Monday', 1, 'CT', 'AR'),
(48823, 'SY BVOC', '', 'Tuesday', 1, 'CT', 'AR'),
(48824, 'SY BVOC', '', 'Wednesday', 1, 'CT', 'AR'),
(48825, 'SY BVOC', '', 'Thursday', 1, 'CT', 'AR'),
(48826, 'SY BVOC', '', 'Friday', 1, 'DTP', 'AP'),
(48827, 'SY BVOC', '', 'Saturday', 1, 'DTP', 'AP'),
(48828, 'SY BVOC', '', 'Monday', 2, 'DTP', 'AP'),
(48829, 'SY BVOC', '', 'Tuesday', 2, 'DTP', 'AP'),
(48830, 'SY BVOC', '', 'Wednesday', 2, 'DTP', 'SG'),
(48831, 'SY BVOC', '', 'Thursday', 2, 'DTP', 'SG'),
(48832, 'SY BVOC', '', 'Friday', 2, 'DTP', 'SG'),
(48833, 'SY BVOC', '', 'Saturday', 2, 'DTP', 'SG'),
(48834, 'SY BVOC', '', 'Monday', 3, 'PY', 'SP'),
(48835, 'SY BVOC', '', 'Tuesday', 3, 'PY', 'SP'),
(48836, 'SY BVOC', '', 'Wednesday', 3, 'PY', 'SP'),
(48837, 'SY BVOC', '', 'Thursday', 3, 'SE & T', 'SAK'),
(48838, 'SY BVOC', '', 'Friday', 3, 'SE & T', 'SAK'),
(48839, 'SY BVOC', '', 'Saturday', 3, 'SE & T', 'SAK'),
(48840, 'SY BVOC', '', 'Monday', 4, 'SL-4 LAB-1', 'AES'),
(48841, 'SY BVOC', '', 'Monday', 5, 'SL-4 LAB-1', 'AES'),
(48842, 'SY BVOC', '', 'Tuesday', 4, 'SL-4 LAB-2', 'SP'),
(48843, 'SY BVOC', '', 'Tuesday', 5, 'SL-4 LAB-2', 'SP'),
(48844, 'SY BVOC', '', 'Wednesday', 4, 'DTP LAB-4', 'SG'),
(48845, 'SY BVOC', '', 'Wednesday', 5, 'DTP LAB-4', 'SG'),
(48846, 'SY BVOC', '', 'Thursday', 4, 'DTP LAB-4', 'SG'),
(48847, 'SY BVOC', '', 'Thursday', 5, 'DTP LAB-4', 'SG'),
(48848, 'TY BCA', 'A', 'Monday', 1, 'CAC', 'DK'),
(48849, 'TY BCA', 'A', 'Tuesday', 1, 'CAC', 'DK'),
(48850, 'TY BCA', 'A', 'Wednesday', 1, 'CAC', 'DK'),
(48851, 'TY BCA', 'A', 'Thursday', 1, 'CAC', 'DK'),
(48852, 'TY BCA', 'A', 'Friday', 1, 'CAC', 'SAK'),
(48853, 'TY BCA', 'A', 'Saturday', 1, 'CAC', 'SAK'),
(48854, 'TY BCA', 'A', 'Monday', 2, 'CAC', 'SAK'),
(48855, 'TY BCA', 'A', 'Tuesday', 2, 'CAC', 'SAK'),
(48856, 'TY BCA', 'A', 'Wednesday', 2, 'CAD', 'RB'),
(48857, 'TY BCA', 'A', 'Thursday', 2, 'CAD', 'RB'),
(48858, 'TY BCA', 'A', 'Friday', 2, 'CAD', 'RB'),
(48859, 'TY BCA', 'A', 'Saturday', 2, 'CAD', 'RB'),
(48860, 'TY BCA', 'A', 'Monday', 3, 'CAD', 'SPP'),
(48861, 'TY BCA', 'A', 'Tuesday', 3, 'CAD', 'SPP'),
(48862, 'TY BCA', 'A', 'Wednesday', 3, 'CAD', 'SPP'),
(48863, 'TY BCA', 'A', 'Thursday', 3, 'CAD', 'SPP'),
(48864, 'TY BCA', 'A', 'Friday', 3, 'CAD LAB-2', 'SPP'),
(48865, 'TY BCA', 'A', 'Friday', 4, 'CAD LAB-2', 'SPP'),
(48866, 'TY BCA', 'A', 'Saturday', 3, 'CAD LAB-2', 'SPP'),
(48867, 'TY BCA', 'A', 'Saturday', 4, 'CAD LAB-2', 'SPP'),
(48868, 'TY BCA', 'A', 'Monday', 4, 'CAC LAB-3', 'AES'),
(48869, 'TY BCA', 'A', 'Monday', 5, 'CAC LAB-3', 'AES'),
(48870, 'TY BCA', 'A', 'Tuesday', 4, 'CAC LAB-3', 'AES'),
(48871, 'TY BCA', 'A', 'Tuesday', 5, 'CAC LAB-3', 'AES'),
(48872, 'TY BCA', 'A', 'Wednesday', 4, 'CAD LAB-4', 'RB'),
(48873, 'TY BCA', 'A', 'Wednesday', 5, 'CAD LAB-4', 'RB'),
(48874, 'TY BCA', 'A', 'Thursday', 4, 'CAD LAB-4', 'RB'),
(48875, 'TY BCA', 'A', 'Thursday', 5, 'CAD LAB-4', 'RB'),
(48876, 'TY BCA', 'A', 'Friday', 5, 'CAD LAB-4', 'SPP'),
(48877, 'TY BCA', 'A', 'Friday', 6, 'CAD LAB-4', 'SPP'),
(48878, 'TY BCA', 'A', 'Saturday', 5, 'CAD LAB-4', 'SPP'),
(48879, 'TY BCA', 'A', 'Saturday', 6, 'CAD LAB-4', 'SPP'),
(48880, 'TY BCA', 'B', 'Monday', 1, 'CAC', 'AES'),
(48881, 'TY BCA', 'B', 'Tuesday', 1, 'CAC', 'AES'),
(48882, 'TY BCA', 'B', 'Wednesday', 1, 'CAC', 'AES'),
(48883, 'TY BCA', 'B', 'Thursday', 1, 'CAC', 'AES'),
(48884, 'TY BCA', 'B', 'Friday', 1, 'CAC', 'RRD'),
(48885, 'TY BCA', 'B', 'Saturday', 1, 'CAC', 'RRD'),
(48886, 'TY BCA', 'B', 'Monday', 2, 'CAC', 'RRD'),
(48887, 'TY BCA', 'B', 'Tuesday', 2, 'CAC', 'RRD'),
(48888, 'TY BCA', 'B', 'Wednesday', 2, 'CAD', 'AP'),
(48889, 'TY BCA', 'B', 'Thursday', 2, 'CAD', 'AP'),
(48890, 'TY BCA', 'B', 'Friday', 2, 'CAD', 'AP'),
(48891, 'TY BCA', 'B', 'Saturday', 2, 'CAD', 'AP'),
(48892, 'TY BCA', 'B', 'Monday', 3, 'CAD', 'SK'),
(48893, 'TY BCA', 'B', 'Tuesday', 3, 'CAD', 'SK'),
(48894, 'TY BCA', 'B', 'Wednesday', 3, 'CAD', 'SK'),
(48895, 'TY BCA', 'B', 'Thursday', 3, 'CAD', 'SK'),
(48896, 'TY BCA', 'B', 'Friday', 3, 'CAC LAB-3', 'AN'),
(48897, 'TY BCA', 'B', 'Friday', 4, 'CAC LAB-3', 'AN'),
(48898, 'TY BCA', 'B', 'Saturday', 3, 'CAC LAB-3', 'AN'),
(48899, 'TY BCA', 'B', 'Saturday', 4, 'CAC LAB-3', 'AN'),
(48900, 'TY BCA', 'B', 'Monday', 4, 'CAD LAB-4', 'AP'),
(48901, 'TY BCA', 'B', 'Monday', 5, 'CAD LAB-4', 'AP'),
(48902, 'TY BCA', 'B', 'Tuesday', 4, 'CAD LAB-4', 'AP'),
(48903, 'TY BCA', 'B', 'Tuesday', 5, 'CAD LAB-4', 'AP'),
(48904, 'TY BCA', 'B', 'Wednesday', 4, 'CAD LAB-4', 'SK'),
(48905, 'TY BCA', 'B', 'Wednesday', 5, 'CAD LAB-4', 'SK'),
(48906, 'TY BCA', 'B', 'Thursday', 4, 'CAD LAB-4', 'SK'),
(48907, 'TY BCA', 'B', 'Thursday', 5, 'CAD LAB-4', 'SK');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `class`
--
ALTER TABLE `class`
  ADD PRIMARY KEY (`classNo`);

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`courseID`),
  ADD KEY `semester_fk` (`semesterID`),
  ADD KEY `programme_fk` (`programmeID`);

--
-- Indexes for table `coursealloc`
--
ALTER TABLE `coursealloc`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `programme`
--
ALTER TABLE `programme`
  ADD PRIMARY KEY (`programmeID`);

--
-- Indexes for table `semester`
--
ALTER TABLE `semester`
  ADD PRIMARY KEY (`semesterID`);

--
-- Indexes for table `teacher`
--
ALTER TABLE `teacher`
  ADD PRIMARY KEY (`teacherID`);

--
-- Indexes for table `timeslot`
--
ALTER TABLE `timeslot`
  ADD PRIMARY KEY (`timeslotID`);

--
-- Indexes for table `timetable`
--
ALTER TABLE `timetable`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `coursealloc`
--
ALTER TABLE `coursealloc`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=153;

--
-- AUTO_INCREMENT for table `programme`
--
ALTER TABLE `programme`
  MODIFY `programmeID` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `teacher`
--
ALTER TABLE `teacher`
  MODIFY `teacherID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `timeslot`
--
ALTER TABLE `timeslot`
  MODIFY `timeslotID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `timetable`
--
ALTER TABLE `timetable`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48908;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
