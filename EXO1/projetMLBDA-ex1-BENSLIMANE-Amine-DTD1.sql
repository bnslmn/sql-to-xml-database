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

-- DTD 1 :

        -- Création des TYPEs et des tables :

-- TYPE Airport :

DROP TYPE T_Airport FORCE;
/
CREATE OR REPLACE  TYPE T_Airport AS object (
   name     VARCHAR2(55 Byte),
   nearCity VARCHAR2(35 Byte),
   country  VARCHAR2(4 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Airport AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<airport name="'||name||'" nearCity="'||nearCity||'"/>');
      return output;
   END;
END;
/

-- TABLE Airport : TEST XML OK

DROP TABLE LesAirports;

CREATE TABLE LesAirports of T_Airport;


-- TYPE Continent : TEST XML OK

DROP TYPE T_Continent FORCE;
/
CREATE OR REPLACE  TYPE T_Continent AS object (
   name     VARCHAR2(35 Byte),
   percent  VARCHAR2(10 Byte),
   country  VARCHAR2(4 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Continent AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<continent name="'||name||'" percent="'||percent||'"/>');
      return output;
   END;
END;
/

-- TABLE continent : TEST XML OK

DROP TABLE LesContinents;
CREATE TABLE LesContinents of T_Continent;


-- TYPE island
DROP TYPE T_Island FORCE;
/
CREATE OR REPLACE  TYPE T_Island AS object (
   name      VARCHAR2(35 Byte),
   latitude  number,
   longitude number,
   nameprovince  VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Island AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<island name="'||name||'"/>');
      output := XMLType.appendchildxml(output,'island', XMLType('<coordinates latitude="'||latitude||'" longitude="'||longitude||'"/>'));
      return output;
   END;
END;
/

-- TABLE island

DROP TABLE LesIslands;
CREATE TABLE LesIslands of T_Island;


-- TYPE Desert

DROP TYPE T_Desert FORCE;
/
CREATE OR REPLACE  TYPE T_Desert AS object (
   name     VARCHAR2(35 Byte),
   area     Number,
   nameprovince  VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Desert AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<desert name="'||name||'" area="'||area||'"/>');
      return output;
   END;
END;
/

-- TABLE Desert 

DROP TABLE LesDeserts;
CREATE TABLE LesDeserts OF T_Desert;

-- TYPE Mountain

DROP TYPE T_Mountain FORCE;
/
CREATE OR REPLACE  TYPE T_Mountain AS object (
   name     VARCHAR2(35 Byte),
   height   Number,
   nameprovince  VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Mountain AS
 member function toXML return XMLType IS
   output XMLType;
   BEGIN
      output := XMLType.CREATExml('<mountain name="'||name||'" height="'||height||'"/>');
      return output;
   END;
END;
/


-- TABLE Mountain

DROP TABLE LesMontains;
CREATE TABLE LesMountains OF T_Mountain;


-- TYPE Province

DROP TYPE T_Province FORCE;
/
CREATE OR REPLACE TYPE T_EnsMountains AS TABLE of T_Mountain;
/
CREATE OR REPLACE TYPE T_EnsDeserts AS TABLE of T_Desert;
/
CREATE OR REPLACE TYPE T_EnsIslands AS TABLE of T_Island;
/
CREATE OR REPLACE  TYPE T_Province AS object (
   nameP    VARCHAR2(35 Byte),
   capital  VARCHAR2(35 Byte),
   country  VARCHAR2(4 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Province AS
 member function toXML return XMLType IS
   output XMLType;
   tmpMontagne T_EnsMountains;
   tmpDesert T_EnsDeserts;
   tmpISland T_EnsIslands;
   BEGIN
      output := XMLType.CREATExml('<province name="'||nameP||'" capital="'||capital||'"/>');
      SELECT value(m) BULK COLLECT into tmpMontagne
      FROM LesMountains m
      WHERE nameP = m.nameprovince ;  
      FOR indx IN 1..tmpMontagne.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpMontagne(indx).toXML());   
      END loop; 
      SELECT value(d) BULK COLLECT into tmpDesert
      FROM LesDeserts d
      WHERE nameP = d.nameprovince ;  
      FOR indx IN 1..tmpDesert.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpDesert(indx).toXML());   
      END loop; 
      SELECT value(s) BULK COLLECT into tmpISland
      FROM LesIslands s
      WHERE nameP = s.nameprovince ;  
      FOR indx IN 1..tmpISland.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpISland(indx).toXML());   
      END loop; 
      return output;
   END;
END;
/

-- TABLE Province
DROP TABLE LesProvinces;
CREATE TABLE LesProvinces OF T_Province;

-- TYPE Country :

DROP TYPE T_Country FORCE;
/
CREATE OR REPLACE TYPE T_EnsContinents AS TABLE of T_Continent;
/
CREATE OR REPLACE TYPE T_EnsProvinces AS TABLE of T_Province;
/
CREATE OR REPLACE TYPE T_EnsAirports AS TABLE of T_Airport;
/
CREATE OR REPLACE  TYPE T_Country AS object (
   idcountry  VARCHAR2(4 Byte),
   name       VARCHAR2(35 Byte),
   member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE body T_Country AS
   member function toXML return XMLType IS
     output XMLType;
     tmpContinent T_EnsContinents;
     tmpProvinces T_EnsProvinces;
     tmpAirpORt T_EnsAirpORts;
     BEGIN
        output := XMLType.CREATExml('<country idcountry="'||idcountry||'" nom="'||name||'"/>');
        SELECT value(c) BULK COLLECT into tmpContinent
        FROM LesContinents c
        WHERE idcountry = c.country ;  
        FOR indx IN 1..tmpContinent.COUNT
        loop
           output := XMLType.appendchildxml(output,'country', tmpContinent(indx).toXML());   
        END loop; 
        SELECT value(p) BULK COLLECT into tmpProvinces
        FROM LesProvinces p
        WHERE idcountry = p.country;  
        FOR indx IN 1..tmpProvinces.COUNT
        loop
           output := XMLType.appendchildxml(output,'country', tmpProvinces(indx).toXML());   
        END loop; 
        SELECT value(t) BULK COLLECT into tmpAirpORt
        FROM LesAirports t
        WHERE idcountry = t.country ;  
        FOR indx IN 1..tmpAirpORt.COUNT
        loop
           output := XMLType.appendchildxml(output,'country', tmpAirpORt(indx).toXML());   
        END loop; 
        return output;
   END;
END;
/


-- TABLE COUNTRY

DROP TABLE LesCountrys;
CREATE TABLE LesCountrys OF T_Country;

-- TYPE MONDIAL

DROP TYPE T_mondial FORCE;

-- Stocker T_Country Dans T_ensCountry

DROP TYPE T_ensCountry;
CREATE OR REPLACE TYPE T_ensCountry AS TABLE OF T_country;
/

CREATE OR REPLACE TYPE T_mondial AS OBJECT(
    name VARCHAR2(50),
    member function toXML return XMLType
)
/



CREATE OR REPLACE TYPE body T_mondial AS
 member function toXML return XMLType IS
   output XMLType;
   tmpCountry T_ensCountry;
   BEGIN
      output := XMLType.CREATExml('<mondial/>');
      SELECT value(c) BULK COLLECT into tmpCountry
        FROM LesCountrys c;  
        FOR indx IN 1..tmpCountry.COUNT
        loop
           output := XMLType.appendchildxml(output,'mondial', tmpCountry(indx).toXML());   
        END loop; 
      return output;
   END;
END;
/

-- TABLE Mondial

DROP TABLE Mondial;
CREATE TABLE Mondial OF T_Mondial;

-- INSERTIONS

INSERT INTO LesCountrys
SELECT T_country(p.code , p.name)
FROM COUNTRY p;


INSERT INTO LesContinents
 SELECT T_continent(c.continent , c.percentage , c.country)
FROM ENCOMPASSES c;

INSERT INTO LesProvinces
SELECT T_province(p.name , p.capital , p.country)
FROM PROVINCE p;

INSERT INTO LesAirports
SELECT T_Airport(p.name , p.city, p.country)
FROM Airport p;

INSERT INTO LesMountains
SELECT T_mountain(m.name, m.height, g.province)
FROM MOUNTAIN m, GEO_MOUNTAIN g 
WHERE g.mountain = m.name;

INSERT INTO LesDeserts
SELECT T_desert(d.name , d.area , g.province)
FROM DESERT d, GEO_DESERT g 
WHERE g.desert = d.name;

INSERT INTO LesIslands
SELECT T_Island(i.name, i.coordinates.latitude , i.coordinates.longitude , g.province)
FROM island i, GEO_ISLAND g 
WHERE g.island = i.name;

INSERT INTO Mondial VALUES ('Monde');

-- affichage du r�sultat
-- @WbOptimizeRowHeight lines=100
SELECT c.toXML().getClobVal() 
FROM Mondial c;


-- expORter le r�sultat dans un fichier 
WbExpORt -TYPE=text
         -file='testdtd1.xml'
         -CREATEDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFORmat='yyyy-MM-dd'
/
SELECT m.toXML().getClobVal() 
FROM Mondial m;

SELECT a.toXML().getClobVal()
FROM LesAirports a;
SELECT a.toXML().getClobVal()
FROM LesContinents a;
SELECT a.toXML().getClobVal()
FROM LesIslands a;
SELECT a.toXML().getClobVal()
FROM LesDeserts a;
SELECT a.toXML().getClobVal()
FROM LesMontagnes a;
SELECT a.toXML().getClobVal()
FROM LesProvinces a;
SELECT a.toXML().getClobVal()
FROM Mondial a;











