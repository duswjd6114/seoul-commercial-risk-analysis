-- 1. 전년 동분기 대비(YoY) KPI 생성

CREATE OR REPLACE VIEW public.commercial_kpi_yoy AS

SELECT
    curr.기준_년분기_코드,
    curr.상권_구분_코드,
    curr.상권_구분_코드_명,
    curr.상권_코드,
    curr.상권_코드_명,
    curr.서비스_업종_코드,
    curr.서비스_업종_코드_명,

    -- 현재 지표
    curr.sales_amount,
    curr.sales_count,
    curr.store_count,
    curr.opened_store_count,
    curr.closed_store_count,
    curr.open_rate,
    curr.close_rate,
    curr.sales_per_store,

    -- 전년 동분기 값
    prev.sales_amount AS prev_sales_amount,
    prev.store_count AS prev_store_count,
    prev.close_rate AS prev_close_rate,
    prev.sales_per_store AS prev_sales_per_store,

    -- 매출 YoY 증감률 (%)
    CASE
        WHEN prev.sales_amount > 0
        THEN (curr.sales_amount - prev.sales_amount)::numeric
             / prev.sales_amount * 100
        ELSE NULL
    END AS sales_yoy_pct,

    -- 점포 수 YoY 증감률 (%)
    CASE
        WHEN prev.store_count > 0
        THEN (curr.store_count - prev.store_count)::numeric
             / prev.store_count * 100
        ELSE NULL
    END AS store_yoy_pct,

    -- 점포당 매출 YoY 증감률 (%)
    CASE
        WHEN prev.sales_per_store > 0
             AND curr.sales_per_store IS NOT NULL
        THEN (curr.sales_per_store - prev.sales_per_store)
             / prev.sales_per_store * 100
        ELSE NULL
    END AS sales_per_store_yoy_pct,

    -- 폐업률 전년 대비 변화 (%p)
    CASE
        WHEN prev.close_rate IS NOT NULL
        THEN curr.close_rate - prev.close_rate
        ELSE NULL
    END AS close_rate_yoy_diff

FROM public.commercial_kpi curr

LEFT JOIN public.commercial_kpi prev
    ON curr.상권_코드 = prev.상권_코드
   AND curr.서비스_업종_코드 = prev.서비스_업종_코드
   AND prev.기준_년분기_코드 = curr.기준_년분기_코드 - 10;

-- 2. YoY 계산 결과 확인
SELECT
    기준_년분기_코드,
    상권_코드_명,
    서비스_업종_코드_명,
    sales_amount,
    prev_sales_amount,
    ROUND(sales_yoy_pct, 2) AS sales_yoy_pct,
    store_count,
    prev_store_count,
    ROUND(store_yoy_pct, 2) AS store_yoy_pct,
    ROUND(sales_per_store_yoy_pct, 2) AS sales_per_store_yoy_pct,
    close_rate,
    prev_close_rate,
    ROUND(close_rate_yoy_diff, 2) AS close_rate_yoy_diff
FROM public.commercial_kpi_yoy
WHERE 기준_년분기_코드 >= 20241
ORDER BY 기준_년분기_코드, 상권_코드, 서비스_업종_코드
LIMIT 20;

-- 3. YoY 데이터 검증
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN prev_sales_amount IS NULL
        THEN 1 ELSE 0 END) AS no_prev_sales,

    SUM(CASE WHEN sales_yoy_pct IS NULL
        THEN 1 ELSE 0 END) AS null_sales_yoy,

    SUM(CASE WHEN store_yoy_pct IS NULL
        THEN 1 ELSE 0 END) AS null_store_yoy,

    SUM(CASE WHEN sales_per_store_yoy_pct IS NULL
        THEN 1 ELSE 0 END) AS null_sales_per_store_yoy,

    SUM(CASE WHEN close_rate_yoy_diff IS NULL
        THEN 1 ELSE 0 END) AS null_close_rate_diff

FROM public.commercial_kpi_yoy
WHERE 기준_년분기_코드 >= 20241;