--Lab 4

--Question 1)

set serveroutput on;
set verify off;

create or replace PROCEDURE mine (
  p_expiry in varchar2,
  p_letter in char) IS
  
  e_invalid exception;
  v_total number;
  
  begin
    dbms_output.put_line('Last day of the month ' || p_expiry || ' is ' || TO_CHAR(last_day(to_date(p_expiry,'MM/YY')),'day'));
    
  case 

    when UPPER(p_letter) = 'P' then
    select count(*) into v_total from USER_OBJECTS
    where object_type = 'PROCEDURE';
    dbms_output.put_line('Number of objects of type ' || UPPER(p_letter) || ' is ' || v_total); 
    
    when UPPER(p_letter) = 'F' then
    select count(*) into v_total from USER_OBJECTS
    where object_type = 'FUNCTION';
    dbms_output.put_line('Number of objects of type ' || UPPER(p_letter) || ' is ' || v_total);
    
    when UPPER(p_letter) = 'B' then
    select count(*) into v_total from USER_OBJECTS
    where object_type = 'PACKAGE';
    dbms_output.put_line('Number of objects of type ' || UPPER(p_letter) || ' is ' || v_total);
    
    else raise e_invalid;
    
  end case; 
    
    exception
    when e_invalid then
    dbms_output.put_line('You have entered an Invalid letter for the stored object. Try P, F or B');
    when others then
    dbms_output.put_line('You have entered an Invalid FORMAT for MONTH and YEAR. Try MM/YY');
    
end mine;
/

EXECUTE  mine ('11/09','P');
EXECUTE  mine ('12/09','f');
EXECUTE  mine ('01/10','T');
EXECUTE  mine ('13/09','P'); 

--Question 2)

set serveroutput on;
set verify off;

Variable v_zipcode number;
Variable v_message varchar2;

create or replace procedure add_zip(
  p_zip zipcode.zip%type,
  p_city zipcode.city%type,
  p_state zipcode.state%type,
  p_rowcount out number,
  p_message out varchar2
) is

v_zip zipcode.zip%type;
begin
  select zip into v_zip from zipcode
  where  zip = p_zip; --p_zip will be the input value
  
  p_message := 'FAILURE';
   if (p_message = 'FAILURE') then 
   dbms_output.put_line('This ZIPCODE ' || p_zip || ' is already in the Database. Try again. ');
   select count(*) into p_rowcount from zipcode
   where state = p_state;
   end if;
   
   p_message := 'SUCCESS';
   
  exception
  when no_data_found then
     p_message := 'SUCCESS';
  insert into zipcode
  values(p_zip, p_city, p_state, USER, SYSDATE, USER, SYSDATE);
   select count(*) into p_rowcount from zipcode
   where state = p_state;

end add_zip;
/


execute add_zip('18104', 'Chicago', 'MI', :v_zipcode, :v_message);
select  * FROM zipcode
where  state = 'MI';
rollback;

print v_zipcode;
print v_message;

execute add_zip('48104', 'Ann Arbor', 'MI', :v_zipcode, :v_message);
select  * FROM zipcode
where  state = 'MI';
rollback;

--Question 3)

set serveroutput on;
set verify off;

Variable v_zipcode number;
Variable v_message varchar2;

create or replace function exist_zip (v_zip zipcode.zip%type) 
return boolean is 
  zip_count number;
begin
  select count(*) into zip_count from zipcode 
  where zip = v_zip;
  if(zip_count >0) then --this means that the zip already exists
    return true;
  else
    return false; -- this means that the zip does not exist
  end if;
end exist_zip;
/

create or replace procedure add_zip2(
  p_zip zipcode.zip%type,
  p_city zipcode.city%type,
  p_state zipcode.state%type,
  p_rowcount out number,
  p_message out varchar2
) is

v_zip zipcode.zip%type;
begin
  select zip into v_zip from zipcode
  where  zip = p_zip; --p_zip will be the input value
  
  p_message := 'FAILURE';
   if (exist_zip(p_zip)) then 
   p_message := 'FAILURE';
   dbms_output.put_line('This ZIPCODE ' || p_zip || ' is already in the Database. Try again. ');
   select count(*) into p_rowcount from zipcode
   where state = p_state;
   end if;
   
   p_message := 'SUCCESS';
   
   desc enrollment
   
  exception
  when no_data_found then
     p_message := 'SUCCESS';
  insert into zipcode
  values(p_zip, p_city, p_state, USER, SYSDATE, USER, SYSDATE);
   select count(*) into p_rowcount from zipcode
   where state = p_state;

end add_zip2;
/ 

execute add_zip2('18104', 'Chicago', 'MI', :v_zipcode, :v_message);
select  * FROM zipcode
where  state = 'MI';
rollback;

print v_zipcode;
print v_message;

execute add_zip2('48104', 'Ann Arbor', 'MI', :v_zipcode, :v_message);
select  * FROM zipcode
where  state = 'MI';
rollback; 

--Question 4)

set serveroutput on;
set autoprint on;
set verify off;

create or replace function instruct_status(
v_fname instructor.first_name%type,
v_lname instructor.last_name%type
) 
return varchar2
is

desc section
desc student
desc zipcode

v_instructor_id instructor.instructor_id%type;
v_section_count number;
v_message varchar2(150);

begin
	select instructor_id into v_instructor_id from instructor
	where first_name = v_fname
	and last_name = v_lname;
	
	select count(instructor_id) into v_section_count from section
	where instructor_id = v_instructor_id;
  
	if (v_section_count > 9) then
	v_message := 'This Instructor will teach ' || v_section_count || ' courses and needs a vacation';
  elsif (v_section_count > 0 and v_section_count <= 9) then
	v_message := 'This Instructor will teach ' || v_section_count || ' courses';
	else
	v_message := 'This Instructor is NOT scheduled to teach ';
	
  end if; 
  return v_message;
	
	exception
	when no_data_found then
	v_message := 'There is NO such instructor'; 
	return v_message;

end instruct_status;
/ 

variable my_message varchar2;

select last_name, instruct_status(first_name, last_name) as "Instructor Info" from instructor
order by last_name;
execute :my_message := instruct_status('Peter', 'Pan'); 
execute :my_message := instruct_status('Irene', 'Willig'); 


