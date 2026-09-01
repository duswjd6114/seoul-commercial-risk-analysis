-- 2023~2025 매출 데이터 컬럼 구조 비교
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'sales_2023_raw',
      'sales_2024_raw',
      'sales_2025_raw'
  )
ORDER BY ordinal_position, table_name;

-- 2023~2025 매출 데이터 통합
CREATE OR REPLACE VIEW public.sales_all AS

SELECT *
FROM public.sales_2023_raw

UNION ALL

SELECT *
FROM public.sales_2024_raw

UNION ALL

SELECT *
FROM public.sales_2025_raw;

-- 2023~2025 매출 통합 데이터 검증
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT 기준_년분기_코드) AS quarter_count,
    MIN(기준_년분기_코드) AS first_quarter,
    MAX(기준_년분기_코드) AS last_quarter
FROM public.sales_all;