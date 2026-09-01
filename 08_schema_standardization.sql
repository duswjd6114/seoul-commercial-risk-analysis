-- 2025년 점포 데이터 컬럼명 표준화

CREATE OR REPLACE VIEW public.stores_2025_std AS
SELECT
    stdr_yyqu_cd        AS 기준_년분기_코드,
    trdar_se_cd         AS 상권_구분_코드,
    trdar_se_cd_nm      AS 상권_구분_코드_명,
    trdar_cd            AS 상권_코드,
    trdar_cd_nm         AS 상권_코드_명,
    svc_induty_cd       AS 서비스_업종_코드,
    svc_induty_cd_nm    AS 서비스_업종_코드_명,
    stor_co             AS 점포_수,
    similr_induty_stor_co AS 유사_업종_점포_수,
    opbiz_rt            AS 개업_율,
    opbiz_stor_co       AS 개업_점포_수,
    clsbiz_rt           AS 폐업_률,
    clsbiz_stor_co      AS 폐업_점포_수,
    frc_stor_co         AS 프랜차이즈_점포_수
FROM public.stores_2025_raw;

SELECT *
FROM public.stores_2025_std
LIMIT 10;