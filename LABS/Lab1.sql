--Q2)

SET SERVEROUTPUT ON;
DECLARE
  v_myString VARCHAR2(50);
  v_myNumber NUMBER(8,2);
  c_myConstant CONSTANT VARCHAR2(5) := '704B';
  v_nextWeek DATE := SYSDATE + 7;
BEGIN
  DBMS_OUTPUT.PUT_LINE('The value of the constant variable is ' || c_myConstant);
  DBMS_OUTPUT.PUT_LINE('The date next week will be ' || v_nextWeek);
END;
-------
DECLARE
        v_myString VARCHAR2(50);
        v_myNumber NUMBER(8,2);
        c_myConstant CONSTANT VARCHAR2(5) := '704B';
        v_nextWeek DATE := SYSDATE + 7;
      BEGIN
      v_myString := 'C++ advanced';
      IF v_myString = 'SQL' THEN
        DBMS_OUTPUT.PUT_LINE('Course Name: ' || v_myString);
      ELSIF c_myConstant = '704B' THEN
          IF v_myString IS NOT NULL THEN
          DBMS_OUTPUT.PUT_LINE('Course Name: ' || v_myString || ', room name: ' || c_MyConstant);
          ELSE
          DBMS_OUTPUT.PUT_LINE('Course is unknown and ' || v_myString || 'room name is: ' || c_MyConstant);
          END IF;
      ELSE DBMS_OUTPUT.PUT_LINE('Course and location could not be determined');
      END IF;
      END;


--Q3)
CREATE TABLE Lab1_tab(
  Id NUMBER,
  LName VARCHAR(20));

CREATE SEQUENCE Lab1_seq
  START WITH 1
  INCREMENT BY 5;

BEGIN --1
    SELECT last_name INTO v_LName FROM Student
    WHERE student_id IN (SELECT DISTINCT student_id FROM Enrollment
              GROUP BY student_id HAVING COUNT(*) = 
                (SELECT MAX(COUNT(*)) FROM Enrollment GROUP BY student_id))
    AND LENGTH(last_name) < 9;
    
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN 
      v_LName := 'Multiple Names';
  END; --1
  
  INSERT INTO Lab1_tab VALUES (Lab1_seq.NEXTVAL, v_LName); 
  
  --now add students with least classes
  BEGIN --2
    SELECT last_name INTO v_LName FROM Student
    WHERE student_id IN (SELECT DISTINCT student_id FROM Enrollment
              GROUP BY student_id HAVING COUNT(*) = 
                (SELECT MIN(COUNT(*)) FROM Enrollment GROUP BY student_id));
    
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN 
      v_LName := 'Multiple Names';
  END; --2 
  
   INSERT INTO Lab1_tab VALUES (Lab1_seq.NEXTVAL, v_LName); 
  
  --instructors with least courses and last name not ending with an s
  BEGIN --3
    SELECT last_name INTO v_LName FROM Instructor
    WHERE Instructor_Id IN (SELECT DISTINCT Instructor_Id FROM Section
              GROUP BY Instructor_Id HAVING COUNT(*) = 
                (SELECT MIN(COUNT(*)) FROM Section GROUP BY Instructor_Id))
                
    AND last_name NOT LIKE '%s';
    
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN 
      v_LName := 'Multiple Names';
  END; --3
  
  INSERT INTO Lab1_tab VALUES (v_Id, v_LName); 
  
  --instructors with most courses
  BEGIN --4
    SELECT last_name INTO v_LName FROM Instructor
    WHERE Instructor_Id IN (SELECT DISTINCT Instructor_Id FROM Section
              GROUP BY Instructor_Id HAVING COUNT(*) = 
                (SELECT MAX(COUNT(*)) FROM Section GROUP BY Instructor_Id));
                
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN 
      v_LName := 'Multiple Names';
  END; --4
  
  INSERT INTO Lab1_tab VALUES (Lab1_seq.NEXTVAL, v_LName); 
  
END; --outer block  



