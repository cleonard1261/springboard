/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

select name from facilities where membercost > 0.0;


/* Q2: How many facilities do not charge a fee to members? */

select count(*) from facilities where membercost = 0.0;


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

select facid, name, membercost, monthlymaintenance
       from ( 
                select facid 
                 , name 
                 , cast(membercost as decimal(4,2)) membercost 
                 , monthlymaintenance 
                 , (.20 * monthlymaintenance ) m 
                from facilities   
            ) sub 
       where membercost < m and  membercost > 0;


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

select * from facilities where facid in (1,5);


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

select  name 
        ,  monthlymaintenance 
        ,  CASE 
             WHEN monthlymaintenance >  100 THEN 'expensive' 
             ELSE 'cheap' 
           END AS fac_type 
from facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

select firstname
        , surname
from members
where joindate = (select max(joindate) from members);


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select distinct CONCAT(m.firstname, ' ',m.surname)  as membername 
        , f.name 
    from bookings b 
     join facilities f 
        on b.facid = f.facid 
     join members m 
        on b.memid = m.memid 
  where b.facid in (0,1) order by 1 ;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select  f.name 
        , CONCAT(m.firstname, ' ',m.surname)  as membername 
        , case 
             when b.memid <> 0 then f.membercost * b.slots 
             else f.guestcost * b.slots 
            end as cost 
            --  , b.starttime 
            from bookings b 
              join facilities f 
                  on b.facid = f.facid 
              join members m 
                  on b.memid = m.memid 
            where date(b.starttime) = '2012-09-14' 
                and case 
                      when b.memid <> 0 then f.membercost * b.slots 
                          else f.guestcost * b.slots 
                     end > 30 
            order by 3 desc;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
    select name, membername, cost from 
         ( select distinct f.name 
                  , CONCAT(m.firstname, ' ',m.surname)  as membername 
                  ,  f.membercost * b.slots as cost 
                  , b.starttime 
               from bookings b 
                join facilities f 
                  on b.facid = f.facid 
                join members m 
                  on b.memid = m.memid 
                 where date(b.starttime) = '2012-09-14' and b.memid <> 0  
                   and f.membercost * b.slots > 30 
            union 
            select distinct f.name 
                  , CONCAT(m.firstname, ' ',m.surname)  as membername 
                  ,  f.guestcost * b.slots as cost 
                  , b.starttime 
               from bookings b 
                join facilities f 
                  on b.facid = f.facid 
                join members m 
                  on b.memid = m.memid 
                 where date(b.starttime) = '2012-09-14' and b.memid = 0  
                   and f.guestcost * b.slots > 30 
            ) sub 
            order by 3 desc;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

     select * from 
           ( 
               select name, sum(revenue) total_revenue from 
                 ( select  f.name 
                          , f.membercost * b.slots as revenue 
                          , b.starttime 
                       from bookings b 
                        join facilities f 
                          on b.facid = f.facid 
                         where  b.memid <> 0  
                    union 
                    select  f.name 
                          , f.guestcost * b.slots as revenue 
                          , b.starttime 
                       from bookings b 
                        join facilities f 
                          on b.facid = f.facid 
                         where b.memid = 0 
                    ) sub 
                group by name 
             ) sub1 
             where total_revenue < 1000 
            order by 2;
            
/* Alternate answer for Q10 */

      select name, total_revenue from 
             ( select  f.name 
                  , sum(case 
                    when b.memid <> 0 then  f.membercost * b.slots 
                    else f.guestcost * b.slots end ) as total_revenue 
               from bookings b 
               join facilities f 
                 on b.facid = f.facid 
            group by f.name 
            order by 2 
            ) t1 
            where total_revenue < 1000 

