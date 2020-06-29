--Lab3

--Question 1 - Using an explicit cursor
set serveroutput on;
set verify off;

declare
 cursor c1 is select description from course 
 where prerequisite is null
 order by description; --alphabetical order
 course_name c1%rowtype;
 counter  number(3) := 0;
begin
  open c1;
  loop
    fetch c1 into course_name;
    exit when c1%notfound;
    dbms_output.put_line('Course Description: ' || c1%rowcount || ': ' || course_name.description);
    counter := c1%rowcount;
  end loop;
  close c1;
    dbms_output.put_line('**********************************************'); 
    dbms_output.put_line('Total # of Courses without the Prerequisites is: ' || counter ); 
end;

--Question 2 - Question 1 re-written using For loop and Index by Table
set serveroutput on;
set verify off;

declare
 cursor c1 is select course_no, description from course --declare the cursor
 where prerequisite is null
 order by description; --alphabetical order
 counter  number(3) := 0;
 
 --now declare the index by table
 type course_table_type is table of course%rowtype
 index by binary_integer;
 my_table course_table_type;
 
begin
  for i in c1 loop
    counter := counter + 1;
    select i.description into my_table(counter).description from course
    where course_no = i.course_no;
     dbms_output.put_line('Course Description: ' || counter || ': ' || my_table(counter).description);
     counter := c1%rowcount;
  end loop;
    dbms_output.put_line('**********************************************'); 
    dbms_output.put_line('Total # of Courses without the Prerequisites is: ' || counter ); 
end;

--Question 3)
set serveroutput on;
set verify off;

accept v_zip prompt 'Enter the first 3 digits of the zip code: '

declare
  type t_rec is record (
    v_zipcode NUMBER,
    v_student_count NUMBER);
    
    v_myrec t_rec;
    
    v_zip_total NUMBER := 0;
    v_students_total NUMBER;
    
  cursor c1 is select ZIP, count(student_id) 
  FROM 
  (select distinct s.zip, s.student_id from student s
  left join enrollment e
  ON s.student_id = e.student_id 
  WHERE s.zip LIKE '&v_zip' || '%')

  GROUP BY zip
  ORDER BY zip;
  
begin
  select count(*) into v_students_total from student where zip LIKE '&v_zip' || '%';
  
    open  c1;
     fetch c1 into  v_myrec;
     if  c1%notfound then
          dbms_output.put_line('This zip area is student empty. Please, try again');
     end if;  
    close c1;

  open c1;
  loop
    fetch c1 into v_myrec;
    exit when c1%notfound;
    dbms_output.put_line('Zip code: ' || v_myrec.v_zipcode || ' has exactly ' || v_myrec.v_student_count || ' students enrolled.');
    v_zip_total := v_zip_total + 1;
  end loop;
  close c1;
  
  dbms_output.put_line('************************************');
  dbms_output.put_line('Total # of zip codes under ' || '&v_zip' || ' is ' || v_zip_total);
  dbms_output.put_line('Total # of Students under zip code ' || '&v_zip' || ' is ' || v_students_total);
  
end;
/ 

--Question 4) - Q3) re written using Cursor For Loop and Index By Table

set serveroutput on;
set verify off;

accept v_zip prompt 'Enter the first 3 digits of the zip code: '

declare
  cursor c1 is select ZIP, count(student_id) as total
  FROM student
  WHERE zip LIKE '&v_zip' || '%'
  GROUP BY zip
  ORDER BY zip;
  
  c_record c1%rowtype;
  
  v_zip_total NUMBER := 0;
  v_students_total NUMBER;
  
  type my_table_type is table of c1%rowtype
  index by binary_integer;
  
  my_table my_table_type;
begin
 select count(*) into v_students_total from student where zip LIKE '&v_zip' || '%';
 
  --error message
    open  c1;
     fetch c1 into  c_record;
     if  c1%notfound then
          dbms_output.put_line('This zip area is student empty. Please, try again');
     end if;  
    close c1;
    
    for i in c1 loop
      v_zip_total := v_zip_total + 1;
      dbms_output.put_line('Zip code: ' || i.zip || ' has exactly ' || i.total || ' students enrolled.');
      
    end loop;
    dbms_output.put_line('************************************');
    dbms_output.put_line('Total # of zip codes under ' || '&v_zip' || ' is ' || v_zip_total);
    dbms_output.put_line('Total # of Students under zip code ' || '&v_zip' || ' is ' || v_students_total);
    
end;
/

















