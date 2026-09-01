-- 2023~2025 점포 데이터 컬럼 구조 비교
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'stores_2023_raw',
      'stores_2024_raw',
      'stores_2025_std'
  )
ORDER BY ordinal_position, table_name;

-- 2023~2025 점포 데이터 통합
CREATE OR REPLACE VIEW public.stores_all AS

SELECT *
FROM public.stores_2023_raw

UNION ALL

SELECT *
FROM public.stores_2024_raw

UNION ALL

SELECT *
FROM public.stores_2025_std;

-- 2023~2025 점포 통합 데이터 검증
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT 기준_년분기_코드) AS quarter_count,
    MIN(기준_년분기_코드) AS first_quarter,
    MAX(기준_년분기_코드) AS last_quarter
FROM public.stores_all;