-- 17-1. Tableau용 최종 상권 위험도 데이터 생성

CREATE OR REPLACE VIEW public.tableau_commercial_risk AS

SELECT
    상권_코드,
    상권_코드_명,

    -- 핵심 위험 지표
    avg_sales_yoy_pct,
    avg_per_store_yoy_pct,
    avg_close_rate_diff,
    triple_warning_pct,

    -- 최종 위험 점수 및 순위
    risk_score,
    risk_rank,

    -- Tableau 표시용 위험 등급
    CASE
        WHEN risk_score >= 75 THEN 'High'
        WHEN risk_score >= 25 THEN 'Medium'
        ELSE 'Low'
    END AS risk_grade

FROM public.commercial_risk_score;

-- 17-2. Tableau용 데이터 확인

SELECT *
FROM public.tableau_commercial_risk
ORDER BY risk_rank
LIMIT 20;

SELECT 1;
ALTER USER postgres WITH PASSWORD 'ax2^^114';