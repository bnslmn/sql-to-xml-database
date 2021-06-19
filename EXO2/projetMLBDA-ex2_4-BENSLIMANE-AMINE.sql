/*  
*   SQL to XML database generation
*   
*   Amine Benslimane
*   Master 1 STL,
*   Sorbonne Université - campus Pierre et Marie Curie, Paris,
*   Jan 2021
*
*   see that on https://github.com/bnslmn/
*
*   Licence GPL v3, feel free to use this code as you wish !
*/

-- TYPE Border
DROP TYPE T_Border FORCE;
/
CREATE OR REPLACE TYPE T_Border AS OBJECT (
    countrycode1 VARCHAR2(4),
    countrycode2 VARCHAR2(4),
    lengthB      NUMBER,
    member function toXML return XMLType
    
)
/
CREATE OR REPLACE TYPE BODY T_Border AS
member function toXML return XMLType IS
output XMLType;
    begin
        output := XMLType.createxml('<border countryCode = "'||countrycode2||'" length = "'||lengthB||'"/>');
        
        return output;
    end;
    
end;
/

-- TABLE Border
DROP TABLE LesBorder;
CREATE TABLE LesBorder OF T_Border;


-- Type Country

DROP TYPE T_Country FORCE;
/
CREATE OR REPLACE TYPE T_Country AS OBJECT(
countrycode VARCHAR2(4),
nameC       VARCHAR2(35),
member function toXML return XMLType
)
/

-- Stocker border dans contCountries

CREATE OR REPLACE TYPE EnsBorder AS TABLE OF T_Border;
/

CREATE OR REPLACE TYPE BODY T_Country AS
member function toXML return XMLType IS
output XMLType;
    tmpBorder EnsBorder;
    blength NUMBER;   -- La variable qui contiendra la somme des longueurs des frontières

    begin
        -- Calcul de blength
        
        SELECT VALUE(b) BULK COLLECT INTO tmpBorder
        FROM LesBorder b 
        WHERE countrycode = b.countrycode1;
        
         blength := 0;     -- On initialise à 0
         
         FOR indx IN 1..tmpBorder.COUNT
         loop
          blength := blength + tmpBorder(indx).lengthB;     -- Pour chaque frontière, on ajoute sa longueur 
        END loop;


        output :=  XMLType.createxml('<country name = "'||nameC||'" blength = "'||blength||'"/>');

        -- Element contCountries
        output :=  XMLType.appendchildxml(output, 'country', XMLType('<contCountries/>'));

        -- Element border
         FOR indx IN 1..tmpBorder.COUNT
         loop
          
          output := XMLType.appendchildxml(output,'country/contCountries', tmpBorder(indx).toXML());   
        END loop;

      return output;
    end;
end;
/


-- TABLE Country

DROP TABLE LesCountrys ;
CREATE TABLE LesCountrys OF T_Country;

-- TYPE ex2 
DROP TYPE T_ex2 FORCE;
CREATE OR REPLACE TYPE T_ex2 AS OBJECT(
   name VARCHAR2(10),
   member function toXML return XMLType
)
/

-- Stocker Les countrys
CREATE OR REPLACE TYPE EnsCountry AS TABLE OF T_Country;
/

CREATE OR REPLACE TYPE BODY T_ex2 AS
 member function toXML return XMLType IS
 output XMLType;
 tmpCountry EnsCountry;
   BEGIN
      output := XMLType.createxml('<ex2/>');
      
      -- Element country
      SELECT VALUE(c) BULK COLLECT INTO tmpCountry
      FROM LesCountrys c ;
      FOR indx IN 1..tmpCountry.COUNT
      loop
         output := XMLType.appendchildxml(output,'ex2', tmpCountry(indx).toXML());   
      END loop;
      return output;
   end;
end;
/

-- TABLE ex2

DROP TABLE ex2;
CREATE TABLE ex2 OF T_ex2;

-- INSERTIONS :

INSERT INTO LesBorder
SELECT T_Border(b.country1 , b.country2, b.length)
FROM Borders b;

INSERT INTO LesBorder
SELECT T_Border(b.country2 , b.country1, b.length)
FROM Borders b;

INSERT INTO LesCountrys
SELECT T_Country(c.code , c.name)
FROM Country c, ENCOMPASSES e 
WHERE c.code = e.country;

INSERT INTO ex2 VALUES ('exo2_4');

-- exporter le r�sultat dans un fichier 
WbExport -type=text
         -file='testlength.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select e.toXML().getClobVal() 
from ex2 e;

