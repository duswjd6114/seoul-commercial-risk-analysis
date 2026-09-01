-- 1. 상권·업종별 기본 KPI 생성
CREATE OR REPLACE VIEW public.commercial_kpi AS

SELECT
    기준_년분기_코드,
    상권_구분_코드,
    상권_구분_코드_명,
    상권_코드,
    상권_코드_명,
    서비스_업종_코드,
    서비스_업종_코드_명,

    -- 매출 지표
    당월_매출_금액 AS sales_amount,
    당월_매출_건수 AS sales_count,

    -- 점포 지표
    점포_수 AS store_count,
    개업_점포_수 AS opened_store_count,
    폐업_점포_수 AS closed_store_count,
    개업_율 AS open_rate,
    폐업_률 AS close_rate,

    -- 점포당 매출
    CASE
        WHEN 점포_수 > 0
        THEN 당월_매출_금액::numeric / 점포_수
        ELSE NULL
    END AS sales_per_store

FROM public.commercial_analysis;

-- 2. 기본 KPI 결과 확인
SELECT *
FROM public.commercial_kpi
LIMIT 10;

-- 3. 기본 KPI 데이터 검증
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN sales_amount IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN store_count IS NULL THEN 1 ELSE 0 END) AS null_store,
    SUM(CASE WHEN sales_per_store IS NULL THEN 1 ELSE 0 END) AS null_sales_per_store,

    MIN(sales_amount) AS min_sales,
    MAX(sales_amount) AS max_sales,

    MIN(store_count) AS min_store_count,
    MAX(store_count) AS max_store_count

FROM public.commercial_kpi;

-- 4. 점포당 매출 NULL 원인 확인
SELECT
    COUNT(*) AS null_sales_per_store,
    SUM(CASE WHEN store_count = 0 THEN 1 ELSE 0 END) AS zero_store_count,
    SUM(CASE WHEN store_count IS NULL THEN 1 ELSE 0 END) AS null_store_count
FROM public.commercial_kpi
WHERE sales_per_store IS NULL;