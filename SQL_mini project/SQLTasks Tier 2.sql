/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

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

/*
SELECT `facid`, `name`, `membercost`, `guestcost`, `initialoutlay`, `monthlymaintenance` FROM `Facilities`
SELECT `memid`, `surname`, `firstname`, `address`, `zipcode`, `telephone`, `recommendedby`, `joindate` FROM `Members`
SELECT `bookid`, `facid`, `memid`, `starttime`, `slots` FROM `Bookings`
*/

/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

      	   SELECT name FROM Facilities WHERE membercost>=0.01

/* Q2: How many facilities do not charge a fee to members? */

       	   SELECT count(name) FROM Facilities WHERE membercost=0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

	   SELECT facid, name, membercost, monthlymaintenance FROM Facilities 
	   WHERE membercost between 0.01 and monthlymaintenance/5

/*or*/

	   SELECT facid, name, membercost, monthlymaintenance FROM Facilities 
	   WHERE membercost > 0 and membercost < monthlymaintenance/5 	

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

    	   SELECT * FROM `Facilities` WHERE facid in (1,5) 

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

   	   SELECT name,
       	   	  CASE WHEN monthlymaintenance > 100 THEN 'expensive' 
         	  ELSE 'cheap' END as type,
	   	  monthlymaintenance	
	   FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

    	   SELECT firstname,surname, joindate FROM `Members` WHERE joindate = (select max(joindate) from Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

    	   SELECT Distinct f.name, concat (m.firstname,' ', m.surname) as member_name
	   FROM Bookings as b
	   Left join Facilities as f
	   	on b.facid=f.facid
	   Left join Members as m
	   	on b.memid=m.memid
	   Where b.memid>0    /* the questions ask for members only not guest!*/
	   order by  m.surname, m.firstname   /* or by member_name not sure which way the question wants*/

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

      	   Select name as F_Name, concat (m.firstname,' ', m.surname) as Member_Name,
	   Case when b.memid>0 then membercost*slots
			else guestcost*slots End as cost
	   From Bookings as b
	   Left join Facilities as f
	   	on b.facid=f.facid
	   Left join Members as m
	   	on b.memid=m.memid
	   Where starttime like '%2012-09-14%' /*and cost > 30   Not sure why it doesn't accept cost here but do in orderby ?????*/
	   having cost>30     /*solved after 1 hr searching!! */
	   order by cost desc   /*Query took 0.0027 sec*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

       	    Select F_name,Member_Name,Cost
	    From  ( Select name as F_Name, concat (m.firstname,' ', m.surname) as Member_Name,/*starttime,slots,*/
       		    	   case when b.memid>0 then slots*membercost else slots*guestcost end as Cost
	    	    From Bookings as b
		    Left join Facilities as f
	   	    	 on b.facid=f.facid
		    Left join Members as m
	   	    	 on b.memid=m.memid
	    	    Where starttime like '%2012-09-14%') as t /*TargetDayBookings*/
	    Where t.Cost>30
	    Order by t.Cost desc    /*Query took 0.0026 sec*/


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

**************************How I connected
import pandas as pd
from sqlalchemy import create_engine
engine=create_engine('sqlite:///sqlite_db_pythonsqlite.db')
Query="Select * From Members"
df = pd.read_sql_query(Query, engine)
df
***************************

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

import pandas as pd
from sqlalchemy import create_engine
engine=create_engine('sqlite:///sqlite_db_pythonsqlite.db')

Query="Select s.Facility_Name,sum(s.Rev) as Revenue \
From (SELECT f.name as Facility_Name, \
        case when b.memid>0 then slots*membercost \
        else slots*guestcost end as Rev \
        FROM `Bookings` as b Left join Facilities as f \
        on b.facid=f.facid) as s \
group by s.Facility_Name \
order by Revenue"

df = pd.read_sql_query(Query, engine)
df[df.Revenue<1000]


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

Query11="\
SELECT m.memid as Member_ID, m.surname, m.firstname, \
       m2.firstname || ' ' || m2.surname as Recommender \
FROM Members as m \
Left join (select * from Members where memid>0) as m2 \
	on m.recommendedby=m2.memid \
where m.memid>0 \
order by m.surname, m.firstname"
df11 = pd.read_sql_query(Query11, engine)
df11.set_index('Member_ID')

/* Q12: Find the facilities with their usage by member, but not guests */
Query12="\
SELECT f.name,m.Member_Name,sum(slots) as Member_Usage \
FROM Bookings as b \
Left Join (select memid,firstname || ' ' || surname as Member_Name \
           from Members where memid>0)as m \
			on m.memid=b.memid \
Left Join Facilities as f using(facid) \
WHERE b.memid>0 Group by f.name,b.memid"

df12 = pd.read_sql_query(Query12, engine)
df12

/* Q13: Find the facilities usage by month, but not guests */


Query13="\
SELECT f.name,strftime('%m', starttime) as Month,sum(slots) as Facility_Usage \
from Bookings AS b \
Left Join Facilities as f using(facid) \
WHERE b.memid > 0 \
Group by f.name,MONTH"
df13=pd.read_sql_query(Query13, engine)
df13

/*
SELECT `facid`, `name`, `membercost`, `guestcost`, `initialoutlay`, `monthlymaintenance` FROM `Facilities`
SELECT `memid`, `surname`, `firstname`, `address`, `zipcode`, `telephone`, `recommendedby`, `joindate` FROM `Members`
SELECT `bookid`, `facid`, `memid`, `starttime`, `slots` FROM `Bookings`
*/

/*
last question in MySQL
SELECT f.name,EXTRACT(MONTH FROM starttime) as month,sum(slots) as Facility_Usage 
FROM Bookings as b 
Left Join Facilities as f 
	using(facid) 
WHERE b.memid>0 Group by f.name,MONTH
*/
