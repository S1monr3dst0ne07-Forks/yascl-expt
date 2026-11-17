
use "lib/debug.yap"

fn my_add(a, b)
{
	return a + b;
}


fn main()
{
	put my_fn_ptr = @my_add;
	put sum = @my_fn_ptr(2, 3);

	print("%d\n", [sum]);
}



