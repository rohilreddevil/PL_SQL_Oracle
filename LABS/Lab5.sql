--Lab5

--Question 1)

set serveroutput on;
set verify off;
set autoprint on;

create or replace function get_descr(p_section_id section.section_id%type) return varchar2 is
  v_description course.description%type; --local variable to store the description
  v_message varchar2(150);
begin
select c.description into v_description from course c join section s --obtain the description that corresponds to the section id provided
on c.course_no = s.course_no 
where s.section_id = p_section_id;

v_message := 'Course Description for Section Id ' || p_section_id || ' is ' || v_description;
return v_message;

exception 
when no_data_found then
v_message:= 'There is NO such Section id: ' || p_section_id;
return v_message;

end get_descr;
/

variable message varchar2(100);
execute :message:= get_descr(150);

execute :message:= get_descr(999);

--Question 2)
set serveroutput on;
set verify off;

create or replace procedure show_bizdays(p_start_date date := sysdate, p_no_days number := 21) is

v_index number:=1;
v_start_date date := p_start_date;
v_day varchar2(1);

begin

while v_index < p_no_days +1 loop

  select substr(to_char(v_start_date, 'DAY'), 0, 1) into v_day -- selects the first letter of the day
  from dual;
  --Bypass the weekends
  if v_day = 'S' then -- Saturday or Sunday
  v_start_date := v_start_date +2;

 else
 dbms_output.put_line('The index is : ' || v_index || ' and the table value is: ' || to_char(v_start_date));
 v_index := v_index + 1;
 v_start_date := v_start_date +1;
 end if;
end loop;
  
end show_bizdays;
/ 

execute show_bizdays;
execute show_bizdays(sysdate+7,10);

--Question 3)

--3A -specification
set serveroutput on;
set verify off;
set autoprint on;

create or replace package Lab5 is 
procedure show_bizdays(p_start_date date := sysdate, p_no_days number := 21);
function get_descr(p_section_id section.section_id%type) return varchar2;
end Lab5;
/

--3B

create or replace package body Lab5 is 

procedure show_bizdays(p_start_date date := sysdate, p_no_days number := 21) is

v_index number:=1;
v_start_date date := p_start_date;
v_day varchar2(1);

begin

while v_index < p_no_days +1 loop

  select substr(to_char(v_start_date, 'DAY'), 0, 1) into v_day -- selects the first letter of the day
  from dual;
  --Bypass the weekends
  if v_day = 'S' then -- Saturday or Sunday
  v_start_date := v_start_date +2;

 else
 dbms_output.put_line('The index is : ' || v_index || ' and the table value is: ' || to_char(v_start_date));
 v_index := v_index + 1;
 v_start_date := v_start_date +1;
 end if;
end loop;
  
end show_bizdays;

function get_descr(p_section_id section.section_id%type) return varchar2 is
  v_description course.description%type; --local variable to store the description
  v_message varchar2(150);
begin
select c.description into v_description from course c join section s --obtain the description that corresponds to the section id provided
on c.course_no = s.course_no 
where s.section_id = p_section_id;

v_message := 'Course Description for Section Id ' || p_section_id || ' is ' || v_description;
return v_message;

exception 
when no_data_found then
v_message:= 'There is NO such Section id: ' || p_section_id;
return v_message;

end get_descr;

end Lab5;
/

--3C
variable message varchar2(100);
execute :message:= Lab5.get_descr(150);
rollback;

execute :message:= Lab5.get_descr(999);
rollback;

execute Lab5.show_bizdays;
execute Lab5.show_bizdays(sysdate+7,10);

--Question 4)

--4A)

set serveroutput on;
set verify off;
set autoprint on;

create or replace package Lab5 is 
procedure show_bizdays(p_start_date date := sysdate, p_no_days number := 21);
procedure show_bizdays(p_start date); --OVERLOADED procedure
function get_descr(p_section_id section.section_id%type) return varchar2;
end Lab5;
/

--4B)

--Regular Procedure
create or replace package body Lab5 is 

procedure show_bizdays(p_start_date date := sysdate, p_no_days number := 21) is

v_index number:=1;
v_start_date date := p_start_date;
v_day varchar2(1);

begin

while v_index < p_no_days +1 loop

  select substr(to_char(v_start_date, 'DAY'), 0, 1) into v_day -- selects the first letter of the day
  from dual;
  --Bypass the weekends
  if v_day = 'S' then -- Saturday or Sunday
  v_start_date := v_start_date +2;

 else
 dbms_output.put_line('The index is : ' || v_index || ' and the table value is: ' || to_char(v_start_date));
 v_index := v_index + 1;
 v_start_date := v_start_date +1;
 end if;
end loop;
  
end show_bizdays;

--OVERLOADED PROCEDURE
procedure show_bizdays(p_start date) is

v_index number:=1;
v_no_of_days number := &v_days;
v_start_date date := p_start;
v_day varchar2(1);

begin

while v_index < v_no_of_days +1 loop

  select substr(to_char(v_start_date, 'DAY'), 0, 1) into v_day -- selects the first letter of the day
  from dual;
  --Bypass the weekends
  if v_day = 'S' then -- Saturday or Sunday
  v_start_date := v_start_date +2;

 else
 dbms_output.put_line('The index is : ' || v_index || ' and the table value is: ' || to_char(v_start_date));
 v_index := v_index + 1;
 v_start_date := v_start_date +1;
 end if;
end loop;
  
end show_bizdays;

--Function
function get_descr(p_section_id section.section_id%type) return varchar2 is
  v_description course.description%type; --local variable to store the description
  v_message varchar2(150);
begin
select c.description into v_description from course c join section s --obtain the description that corresponds to the section id provided
on c.course_no = s.course_no 
where s.section_id = p_section_id;

v_message := 'Course Description for Section Id ' || p_section_id || ' is ' || v_description;
return v_message;

exception 
when no_data_found then
v_message:= 'There is NO such Section id: ' || p_section_id;
return v_message;

end get_descr;

end Lab5;
/

--4C)
execute Lab5.show_bizdays;
execute Lab5.show_bizdays(sysdate+7,10);
execute Lab5.show_bizdays(p_start => sysdate +5);




