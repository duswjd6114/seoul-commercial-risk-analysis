-- 1. 2024년 점포 원본 데이터 기본 검증
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT 기준_년분기_코드) AS quarter_count,
    MIN(기준_년분기_코드) AS first_quarter,
    MAX(기준_년분기_코드) AS last_quarter
FROM public.stores_2024_raw;

-- 2. 2024년 점포 중복 데이터 검사
SELECT
    기준_년분기_코드,
    상권_코드,
    서비스_업종_코드,
    COUNT(*) AS duplicate_count
FROM public.stores_2024_raw
GROUP BY
    기준_년분기_코드,
    상권_코드,
    서비스_업종_코드
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 3. 2024년 점포 핵심 컬럼 NULL 검사
SELECT
    SUM(CASE WHEN 기준_년분기_코드 IS NULL THEN 1 ELSE 0 END) AS null_quarter,
    SUM(CASE WHEN 상권_코드 IS NULL THEN 1 ELSE 0 END) AS null_area,
    SUM(CASE WHEN 서비스_업종_코드 IS NULL THEN 1 ELSE 0 END) AS null_industry,
    SUM(CASE WHEN 점포_수 IS NULL THEN 1 ELSE 0 END) AS null_store_count,
    SUM(CASE WHEN 폐업_점포_수 IS NULL THEN 1 ELSE 0 END) AS null_closed_count
FROM public.stores_2024_raw;

-- 4. 2024년 점포 이상값 검사
SELECT
    SUM(CASE WHEN 점포_수 < 0 THEN 1 ELSE 0 END) AS negative_store_count,
    SUM(CASE WHEN 개업_점포_수 < 0 THEN 1 ELSE 0 END) AS negative_open_count,
    SUM(CASE WHEN 폐업_점포_수 < 0 THEN 1 ELSE 0 END) AS negative_closed_count,
    SUM(CASE WHEN 개업_율 < 0 THEN 1 ELSE 0 END) AS negative_open_rate,
    SUM(CASE WHEN 폐업_률 < 0 THEN 1 ELSE 0 END) AS negative_closed_rate
FROM public.stores_2024_raw;