-- pg-03-explain-analyze.sql

-- 실행 계획을 보자
EXPLAIN
SELECT * FROM large_customers WHERE customer_type ='VIP';

-- Seq Scan on Large_customers (cost=0.00..33746.00 rows =10013 width=159byte)
-- cost = 점수(낮을수록 좋음) / rows * width = 총 메모리 사용량 
-- Filter: (customer_type = 'VIP'::text)

-- 실행 + 통계
EXPLAIN ANALYZE 
SELECT * FROM large_customers WHERE customer_type ='VIP';

-- Seq Scan on Large_customers (cost=0.00..33746.00 rows =10013 width=159byte)
-- cost = 점수(낮을수록 좋음) / rows * width = 총 메모리 사용량 
-- Filter: (customer_type = 'VIP'::text)
-- ROWS Removed by Filter : 89955
--


-- 버퍼 사용량 포함
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM large_customers WHERE loyalty_points > 8000;

-- 상제 정보 포함

--  json형식

-- 진단

