/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:
URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT *
FROM Facilities
WHERE `membercost` >1
LIMIT 0 , 1000

/* Q2: How many facilities do not charge a fee to members? */
SELECT * FROM `Facilities` WHERE `membercost` = 0 
5 Facilites do not charge 

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT *
FROM Facilities
Where `membercost`!=0 and `membercost` < (`monthlymaintenance`/5)

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM `Facilities` WHERE `facid`In(2,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT * ,
case when `monthlymaintenance` > 100 then 'expensive'
else 'cheap' end as  price 
FROM `Facilities`
Name of the facilities Tennis Court 1, Tennis Court 2, Massage Room 1, Massage Room 2

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

Select m.`surname`, m.`firstname`, m.`joindate` From `Members` as m
Where `joindate` = (Select Max(`joindate`) from `Members`) 

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT Concat_WS(" ", m.firstname, m.surname) as fullname, f.name
From Bookings as b, Members as m, Facilities as f
Where(b.facid = f.facid) And (b.memid = m.memid) and f.name like 'Tennis%' And m.firstname != 'GUEST'
Order by m.firstname 

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
Select f.name, CONCAT_WS(" ", m.surname, m.firstname) as fullname, starttime,
Case
when b.memid = 0 then f.guestcost * b.slots 
else f.membercost*b.slots end as cost
From Bookings as b, Facilities as f, Members as m
Where b.starttime like '2012-09-14%'
And b.memid =m.memid
And b.facid = f.facid 
And (case when m.memid = 0 Then f.guestcost*b.slots else f.membercost*b.slots end > 30)

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
Select facility, price, time
From 
(Select
      f.name as facility, b.starttime as time, 
     case
     When b.memid = 0
     then f.guestcost*b.slots 
        else f.membercost*b.slots end as price
          From Bookings as b
          Inner join Facilities as f On  b.facid = f.facid
          Inner Join Members as m On b.memid = m.memid
           ) as sub
Where Price > 30 and  time like '2012-09-14%'

PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. */

/*Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.*/
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
    SELECT f.name,
        sum(case when b.memid = 0 then guestcost*slots 
        else membercost * slots end) as revenue
        From Facilities as f
        Inner Join Bookings as b
        On f.facid = b.facid
        Group by f.name
        Having revenue < 1000
        
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
      Select m.firstName || ' ' || m.surname AS FullName, m.memid, m.recommendedby, n.firstName || ' ' ||n.surname recommended_full_name
            From Members as m
            Inner join Members as n
            Where m.recommendedby = n.memid
            Group by Fullname
            Having m.memid >0 and  m.recommendedby != 0

/* Q12: Find the facilities with their usage by member, but not guests */
   SELECT  Firstname ||' ' || surname as fullname, slots 
            FROM Members as m
            Inner Join Bookings as b
            On m.memid = b.memid
            Inner join Facilities as f
            On b.facid = f.facid
            Where firstname not like 'Guest%'
            Group by f.name, fullname

/* Q13: Find the facilities usage by month, but not guests */
SELECT f.name, Extract(Month from starttime) as month, slots
                FROM Members AS m
                Inner Join Bookings as b
                On m.memid = b.memid
                Inner join Facilities as f
                On b.facid = f.facid
                Where firstname not like 'Guest%'
                Group by f.name, month
