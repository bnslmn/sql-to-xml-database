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



/*** CE FICHIER SQL CONTIENT EXO2_1 et EXO2_2 ***/




-- TYPE Mountain

DROP TYPE T_Mountain FORCE;
/
CREATE OR REPLACE  TYPE T_Mountain AS object (
   nameM     VARCHAR2(35 Byte),
   heightM   Number,
   idcountry  VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Mountain AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<mountain name="'||nameM||'" height="'||heightM||'"/>');
      return output;
   END;
END;
/


-- TABLE Mountain

DROP TABLE LesMountains;
CREATE TABLE LesMountains OF T_Mountain;

-- TYPE Desert

DROP TYPE T_Desert FORCE;
/
CREATE OR REPLACE  TYPE T_Desert AS object (
   nameD     VARCHAR2(35 Byte),
   areaD     Number,
   idcountry  VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Desert AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<desert name="'||nameD||'" area="'||areaD||'"/>');
      return output;
   END;
END;
/

-- TABLE Desert 

DROP TABLE LesDeserts;
CREATE TABLE LesDeserts OF T_Desert;

-- TYPE island
DROP TYPE T_Island FORCE;
/
CREATE OR REPLACE  TYPE T_Island AS object (
   nameI      VARCHAR2(35 Byte),
   latitude  number,
   longitude number,
   idcountry  VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Island AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<island name="'||nameI||'"/>');
      output := XMLType.appendchildxml(output,'island', XMLType('<coordinates latitude="'||latitude||'" longitude="'||longitude||'"/>'));
      return output;
   END;
END;
/

-- TABLE island

DROP TABLE LesIslands;
CREATE TABLE LesIslands of T_Island;

-- TYPE COUNTRY

DROP TYPE T_Country;
/
CREATE OR REPLACE TYPE T_Country AS OBJECT(
    idcode VARCHAR2(4),
    nameC VARCHAR2(35),
    member function toXML return XMLType
)
/
CREATE OR REPLACE TYPE EnsMountains AS TABLE OF T_Mountain;
/
CREATE OR REPLACE TYPE EnsDeserts AS TABLE OF T_Desert;
/
CREATE OR REPLACE TYPE EnsIslands AS TABLE OF T_Island;
/
CREATE OR REPLACE TYPE BODY T_Country AS 
member function toXML return XMLType IS
output XMLType;
    tmpMountains EnsMountains;
    tmpDeserts   EnsDeserts;
    tmpIslands   EnsIslands;
    heightP      NUMBER;

    BEGIN
      output := XMLType.CREATExml('<country name="'||nameC||'"/>');  
      output := XMLType.appendchildxml(output,'country',XMLType('<geo/>'));
      
      -- Elements Mountain
      SELECT VALUE(m) BULK COLLECT INTO tmpMountains
      FROM LesMountains m
      WHERE idcode = m.idcountry;
      FOR indx IN 1..tmpMountains.COUNT
      loop
         output := XMLType.appendchildxml(output,'country/geo', tmpMountains(indx).toXML());   
      END loop; 

      -- Elements Desert
      SELECT VALUE(d) BULK COLLECT INTO tmpDeserts
      FROM LesDeserts d
      WHERE idcode = d.idcountry;
      FOR indx IN 1..tmpDeserts.COUNT
      loop
         output := XMLType.appendchildxml(output,'country/geo', tmpDeserts(indx).toXML());   
      END loop; 

      -- Element Island
      SELECT VALUE(i) BULK COLLECT INTO tmpIslands
      FROM LesIslands i
      WHERE idcode = i.idcountry;
      FOR indx IN 1..tmpIslands.COUNT
      loop
         output := XMLType.appendchildxml(output,'country/geo', tmpIslands(indx).toXML());   
      END loop;

      -- AJOUT DE L'ELEMENT peak 
      
      heightP := -1;  -- Initialiser peak à -1

      SELECT VALUE(m) BULK COLLECT INTO tmpMountains
      FROM LesMountains m
      WHERE idcode = m.idcountry;
      FOR indx IN 1..tmpMountains.COUNT
      loop
         IF tmpMountains(indx).heightM > heightP THEN
            heightP := tmpMountains(indx).heightM;            -- Nouveau peak trouvé
         END IF;
      END loop; 

      output := XMLType.appendchildxml(output, 'country', XMLType('<peak height = "'||heightP||'"/>'));

      return output;
   end;
end;
/

-- TABLE Country

DROP TABLE LesCountry;
CREATE TABLE LesCountry OF T_Country;

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
      FROM LesCountry c ;
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

-- INSERTIONS 

INSERT INTO LesMountains
SELECT T_Mountain(m.name, m.height ,g.country)
FROM Mountain m, GEO_MOUNTAIN g
WHERE g.mountain = m.name;

INSERT INTO LesDeserts
SELECT T_Desert(d.name , d.area, g.country)
FROM Desert d, GEO_DESERT g 
WHERE g.desert = d.name;

INSERT INTO LesIslands
SELECT T_Island(i.name , i.coordinates.latitude , i.coordinates.longitude, g.country)
FROM Island i, GEO_ISLAND g
WHERE i.name = g.island;

INSERT INTO LesCountry
SELECT T_Country(c.code , c.name)
FROM Country c;

INSERT INTO ex2 VALUES('test');

-- exporter le r�sultat dans un fichier 
WbExport -type=text
         -file='test2.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select e.toXML().getClobVal() 
from ex2 e;


