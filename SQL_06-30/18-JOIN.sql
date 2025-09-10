-- 18-JOIN.sql

-- 고객정보 + 주문정보
USE lecture;


SELECT
  *,
  (
    SELECT customer_name FROM customers c
    WHERE c.customer_id=s.customer_id
  ) AS 주문고객이름,
  (
    SELECT customer_type FROM customers c
    WHERE c.customer_id=s.customer_id
  ) AS 고객등급
FROM sales s;

-- JOIN
SELECT
  COUNT(*)
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id;
--



-- 모든 고객의 구매 현황 분석(구매를 하지 않았어도 분석)
-- 그냥 다 붙인거 120과 50의 경우의 수 6000개 -> 데이터로서 의미가 없다.
SELECT
	Count(*)
FROM customers c 
JOIN sales s ;
-- 

SELECT 
	COUNT(*)
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id ;



-- LEFT JOIN은 붙인게 NULL이여도 해주고 INNER JOIN은 붙인게 NULL이면 안 해줌 

SELECT
	c.customer_id,
	c.customer_name,
	c.customer_type,
	COUNT(*) AS '주문회수',
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id -- WHERE s.id IS NULL; -> 한 번도 주문한적 없는 사람들이 
GROUP BY c.customer_id, c.customer_name, c.customer_type
;


-- 함수 coalesce(,0)이면 첫번째 값이 NULL인 경우 0으로 해라
SELECT customer_id FROM sales s;
-- id, order_date, customer_id, product_id, product_name, category, quantity, unit_price, total_amount, sales_rep, region

--
SELECT
	customer_id,
    COUNT(*) AS 구개건수,
    SUM(total_amount) AS 총구매액 , 
    AVG(total_amount) AS 평균구매액,
    CASE
		WHEN COUNT (*) = 0 THEN '잠재고객'
        WHEN COUNT (*) >= 10 THEN '충성고객'
        WHEN COUNT (*) >= 3 THEN '일반고객' -- *로 했을 때는 한 줄로 세버리는데 'id'로 세면 컬럼을 세니깐 결과가 다르다
        ELSE '신규고객'
	END AS 활성도
FROM sales s

GROUP BY customer_id; 
-- 


-- 각 등급별 구매액 평균
SELECT *
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id 
WHERE c.customer_type = '개인' ;

--GROUP_BY
SELECT * FROM customers ;
SELECT customer_id, COUNT(customer_id)
FROM customers 
GROUP BY customer_id ;


