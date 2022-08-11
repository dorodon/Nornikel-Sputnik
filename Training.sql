--1
DECLARE @Tb1 TABLE
(
Tag varchar(128),
Value int,
DateTimeChange datetime
)INSERT INTO @Tb1VALUES('Income', 5, '20220101'),('Income', 7, '20220305'),('Income', 15, '20220802'),('Award', 5, '20220203'),('Award', 2, '20220416'),('Outcome', 1, '20220101'),('Outcome', 7, '20220214'),('Outcome', 10, '20220729'),('Outcome', 14, '20220802')SELECT 	t.Tag, Value, t.DateTimeChangeFROM 	@Tb1 t INNER JOIN (SELECT Tag, MAX(DateTimeChange) DateTimeChange FROM @Tb1 GROUP BY Tag)z		ON t.Tag = z.Tag AND t.DateTimeChange = z.DateTimeChangeORDER BY t.TagGO--2DECLARE @Tb1 TABLE
(
DT datetime,
TotalMoney int
)INSERT INTO @Tb1VALUES('20200101', 500),('20200201', 1000),('20200301', 3000),('20200401', 5000),('20200501', 6000),('20200601', 10000),('20200701', 9000),('20200801', 13000),('20200901', 19000),('20201001', 17000),('20201101', 26000),('20201201', 40000),('20210101', 35000),('20210201', 41000)SELECT	z.Period_Start,	z.Period_End,	CASE		WHEN z.Diff > 0 THEN z.Diff ELSE 0	END Income,	CASE		WHEN z.Diff < 0 THEN z.Diff ELSE 0	END LossFROM(SELECT	DT Period_Start,	LEAD(DT) OVER (ORDER BY DT) Period_End,	LEAD(TotalMoney) OVER (ORDER BY DT) - TotalMoney DiffFROM @Tb1)zWHERE z.Period_End IS NOT NULLGO-- 3DECLARE @Tb1 TABLE
(
Name varchar(128),
Job_start date,
Job_end date
)INSERT INTO @Tb1VALUES('Peter', '20210101', '20210201'),('Ivan', '20210301', '20210308'),('Boris', '20220201', '20220215'),('Pavel', '20200715', '20200825'),('Vadim', '20181205', '20190120');WITH cteAS(	SELECT 		Name,		DATEDIFF(dd, Job_start, Job_end) + 1 all_days,		CASE			WHEN DATEPART(wk, Job_end) - DATEPART(wk, Job_start) = 0 THEN 1 ELSE 0		END same_week,		DATEDIFF(YEAR, Job_start, Job_end) diff_year,		CASE			WHEN ABS(DATEPART(wk, Job_end) - DATEPART(wk, Job_start)) > 1 THEN 2 * (DATEDIFF(wk, Job_start, Job_end)-1)			ELSE 0		END inside_days,		CASE DATEPART(dw, Job_start)			WHEN 7 THEN 1			ELSE 2		END firstweek_days,		CASE DATEPART(dw, Job_end)			WHEN 7 THEN 2			WHEN 6 THEN 1			ELSE 0		END lastweek_days	FROM @Tb1)SELECT 	z.name,	z.all_days - z.inside_days - z.outside_days daysFROM(SELECT	cte.Name,	cte.all_days,	cte.inside_days - 2 * cte.diff_year inside_days,	CASE		WHEN cte.same_week = 1 AND firstweek_days >= lastweek_days THEN firstweek_days		WHEN cte.same_week = 1 AND firstweek_days < lastweek_days THEN lastweek_days		ELSE firstweek_days + lastweek_days	END outside_daysFROM cte)zORDER BY z.Name