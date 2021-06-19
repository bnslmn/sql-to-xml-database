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

-- La séquence des pays qui détiennent la première place
-- en terme de total de population par rapport aux pays du même continent

-- TYPE COUNTRY

DROP TYPE T_Country FORCE;
/
CREATE OR REPLACE TYPE T_Country AS OBJECT(
    idCountry VARCHAR2(4),
    nameC   VARCHAR2(35),
    continentC VARCHAR2 (20),
    populationC NUMBER,
    member function toXML return XMLType
)
/
CREATE OR REPLACE TYPE BODY T_Country AS
member function toXML return XMLType IS
output XMLType;
    begin
    output := XMLType.createxml('<country name = "'||nameC||'" population = "'||populationC||'"/>');
    return output;
    end;
end;
/

-- TABLE Country

DROP TABLE LesCountrys;
CREATE TABLE LesCountrys OF T_Country;


-- TYPE Continent
DROP TYPE T_Continent FORCE;
/
CREATE OR REPLACE TYPE T_Continent AS OBJECT (
    idContinent VARCHAR2(20),
    member function toXML return XMLType
)
/
-- Stocker les countrys dans continent
CREATE OR REPLACE TYPE EnsCountry AS TABLE OF T_Country;

CREATE OR REPLACE TYPE BODY T_Continent AS
member function toXML return XMLType IS
output XMLType;
    tmpCountry EnsCountry;
    begin
        output := XMLType.createxml('<continent name = "'||idContinent||'"/>');

        -- Element country
         SELECT VALUE(c) BULK COLLECT INTO tmpCountry
        FROM LesCountrys c
        WHERE idContinent = c.continentC;
        for indx IN 1..tmpCountry.COUNT
        loop
            output := XMLType.appendchildxml(output,'continent', tmpCountry(indx).toXML());  
        end loop;

        return output;
    end;
end;
/

-- TABLE Continent

DROP TABLE LesContinents;
CREATE TABLE LesContinents OF T_Continent;


-- TYPE ex3
DROP TYPE T_ex3 FORCE;
/
CREATE OR REPLACE TYPE T_ex3 AS OBJECT(
    name  VARCHAR2(10),
    member function toXML return XMLType
)
/

-- Stocker les Continents dans ex3

CREATE OR REPLACE TYPE EnsContinent AS TABLE OF T_Continent;
/


CREATE OR REPLACE TYPE BODY T_ex3 AS
member function toXML return XMLType IS
output XMLType;
    tmpContinent EnsContinent;
    begin
        output := XMLType.createxml('<ex3/>');

        -- Element country

        SELECT VALUE(c) BULK COLLECT INTO tmpContinent
        FROM LesContinents c;
        for indx IN 1..tmpContinent.COUNT
        loop
            output := XMLType.appendchildxml(output,'ex3', tmpContinent(indx).toXML());  
        end loop;

        return output; 
    end;
end;
/

-- TABLE ex3 
DROP TABLE ex3;
CREATE TABLE ex3 OF T_ex3;


-- INSERTIONS :

INSERT INTO LesCountrys
SELECT T_Country(c.code , c.name , e.continent , c.population)
FROM Country c, ENCOMPASSES e 
WHERE c.code = e.country;

INSERT INTO LesContinents (idcontinent)
SELECT DISTINCT e.continent
FROM ENCOMPASSES e;

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

-- Autre solution : Ajouter que les pays qui ont la plus forte population de tout les continents pour faciliter xPath !

SELECT c1.code , c1.name , e1.continent , MAX(c1.population)
 FROM Country c1, Encompasses e1
 WHERE c1.code = e1.country;

