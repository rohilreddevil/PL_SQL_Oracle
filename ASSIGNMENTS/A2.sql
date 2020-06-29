/*
Assignment: 2
Group #5
*/

SET SERVEROUTPUT ON
SET VERIFY OFF;

---------------
-- Question: 1
---------------

CREATE OR REPLACE PROCEDURE modify_sal(
        p_dept_id employees.department_id%TYPE
    ) IS
    --local declarations go here
    v_flag CHAR;
    
    v_employee_department NUMBER; -- the department the employee is part of 
    v_avg_sal employees.salary%TYPE;
    v_employee_count NUMBER := 0;
    
    e_no_employees EXCEPTION;
    
    --declare the cursor
    CURSOR cur_emps(p_deptno departments.department_id%TYPE) IS
        SELECT first_name, last_name, salary
            FROM employees
            WHERE department_id = p_deptno
            FOR UPDATE OF salary NOWAIT;

BEGIN
    
    --check if the department exists...
    SELECT 'Y' INTO v_flag
        FROM departments 
        WHERE department_id = p_dept_id;
    
    --now count the number of employees in the department id provided
    SELECT count(employee_id) INTO v_employee_department 
        FROM employees 
        WHERE department_id = p_dept_id;
    
    --if there are NO employees, raise the appropriate exception
    IF v_employee_department = 0 THEN
        RAISE e_no_employees;
    END IF;
    
    --store the average salary in the local variable
    SELECT nvl(avg(salary), 0) INTO v_avg_sal 
        FROM employees 
        WHERE department_id = p_dept_id;
    
     FOR r_emps IN cur_emps(p_dept_id) LOOP
        IF (r_emps.salary < v_avg_sal) THEN
            UPDATE employees
                SET salary = v_avg_sal
                WHERE CURRENT OF cur_emps;
            DBMS_OUTPUT.PUT_LINE('Employee ' || r_emps.first_name || ' ' || r_emps.last_name || ' just got an increase of $' || (v_avg_sal - r_emps.salary));
            v_employee_count := v_employee_count + 1; --indicates that an employee's salary has been updated
        END IF;
    END LOOP;
    
    IF(v_employee_count = 0) THEN
        DBMS_OUTPUT.PUT_LINE('No salary was modified in Department: ' || p_dept_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total # of employees who received salary increase is: ' || v_employee_count); 
    END IF;
    
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('This Department Id is invalid: ' || p_dept_id);
        WHEN e_no_employees THEN
            DBMS_OUTPUT.PUT_LINE('There are no employees in the following department: ' || p_dept_id);
END modify_sal;
/

EXECUTE modify_sal(99);
ROLLBACK;

EXECUTE modify_sal(190);
ROLLBACK;

EXECUTE modify_sal(10);
ROLLBACK;

EXECUTE modify_sal(110);
ROLLBACK;

EXECUTE modify_sal(60);
ROLLBACK;

/*
Output:
Case 1 (EXECUTE modify_sal(99);):
This Department Id is invalid: 99


PL/SQL procedure successfully completed.


Rollback complete.

Case 2 (EXECUTE modify_sal(190);):
There are no employees in the following department: 190


PL/SQL procedure successfully completed.


Rollback complete.

Case 3 (EXECUTE modify_sal(10);):
No salary was modified in Department: 10


PL/SQL procedure successfully completed.


Rollback complete.

Case 4 (EXECUTE modify_sal(110);):
Employee William Gietz just got an increase of $1850
Total # of employees who received salary increase is: 1


PL/SQL procedure successfully completed.


Rollback complete.

Case 5 (EXECUTE modify_sal(60);):
Employee David Austin just got an increase of $960
Employee Valli Pataballa just got an increase of $960
Employee Diana Lorentz just got an increase of $1560
Total # of employees who received salary increase is: 3


PL/SQL procedure successfully completed.


Rollback complete.
*/


---------------
-- Question: 2
---------------

CREATE OR REPLACE FUNCTION total_cost ( 
        p_student_id student.student_id%TYPE
    ) RETURN NUMBER IS 
    
    v_flag CHAR;
    
    v_enrolled_courses NUMBER;
    v_total_cost NUMBER;
    
    e_not_enrolled EXCEPTION;
    
    BEGIN
        
        SELECT 'Y' INTO v_flag
            FROM student
            WHERE student_id = p_student_id;
            
        SELECT count(section_id) INTO v_enrolled_courses
            FROM enrollment
            WHERE student_id = p_student_id;
    
        IF v_enrolled_courses = 0 THEN 
            RAISE e_not_enrolled;    
        END IF;
        
        SELECT nvl(sum(c.cost), 0) INTO v_total_cost
            FROM (enrollment e JOIN section s ON e.section_id = s.section_id)
                JOIN course c ON s.course_no = c.course_no
            WHERE e.student_id = p_student_id;
    
        RETURN v_total_cost;
    
    EXCEPTION 
        WHEN e_not_enrolled THEN 
            RETURN 0;
        WHEN NO_DATA_FOUND THEN 
            RETURN -1;
        
END total_cost;
/


VARIABLE b_cost NUMBER;
EXECUTE :b_cost := total_cost(194);
PRINT b_cost;

EXECUTE :b_cost := total_cost(294);
PRINT b_cost;

EXECUTE :b_cost := total_cost(494);
PRINT b_cost;

/*
Output:

Case 1(EXECUTE :b_cost := total_cost(194);):
PL/SQL procedure successfully completed.


    B_COST
----------
      1195


Case 2 (EXECUTE :b_cost := total_cost(294);):
PL/SQL procedure successfully completed.


    B_COST
----------
         0


Case 3 (EXECUTE :b_cost := total_cost(494);):
PL/SQL procedure successfully completed.


    B_COST
----------
        -1

*/

---------------
-- Question: 3
---------------

CREATE OR REPLACE PACKAGE my_pack IS
    PROCEDURE modify_sal(p_dept_id employees.department_id%TYPE);
    FUNCTION total_cost(p_student_id student.student_id%TYPE) RETURN NUMBER;
END my_pack;
/

CREATE OR REPLACE PACKAGE BODY my_pack IS

    PROCEDURE modify_sal(
            p_dept_id employees.department_id%TYPE
        ) IS
        --local declarations go here
        v_flag CHAR;
        
        v_employee_department NUMBER; -- the department the employee is part of 
        v_avg_sal employees.salary%TYPE;
        v_employee_count NUMBER := 0;
        
        e_no_employees EXCEPTION;
        
        --declare the cursor
        CURSOR cur_emps(p_deptno departments.department_id%TYPE) IS
            SELECT first_name, last_name, salary
                FROM employees
                WHERE department_id = p_deptno
                FOR UPDATE OF salary NOWAIT;
    
    BEGIN
        
        --check if the department exists...
        SELECT 'Y' INTO v_flag
            FROM departments 
            WHERE department_id = p_dept_id;
        
        --now count the number of employees in the department id provided
        SELECT count(employee_id) INTO v_employee_department 
            FROM employees 
            WHERE department_id = p_dept_id;
        
        --if there are NO employees, raise the appropriate exception
        IF v_employee_department = 0 THEN
            RAISE e_no_employees;
        END IF;
        
        --store the average salary in the local variable
        SELECT nvl(avg(salary), 0) INTO v_avg_sal 
            FROM employees 
            WHERE department_id = p_dept_id;
        
         FOR r_emps IN cur_emps(p_dept_id) LOOP
            IF (r_emps.salary < v_avg_sal) THEN
                UPDATE employees
                    SET salary = v_avg_sal
                    WHERE CURRENT OF cur_emps;
                DBMS_OUTPUT.PUT_LINE('Employee ' || r_emps.first_name || ' ' || r_emps.last_name || ' just got an increase of $' || (v_avg_sal - r_emps.salary));
                v_employee_count := v_employee_count + 1; --indicates that an employee's salary has been updated
            END IF;
        END LOOP;
        
        IF(v_employee_count = 0) THEN
            DBMS_OUTPUT.PUT_LINE('No salary was modified in Department: ' || p_dept_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Total # of employees who received salary increase is: ' || v_employee_count); 
        END IF;
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('This Department Id is invalid: ' || p_dept_id);
            WHEN e_no_employees THEN
                DBMS_OUTPUT.PUT_LINE('There are no employees in the following department: ' || p_dept_id);
    
    END modify_sal;



    FUNCTION total_cost ( 
            p_student_id student.student_id%TYPE
        ) RETURN NUMBER IS 
        
        v_flag CHAR;
        
        v_enrolled_courses NUMBER;
        v_total_cost NUMBER;
        
        e_not_enrolled EXCEPTION;
        
    BEGIN
        
        SELECT 'Y' INTO v_flag
            FROM student
            WHERE student_id = p_student_id;
            
        SELECT count(section_id) INTO v_enrolled_courses
            FROM enrollment
            WHERE student_id = p_student_id;
    
        IF v_enrolled_courses = 0 THEN 
            RAISE e_not_enrolled;    
        END IF;
        
        SELECT nvl(sum(c.cost), 0) INTO v_total_cost
            FROM (enrollment e JOIN section s ON e.section_id = s.section_id)
                JOIN course c ON s.course_no = c.course_no
            WHERE e.student_id = p_student_id;
    
        RETURN v_total_cost;
    
        EXCEPTION 
            WHEN e_not_enrolled THEN 
                RETURN 0;
            WHEN NO_DATA_FOUND THEN 
                RETURN -1;
            
    END total_cost;
    
END my_pack;
/

EXECUTE my_pack.modify_sal(99);
ROLLBACK;

EXECUTE my_pack.modify_sal(190);
ROLLBACK;

EXECUTE my_pack.modify_sal(10);
ROLLBACK;

EXECUTE my_pack.modify_sal(110);
ROLLBACK;

EXECUTE my_pack.modify_sal(60);
ROLLBACK;




VARIABLE b_cost NUMBER;
EXECUTE :b_cost := my_pack.total_cost(194);
PRINT b_cost;

EXECUTE :b_cost := my_pack.total_cost(294);
PRINT b_cost;

EXECUTE :b_cost := my_pack.total_cost(494);
PRINT b_cost;


/*
Output 1 modify_sal:
Case 1 (EXECUTE my_pack.modify_sal(99);):
This Department Id is invalid: 99


PL/SQL procedure successfully completed.


Rollback complete.

Case 2 (EXECUTE my_pack.modify_sal(190);):
There are no employees in the following department: 190


PL/SQL procedure successfully completed.


Rollback complete.

Case 3 (EXECUTE my_pack.modify_sal(10);):
No salary was modified in Department: 10


PL/SQL procedure successfully completed.


Rollback complete.

Case 4 (EXECUTE my_pack.modify_sal(110);):
Employee William Gietz just got an increase of $1850
Total # of employees who received salary increase is: 1


PL/SQL procedure successfully completed.


Rollback complete.

Case 5 (EXECUTE my_pack.modify_sal(60);):
Employee David Austin just got an increase of $960
Employee Valli Pataballa just got an increase of $960
Employee Diana Lorentz just got an increase of $1560
Total # of employees who received salary increase is: 3


PL/SQL procedure successfully completed.


Rollback complete.

*/

/*
Output 2 total_cost:

Case 1(EXECUTE :b_cost := my_pack.total_cost(194);):
PL/SQL procedure successfully completed.


    B_COST
----------
      1195


Case 2 (EXECUTE :b_cost := my_pack.total_cost(294);):
PL/SQL procedure successfully completed.


    B_COST
----------
         0


Case 3 (EXECUTE :b_cost := my_pack.total_cost(494);):
PL/SQL procedure successfully completed.


    B_COST
----------
        -1

*/

---------------
-- Question: 4
---------------

CREATE OR REPLACE PACKAGE my_pack IS
    PROCEDURE modify_sal(p_dept_id employees.department_id%TYPE);
    FUNCTION total_cost(p_student_id student.student_id%TYPE) RETURN NUMBER;
    FUNCTION total_cost(p_first student.first_name%TYPE, p_last student.last_name%TYPE) RETURN NUMBER;
    FUNCTION total_cost(p_zip student.zip%TYPE) RETURN NUMBER;
END my_pack;
/

CREATE OR REPLACE PACKAGE BODY my_pack IS

    PROCEDURE modify_sal(
            p_dept_id employees.department_id%TYPE
        ) IS
        
        --local declarations go here
        v_flag CHAR;
        
        v_employee_department NUMBER; -- the department the employee is part of 
        v_avg_sal employees.salary%TYPE;
        v_employee_count NUMBER := 0;
        
        e_no_employees EXCEPTION;
        
        --declare the cursor
        CURSOR cur_emps(p_deptno departments.department_id%TYPE) IS
            SELECT first_name, last_name, salary
                FROM employees
                WHERE department_id = p_deptno
                FOR UPDATE OF salary NOWAIT;
    
    BEGIN
        
        --check if the department exists...
        SELECT 'Y' INTO v_flag
            FROM departments 
            WHERE department_id = p_dept_id;
        
        --now count the number of employees in the department id provided
        SELECT count(employee_id) INTO v_employee_department 
            FROM employees 
            WHERE department_id = p_dept_id;
        
        --if there are NO employees, raise the appropriate exception
        IF v_employee_department = 0 THEN
            RAISE e_no_employees;
        END IF;
        
        --store the average salary in the local variable
        SELECT nvl(avg(salary), 0) INTO v_avg_sal 
            FROM employees 
            WHERE department_id = p_dept_id;
        
         FOR r_emps IN cur_emps(p_dept_id) LOOP
            IF (r_emps.salary < v_avg_sal) THEN
                UPDATE employees
                    SET salary = v_avg_sal
                    WHERE CURRENT OF cur_emps;
                DBMS_OUTPUT.PUT_LINE('Employee ' || r_emps.first_name || ' ' || r_emps.last_name || ' just got an increase of $' || (v_avg_sal - r_emps.salary));
                v_employee_count := v_employee_count + 1; --indicates that an employee's salary has been updated
            END IF;
        END LOOP;
        
        IF(v_employee_count = 0) THEN
            DBMS_OUTPUT.PUT_LINE('No salary was modified in Department: ' || p_dept_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Total # of employees who received salary increase is: ' || v_employee_count); 
        END IF;
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('This Department Id is invalid: ' || p_dept_id);
            WHEN e_no_employees THEN
                DBMS_OUTPUT.PUT_LINE('There are no employees in the following department: ' || p_dept_id);
    END modify_sal;



    FUNCTION total_cost ( 
            p_student_id student.student_id%TYPE
        ) RETURN NUMBER IS 
        
        v_flag CHAR;
        
        v_enrolled_courses NUMBER;
        v_total_cost NUMBER;
        
        e_not_enrolled EXCEPTION;
        
    BEGIN
        
        SELECT 'Y' INTO v_flag
            FROM student
            WHERE student_id = p_student_id;
            
        SELECT count(section_id) INTO v_enrolled_courses
            FROM enrollment
            WHERE student_id = p_student_id;
    
        IF v_enrolled_courses = 0 THEN 
            RAISE e_not_enrolled;    
        END IF;
        
        SELECT nvl(sum(c.cost), 0) INTO v_total_cost
            FROM (enrollment e JOIN section s ON e.section_id = s.section_id)
                JOIN course c ON s.course_no = c.course_no
            WHERE e.student_id = p_student_id;
    
        RETURN v_total_cost;
    
        EXCEPTION 
            WHEN e_not_enrolled THEN 
                RETURN 0;
            WHEN NO_DATA_FOUND THEN 
                RETURN -1;
            
    END total_cost;
    
    FUNCTION total_cost (
            p_first student.first_name%TYPE,
            p_last student.last_name%TYPE
        ) RETURN NUMBER IS
                
        v_stud_id student.student_id%TYPE;
    BEGIN
    
        SELECT student_id INTO v_stud_id
            FROM student
            WHERE upper(first_name) = upper(p_first)
                AND upper(last_name) = upper(p_last);
            
        RETURN total_cost(v_stud_id);
        
        EXCEPTION
            WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
                RETURN -1;
    END total_cost;
    
    FUNCTION total_cost (
            p_zip student.zip%TYPE
        ) RETURN NUMBER IS
        
        CURSOR cur_stud IS
            SELECT student_id
                FROM student
                WHERE zip = p_zip;
                
        rec_tmp cur_stud%ROWTYPE;
        v_tot NUMBER := 0;
    BEGIN
    
        OPEN cur_stud;
        FETCH cur_stud INTO rec_tmp;
        IF cur_stud%NOTFOUND THEN
            CLOSE cur_stud;
            RETURN -1;
        ELSE
            CLOSE cur_stud;
            FOR rec_stud IN cur_stud LOOP
                v_tot := v_tot + total_cost(rec_stud.student_id);
            END LOOP;
            RETURN v_tot;
        END IF;
    END total_cost;

END my_pack;
/

VARIABLE b_tot NUMBER;

EXECUTE :b_tot := my_pack.total_cost('VERONA', 'GRANT');
PRINT b_tot;

EXECUTE :b_tot := my_pack.total_cost('YVONNE', 'WINNICKI');
PRINT b_tot;

EXECUTE :b_tot := my_pack.total_cost('PETER', 'PAN');
PRINT b_tot;

EXECUTE :b_tot := my_pack.total_cost('07044');
PRINT b_tot;

EXECUTE :b_tot := my_pack.total_cost('11209');
PRINT b_tot;

EXECUTE :b_tot := my_pack.total_cost('11111');
PRINT b_tot;


/*
Output:

Case 1 (EXECUTE :b_tot := my_pack.total_cost('VERONA', 'GRANT');):
PL/SQL procedure successfully completed.


     B_TOT
----------
      1195

Case 2 (EXECUTE :b_tot := my_pack.total_cost('YVONNE', 'WINNICKI');):
PL/SQL procedure successfully completed.


     B_TOT
----------
         0

Case 3 (EXECUTE :b_tot := my_pack.total_cost('PETER', 'PAN');):
PL/SQL procedure successfully completed.


     B_TOT
----------
        -1

Case 4 (EXECUTE :b_tot := my_pack.total_cost('07044');):
PL/SQL procedure successfully completed.


     B_TOT
----------
      1195

Case 5 (EXECUTE :b_tot := my_pack.total_cost('11209');):
PL/SQL procedure successfully completed.


     B_TOT
----------
      7070

Case 6 (EXECUTE :b_tot := my_pack.total_cost('11111');):
PL/SQL procedure successfully completed.


     B_TOT
----------
        -1

*/
