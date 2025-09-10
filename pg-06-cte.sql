--pg-06-cte.sql

SELECT * FROM customers;


-- WITH를 통해서 만들어진 테이블


SELECT 
	c.region AS 지역명,
	COUNT(DISTINCT c.customer_id) AS 고객수,
	COUNT(o.order_id) AS 주문수,
	COALESCE(AVG(o.amount), 0) AS 평균주문금액	
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region ;

WITH region_summary AS (
	SELECT 
		c.region AS 지역명,
		COUNT(DISTINCT c.customer_id) AS 고객수,
		COUNT(o.order_id) AS 주문수,
		COALESCE(AVG(o.amount), 0) AS 평균주문금액	
	FROM customers c
	LEFT JOIN orders o ON c.customer_id = o.customer_id
	GROUP BY c.region 
)
SELECT
	지역명,
	고객수,
	주문수,
	ROUND(평균주문금액) AS 평균주문금액
FROM region_summary
ORDER BY 고객수 DESC 	

-- Logic 과 Present 를 구분 할 수 있다. 생각과 표현을 구분해서 구현 할 수 있다.

