
use "lib/debug.yap"

fn my_add(a, b)
{
	return a + b;
}

fn my_sub(a, b)
{
	return a - b;
}

fn apply_twice(func, a, b, c)
{
	return @func(@func(a, b), c);
}



fn main()
{
	print("%d\n", [apply_twice(@my_add, 5, 2, 3)]);
	print("%d\n", [apply_twice(@my_sub, 5, 2, 3)]);
}



