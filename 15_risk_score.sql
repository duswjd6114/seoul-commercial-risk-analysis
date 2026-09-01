CREATE OR REPLACE VIEW public.commercial_risk_score as

-- 1. 상권별 위험 지표 백분위 점수 변환
WITH area_metrics AS (
    SELECT
        상권_코드,
        상권_코드_명,

        -- 위험 신호 강도
        AVG(sales_yoy_pct) AS avg_sales_yoy_pct,
        AVG(sales_per_store_yoy_pct) AS avg_per_store_yoy_pct,
        AVG(close_rate_yoy_diff) AS avg_close_rate_diff,

        -- 3개 위험 신호 동시 발생 비율
        100.0 * COUNT(*) FILTER (
            WHERE sales_yoy_pct < 0
              AND sales_per_store_yoy_pct < 0
              AND close_rate_yoy_diff > 0
        )
        / NULLIF(COUNT(*) FILTER (
            WHERE sales_yoy_pct IS NOT NULL
              AND sales_per_store_yoy_pct IS NOT NULL
              AND close_rate_yoy_diff IS NOT NULL
        ), 0) AS triple_warning_pct

    FROM public.commercial_kpi_yoy
    WHERE 기준_년분기_코드 BETWEEN 20251 AND 20254

    GROUP BY
        상권_코드,
        상권_코드_명

    -- 앞에서 정한 최소 표본 기준
    HAVING COUNT(*) FILTER (
        WHERE sales_yoy_pct IS NOT NULL
    ) >= 20
),
risk_percentile AS (
    SELECT
        *,

        -- 매출이 낮을수록 위험점수 ↑
        100 * (1 - PERCENT_RANK() OVER (
            ORDER BY avg_sales_yoy_pct
        )) AS sales_risk,

        -- 점포당 매출이 낮을수록 위험점수 ↑
        100 * (1 - PERCENT_RANK() OVER (
            ORDER BY avg_per_store_yoy_pct
        )) AS per_store_risk,

        -- 폐업률 상승이 클수록 위험점수 ↑
        100 * PERCENT_RANK() OVER (
            ORDER BY avg_close_rate_diff
        ) AS close_risk,

        -- 3중 위험 발생 비율이 높을수록 위험점수 ↑
        100 * PERCENT_RANK() OVER (
            ORDER BY triple_warning_pct
        ) AS warning_risk

    FROM area_metrics
)

-- 최종 Risk Score 및 위험 순위 산출
SELECT
    상권_코드,
    상권_코드_명,

    ROUND(avg_sales_yoy_pct, 2) AS avg_sales_yoy_pct,
    ROUND(avg_per_store_yoy_pct, 2) AS avg_per_store_yoy_pct,
    ROUND(avg_close_rate_diff, 2) AS avg_close_rate_diff,
    ROUND(triple_warning_pct, 2) AS triple_warning_pct,

    -- 4개 위험지표 동일 가중치(각 25%)
    ROUND((
        sales_risk * 0.25
      + per_store_risk * 0.25
      + close_risk * 0.25
      + warning_risk * 0.25
    )::numeric, 2) AS risk_score,

    -- 위험도 순위
    RANK() OVER (
        ORDER BY (
            sales_risk * 0.25
          + per_store_risk * 0.25
          + close_risk * 0.25
          + warning_risk * 0.25
        ) DESC
    ) AS risk_rank

FROM risk_percentile

ORDER BY risk_score DESC;