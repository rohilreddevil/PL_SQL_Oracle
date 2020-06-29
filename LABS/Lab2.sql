--dbs501 lab2 - Rohil Khakhar

--Question 1

set serveroutput on;
set verify off;

ACCEPT  v_scale PROMPT 'Enter your input scale (C or F) for temperature: ';
ACCEPT  v_temp PROMPT 'Enter your temperature value to be converted: ';

DECLARE
  my_scale char(1) := '&v_scale'; --value obtained at run time
  temp number (3,1):= '&v_temp'; --value obtained at run time
BEGIN
  IF upper(my_scale) = 'F' THEN
  temp:= (temp-32)*(5/9);
  dbms_output.put_line(' Your converted temperature in C is exactly ' || temp);
  
  ELSIF upper(my_scale) = 'C' THEN
  temp:= (temp*(9/5)) + 32;
  dbms_output.put_line(' Your converted temperature in F  is exactly ' || temp);
  
  ELSE
  dbms_output.put_line(' This is NOT a valid scale. Must be C or F');
  
  END IF;
  
END;
/

--Question 2

set serveroutput on;
set verify off;

accept v_id prompt 'Please enter the Instructor Id: '
DECLARE
  v_instructor_id number(8,0) := '&v_id';
  v_fullname varchar2(50);
  v_section_count number(2);
  v_message varchar2(100);
BEGIN

select first_name || ' ' || last_name into v_fullname from instructor --obtain full name
where instructor_id = v_instructor_id;

select count(section_id) into v_section_count from section --count the sections taught
where instructor_id = v_instructor_id;

v_message := case
  when v_section_count = 10 then 'This instructor needs to rest in the next term'
  when v_section_count = 9 then 'This instructor has enough sections'
  when v_section_count < 3 then 'This instructor may teach more sections'
  else 'It is upto the teacher to decide his sections'
end;
dbms_output.put_line('Instructor, ' || v_fullname || ' teaches ' || v_section_count || ' section(s)');
dbms_output.put_line(v_message);

EXCEPTION
    WHEN NO_DATA_FOUND THEN 
    dbms_output.put_line('This is not a valid instructor');

END;
/

--Question 3)

set pagesize 120;
set linesize 120;
set serveroutput on;
set verify off;

accept v_positive prompt 'Please enter a Positiive Integer: ';

declare
  v_integer number(5) := '&v_positive'; -- upper bound
  v_sum number(10);
  v_string varchar2(10);
  v_track number(5); 
begin

if mod(v_integer,2) = 0 then 

v_track := v_integer;
v_sum:=0;

  while v_track > 0 loop
    v_sum := v_sum + v_track;
    v_track := v_track - 2; 
  end loop;
  v_string := 'Even';
  
else -- if the upper bound is odd
v_track := v_integer;
v_sum:=0;

  while v_track > 0 loop
    v_sum := v_sum + v_track;
    v_track := v_track - 2; 
  end loop;
  v_string := 'Odd';

end if;
dbms_output.put_line('The sum of ' || v_string || ' integers between 1 and ' || v_integer || ' is ' || v_sum);

end;
/

--Question 4

set pagesize 120;
set linesize 120;
set serveroutput on;
set verify off;

accept v_location prompt 'Enter valid Location Id:';

declare
  v_location_id locations.location_id%TYPE := '&v_location';
  v_dept_count number;
  v_employee_count number;
  x number:= 1;
  y number:=1;
begin

UPDATE  Departments   SET   location_id = 1400
WHERE  department_id IN (40,70) ;

select count(department_id) into v_dept_count --how many departments in that location
from departments where location_id = v_location_id;

select count(employee_id) into v_employee_count --how many employees in that location
from employees  where department_id in 
                              (select department_id 
                              from departments where location_id = v_location_id);

for x in 1.. v_dept_count loop
  dbms_output.put_line ('Outer Loop: Department #' || x);
  for y in 1.. v_employee_count loop
    dbms_output.put_line ('**Inner Loop: Employee #' || y);
  end loop;
end loop;

end;
/
rollback;


