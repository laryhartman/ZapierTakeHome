CREATE DATABASE ZapierTakeHome;

SELECT COUNT(*) FROM tasks_used 

SELECT COUNT(*) FROM ZapierTakeHome.tasks_used_07July2017

SELECT user_id, date, COUNT(*)
		FROM ZapierTakeHome.tasks_used_07July2017
		GROUP BY user_id, date
		HAVING COUNT(*) > 1

SELECT * FROM ZapierTakeHome.tasks_used_07July2017 AS TU
JOIN (SELECT user_id, date, COUNT(*)
		FROM ZapierTakeHome.tasks_used_07July2017
		GROUP BY user_id, date
		HAVING COUNT(*) > 1) AS MyDups
ON TU.user_id = MyDups.user_id
AND	TU.date = MyDups.date
ORDER BY TU.user_id, TU.date

SELECT * 
		FROM ZapierTakeHome.tasks_used_07July2017 WHERE tasks_used_per_day = 0

CREATE TABLE ZapierTakeHome.tasks_used (
		  user_id int(11) NOT NULL,
		  date datetime NOT NULL,
		  PRIMARY KEY (user_id, date)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO ZapierTakeHome.tasks_used(user_id, date)
		SELECT DISTINCT user_id, date
		FROM ZapierTakeHome.tasks_used_07July2017

        
SELECT Active.Month, Active.Monthname, Active.ActiveUsers, Churn.ChurnUsers
FROM (
		/* A user is considered active on any day where they have at least one task is executed 
		in the 28 days leading up to the event. */
		SELECT MONTH(TU.date) AS Month
				,MONTHNAME(TU.date) AS MonthName
                ,COUNT(DISTINCT TU.user_id) AS ActiveUsers
		FROM ZapierTakeHome.tasks_used TU
		LEFT JOIN (SELECT user_id
							,date 
			FROM ZapierTakeHome.tasks_used 
			) UserTasks /* A user is considered active on any day where they have at least one task is executed 
						in the 28 days leading up to the event. */
			ON TU.user_id = UserTasks.user_id
			AND UserTasks.date BETWEEN TU.Date AND DATE_SUB(TU.date, INTERVAL 28 DAY)
		GROUP BY MONTH(TU.date), MONTHNAME(TU.date)
        ) AS Active
LEFT JOIN (
		/* A user is considered to be churn the 28 days following their last being considered active. */
		SELECT MONTH(churnDate) AS Month
				,COUNT(DISTINCT user_id) AS ChurnUsers 
        FROM (
			SELECT TU.user_id
					,MAX(DATE_ADD(TU.date, INTERVAL 27 DAY)) AS churnDate
			FROM ZapierTakeHome.tasks_used TU
			LEFT JOIN
				(SELECT DISTINCT user_id, date
				 FROM ZapierTakeHome.tasks_used
				) AS ActiveDates /* A user is no longer part of churn if they become active again.*/
				ON DATE_ADD(TU.date, INTERVAL 27 DAY) < ActiveDates.date
			AND ActiveDates.date IS NULL
			GROUP BY TU.user_id) AS ChurnDateByUser
		GROUP BY MONTH(churnDate)
		) AS Churn ON Active.Month = Churn.Month
ORDER BY Active.Month;

    
