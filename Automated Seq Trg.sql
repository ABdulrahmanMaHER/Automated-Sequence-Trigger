declare
 cursor tables_columns is 
 select TABLE_NAME,COLUMN_NAME
 from user_cons_columns
 where CONSTRAINT_NAME like '%PK' 
 and COLUMN_NAME in (select COLUMN_NAME from USER_TAB_COLUMNS where DATA_TYPE='NUMBER')
 and table_name in (select object_name from user_objects where object_type ='TABLE');
 
 
  cursor trigger_seq is 
 SELECT object_type,object_name
 FROM USER_OBJECTS
 where object_type in ('TRIGGER','SEQUENCE');

  max_id varchar2(3000);
  v_max  number(8);
  maximum number(8);

begin      
    for s in trigger_seq loop
     if s.object_type='SEQUENCE' and s.object_name like'%_SEQ%' then
      execute immediate 'drop SEQUENCE '||s.OBJECT_NAME;
     elsif s.object_type='TRIGGER' and s.object_name like'%_TRG%' then 
      execute immediate 'drop TRIGGER '||s.OBJECT_NAME;
     end if;
     end loop; 
  
         for r in tables_columns loop
             max_id :=
            'SELECT MAX('
         || r.COLUMN_NAME
         || ') FROM '
         || r.TABLE_NAME;
           EXECUTE IMMEDIATE max_id INTO v_max;
           maximum:=v_max+1;
         
       execute immediate 'CREATE SEQUENCE ' || r.TABLE_NAME||'_SEQ START WITH ' || maximum || 'MAXVALUE 999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER';

       execute immediate 'CREATE OR REPLACE TRIGGER ' || r.TABLE_NAME||'_TRG '||
           ' BEFORE INSERT ON ' || r.TABLE_NAME ||
           ' FOR EACH ROW' ||
           ' BEGIN' ||
           '   :NEW.' || r.COLUMN_NAME || ' := ' || r.TABLE_NAME||'_SEQ' || '.NEXTVAL;' ||
           ' END;';

      end loop;
end;

show error
