/*
LA Crimes Data Visualization

SQL Queries
*/

#Type of crime vs crime status
#Show if certain types of crimes are more commonly left as cold cases

SELECT CrimeCode, c.Description, StatusDescription, COUNT(StatusDescription) AS Count
FROM crime_data d 
JOIN crime_codes c ON d.CrimeCode = c.Crime_Code
GROUP BY CrimeCode, StatusDescription
ORDER BY CrimeCode, Count;

#Find the types of crimes that happen at all listed locations and see where the most common crimes take place

SELECT PremiseCode, prem.Description AS Premise, CrimeCode, cri.Description AS Crime, COUNT(CrimeCode) AS Count
FROM crime_data dat
JOIN premise_codes prem ON prem.Premise_Code = dat.PremiseCode
JOIN crime_codes cri On cri.Crime_Code = dat.CrimeCode
GROUP BY PremiseCode, CrimeCode
ORDER BY Count DESC;

#Find the location and victim description of each crime from 2010-2014

SELECT CrimeCode, Description, STR_TO_DATE(DateOccurred, '%m/%d/%Y') AS Date, VictimAge, VictimSex, VictimDescent, Location
FROM crime_data
JOIN crime_codes ON CrimeCode = Crime_Code
WHERE Location IS NOT NULL AND YEAR(STR_TO_DATE(DateOccurred, '%m/%d/%Y')) BETWEEN '2010' AND '2014' 
ORDER BY DateOccurred ASC;

#Find the average response time in each area

SELECT AreaID, AreaName, AVG(DATEDIFF(STR_TO_DATE(DateReported, '%m/%d/%Y'), STR_TO_DATE(DateOccurred, '%m/%d/%Y'))) AS AvgResponse
FROM crime_data
GROUP BY AreaID
ORDER BY AvgResponse DESC;