-- 1. Risk Score View 생성 확인

SELECT
    상권_코드_명,
    avg_sales_yoy_pct,
    avg_per_store_yoy_pct,
    avg_close_rate_diff,
    triple_warning_pct,
    risk_score,
    risk_rank
FROM public.commercial_risk_score
ORDER BY risk_rank
LIMIT 10;

-- 2. Risk Score 상위·중위·하위 그룹 비교
WITH risk_group AS (
    SELECT
        *,
        CASE
            WHEN risk_score >= 75 THEN 'High'
            WHEN risk_score >= 25 THEN 'Medium'
            ELSE 'Low'
        END AS risk_group
    FROM public.commercial_risk_score
)

SELECT
    risk_group,

    -- 그룹별 상권 수
    COUNT(*) AS area_count,

    -- 실제 지표 평균
    ROUND(AVG(avg_sales_yoy_pct), 2) AS avg_sales_yoy_pct,
    ROUND(AVG(avg_per_store_yoy_pct), 2) AS avg_per_store_yoy_pct,
    ROUND(AVG(avg_close_rate_diff), 2) AS avg_close_rate_diff,
    ROUND(AVG(triple_warning_pct), 2) AS avg_triple_warning_pct,

    -- 평균 위험점수
    ROUND(AVG(risk_score), 2) AS avg_risk_score

FROM risk_group

GROUP BY risk_group

ORDER BY avg_risk_score DESC;

-- 3. 매출 증감률 이상치 확인
SELECT
    상권_코드_명,
    avg_sales_yoy_pct,
    avg_per_store_yoy_pct,
    avg_close_rate_diff,
    risk_score,
    risk_rank
FROM public.commercial_risk_score

-- 매출 증가율이 가장 큰 상권부터 확인
ORDER BY avg_sales_yoy_pct DESC

LIMIT 20;

-- 4. Risk Score 그룹별 중앙값 검증
WITH risk_group AS (
    SELECT
        *,
        CASE
            WHEN risk_score >= 75 THEN 'High'
            WHEN risk_score >= 25 THEN 'Medium'
            ELSE 'Low'
        END AS risk_group
    FROM public.commercial_risk_score
)

SELECT
    risk_group,
    COUNT(*) AS area_count,

    -- 그룹별 실제 지표 중앙값
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY avg_sales_yoy_pct)::numeric, 2
    ) AS median_sales_yoy_pct,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY avg_per_store_yoy_pct)::numeric, 2
    ) AS median_per_store_yoy_pct,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY avg_close_rate_diff)::numeric, 2
    ) AS median_close_rate_diff,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY triple_warning_pct)::numeric, 2
    ) AS median_triple_warning_pct,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY risk_score)::numeric, 2
    ) AS median_risk_score

FROM risk_group

GROUP BY risk_group

ORDER BY median_risk_score DESC;