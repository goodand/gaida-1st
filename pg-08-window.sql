-- pg-08-window.sql
-- 창 밖에 있는 정보까지 본다?
-- window 함수 OVER 구문

-- 전체 구매액 평균
SELECT AVG(amount) FROM orders;
-- 고객별 구매액 평균

SELECT
	?
FROM orders
GROUP BY customer_id
-- 그룹바이를 하면 전체를 못 보니깐 그렇지


-- 스칼라랑 백터랑 동시에 SELECT 안 된데

-- 각 데이터와 전체 평균을 동시에 확인하려면?
SELECT 
	order_id,
	customer_id,
	amount,
	AVG(amount) OVER() as 전체평균
FROM orders
LIMIT 10 ;

-- 원래는 집계함수인데 

-- ROW_NUMBER() -> 줄세우기 [ROW_NUMBER() OVER(ORDER BY 정렬기준)]

SELECT
	order_id,
	customer_id,
	amount,
	ROW_NUMBER() OVER (ORDER BY amount DESC) as 호구번호
FROM orders
ORDER BY 호구번호
LIMIT 20 OFFSET 40 ; -- 앞에 20번은 빼고 21번부터..;


-- 주문 날짜가 최신인 순서대로 번호 매기기
-- 최신 주문 날짜 ? 그냥 주문 날짜를 최신 기준으로 하면 되는거 아냐?

SELECT * FROM orders ;
SELECT * FROM customers ; 

SELECT
	order_id,
	customer_id,
	amount,
	order_date,
	ROW_NUMBER() OVER (ORDER BY order_date DESC) as 최신주문순서
FROM orders
ORDER BY 최신주문순서
LIMIT 20 ; 
-- 몇 번째로 인지

-- 랭크? 
SELECT
	order_id,
	customer_id,
	amount,
	order_date,
	ROW_NUMBER() OVER (ORDER BY order_date DESC) as 최신주문순서,
	RANK() OVER (ORDER BY order_date DESC) as 랭크,
	DENSE_RANK() OVER (ORDER BY order_date DESC) as 덴스랭크 --중복되는 것을 묶어서 rank
FROM orders
ORDER BY 최신주문순서
LIMIT 20 ; 

-- 7월 매출 TOP3 고객 찾기
-- [id, 고객의 7월 구입앱, 순위]
-- customers c c.customer_name
-- 7월 구입 총액
SELECT 
	customer_id,
	sum(amount)  AS 월구매액 --월구매액의 RANK는 이 단계에서 못 함, 왜냐면 집계 아직 미완, 그래서 WITH 밖에서 하면 되는
FROM orders
WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY customer_id ;


-- 
WITH july_sales AS (
	SELECT 
		customer_id,
		sum(amount)  AS 월구매액 --월구매액의 RANK는 이 단계에서 못 함, 왜냐면 집계 아직 미완, 그래서 WITH 밖에서 하면 되는
	FROM orders
	WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31'
	GROUP BY customer_id 
),
RANKING AS (
	SELECT
		customer_id,
		월구매액,
		ROW_NUMBER() OVER(ORDER BY 월구매액) AS 순위
	FROM july_sales 
)
SELECT 
	r.customer_id,
	c.customer_name,
	r.월구매액,
	r.순위
FROM RANKING r 
INNER JOIN customers c ON r.customer_id = c.customer_id 
WHERE r.순위 <=10
;

-- (https://github.com/verba-neo/gaida-1/blob/main/SQL/codes/pg-08-window.sql)
-- 각 지역에서 매출 1위 고객 => ROW_NUMBER()로 숫자를 메기고, 이 컬럼의 값이 1인 사람
-- region, amount, group by region, 윈도우함수 이용하여 DENSE-RANK, 이거 GROUP BY를 이용하면 안 되는건가? 내가 원하는건 스칼라인데 GROUP BY를 이용하면 벡터로 제한을 해야 하니깐
-- region 