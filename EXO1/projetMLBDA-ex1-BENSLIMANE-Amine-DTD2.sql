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

/* 
  Headquarter sera finalement un attribut de Organization 


-- TYPE headquarter

DROP TYPE T_headquarter FORCE;

CREATE OR REPLACE TYPE T_headquarter AS OBJECT(
    name VARCHAR2(40),
    nameOrg VARCHAR2(80),
    member function toXML return XMLType
)
/
CREATE OR REPLACE TYPE BODY T_headquarter AS
member function toXML return XMLType IS
output XMLType;
    begin
     output := XMLType.createxml('<headquarter name = "'||name||'"/>');
     return output;
    end;
end;
/

-- TABLE LesHeadquarters

DROP TABLE LesHeadquarters;
CREATE TABLE LesHeadquarters OF T_headquarter; */


-- TYPE border

DROP TYPE T_borders FORCE;
/
CREATE OR REPLACE TYPE T_borders AS OBJECT(
    countryCode1 VARCHAR2(4),
    countryCode2 VARCHAR2(4),
    length NUMBER,
    member function toXML return XMLType
)
/
CREATE OR REPLACE TYPE BODY T_borders AS
member function toXML return XMLType IS
output XMLType;
    begin
        output := XMLType.createxml('<border countryCode = "'||countryCode2||'" length = "'||length||'"/>');

        return output;
    end;
end;
/

-- TABLE LesBorder

DROP TABLE LesBorders;
CREATE TABLE LesBorders OF T_borders;



-- TYPE Langage

DROP TYPE T_langage FORCE;
/
CREATE OR REPLACE TYPE T_langage AS OBJECT(
    name VARCHAR2(50),
    country VARCHAR2(4),
    percent NUMBER,
    member function toXML return XMLType
)
/
CREATE OR REPLACE TYPE BODY T_langage AS
member function toXML return XMLType IS
output XMLType;
    begin
        output := XMLType.createxml('<language language = "'||name||'" percent = "'||percent||'"/>');
        return output;
    end;
end;
/

-- TABLE langage

DROP TABLE LesLangages;
CREATE TABLE LesLangages OF T_langage;

-- TYPE Country

DROP TYPE T_country FORCE;
/

CREATE OR REPLACE TYPE T_country AS OBJECT(
    code VARCHAR2(4),
    name VARCHAR2(35),
    population NUMBER,
    org VARCHAR2(12),
    member function toXML return XMLType
)
/
-- Stocker des langages dans country
DROP TYPE EnsLangages FORCE;
CREATE TYPE EnsLangages AS TABLE OF T_langage;
/
--Stocker des borders dans country
DROP TYPE EnsBorders FORCE;
CREATE TYPE EnsBorders AS TABLE OF T_borders;
/
CREATE OR REPLACE TYPE BODY T_country AS
member function toXML return XMLType IS
output XMLType;
    tmpLangages EnsLangages;
    tmpBorders  EnsBorders;

    begin
        output := XMLType.createxml('<country code = "'||code||'" name = "'||name||'" population = "'||population||'"/>');
        -- Element Langage
        SELECT VALUE(l) BULK COLLECT INTO tmpLangages
        FROM LesLangages l
        WHERE code = l.country;
        for indx IN 1..tmpLangages.COUNT
        loop
            output := XMLType.appendchildxml(output,'country', tmpLangages(indx).toXML());   
        end loop;

        output := XMLType.appendchildxml(output, 'country', XMLType('<borders/>'));
        
        -- Element Borders
        SELECT VALUE(b) BULK COLLECT INTO tmpBorders
        FROM LesBorders b 
        WHERE code = b.countryCode1;
        for indx IN 1..tmpBorders.COUNT
        loop
            output := XMLType.appendchildxml(output,'country/borders', tmpBorders(indx).toXML());   
        end loop;
        return output;
    end;
end;
/

-- TABLE Country

DROP TABLE LesCountry;

CREATE TABLE LesCountry OF T_country;

-- TYPE Organization

DROP TYPE T_organization FORCE;
/

CREATE OR REPLACE TYPE T_organization AS OBJECT(
    abbreviation VARCHAR2(12),
    city VARCHAR2(35),
    member function toXML return XMLType
)
/
CREATE OR REPLACE TYPE EnsCountry AS TABLE OF T_country;
/
CREATE OR REPLACE TYPE BODY T_organization AS
member function toXML return XMLType IS
output XMLType;
    tmpCountry EnsCountry;
    begin
        output:= XMLType.createxml('<organization/>');

        -- Element country
        SELECT VALUE(c) BULK COLLECT INTO tmpCountry
        FROM LesCountry c
        WHERE abbreviation = c.org;
        for indx IN 1..tmpCountry.COUNT
        loop
            output := XMLType.appendchildxml(output,'organization', tmpCountry(indx).toXML());   
        end loop;

        -- Element headquarter
        output := XMLType.appendchildxml(output,'organization', XMLType('<headquarter name ="'||city||'" />'));
        return output;
    end;
end;
/


-- TABLE Organization

DROP TABLE LesOrganizations;

CREATE TABLE LesOrganizations OF T_organization;

-- TYPE Mondial

DROP TYPE T_mondial FORCE;
CREATE OR REPLACE TYPE T_mondial AS OBJECT(
    monde VARCHAR2(12),
    member function toXML return XMLType
)
/

CREATE OR REPLACE TYPE EnsOrganization AS TABLE OF T_organization;
/

CREATE OR REPLACE TYPE BODY T_mondial AS
member function toXML return XMLType IS
output XMLType;
    tmpOrganization EnsOrganization;

    begin
        output := XMLType.createxml('<mondial/>');

        -- Element organization
        SELECT VALUE(o) BULK COLLECT INTO tmpOrganization
        FROM LesOrganizations o;
        for indx IN 1..tmpOrganization.COUNT
        loop
            output := XMLType.appendchildxml(output,'mondial', tmpOrganization(indx).toXML());   
        end loop;

        return output;
    end;
end;
/

-- TABLE Mondial

DROP TABLE Mondial;

CREATE TABLE Mondial OF T_mondial;

-- INSERTIONS :

-- On insère deux fois en permutant les codes car Borders n'est pas symétrique !

INSERT INTO LesBorders
SELECT T_borders(b.country1, b.country2, b.length )
FROM BORDERS b;
INSERT INTO LesBorders
SELECT T_borders(b.country2, b.country1, b.length )
FROM BORDERS b;



INSERT INTO LesLangages
SELECT T_langage(l.name , l.country, l.percentage)
FROM LANGUAGE l;

INSERT INTO LesCountry
SELECT T_country(c.code, c.name, c.population, i.organization)
FROM COUNTRY c, IsMember i 
WHERE c.code = i.country;

INSERT INTO LesOrganizations
SELECT T_organization(o.abbreviation , o.city)
FROM ORGANIZATION o;


-- On a besoin que d'un seul élément mondial ;

INSERT INTO Mondial VALUES ('Monde');


-- exporter le r�sultat dans un fichier 
WbExport -type=text
         -file='mondial.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from Mondial m;



