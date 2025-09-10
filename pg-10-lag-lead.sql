-- pg-10-lag-lead.sql 

-- 컴퓨터 랙 걸린다 할 때 lag -타임머신?

-- LAG() : 이전 값을 가져온다.

-- 전월 대비 매출 분석

-- 매달 매출을 확인

-- 위 테이블에 증감률 컬럼 추가
-- 테스트용 질문 : between '2024-01-01' and '2024-05-30' 기간 동안 product 판매량 중 5번 이상 팔린 것만 보여줘
SELECT * FROM orders;
SELECT 
	TO_CHAR(order_date, 'M') AS MONTH 
FROM orders;
--
SELECT 
	product_id,
	order_date,
	COUNT (*) 
FROM orders
WHERE order_date between '2024-01-01' and '2024-05-30'
GROUP BY order_date, product_id;

--
WITH tests AS (
	SELECT 
		product_id,
		order_date,
		COUNT (*) AS counts 
	FROM orders
	WHERE order_date between '2024-01-01' and '2024-05-30'
	GROUP BY order_date, product_id
) 
SELECT 
	EXTRACT(MONTH FROM order_date) AS MONTH, 	
	product_id, 
	counts 
FROM tests
WHERE counts >=1 ;

SELECT 
	EXTRACT(MONTH FROM order_date) AS MONTH 	
FROM orders ;
--

	SELECT 
		DATE_TRUNC('month', order_date) AS 월,
		SUM(amount) AS 월매출
	FROM orders
	GROUP BY DATE_TRUNC('month', order_date);
	--
WITH monthly_sales AS (
	SELECT 
		DATE_TRUNC('month', order_date) AS 월,
		SUM(amount) AS 월매출
	FROM orders
	GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
	TO_CHAR(월, 'YYYY-MM') AS 년월,
	월매출,
	LAG(월매출,1) OVER (ORDER BY 월) AS 전월매출 
	월매출 - LAG(월매출,1) OVER (ORDER BY 월) AS 증감액
	CASE 
		WHEN LAG(월매출, 1) OVER (ORDER BY 월) IS NULL THEN NULL
		ELSE ROUND(
			월매출 - LAG(월매출,1) OVER (ORDER BY 월) * 100 --매출변동 
			/ LAG(월매출,1) OVER (ORDER BY 월) AS 증감액 --저번달
		,2)  
		END AS 증감률
FROM monthly_sales
ORDER BY 월;


-- 고객별 다음 구매를 예측 할 수 있을까
-- [고객 id, 주문일, 구매액, 다음구매일, 다음구매액수]
-- 고객별로 PARTITIOPN 필요
-- ORDER By customer_id, order_date LIMIT 10;
-- 
SELECT * FROM customers ; -- customer_id,
SELECT * FROM orders ; --  order_date, amount, lag 구매일, 구매액수 lag order_date, lag amount

SELECT 
	customer_id,
	order_date, 
	amount,
	LEAD(order_Date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일,
	LEAD(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일
FROM orders
WHERE customer_id = 'CUST-000001'
ORDER BY customer_id, order_Date

-- [고객 id, 주문일, 금액, 구매 순서(row_number)]
-- 이전 구매간격, 다음구매간격
-- 금액변화 =(이번-저번)
-- 금액변화율
-- 누적 구매 금액 (SUM OVER)
-- [추가 과제] 누적 평균 구매 음액 OPtion (AVG OVER) 
-- 자동 계산을 할꺼면 하나의 행에서 다뤄야 하기 때문에 하나의 행으로 만들어줘야 한다.

-- 파티션에서의 최고, 최저 찾기
-- 카테고리별 최고/최저
-- ROWS BETWEEN UNBOUNDEDE PRECEDING AND UNBOUND FOLLOWNING -- 파티션의 모든 행을 봐라
SELECT
	category,
	product_name,
	price,
	FIRST_VALUE(product_name) OVER(
	PARTITION BY category
	ORDER BY price DESC
	ROWS BETWEEN UNBOUNDEDE PRECEDING AND UNBOUND FOLLOWNING -- 파티션의 모든 행을 봐라
	) AS 최고가상품명
	FIRST_VALUE 
	)


-- 조금 있다가 -- 인덱스 최적화 롤업, 큐브 했나?
-- 
	
	
