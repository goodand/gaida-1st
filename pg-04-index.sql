-- pg-04-index.sql

-- 인덱스가 오남용되면 그것을 찾는데 더 오래 걸려 버린다.

-- 인덱스 조회
SELECT 
	tablename,
	indexname,
	indexdef
FROM pg_indexes
WHERE tablename IN ('large_orders','large_customers');

ANALYZE large_orders;
ANALYZE large_customers;

--실제 운영에서는 X (캐시 날리기)
SELECT pg_stat_reset();

-- EXPLAIN ANLAYZE
SELECT * FROM large_orders
WHERE customer_id='CUST-25000.';

SELECT * FROM large_orders
WHERE amount BETWEEN 80000 AND 1000000;

EXPLAIN ANALYZE 
SELECT * FROM large_orders
WHERE region='서울' AND amount > 500000 AND order_date >= '2024-07-08';

EXPLAIN ANALYZE 
SELECT * FROM large_orders
WHERE region='서울' 
ORDER BY amount DESC 
LIMIT 100 ;

CREATE INDEX idx_orders_customer_id ON large_orders(customer_id); 
CREATE INDEX idx_orders_amount_id ON large_orders(amount);
CREATE INDEX idx_orders_region ON large_orders(region);

EXPLAIN ANALYZE 
SELECT * FROM large_orders
WHERE customer_id= 'CUST-10254.'; 

EXPLAIN ANALYZE 
SELECT * FROM large_orders
WHERE amount BETWEEN 80000 AND 1000000;


-- 카테고라이징 되어 있는게 (Group By 쓸 수 있는게 )인덱스를 썼을 때 강력하다.


-- 복합 인덱스

CREATE INDEX idx_orders_region_amount ON large_orders(region, amount); 
CREATE INDEX idx_orders_amount_region ON large_orders(amount, region); 

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE region = '서울' AND amount > 800000; -- 652 => 176


EXPLAIN ANALYZE 
SELECT * FROM large_orders
WHERE customer_id= 'CUST-25000.'
	AND order_date >= '2024-07-01'
ORDER BY order_date DESC;

-- Index 순서 가이드라인

-- 고유값 비율
SELECT 
	COUNT(DISTINCT region) AS 고유지역수,
	COUNT(*) AS 전체행수,
	ROUND(COUNT(DISTINCT region) * 100 / COUNT(*),2) AS 선택도
FROM large_orders;


SELECT
	COUNT(DISTINCT amount) AS 고유금액수,
	COUNT(*) AS 전체행수
FROM large_orders;

SELECT
	COUNT(DISTINCT customer_id) AS 고유고객수,
	COUNT(*) AS 전체행수
FROM large_orders;
