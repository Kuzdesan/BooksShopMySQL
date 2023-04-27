--TASK11 
SELECT title, SUM(Количество) AS "Количество", SUM(Сумма) AS "Сумма" 
FROM(
	SELECT title, SUM(ba.amount) AS "Количество", SUM(ba.amount*ba.price) AS "Сумма" 
	FROM buy_archive AS ba INNER JOIN book USING(book_id) GROUP BY title
		UNION 
	SELECT title, SUM(bb.amount) AS "Количество", SUM(bb.amount*price) AS "Сумма" 
	FROM buy_book AS bb INNER JOIN book USING(book_id) 
	INNER JOIN buy_step AS bs USING(buy_id) 
	WHERE step_id=1 AND date_step_end IS NOT NULL GROUP BY title
	) 
AS query GROUP BY title ORDER BY Сумма DESC;

--TASK12
UPDATE book AS b INNER JOIN buy_book AS bb USING(book_id) 
SET b.amount=b.amount- bb.amount WHERE buy_id=5;
SELECT * FROM book;

--TASK13
CREATE TABLE buy_pay AS SELECT
title, name_author, price, bb.amount, (price*bb.amount) AS "Стоимость" 
FROM buy_book AS bb INNER JOIN book USING(book_id)
 INNER JOIN author USING(author_id) WHERE buy_id=5 ORDER BY title;
SELECT* FROM buy_pay

--TASK14
CREATE TABLE buy_pay AS SELECT 
    buy_id, SUM(bb.amount) AS "Количество", SUM(price*bb.amount) AS "Итого"
FROM buy_book AS bb INNER JOIN book USING (book_id) 
WHERE buy_id=5 GROUP BY buy_id;
SELECT* FROM buy_pay;

--TASK15
INSERT INTO buy_step(buy_id, step_id) 
SELECT buy_id, step_id FROM buy CROSS JOIN step WHERE buy_id=5;

--task16
UPDATE client AS cl INNER JOIN buy USING (client_id)
INNER JOIN buy_book USING(buy_id) 
INNER JOIN book USING (book_id) 
INNER JOIN author USING (author_id) 
SET name_client = CONCAT('Бул-', name_client) WHERE name_author = 'Булгаков М.А.';
INSERT INTO genre(name_genre) SELECT 'Экстремизм';
UPDATE book 
INNER JOIN author USING(author_id)
INNER JOIN genre USING(genre_id)
SET book.genre_id = (SELECT genre_id FROM genre WHERE name_genre = "Экстремизм"), 
price = price*10 
WHERE name_author = 'Булгаков М.А.';
SELECT* FROM client;
SELECT* FROM genre;
SELECT* FROM book;

--TASK17
SELECT beg_range, end_range, Средняя_цена, Стоимость, Количество FROM
(SELECT 0 AS beg_range, 600 AS end_range, ROUND(AVG(price), 2) AS Средняя_цена, SUM(price*amount) AS Стоимость, COUNT(title) AS Количество FROM book WHERE price<600
UNION
SELECT 600 AS beg_range, 700 AS end_range, ROUND(AVG(price), 2) AS Средняя_цена, SUM(price*amount) AS Стоимость, COUNT(title) AS Количество FROM book WHERE price>=600 AND price<=700
UNION
SELECT 700 AS beg_range, 10000 AS end_range, ROUND(AVG(price), 2) AS Средняя_цена, SUM(price*amount) AS Стоимость, COUNT(title) AS Количество FROM book WHERE price>700) AS query
ORDER BY beg_range;

--TASK18
DELETE FROM book WHERE (mod(price, truncate(price,0)))=0.99;
DELETE FROM supply WHERE (mod(price, truncate(price,0)))=0.99;

--TASK19
SET @avg_price := (SELECT AVG(price) FROM book);
SELECT author, SUM(price*amount) AS Стоимость 
FROM book 
WHERE author IN (SELECT DISTINCT author FROM book WHERE price>@avg_price) 
GROUP BY author ORDER BY Стоимость DESC;

--TASK20
WITH t1(Автор, Название_книги, Количество, Розничная_цена, Скидка) AS
(
	SELECT author AS Автор, title AS Название_книги, amount AS Количество, price AS Розничная_цена, 
	IF(amount>9, 15, 0) AS Скидка FROM book
)
SELECT Автор, Название_книги, Количество, Розничная_цена, Скидка, 
ROUND((Розничная_цена-(Розничная_цена*Скидка*0.01)),2) AS Оптовая_цена 
FROM t1 ORDER BY Автор, Название_книги;