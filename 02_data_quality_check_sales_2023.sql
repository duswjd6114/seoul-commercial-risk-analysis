-- 2023년 원본 데이터 기본 검증
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT 기준_년분기_코드) AS quarter_count,
    MIN(기준_년분기_코드) AS first_quarter,
    MAX(기준_년분기_코드) AS last_quarter
FROM public.sales_2023_raw;
-- 2023년 중복 데이터 검사
SELECT
    기준_년분기_코드,
    상권_코드,
    서비스_업종_코드,
    COUNT(*) AS duplicate_count
FROM public.sales_2023_raw
GROUP BY
    기준_년분기_코드,
    상권_코드,
    서비스_업종_코드
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
-- 핵심 컬럼 NULL 검사
SELECT
    SUM(CASE WHEN 기준_년분기_코드 IS NULL THEN 1 ELSE 0 END) AS null_quarter,
    SUM(CASE WHEN 상권_코드 IS NULL THEN 1 ELSE 0 END) AS null_area,
    SUM(CASE WHEN 서비스_업종_코드 IS NULL THEN 1 ELSE 0 END) AS null_industry,
    SUM(CASE WHEN 당월_매출_금액 IS NULL THEN 1 ELSE 0 END) AS null_sales
FROM public.sales_2023_raw;
SELECT COUNT(*) AS negative_sales_rows
FROM public.sales_2023_raw
WHERE 당월_매출_금액 < 0;