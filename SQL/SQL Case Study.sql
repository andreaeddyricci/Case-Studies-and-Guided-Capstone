

/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name 
FROM Facilities 
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */ 4
SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance 
FROM Facilities 
WHERE membercost < .20 * monthlymaintenance
AND membercost > 0;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM Facilities WHERE facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	ELSE 'cheap' END
	AS cost_category
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname,surname
FROM Members
ORDER BY joindate DESC;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT name AS facility_name, concat(surname,', ',firstname) AS member
FROM Bookings
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
LEFT JOIN Members
ON Bookings.memid = Members.memid
WHERE Bookings.facid IN (0,1)
AND Bookings.memid <> 0
GROUP BY facility_name, member
ORDER BY member;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT name AS facility, concat(surname,', ',firstname) AS name,
	CASE WHEN (Bookings.memid = 0 AND guestcost*slots > 30) THEN guestcost*slots
	WHEN (Bookings.memid <> 0 AND membercost*slots > 30) THEN membercost*slots END AS cost
FROM Bookings
LEFT JOIN Facilities
	ON Bookings.facid = Facilities.facid
LEFT JOIN Members
	ON Bookings.memid = Members.memid
WHERE starttime LIKE '2012-09-14 %'
	AND (Bookings.memid = 0 AND guestcost*slots > 30)
	OR (Bookings.memid <> 0 AND membercost*slots > 30)
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT name, cost
FROM(
	SELECT name AS facility, concat(surname,', ',firstname) AS name,
	CASE WHEN (Bookings.memid = 0 AND guestcost*slots > 30) THEN guestcost*slots
	WHEN (Bookings.memid <> 0 AND membercost*slots > 30) THEN membercost*slots END AS cost
	FROM Bookings
	LEFT JOIN Facilities
		ON Bookings.facid = Facilities.facid
	LEFT JOIN Members
		ON Bookings.memid = Members.memid
	WHERE starttime LIKE '2012-09-14 %'
		AND (Bookings.memid = 0 AND guestcost*slots > 30)
		OR (Bookings.memid <> 0 AND membercost*slots > 30)) AS subquery
ORDER BY cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT name AS facility,
	SUM(CASE WHEN Bookings.memid = 0 THEN guestcost*slots
	WHEN Bookings.memid <> 0 THEN membercost*slots END) AS total_revenue
FROM Bookings
LEFT JOIN Facilities
	ON Bookings.facid = Facilities.facid
WHERE guestcost*slots < 1000
	OR membercost*slots < 1000
GROUP BY name
ORDER BY total_revenue DESC;


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT m1.surname,m1.firstname,m2.surname AS surname_recommendedby, m2.firstname AS firstname_recommendedby
FROM Members AS m1
INNER JOIN Members AS m2
	ON m1.recommendedby = m2.memid
WHERE m1.memid <> 0
ORDER BY m2.surname,m2.firstname;


/* Q12: Find the facilities with their usage by member, but not guests */
SELECT facid, memid, COUNT(bookid)
FROM Bookings
WHERE memid != 0
GROUP BY facid,memid;

/* Q13: Find the facilities usage by month, but not guests */
SELECT EXTRACT(MONTH FROM starttime) AS month, facid, COUNT(bookid)
FROM Bookings
WHERE memid != 0
GROUP BY month, facid;
