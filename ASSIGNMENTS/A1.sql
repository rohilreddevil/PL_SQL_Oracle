---------------------------
-- Assignment 1 - Group #5
-- 
-- Members:
-- Nicholas Defranco
-- Rohil Kalpesh Khakhar
-- Philip Mroczkowski
-- Raymond Rambo
---------------------------

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-------------------
-- Question 1
-------------------

VARIABLE b_loc_id NUMBER;

ACCEPT code PROMPT 'Enter value for country: ';
DECLARE
    v_city_name  locations.city%TYPE;
    v_prov       locations.state_province%TYPE;
    v_ch         CHAR;
    v_flag       INTEGER := 0;
    v_length     PLS_INTEGER;
BEGIN

    BEGIN
        SELECT 1 INTO v_flag
            FROM countries
            WHERE upper(country_id) = upper('&code');
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('This country code does NOT exist');
    END;
    
    IF v_flag = 1 THEN
        SELECT location_id, length(street_address), upper(city)
            INTO :b_loc_id, v_length, v_city_name
            FROM locations
            WHERE state_province IS NULL
                AND upper(country_id) = upper('&code');
                
        v_ch := substr(v_city_name, 1, 1);
        
        v_ch := CASE 
            WHEN v_ch IN ('A', 'B', 'E', 'F') THEN '*'
            WHEN v_ch IN ('C', 'D', 'G', 'H') THEN '&'
            ELSE '#'
            END;
        
        FOR i in 1..v_length LOOP
            v_prov := v_prov || v_ch;
        END LOOP;
        
        UPDATE locations
            SET state_province = v_prov
            WHERE location_id = :b_loc_id;
        
        DBMS_OUTPUT.PUT_LINE('City ' || v_city_name || ' has modified its province to ' || v_prov);
    END IF;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('This country has NO cities listed.');
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('This country has MORE THAN ONE City without province listed.');
END;
/

/*
Upon executing this SELECT statement, it will prompt for the
value of the bind variable. However, I wanted it to take on the
value recieved from the query within the PL/SQL block and use
that within the query.
I unfortunately could not figure out how to do that.
*/

-- NOTES:
-- First test case b_loc_id should be 1300
-- Second test case b_loc_id should be 2400
-- Third and fourth test cases b_loc_id should be null
SELECT *
    FROM locations
    WHERE location_id = :b_loc_id;


ROLLBACK;

/*
Output 1:
Enter value for country: JP 
City HIROSHIMA has modified its province to &&&&&&&&&&&&&&&


PL/SQL procedure successfully completed.

1300	9450 Kamiya-cho	6823	Hiroshima	&&&&&&&&&&&&&&&	JP

Rollback complete.

Output 2:
Enter value for country: UK
City LONDON has modified its province to ##############


PL/SQL procedure successfully completed.

2400	8204 Arthur St		London	##############	UK

Rollback complete.

Output 3:
Enter value for country: IT
This country has MORE THAN ONE City without province listed.


PL/SQL procedure successfully completed.

no rows selected

Rollback complete.

Output 4:

This country code does NOT exist


PL/SQL procedure successfully completed.

no rows selected

Rollback complete.
*/

--------------------
-- Question 2
--------------------


DECLARE
    column_exists EXCEPTION;
    PRAGMA exception_init (column_exists , -01430);
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE countries ADD flag CHAR(7)';
    EXCEPTION
        WHEN column_exists THEN NULL;
END;
/

ACCEPT id PROMPT 'Enter value for region: ';
DECLARE
    v_c_id      countries.country_id%TYPE;
    v_c_name    countries.country_name%TYPE;
    v_flag      countries.flag%TYPE;
    v_loopc     BINARY_INTEGER := 0;
    v_exists    INTEGER := 0;
BEGIN

    -- check existance for a region id...
    BEGIN
        SELECT 1 INTO v_exists
            FROM regions
            WHERE region_id = &id;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('This region ID has does NOT exist: ' || &id);
    END;
    
    IF v_exists = 1 THEN
        -- This used to be your cursor.
        SELECT c.country_id, country_name
        INTO v_c_id, v_c_name
        FROM countries c LEFT JOIN locations l
            ON c.country_id = l.country_id
        WHERE region_id = &id
            AND city IS NULL;
            
        DBMS_OUTPUT.PUT_LINE('In the region ' || &id || ' there is ONE country ' || v_c_name || ' with NO city');    
            
        FOR rec_countries IN (
        
                SELECT c.country_id, c.region_id
                    FROM countries c LEFT JOIN locations l
                        ON c.country_id = l.country_id
                    WHERE l.city IS NULL
                    
            )
        LOOP
            
            v_flag :='Empty_' || rec_countries.region_id;
            
            UPDATE countries 
                SET flag = v_flag 
                WHERE country_id = rec_countries.country_id;
            
            v_loopc := v_loopc + 1;
            
        END LOOP;
    
        DBMS_OUTPUT.PUT_LINE('Number of countries with NO cities listed is: ' || v_loopc);
        
    END IF;
    
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('This region ID has MORE THAN ONE country without cities listed: ' || &id);
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('There are no countries listed in this region that do not have a city: ' || &id);
END;
/

SELECT *
    FROM countries
    WHERE flag IS NOT NULL
    ORDER BY region_id;--, country_name; 
    
-- Instructions specify to have a minor sorting key of country name
-- but it does not match the test case.

ROLLBACK;

/*
Output 1:

PL/SQL procedure successfully completed.

Enter value for region: 5
This region ID has does NOT exist: 5


PL/SQL procedure successfully completed.

no rows selected

Rollback complete.


Output 2:

PL/SQL procedure successfully completed.

Enter value for region: 1
This region ID has MORE THAN ONE country without cities listed: 1


PL/SQL procedure successfully completed.

no rows selected

Rollback complete.


Output 3:

PL/SQL procedure successfully completed.

Enter value for region: 2
In the region 2 there is ONE country Argentina with NO city
Number of countries with NO cities listed is: 11


PL/SQL procedure successfully completed.

BE	Belgium	1	Empty_1
DK	Denmark	1	Empty_1
FR	France	1	Empty_1
AR	Argentina	2	Empty_2
HK	HongKong	3	Empty_3
ZW	Zimbabwe	4	Empty_4
IL	Israel	4	Empty_4
KW	Kuwait	4	Empty_4
NG	Nigeria	4	Empty_4
ZM	Zambia	4	Empty_4
EG	Egypt	4	Empty_4

Rollback complete.
*/

------------------
-- Question 3
------------------


ACCEPT id PROMPT 'Enter value for region: ';
DECLARE
    
    CURSOR cur_countries IS
        SELECT region_id, country_name
        FROM countries c LEFT JOIN locations l
            ON c.country_id = l.country_id
        WHERE location_id IS NULL 
        ORDER BY country_name
        FOR UPDATE OF flag NOWAIT;
    
    TYPE country_name_type IS TABLE OF
        cur_countries%ROWTYPE
        INDEX BY PLS_INTEGER;
        
    c_increase_by       CONSTANT PLS_INTEGER := 10;
    alpha_countries_tab country_name_type;
    v_exists            BOOLEAN := FALSE;
        
BEGIN

    DECLARE
        CURSOR check_cur(r_id regions.region_id%TYPE) IS
            SELECT region_id
                FROM regions
                WHERE region_id = r_id;
                
        tmp     regions.region_id%TYPE;
    BEGIN 
        OPEN check_cur(&id);
        FETCH check_cur INTO tmp;
        v_exists := check_cur%FOUND;
        CLOSE check_cur;
    END;

    IF v_exists THEN
        DECLARE
            i                     PLS_INTEGER := c_increase_by;
        BEGIN
            FOR rec_countries IN cur_countries LOOP
                alpha_countries_tab(i).country_name := rec_countries.country_name;
                alpha_countries_tab(i).region_id := rec_countries.region_id;
                UPDATE countries
                    SET flag = 'EMPTY_' || rec_countries.region_id
                    WHERE CURRENT OF cur_countries;
                DBMS_OUTPUT.PUT_LINE('Index Table Key: ' || i || ' has a value of ' || alpha_countries_tab(i).country_name);
                i := i + c_increase_by;
            END LOOP;
        END;
        DBMS_OUTPUT.PUT_LINE('======================================================================');
        DBMS_OUTPUT.PUT_LINE('Total number of elements in the Index Table or Number of countries with NO cities listed is: ' || alpha_countries_tab.count());
        DBMS_OUTPUT.PUT_LINE('Second element (Country) in the Index Table is: ' || to_char(alpha_countries_tab(alpha_countries_tab.next(alpha_countries_tab.first())).country_name));
        DBMS_OUTPUT.PUT_LINE('Before the last element (Country) in the Index Table is: ' || to_char(alpha_countries_tab(alpha_countries_tab.prior(alpha_countries_tab.last())).country_name));
        DBMS_OUTPUT.PUT_LINE('======================================================================');
        DECLARE
            v_num_no_city         PLS_INTEGER := 0;
        BEGIN
            FOR i IN 1..alpha_countries_tab.count() LOOP
                IF alpha_countries_tab(i * c_increase_by).region_id = &id THEN
                    DBMS_OUTPUT.PUT_LINE('In the region ' || &id || ' there is country ' || alpha_countries_tab(i * c_increase_by).country_name || ' with NO city.');
                    v_num_no_city := v_num_no_city + 1;
                END IF;
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('======================================================================');
            DBMS_OUTPUT.PUT_LINE('Total Number of countries with NO cities listed in the Region ' || &id || ' is: ' || v_num_no_city);
        END;
    ELSE
        DBMS_OUTPUT.PUT_LINE('This region ID has does NOT exist: ' || &id);
    END IF;
    
END;
/

SELECT *
    FROM countries
    WHERE flag IS NOT NULL
    ORDER BY region_id, country_name;

ROLLBACK;

/*
Output 1:

Enter value for region: 5
This region ID has does NOT exist: 5


PL/SQL procedure successfully completed.

no rows selected

Rollback complete.

Output 2:

Enter value for region: 1
Index Table Key: 10 has a value of Argentina
Index Table Key: 20 has a value of Belgium
Index Table Key: 30 has a value of Denmark
Index Table Key: 40 has a value of Egypt
Index Table Key: 50 has a value of France
Index Table Key: 60 has a value of HongKong
Index Table Key: 70 has a value of Israel
Index Table Key: 80 has a value of Kuwait
Index Table Key: 90 has a value of Nigeria
Index Table Key: 100 has a value of Zambia
Index Table Key: 110 has a value of Zimbabwe
======================================================================
Total number of elements in the Index Table or Number of countries with NO cities listed is: 11
Second element (Country) in the Index Table is: Belgium
Before the last element (Country) in the Index Table is: Zambia
======================================================================
In the region 1 there is country Belgium with NO city.
In the region 1 there is country Denmark with NO city.
In the region 1 there is country France with NO city.
======================================================================
Total Number of countries with NO cities listed in the Region 1 is: 3


PL/SQL procedure successfully completed.

BE	Belgium	1	EMPTY_1
DK	Denmark	1	EMPTY_1
FR	France	1	EMPTY_1
AR	Argentina	2	EMPTY_2
HK	HongKong	3	EMPTY_3
EG	Egypt	4	EMPTY_4
IL	Israel	4	EMPTY_4
KW	Kuwait	4	EMPTY_4
NG	Nigeria	4	EMPTY_4
ZM	Zambia	4	EMPTY_4
ZW	Zimbabwe	4	EMPTY_4

Rollback complete.


Output 3:

Enter value for region: 2
Index Table Key: 10 has a value of Argentina
Index Table Key: 20 has a value of Belgium
Index Table Key: 30 has a value of Denmark
Index Table Key: 40 has a value of Egypt
Index Table Key: 50 has a value of France
Index Table Key: 60 has a value of HongKong
Index Table Key: 70 has a value of Israel
Index Table Key: 80 has a value of Kuwait
Index Table Key: 90 has a value of Nigeria
Index Table Key: 100 has a value of Zambia
Index Table Key: 110 has a value of Zimbabwe
======================================================================
Total number of elements in the Index Table or Number of countries with NO cities listed is: 11
Second element (Country) in the Index Table is: Belgium
Before the last element (Country) in the Index Table is: Zambia
======================================================================
In the region 2 there is country Argentina with NO city.
======================================================================
Total Number of countries with NO cities listed in the Region 2 is: 1


PL/SQL procedure successfully completed.

BE	Belgium	1	EMPTY_1
DK	Denmark	1	EMPTY_1
FR	France	1	EMPTY_1
AR	Argentina	2	EMPTY_2
HK	HongKong	3	EMPTY_3
EG	Egypt	4	EMPTY_4
IL	Israel	4	EMPTY_4
KW	Kuwait	4	EMPTY_4
NG	Nigeria	4	EMPTY_4
ZM	Zambia	4	EMPTY_4
ZW	Zimbabwe	4	EMPTY_4

Rollback complete.
*/

---------------------
-- Question 4
---------------------

ACCEPT desc PROMPT 'Enter the piece of the course description in UPPER case: ';
ACCEPT last PROMPT 'Enter the beginning of Instructor last name in UPPER CASE: ';
DECLARE
            
    CURSOR cur_section(p_desc course.description%TYPE, p_last instructor.last_name%TYPE) IS
        SELECT section_id, section_no, course_no, instructor_id
            FROM section
            WHERE course_no IN (
                    SELECT course_no
                        FROM course
                        WHERE upper(description) LIKE ('%' || upper(p_desc) || '%')
            )
            AND instructor_id IN (
                    SELECT instructor_id
                        FROM instructor
                        WHERE upper(last_name) LIKE (upper(p_last) || '%')
            );
            
    CURSOR cur_num_enroll(p_id enrollment.section_id%TYPE) IS
        SELECT count(student_id) AS enrolls
            FROM enrollment
            WHERE section_id = p_id;
            
    TYPE instructors_type IS TABLE OF
        instructor.last_name%TYPE
        INDEX BY PLS_INTEGER;
        
    TYPE courses_type IS TABLE OF
        course.description%TYPE
        INDEX BY PLS_INTEGER;
    
    instructors_tab instructors_type;
    courses_tab courses_type;
    
    v_tot_enrolls    PLS_INTEGER := 0;
    rec_tmp          cur_section%ROWTYPE;
    
BEGIN

    OPEN cur_section('&desc', '&last');
    FETCH cur_section INTO rec_tmp;
    IF cur_section%NOTFOUND THEN
        CLOSE cur_section;
        DBMS_OUTPUT.PUT_LINE('There is NO data for this input match between the course description piece and the surname start of Instructor. Try again!');
    ELSE
        CLOSE cur_section;
        FOR rec_course IN (SELECT course_no, description
                    FROM course
                    WHERE upper(description) LIKE ('%' || upper('&desc') || '%')) LOOP
        courses_tab(rec_course.course_no) := rec_course.description;
        END LOOP;
    
        FOR rec_instructor IN (SELECT instructor_id, last_name 
                        FROM instructor 
                        WHERE upper(last_name) LIKE (upper('&last') || '%')) LOOP
            instructors_tab(rec_instructor.instructor_id) := rec_instructor.last_name;
        END LOOP;
        
        FOR rec_section IN cur_section('&desc', '&last') LOOP
            DBMS_OUTPUT.PUT_LINE('Course No: ' || rec_section.course_no 
                || ' ' || courses_tab(rec_section.course_no) || ' with Section Id: ' 
                || rec_section.section_id || '  is taught by ' 
                || instructors_tab(rec_section.instructor_id) || ' in the Course Section: ' 
                || rec_section.section_no);
            FOR rec_num_enroll IN cur_num_enroll(rec_section.section_id) LOOP
                DBMS_OUTPUT.PUT_LINE('This section Id has an enrollment of: ' 
                    || rec_num_enroll.enrolls);   
                v_tot_enrolls := rec_num_enroll.enrolls + v_tot_enrolls;
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('*********************************************************************');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('This input match has a total enrollment of: ' || v_tot_enrolls || ' students.');       
    END IF;
END;
/

/*
Output 1:
Enter the piece of the course description in UPPER case: DATA
Enter the beginning of Instructor last name in UPPER CASE: W
There is NO data for this input match between the course description piece and the surname start of Instructor. Try again!


PL/SQL procedure successfully completed.

Output 2:
Enter the piece of the course description in UPPER case: INTRO
Enter the beginning of Instructor last name in UPPER CASE: W

Course No: 25 Intro to Programming with Section Id: 88  is taught by Wojick in the Course Section: 4
This section Id has an enrollment of: 5
*********************************************************************
Course No: 120 Intro to Java Programming with Section Id: 149  is taught by Wojick in the Course Section: 4
This section Id has an enrollment of: 1
*********************************************************************
Course No: 240 Intro to the Basic Language with Section Id: 102  is taught by Wojick in the Course Section: 2
This section Id has an enrollment of: 1
*********************************************************************
This input match has a total enrollment of: 7 students.


PL/SQL procedure successfully completed.

Output 3:
Enter the piece of the course description in UPPER case: JAVA
Enter the beginning of Instructor last name in UPPER CASE: S

Course No: 120 Intro to Java Programming with Section Id: 150  is taught by Schorin in the Course Section: 5
This section Id has an enrollment of: 3
*********************************************************************
Course No: 122 Intermediate Java Programming with Section Id: 153  is taught by Smythe in the Course Section: 2
This section Id has an enrollment of: 3
*********************************************************************
Course No: 124 Advanced Java Programming with Section Id: 127  is taught by Schorin in the Course Section: 2
This section Id has an enrollment of: 1
*********************************************************************
This input match has a total enrollment of: 7 students.


PL/SQL procedure successfully completed.
*/
