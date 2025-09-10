-- pg-09-partition.sql

-- partition by -> 데이터를 특정 그룹으로 나고, window 함수로 결과를 확인
-- 동(1~4) | 층(15,10,20) | 호수 | 이름
-- 101 | 20 | 2001

 SELECT 
 	region,
	customer _id,
	amount,
	ROW_NUMBRT() OVER 
	ROW_NUMBRT() OVER 
	RANK() OVER
	DENSE_RANK() OVER (ORDER BY amount DESC) AS 전체순위
	DENSE_RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS 지역순위
FROM orders LIMIT 10 ;

-- SUM () OVER ()
-- 일별 누적 매출액
SELECT 
	order_date,
	SUM(amount) AS 일매출
FROM orders
WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY order_date
ORDER BY order_date;
--
WITH daily_sales AS (
	SELECT 
		order_date,
		SUM(amount) AS 일매출
	FROM orders
	WHERE order_date BETWEEN '2024-07-01' AND '2024-08-31'
	GROUP BY order_date
	ORDER BY order_date
)
SELECT 
	order_date,
	일매출,
	-- 범위 내에서 계속 누적
	SUM(일매출) OVER (ORDER BY order_date) AS 누적매출,
	-- 범위 내에서 PARTITION 바뀔 때 초기화
	SUM(일매출) OVER (
		PARTITION BY DATE_TRUNC('month',order_date)
		ORDER BY order_date
	) AS 월누적매출
FROM daily_sales ;

-- AVG() OVER ()
WITH daily_sales AS (
	SELECT 
		order_date,
		SUM(amount) AS 일매출
	FROM orders
	WHERE order_date BETWEEN '2024-07-01' AND '2024-08-31'
	GROUP BY order_date
	ORDER BY order_date
)
SELECT 
	order_date,
	일매출,
	ROUND(AVG(일매출)) OVER(
		ORDER BY order_date
	)) AS 일평균
	)
FROM daily_sales ;

-- 각 지역에서 총구매액 1위 고객 => ROW_NUMBER()로 숫자를 매기고, 이 컬럼의 값이 1인 사람
-- [지역, 고객이름, 총구매액]
-- CTE
-- 1. 지역-사람별 "매출 데이터 생성" [지역, 고객id, 이름, 해당 고객의 총 매출]
-- 2. "매출데이터"에 새로운 열(ROW_NUMBER)추가
-- 3. 최종 데이터 표시


SELECT * FROM orders;

--
SELECT
	region,
	customer_id,
	SUM(amount) OVER (
		PARTITION BY customer_id ORDER BY region 
	) AS 총구매액
FROM orders;

-- 상상해보면 첫번째 : 지역, 그리고 지역별로 customer_id는 하나만 왜냐면 customer_id의 sum이 다음  표에서 나와야 하니깐

SELECT
	region,
	customer_id,
	SUM(amount) 
FROM orders;


-- 강사님 프로세스 : 
-- inner join 먼저, 그 다음 GROUP BY로 region, customerid, customername
-- 그 다음 WITH로 임시 테이블화해주고, ROW_NUMBER와 파티션으로 region을 해준다. 고객별 총매출로 정렬(Order BY) 얘도 ranked_by_region으로 with화 
-- 그 다음 WHERE로 지역순위 범위 지정 


-- 카테고리별 인기 상품(매출 순위, 판매순위) Top 5
-- CTE
-- [상품 카테고리, 상품 id, 상품 이름, 상품 가격, 해당 상품의 주문건수, 해당상품 판매 개수, 해당 상품 총 매출]
-- 위에서 만든 테이블에 Window함수 컬럼 추가 + [매출순위, 판매량 순위]
-- 총데이터 표시 (매출순위 1~5위 기준으로 표시)

-- 3단계 정도로 생각을 해보자
-- -- 일단 해야 할 일부터 정리하자 2가지 이상의 순서를 한 번에 보일 수 있나? 카테고리별 인기 상품
-- -- 어떤 테이블과 데이터를 써야하지?
SELECT * FROM products;
SELECT 
	category, 
	product_id, 
	product_name, 
	price, 
	stock_quantity, 
	price * stock_quantity AS 상품총매출,
	DENSE_RANK() OVER (ORDER BY price * stock_quantity DESC) AS 상품매출량순위,
	DENSE_RANK() OVER (ORDER BY stock_quantity DESC) AS 상품판매량순위 -- 순위는 결국 정렬 순서일 뿐이야
FROM products;

-- 상품판매량순위, 상품매출량순위 각각 5위까지 보여줄려면 어떻게 하지? 순위에서 일치하지 않을 때는 어떻게 하고?

-- 강사님 프로세스 : 
-- LEFT JOIN orders 근데 왜 함? 아 stock_quantitiy는 재고이지 판매개수가 아니니깐 
-- GROUP BY category, product_id (unique), product_name
-- 위에꺼 with화하고 DENSE_RANK와 파티션으로 카테고리, 정렬 기준 총매출, 판매개수, 
-- 위에꺼 'ranked_product' with화하고 매출순위 WHERE로 ORDERBY로 category, 매출순위 ; 
-- 



