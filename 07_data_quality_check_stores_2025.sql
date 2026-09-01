-- 1. 2025년 점포 원본 데이터 기본 검증
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT stdr_yyqu_cd) AS quarter_count,
    MIN(stdr_yyqu_cd) AS first_quarter,
    MAX(stdr_yyqu_cd) AS last_quarter
FROM public.stores_2025_raw;

-- 2. 2025년 점포 중복 데이터 검사
SELECT
    stdr_yyqu_cd,
    trdar_cd,
    svc_induty_cd,
    COUNT(*) AS duplicate_count
FROM public.stores_2025_raw
GROUP BY
    stdr_yyqu_cd,
    trdar_cd,
    svc_induty_cd
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 3. 2025년 점포 핵심 컬럼 NULL 검사
SELECT
    SUM(CASE WHEN stdr_yyqu_cd IS NULL THEN 1 ELSE 0 END) AS null_quarter,
    SUM(CASE WHEN trdar_cd IS NULL THEN 1 ELSE 0 END) AS null_area,
    SUM(CASE WHEN svc_induty_cd IS NULL THEN 1 ELSE 0 END) AS null_industry,
    SUM(CASE WHEN stor_co IS NULL THEN 1 ELSE 0 END) AS null_store_count,
    SUM(CASE WHEN clsbiz_stor_co IS NULL THEN 1 ELSE 0 END) AS null_closed_count
FROM public.stores_2025_raw;

-- 4. 2025년 점포 이상값 검사
SELECT
    SUM(CASE WHEN stor_co < 0 THEN 1 ELSE 0 END) AS negative_store_count,
    SUM(CASE WHEN opbiz_stor_co < 0 THEN 1 ELSE 0 END) AS negative_open_count,
    SUM(CASE WHEN clsbiz_stor_co < 0 THEN 1 ELSE 0 END) AS negative_closed_count,
    SUM(CASE WHEN opbiz_rt < 0 THEN 1 ELSE 0 END) AS negative_open_rate,
    SUM(CASE WHEN clsbiz_rt < 0 THEN 1 ELSE 0 END) AS negative_closed_rate
FROM public.stores_2025_raw;