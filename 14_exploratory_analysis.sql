-- 1. 분기별 위험 신호 발생 건수 확인
SELECT
    기준_년분기_코드,

    -- 전년 동기와 비교 가능한 상권×업종 수
    COUNT(*) FILTER (
        WHERE sales_yoy_pct IS NOT NULL
    ) AS comparable_rows,

    -- 전년 동기 대비 매출이 감소한 수
    COUNT(*) FILTER (
        WHERE sales_yoy_pct < 0
    ) AS sales_decline_rows,

    -- 전년 동기 대비 점포당 매출이 감소한 수
    COUNT(*) FILTER (
        WHERE sales_per_store_yoy_pct < 0
    ) AS per_store_decline_rows,

    -- 전년 동기 대비 폐업률이 상승한 수
    COUNT(*) FILTER (
        WHERE close_rate_yoy_diff > 0
    ) AS close_rate_up_rows,

    -- 매출↓ + 점포당 매출↓ + 폐업률↑가 동시에 나타난 수
    COUNT(*) FILTER (
        WHERE sales_yoy_pct < 0
          AND sales_per_store_yoy_pct < 0
          AND close_rate_yoy_diff > 0
    ) AS triple_warning_rows

FROM public.commercial_kpi_yoy
WHERE 기준_년분기_코드 >= 20241

GROUP BY 기준_년분기_코드
ORDER BY 기준_년분기_코드;

-- 2. 분기별 위험 신호 발생 비율 확인
SELECT
    기준_년분기_코드,

    -- 전년 동기와 비교 가능한 상권×업종 수
    COUNT(*) FILTER (
        WHERE sales_yoy_pct IS NOT NULL
    ) AS comparable_rows,

    -- 매출 감소 비율
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE sales_yoy_pct < 0)
        / NULLIF(COUNT(*) FILTER (WHERE sales_yoy_pct IS NOT NULL), 0)
    , 2) AS sales_decline_pct,

    -- 점포당 매출 감소 비율
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE sales_per_store_yoy_pct < 0)
        / NULLIF(COUNT(*) FILTER (WHERE sales_per_store_yoy_pct IS NOT NULL), 0)
    , 2) AS per_store_decline_pct,

    -- 폐업률 상승 비율
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE close_rate_yoy_diff > 0)
        / NULLIF(COUNT(*) FILTER (WHERE close_rate_yoy_diff IS NOT NULL), 0)
    , 2) AS close_rate_up_pct,

    -- 매출↓ + 점포당 매출↓ + 폐업률↑ 동시 발생 비율
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE sales_yoy_pct < 0
              AND sales_per_store_yoy_pct < 0
              AND close_rate_yoy_diff > 0
        )
        / NULLIF(COUNT(*) FILTER (
            WHERE sales_yoy_pct IS NOT NULL
              AND sales_per_store_yoy_pct IS NOT NULL
              AND close_rate_yoy_diff IS NOT NULL
        ), 0)
    , 2) AS triple_warning_pct

FROM public.commercial_kpi_yoy
WHERE 기준_년분기_코드 >= 20241

GROUP BY 기준_년분기_코드
ORDER BY 기준_년분기_코드;

-- 3. 2025년 상권별 위험 신호 탐색
SELECT
    상권_코드,
    상권_코드_명,
    -- 전년 동기 비교 가능 데이터 수
    COUNT(*) FILTER (
        WHERE sales_yoy_pct IS NOT NULL
    ) AS comparable_rows,
    -- 매출 감소 비율
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE sales_yoy_pct < 0)
        / NULLIF(COUNT(*) FILTER (WHERE sales_yoy_pct IS NOT NULL), 0)
    , 2) AS sales_decline_pct,
    -- 점포당 매출 감소 비율
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE sales_per_store_yoy_pct < 0)
        / NULLIF(COUNT(*) FILTER (WHERE sales_per_store_yoy_pct IS NOT NULL), 0)
    , 2) AS per_store_decline_pct,
    -- 폐업률 상승 비율
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE close_rate_yoy_diff > 0)
        / NULLIF(COUNT(*) FILTER (WHERE close_rate_yoy_diff IS NOT NULL), 0)
    , 2) AS close_rate_up_pct,
    -- 3개 위험 신호 동시 발생 비율
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE sales_yoy_pct < 0
              AND sales_per_store_yoy_pct < 0
              AND close_rate_yoy_diff > 0
        )
        / NULLIF(COUNT(*) FILTER (
            WHERE sales_yoy_pct IS NOT NULL
              AND sales_per_store_yoy_pct IS NOT NULL
              AND close_rate_yoy_diff IS NOT NULL
        ), 0)
    , 2) AS triple_warning_pct
FROM public.commercial_kpi_yoy

-- 2025년 4개 분기
WHERE 기준_년분기_코드 BETWEEN 20251 AND 20254
GROUP BY
    상권_코드,
    상권_코드_명

-- (4.분포 확인 후 추가) 비교 가능 데이터가 20건 이상인 상권만 분석 
HAVING COUNT(*) FILTER (
    WHERE sales_yoy_pct IS NOT NULL
) >= 20
ORDER BY triple_warning_pct DESC NULLS LAST;

-- 4. 상권별 비교 가능 데이터 수 분포 확인
WITH area_counts AS (
    SELECT
        상권_코드,
        상권_코드_명,
        COUNT(*) FILTER (
            WHERE sales_yoy_pct IS NOT NULL
        ) AS comparable_rows
    FROM public.commercial_kpi_yoy
    WHERE 기준_년분기_코드 BETWEEN 20251 AND 20254
    GROUP BY 상권_코드, 상권_코드_명
)

SELECT
    MIN(comparable_rows) AS min_rows,
    ROUND(AVG(comparable_rows), 2) AS avg_rows,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY comparable_rows) AS q1_rows,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY comparable_rows) AS median_rows,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY comparable_rows) AS q3_rows,
    MAX(comparable_rows) AS max_rows
FROM area_counts;

-- 5. 2025년 상권별 위험 신호 강도 확인
SELECT
    상권_코드,
    상권_코드_명,

    -- 비교 가능 데이터 수
    COUNT(*) FILTER (
        WHERE sales_yoy_pct IS NOT NULL
    ) AS comparable_rows,

    -- 평균 매출 증감률
    ROUND(AVG(sales_yoy_pct), 2) AS avg_sales_yoy_pct,

    -- 평균 점포당 매출 증감률
    ROUND(AVG(sales_per_store_yoy_pct), 2) AS avg_per_store_yoy_pct,

    -- 평균 폐업률 증감(%p)
    ROUND(AVG(close_rate_yoy_diff), 2) AS avg_close_rate_diff

FROM public.commercial_kpi_yoy

WHERE 기준_년분기_코드 BETWEEN 20251 AND 20254

GROUP BY
    상권_코드,
    상권_코드_명

-- 앞에서 정한 최소 표본 기준
HAVING COUNT(*) FILTER (
    WHERE sales_yoy_pct IS NOT NULL
) >= 20

-- 평균 매출 감소폭이 큰 상권부터
ORDER BY avg_sales_yoy_pct ASC NULLS LAST;

-- 6. Risk Score 설계를 위한 지표 분포 확인
WITH area_metrics AS (
    SELECT
        상권_코드,
        상권_코드_명,

        -- 평균 매출 증감률
        AVG(sales_yoy_pct) AS avg_sales_yoy_pct,

        -- 평균 점포당 매출 증감률
        AVG(sales_per_store_yoy_pct) AS avg_per_store_yoy_pct,

        -- 평균 폐업률 증감
        AVG(close_rate_yoy_diff) AS avg_close_rate_diff

    FROM public.commercial_kpi_yoy

    WHERE 기준_년분기_코드 BETWEEN 20251 AND 20254

    GROUP BY
        상권_코드,
        상권_코드_명

    HAVING COUNT(*) FILTER (
        WHERE sales_yoy_pct IS NOT NULL
    ) >= 20
)

SELECT
    -- 매출 증감률 분포
    ROUND(PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY avg_sales_yoy_pct)::numeric, 2) AS sales_q1,
    ROUND(PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY avg_sales_yoy_pct)::numeric, 2) AS sales_median,
    ROUND(PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY avg_sales_yoy_pct)::numeric, 2) AS sales_q3,

    -- 점포당 매출 증감률 분포
    ROUND(PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY avg_per_store_yoy_pct)::numeric, 2) AS per_store_q1,
    ROUND(PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY avg_per_store_yoy_pct)::numeric, 2) AS per_store_median,
    ROUND(PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY avg_per_store_yoy_pct)::numeric, 2) AS per_store_q3,

    -- 폐업률 증감 분포
    ROUND(PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY avg_close_rate_diff)::numeric, 2) AS close_q1,
    ROUND(PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY avg_close_rate_diff)::numeric, 2) AS close_median,
    ROUND(PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY avg_close_rate_diff)::numeric, 2) AS close_q3

FROM area_metrics;