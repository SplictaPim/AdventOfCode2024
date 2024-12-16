-----------------------------------------------------------
-----------------------------------------------------------
-- vraag 1:
-----------------------------------------------------------
-----------------------------------------------------------
SELECT sum(mul[1]::bigint * mul[2]::bigint)
FROM (
	select regexp_matches("Input", 'mul\((\d+),(\d+)\)', 'g') as mul
	from "AoC2024"."InputDay3"
	)
;
-----------------------------------------------------------
-----------------------------------------------------------
-- Vraag 2:
-----------------------------------------------------------
-----------------------------------------------------------
with items as (	select mul, row_number() over () as rnum from (
	select unnest(regexp_matches("Input", '(don''t\(\))|(do\(\))|(mul\(\d+,\d+\))', 'g')) as mul from "AoC2024"."InputDay3"
	)
	where mul is not null
	union
	select 'do()', 0 as rnum
	order by rnum
	)
, dos as (select * from items where mul = 'do()' union select 'do()' as mul, 0 as rnum)
, dont as (select * from items where mul = 'don''t()')
, instructions as (
    select *, true as enabled from dos
    union select *, false as enabled from dont
    order by rnum asc
)

, enableditems as (
	select items.mul, items.rnum, enabled
    from items,
    lateral (
        select enabled
        from instructions i
        where i.rnum <= items.rnum
        order by i.rnum desc limit 1
    ) inst
)
 select sum(mul[1]::bigint * mul[2]::bigint)
 from (
 select regexp_matches(mul, 'mul\((\d+),(\d+)\)', 'g') as mul
	from enableditems where enabled = true 
	and mul LIKE 'mul%')
