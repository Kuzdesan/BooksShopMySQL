--TASK1
SELECT buy_id, bk.title, bk.price, bb.amount 
FROM client AS c INNER JOIN buy AS b USING (client_id) 
INNER JOIN buy_book AS bb USING(buy_id) 
INNER JOIN book AS bk USING(book_id) 
WHERE name_client = "Баранов Павел" 
ORDER BY buy_id, title;

--TASK2
SELECT name_author, title, COUNT(buy_id) AS "Количество" 
FROM book LEFT JOIN buy_book USING (book_id) 
INNER JOIN author USING(author_id) 
GROUP BY name_author, title 
ORDER BY name_author, title;

--TASK3
SELECT name_city, COUNT(buy_id) AS "Количество"
FROM client AS cl INNER JOIN city AS c USING (city_id) 
INNER JOIN buy AS b USING(client_id) 
GROUP BY name_city 
ORDER BY Количество DESC, name_city;

--TASK4
SELECT buy_id, date_step_end 
FROM buy_step AS bs INNER JOIN  step AS s USING(step_id)
WHERE step_id=1 
	AND 
date_step_beg IS NOT NULL 
	AND 
date_step_end IS NOT NULL;

--TASK5
SELECT buy_id, name_client, SUM(bb.amount*b.price) AS "Стоимость" 
FROM client AS cl INNER JOIN buy USING (client_id) 
INNER JOIN buy_book AS bb USING(buy_id) 
INNER JOIN book AS b USING (book_id) 
GROUP BY buy_id, name_client 
ORDER BY buy_id;

--TASK6
SELECT buy_id, name_step 
FROM buy_step AS bs INNER JOIN step AS s USING (step_id)
WHERE date_step_end IS NULL 
	AND 
date_step_beg IS NOT NULL 
ORDER BY buy_id;

--TASK7
SELECT buy_id, DATEDIFF(date_step_end, date_step_beg) AS "Количество_дней", 
    IF(
        (DATEDIFF(date_step_end, date_step_beg)-days_delivery)>0, 
        (DATEDIFF(date_step_end, date_step_beg)-days_delivery), 0)  AS "Опоздание" 
    FROM client AS cl INNER JOIN city AS c USING (city_id)
                  INNER JOIN buy USING(client_id)
                  INNER JOIN buy_step AS bs USING(buy_id)
                  INNER JOIN step AS s USING (step_id)
    WHERE name_step = "Транспортировка" AND date_step_beg IS NOT NULL AND date_step_end IS NOT NULL;
	
--TASK8
SELECT DISTINCT name_client FROM client AS cl 
    INNER JOIN buy AS b USING (client_id)
    INNER JOIN buy_book AS bb USING(buy_id)
    INNER JOIN book USING(book_id)
    INNER JOIN author AS a USING(author_id)
    WHERE name_author = "Достоевский Ф.М." ORDER BY name_client;

--TASK9
SELECT name_genre, Количество FROM 
    (SELECT name_genre, SUM(bb.amount) AS "Количество" FROM buy_book AS bb 
         INNER JOIN book AS b USING(book_id) 
         INNER JOIN genre AS g USING(genre_id)
         GROUP BY name_genre) 
     AS query 
     WHERE Количество =
     (SELECT MAX(Количество) FROM 
          (SELECT name_genre, SUM(bb.amount) AS "Количество" 
               FROM buy_book AS bb 
               INNER JOIN book AS b USING(book_id)
               INNER JOIN genre AS g USING(genre_id)
               GROUP BY name_genre) 
          as qq);
		  
--TASK10
SELECT YEAR(date_payment) AS "Год", MONTHNAME(date_payment) AS "Месяц", SUM(amount*price) AS "Сумма" 
FROM buy_archive GROUP BY YEAR(date_payment), MONTHNAME(date_payment)
	UNION
SELECT YEAR(date_step_end) AS "Год", MONTHNAME(date_step_end) AS "Месяц", SUM(bb.amount*price) AS "Сумма" 
FROM buy_step AS bs INNER JOIN step USING(step_id)
INNER JOIN buy_book AS bb USING(buy_id) 
INNER JOIN book AS b USING(book_id) 
WHERE name_step="Оплата" AND date_step_end IS NOT NULL 
GROUP BY YEAR(date_step_end), MONTHNAME(date_step_end)
ORDER BY Месяц;	
