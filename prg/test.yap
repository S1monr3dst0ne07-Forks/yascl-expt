
// translated from:
//   https://github.com/raysan5/raylib/blob/master/examples/core/core_basic_window.c

// compile and link like this:
//    make
//    ./yascl prg/test.yap main.o
//    cc -no-pie -o main main.o -lraylib -lm -lX11

// if you're on wayland link like this:
//    cc -no-pie -o main main.o -lraylib -lm \
//       -lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon


use "lib/syscall.yap"
use "lib/mem.yap"
use "lib/chunk.yap"


seq Config
{
	SCREEN_WIDTH  = 800,
	SCREEN_HEIGHT = 450,
}

fn disable_glibc_brk_fuckshit()
{
	// we need glibc to NOT touch the
	// program break, because that's
	// where our Chunk heap lives.

	?mallopt(
		0-3, // M_MMAP_THRESHOLD
		0,
	);

	?mallopt(
		0-1, // M_TRIM_THRESHOLD
		0-1,
	);
}

fn cstr(qstr)
{
	put len  = Str::Len(qstr);
	put bstr = Chunk::New(len);
	Mem::ToBytes(bstr, qstr, len);
	return bstr;
}

fn RayColor2PBVObject(r, g, b, a)
{
	return
		(r      ) |
		(g << 8 ) |
		(b << 16) |
		(a << 24) ;
}


fn main()
{
	disable_glibc_brk_fuckshit();

	put RAYWHITE  = RayColor2PBVObject(245, 245, 245, 255);
	put LIGHTGRAY = RayColor2PBVObject(200, 200, 200, 255);

	?InitWindow(
		Config::SCREEN_WIDTH,
		Config::SCREEN_HEIGHT,
		cstr("raylib [core] example - basic window"),
	);

	?SetTargetFPS(60);

	put string = cstr("Congrats! You created your first window!");

	lab loop;
		jump done ~ ?WindowShouldClose();

		?BeginDrawing();
			?ClearBackground(RAYWHITE);
			?DrawText(
				string,
				190, 200, 20,
				LIGHTGRAY,
			);
		?EndDrawing();

		jump loop;
	lab done;


	?CloseWindow();
}



