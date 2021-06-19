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

-- TYPE Organization

DROP TYPE T_organization FORCE;
/

CREATE OR REPLACE TYPE T_organization AS OBJECT(
    abbreviationO VARCHAR2(12),
    establishedO DATE,
    member function toXML return XMLType
)
/
CREATE OR REPLACE TYPE BODY T_organization AS
member function toXML return XMLType IS
output XMLType;

    begin
        output:= XMLType.createxml('<organization name = "'||abbreviationO||'" date = "'||establishedO||'"/>');
        return output;
    end;
end;
/

-- TABLE ORGANIZATION

DROP TABLE LesOrganizations;

CREATE TABLE LesOrganizations OF T_organization;

-- TYPE Country

DROP TYPE T_Country FORCE;
/
CREATE OR REPLACE TYPE T_Country AS OBJECT(
    idCountry VARCHAR2(4),
    nameC   VARCHAR2(35),
    organizationC VARCHAR2(12),
    member function toXML return XMLType
)
/

-- Stocker Les organizations dans country

CREATE OR REPLACE TYPE EnsOrganization AS TABLE OF T_Organization;
/
CREATE OR REPLACE TYPE BODY T_Country AS
member function toXML return XMLType IS
output XMLType;
    tmpOrganization EnsOrganization;

    begin
        output := XMLType.createxml('<country name = "'||nameC||'"/>');

        -- Stocker élément organizations

        SELECT VALUE(o) BULK COLLECT INTO tmpOrganization
        FROM LesOrganizations o
        WHERE organizationC = o.abbreviationO;

        for indx IN 1..tmpOrganization.COUNT
        loop
            output := XMLType.appendchildxml(output,'country', tmpOrganization(indx).toXML());   
        end loop;

        return output;
    end;
end;
/

-- TABLE Country
DROP TABLE LesCountry;
CREATE TABLE LesCountry OF T_Country;


-- TYPE ex3
DROP TYPE T_ex3 FORCE;
/
CREATE OR REPLACE TYPE T_ex3 AS OBJECT(
    name  VARCHAR2(10),
    member function toXML return XMLType
)
/

-- Stocker les Continents dans ex3

CREATE OR REPLACE TYPE EnsCountry AS TABLE OF T_Country;
/


CREATE OR REPLACE TYPE BODY T_ex3 AS
member function toXML return XMLType IS
output XMLType;
    tmpCountry EnsCountry;
    begin
        output := XMLType.createxml('<ex3/>');

        -- Element country

        SELECT VALUE(c) BULK COLLECT INTO tmpCountry
        FROM LesCountry c;
        for indx IN 1..tmpCountry.COUNT
        loop
            output := XMLType.appendchildxml(output,'ex3', tmpCountry(indx).toXML());  
        end loop;

        return output; 
    end;
end;
/

-- TABLE ex3 
DROP TABLE ex3;
CREATE TABLE ex3 OF T_ex3;

-- INSERTIONS :

INSERT INTO LesOrganizations
SELECT T_Organization(o.abbreviation , o.established )
FROM Organization O;

INSERT INTO LesCountry
SELECT T_Country(c.code , c.name , i.organization)
FROM Country c, IsMember i
WHERE c.code = i.country;

INSERT INTO ex3 VALUES ('Test');

WbExpORt -TYPE=text
         -file='test3.xml'
         -CREATEDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFORmat='yyyy-MM-dd'
/
SELECT e.toXML().getClobVal() 
FROM ex3 e;


