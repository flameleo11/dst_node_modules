function test(tag)
	for i=0,3 do
		print(tag, i, getfenv(i))
	end
end



test(1)


require "t2"


1	0	table: 0x55c24af40900
1	1	table: 0x55c24af40900
1	2	table: 0x55c24af40900
1	3	table: 0x55c24af40900
222	table: 0x55c24af4c6c0
2	0	table: 0x55c24af40900
2	1	table: 0x55c24af40900
2	2	table: 0x55c24af4c6c0
2	3	table: 0x55c24af40900
333	table: 0x55c24af4c5b0
3	0	table: 0x55c24af40900
3	1	table: 0x55c24af40900
3	2	table: 0x55c24af4c5b0
3	3	table: 0x55c24af4c6c0
nil	nil	123





-- 1	0	table: 0x558bb6620900
-- 1	1	table: 0x558bb6620900
-- 1	2	table: 0x558bb6620900
-- 1	3	table: 0x558bb6620900
-- 222	table: 0x558bb662be90
-- 2	0	table: 0x558bb6620900
-- 2	1	table: 0x558bb6620900
-- 2	2	table: 0x558bb662be90
-- 2	3	table: 0x558bb6620900
-- 333	table: 0x558bb662be40
-- 3	0	table: 0x558bb6620900
-- 3	1	table: 0x558bb6620900
-- 3	2	table: 0x558bb662be40
-- 3	3	table: 0x558bb662be90
-- [Finished in 0.0s]

-- 1	0	table: 0x55b496c8d900
-- 1	1	table: 0x55b496c8d900
-- 1	2	table: 0x55b496c8d900
-- 1	3	table: 0x55b496c8d900
-- 222	table: 0x55b496c98e90
-- 2	0	table: 0x55b496c8d900
-- 2	1	table: 0x55b496c8d900
-- 2	2	table: 0x55b496c98e90
-- 2	3	table: 0x55b496c8d900
-- [Finished in 0.0s]

-- 1	0	table: 0x560042c9d900
-- 1	1	table: 0x560042c9d900
-- 1	2	table: 0x560042c9d900
-- 1	3	table: 0x560042c9d900
-- 2	0	table: 0x560042c9d900
-- 2	1	table: 0x560042c9d900
-- 2	2	table: 0x560042ca8d00
-- 2	3	table: 0x560042c9d900
-- [Finished in 0.0s]



-- 1	0	table: 0x55ef22949900
-- 1	1	table: 0x55ef22949900
-- 1	2	table: 0x55ef22949900
-- 1	3	table: 0x55ef22949900
-- 2	0	table: 0x55ef22949900
-- 2	1	table: 0x55ef22949900
-- 2	2	table: 0x55ef22949900
-- 2	3	table: 0x55ef22949900