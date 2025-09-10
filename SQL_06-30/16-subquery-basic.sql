-- 16-subquery-basic.sql

USE lecture ;


-- 매출 평균 보다 더 높은 금액을 주문한 판매 데이터(*) 보여줘
-- 0단계 : 데이터 조회
SELECT * FROM products ; 
SELECT * FROM sales ; 
-- 1단계 : 매출 평균 구하기
SELECT avg(total_amount) FROM products ;
