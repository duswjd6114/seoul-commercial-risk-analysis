-- 1. 매출 데이터 기준 점포 데이터 매칭 여부 확인
SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(st.기준_년분기_코드) AS matched_rows,
    COUNT(*) - COUNT(st.기준_년분기_코드) AS unmatched_rows
FROM public.sales_all s
LEFT JOIN public.stores_all st
    ON s.기준_년분기_코드 = st.기준_년분기_코드
   AND s.상권_코드 = st.상권_코드
   AND s.서비스_업종_코드 = st.서비스_업종_코드;

-- 2. 매출 + 점포 데이터 결합
CREATE OR REPLACE VIEW public.commercial_analysis AS

SELECT
    s.*,
    st.점포_수,
    st.유사_업종_점포_수,
    st.개업_율,
    st.개업_점포_수,
    st.폐업_률,
    st.폐업_점포_수,
    st.프랜차이즈_점포_수
FROM public.sales_all s
LEFT JOIN public.stores_all st
    ON s.기준_년분기_코드 = st.기준_년분기_코드
   AND s.상권_코드 = st.상권_코드
   AND s.서비스_업종_코드 = st.서비스_업종_코드;

-- 3. 매출 + 점포 JOIN 결과 검증
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT 기준_년분기_코드) AS quarter_count,
    MIN(기준_년분기_코드) AS first_quarter,
    MAX(기준_년분기_코드) AS last_quarter,

    SUM(CASE WHEN 점포_수 IS NULL THEN 1 ELSE 0 END) AS null_store_count,
    SUM(CASE WHEN 폐업_점포_수 IS NULL THEN 1 ELSE 0 END) AS null_closed_count
FROM public.commercial_analysis;