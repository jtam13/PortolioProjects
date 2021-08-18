/*
LA Crimes Data Exploration

Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
 
 #Reformat VictimDescent column to show full names of descent without abbreviations

SELECT DISTINCT(VictimDescent), COUNT(VictimDescent) AS Total FROM crime_data GROUP BY VictimDescent ORDER BY Total DESC;
UPDATE crime_data SET VictimDescent = 'Other Asian' WHERE VictimDescent = 'A'; 
UPDATE crime_data SET VictimDescent = 'Black' WHERE VictimDescent = 'B';
UPDATE crime_data SET VictimDescent = 'Chinese' WHERE VictimDescent = 'C';
UPDATE crime_data SET VictimDescent = 'Filipino' WHERE VictimDescent = 'F';
UPDATE crime_data SET VictimDescent = 'Guamanian' WHERE VictimDescent = 'G';
UPDATE crime_data SET VictimDescent = 'Hispanic' WHERE VictimDescent = 'H';
UPDATE crime_data SET VictimDescent = 'Native American' WHERE VictimDescent = 'I';
UPDATE crime_data SET VictimDescent = 'Japanese' WHERE VictimDescent = 'J';
UPDATE crime_data SET VictimDescent = 'Korean' WHERE VictimDescent = 'K';
UPDATE crime_data SET VictimDescent = 'Other' WHERE VictimDescent = 'O';
UPDATE crime_data SET VictimDescent = 'Pacific Islander' WHERE VictimDescent = 'P';
UPDATE crime_data SET VictimDescent = 'Samoan' WHERE VictimDescent = 'S';
UPDATE crime_data SET VictimDescent = 'Hawaiian' WHERE VictimDescent = 'Hawaian';
UPDATE crime_data SET VictimDescent = 'Vietnamese' WHERE VictimDescent = 'V';
UPDATE crime_data SET VictimDescent = 'Unknown' WHERE VictimDescent = 'X';
UPDATE crime_data SET VictimDescent = 'White' WHERE VictimDescent = 'W';
UPDATE crime_data SET VictimDescent = 'Indian' WHERE VictimDescent = 'Z';
UPDATE crime_data SET VictimDescent = 'Cambodian' WHERE VictimDescent = 'D';
UPDATE crime_data SET VictimDescent = 'Laotian' WHERE VictimDescent = 'L';

#Select data that we are going to be starting with

SELECT CrimeCode, MOCodes, VictimAge, VictimSex, AreaID, AreaName, PremiseCode, StatusDescription
FROM crime_data;

#CREATE VIEWS FOR VIOLENT AND NONVIOLENT CRIMES

#Categorize violent crimes from crime codes

CREATE VIEW violent_crime AS
SELECT Crime_Code, Description
FROM crime_codes
WHERE Description REGEXP 'assault|battery|homicide|robbery|rape|abuse|shots|lynching|bombing|weapon|sex|kidnap|fired|murder'; 

#Categorize nonviolent crimes from crime codes

CREATE VIEW nonviolent_crime AS
SELECT Crime_Code, Description
FROM crime_codes
WHERE crime_code NOT IN (
SELECT crime_code FROM violent_crime) AND LENGTH(description) > 1;

#CRIME PATTERN ANALYSIS

#Number of crimes on men vs number of crimes on women

SELECT VictimSex, COUNT(VictimSex) AS Count
FROM crime_data
GROUP BY VictimSex
ORDER BY Count DESC;

#Show what ages are most commonly victims of crime

SELECT VictimAge, COUNT(VictimAge) AS Count
FROM crime_data
GROUP BY VictimAge
ORDER BY Count DESC;

#Show what descents/races are most commonly victims of crime

SELECT VictimDescent, COUNT(VictimDescent) AS Count
FROM crime_data
GROUP BY VictimDescent
ORDER BY Count DESC;

#Show what types of crimes are most commonly directed at women vs men

SELECT CrimeCode, c.Description AS Description, VictimSex, COUNT(VictimSex) AS Count
FROM crime_data d
JOIN crime_codes c ON d.CrimeCode =  c.Crime_Code
GROUP BY CrimeCode, VictimSex
ORDER BY CrimeCode;

#Type of crime vs crime status
#Show if certain types of crimes are more commonly left as cold cases

SELECT CrimeCode, c.Description, StatusDescription, COUNT(StatusDescription) AS Count
FROM crime_data d 
JOIN crime_codes c ON d.CrimeCode = c.Crime_Code
GROUP BY CrimeCode, StatusDescription
ORDER BY CrimeCode, Count;

#TEMPORAL AND SPATIAL ANALYSIS
 
#Find the types of crimes that happen at all listed locations and see where the most common crimes take place

SELECT PremiseCode, prem.Description, CrimeCode, cri.Description, COUNT(CrimeCode) AS Count
FROM crime_data dat
JOIN premise_codes prem ON prem.Premise_Code = dat.PremiseCode
JOIN crime_codes cri On cri.Crime_Code = dat.CrimeCode
GROUP BY PremiseCode, CrimeCode
ORDER BY Count DESC;

#Cross reference data to check the accuracy of the previous query

SELECT PremiseCode, CrimeCode, COUNT(CrimeCode)
FROM crime_data
WHERE PremiseCode = 502 AND CrimeCode = 626
GROUP BY PremiseCode;

#Find the most common times for violent crimes using a temp table to get the times of all violent crimes

DROP TEMPORARY TABLE IF EXISTS violent_time;

CREATE TEMPORARY TABLE violent_time (
select CrimeCode, Description, TimeOccurred, count(TimeOccurred) over (partition by CrimeCode order by TimeOccurred) as TimeCount
from crime_data 
join crime_codes on CrimeCode = Crime_Code
where CrimeCode in (
select crime_code from violent_crime));

SELECT CrimeCode, Description, TimeOccurred, MAX(TimeCount) AS CrimeCount
FROM violent_time
GROUP BY CrimeCode
ORDER BY CrimeCount DESC;

#Find the most common times for nonviolent crimes using a temp table to get the times of all nonviolent crimes

DROP TEMPORARY TABLE IF EXISTS nonviolent_time;

CREATE TEMPORARY TABLE nonviolent_time (
select CrimeCode, Description, TimeOccurred, Count(TimeOccurred) over (partition by CrimeCode order by TimeOccurred) as TimeCount
from crime_data 
join crime_codes on CrimeCode = Crime_Code
where CrimeCode in (
select crime_code from nonviolent_crime));

SELECT CrimeCode, Description, TimeOccurred, MAX(TimeCount) AS CrimeCount
FROM nonviolent_time
GROUP BY CrimeCode
ORDER BY CrimeCount DESC;

#Find the most common premises and areas for violent crimes using a temp table to get the locations of all violent crimes

DROP TEMPORARY TABLE IF EXISTS violent_location;

CREATE TEMPORARY TABLE violent_location (
select CrimeCode, cri.Description as Crime, PremiseCode, prem.Description as Premise, Count(PremiseCode) over (partition by CrimeCode order by PremiseCode) as PremCount, AreaID, AreaName, Count(AreaID) Over (Partition By CrimeCode Order By AreaId) as AreaCount
from crime_data
join crime_codes cri on CrimeCode = Crime_Code
join premise_codes prem on PremiseCode = Premise_Code
where CrimeCode in (
select Crime_Code from violent_crime)
);

SELECT CrimeCode, Crime, PremiseCode, Premise, MAX(PremCount) AS PremCount, AreaID, AreaName, MAX(AreaCount) AS AreaCount
FROM violent_location
GROUP BY CrimeCode, PremiseCode, AreaID
ORDER BY PremCount DESC, AreaCount DESC;

#Find the most common premises and areas for nonviolent crimes using a temp table to get the locations of all nonviolent crimes

DROP TEMPORARY TABLE IF EXISTS nonviolent_location;

CREATE TEMPORARY TABLE nonviolent_location (
select CrimeCode, cri.Description as Crime, PremiseCode, prem.Description as Premise, Count(PremiseCode) over (partition by CrimeCode order by PremiseCode) as PremCount, AreaID, AreaName, Count(AreaID) Over (Partition By CrimeCode Order By AreaId) as AreaCount
from crime_data
join crime_codes cri on CrimeCode = Crime_Code
join premise_codes prem on PremiseCode = Premise_Code
where CrimeCode in (
select Crime_Code from nonviolent_crime)
);

SELECT CrimeCode, Crime, PremiseCode, Premise, MAX(PremCount) AS PremCount, AreaID, AreaName, MAX(AreaCount) AS AreaCount
FROM nonviolent_location
GROUP BY CrimeCode, PremiseCode, AreaID
ORDER BY PremCount DESC, AreaCount DESC;

#Find the time between when a crime occurs and when a crime is reported

SELECT CrimeCode, Description, DateOccurred, DateReported, DATEDIFF(STR_TO_DATE(DateReported, '%m/%d/%Y'), STR_TO_DATE(DateOccurred, '%m/%d/%Y')) AS Duration
FROM crime_data
JOIN crime_codes ON CrimeCode = Crime_Code;

#Find the average response time in each area

SELECT AreaID, AreaName, AVG(DATEDIFF(STR_TO_DATE(DateReported, '%m/%d/%Y'), STR_TO_DATE(DateOccurred, '%m/%d/%Y'))) AS AvgResponse
FROM crime_data
GROUP BY AreaID
ORDER BY AvgResponse DESC;



