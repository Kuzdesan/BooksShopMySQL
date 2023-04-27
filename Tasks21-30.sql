--TASK21
SELECT author, COUNT(DISTINCT title) AS Количество_произведений, 
MIN(price) AS Минимальная_цена, SUM(amount) AS Число_книг 
FROM book WHERE author IN (
	SELECT DISTINCT author FROM book WHERE amount>1 AND price>500
	)
GROUP BY author HAVING Количество_произведений>1 ORDER BY author;

--TASK22
SELECT name_genre, SUM(bb.amount) AS Количество 
FROM buy_book AS bb INNER JOIN book USING(book_id) 
INNER JOIN genre USING(genre_id) 
GROUP BY name_genre HAVING 
Количество = (
	SELECT MIN(local_min) AS min FROM (
		SELECT DISTINCT genre_id, 
		SUM(bb.amount) OVER (PARTITION BY genre_id) AS local_min 
		FROM buy_book AS bb INNER JOIN book USING(book_id)
		) AS query
);

--TASK23
SET @avg_amount := 
        (SELECT ROUND(SUM(amount)/COUNT(amount), 2) FROM
             (SELECT amount FROM book
                 UNION
             SELECT amount FROM supply) AS subquery
        );
CREATE TABLE store AS 
SELECT title, author, MAX(price) AS price, SUM(amount) AS amount FROM
(SELECT title, author, amount, price FROM book
UNION 
SELECT title, author, amount, price FROM supply) AS query 
GROUP BY title, author
HAVING amount>=@avg_amount
ORDER BY title, price DESC;

SELECT* FROM store;

--TASK24
SELECT 
    author,
    title,
    CASE
        WHEN price<500 THEN 'низкая'
        WHEN price<=700 THEN 'средняя'
        ELSE 'высокая'
    END
    AS price_category,
    (price*amount) AS cost
FROM book WHERE author NOT LIKE "Есенин%" AND title<>"Белая Гвардия"
ORDER BY cost DESC, title;

--TASK25
SET @max_price := (SELECT MAX(price*amount) FROM book);
SELECT title, author, amount, 
ROUND(@max_price-(price*amount), 2) AS Разница_с_макс_стоимостью 
FROM book WHERE mod(amount,2)=1
ORDER BY Разница_с_макс_стоимостью DESC;

--TASK26
SELECT author, title, amount, price,
        CASE
            WHEN amount>=5 THEN '50%'
            ELSE
               CASE 
                   WHEN price>=700 THEN '20%'
                   ELSE '10%'
               END
         END
AS Скидка,
        CASE
            WHEN amount>=5 THEN ROUND(price*0.5, 2)
            ELSE
               CASE 
                   WHEN price>=700 THEN ROUND(price*0.8, 2)
                   ELSE ROUND(price*0.9, 2)
               END
         END        
AS Цена_со_скидкой  FROM book;

--TASK27
SELECT CONCAT('Графоман и ', author) AS Автор, CONCAT(title, '. Краткое содержание.') AS Название,
    CASE
        WHEN price*0.4> 250 THEN 250
        ELSE price*0.4
    END
AS Цена,
    CASE
        WHEN amount<=3 THEN 'высокий'
        WHEN amount<=10 THEN 'средний'
        ELSE 'низкий'
    END
AS Спрос,
    CASE 
        WHEN (amount BETWEEN 1 AND 2) THEN 'очень мало'
        WHEN (amount BETWEEN 3 AND 14) THEN 'в наличии'
        ELSE 'много'
    END
AS Наличие
FROM book ORDER BY Цена, amount, Название;

--TASK28
SET @avg_ord := (
	SELECT ROUND(AVG(ptr), 2) 
	FROM (	
		SELECT buy_id, SUM(price*bb.amount) AS ptr 
		FROM buy INNER JOIN buy_book AS bb USING(buy_id) 
		INNER JOIN book USING(book_id) 
		GROUP BY buy_id
		) AS query
	);

SELECT name_client, SUM(bb.amount*price) AS Общая_сумма_заказов, 
COUNT(DISTINCT buy_id) AS Заказов_всего, SUM(bb.amount) AS Книг_всего 
FROM client INNER JOIN buy USING(client_id)
INNER JOIN buy_book AS bb USING(buy_id) 
INNER JOIN book USING(book_id) 
GROUP BY name_client 
HAVING Общая_сумма_заказов > @avg_ord 
ORDER BY name_client;

--TASK29
SELECT author AS Автор, MIN(amount) AS Наименьшее_кол_во, MAX(amount) AS Наибольшее_кол_во FROM book 
WHERE author IN (
    SELECT author FROM(
                       SELECT author, SUM(amount) FROM book GROUP BY author HAVING SUM(amount)<10) AS q
    ) GROUP BY Автор
ORDER BY Автор;

--TASK30
SET @num := (
	SELECT buy_id FROM buy INNER JOIN client USING(client_id) 
	WHERE name_client = "Баранов Павел" ORDER BY buy_id DESC LIMIT 1);

INSERT INTO buy_book(buy_id, book_id, amount) 
    SELECT @num, book_id, 1 
	FROM author INNER JOIN book USING(author_id) 
	LEFT JOIN buy_book USING(book_id) 
	WHERE name_author LIKE "Достоевский%";
