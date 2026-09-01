SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'sales_2023_raw'
ORDER BY ordinal_position;
DO $$
DECLARE
    col RECORD;
BEGIN
    FOR col IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'sales_2023_raw'
          AND data_type = 'integer'
          AND column_name LIKE '%매출_금액%'
    LOOP
        EXECUTE format(
            'ALTER TABLE public.sales_2023_raw ALTER COLUMN %I TYPE BIGINT',
            col.column_name
        );
    END LOOP;
END $$;
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'sales_2023_raw'
ORDER BY ordinal_position;