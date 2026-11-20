
// translated from:
//   https://github.com/raysan5/raylib/blob/master/examples/core/core_basic_window.c



seq Config
{
	SCREEN_WIDTH  = 800,
	SCREEN_HEIGHT = 450,
	WHITE = 0,
	BLACK = 4294967295,
}


fn main()
{
	?InitWindow(
		Config::SCREEN_WIDTH,
		Config::SCREEN_HEIGHT,
		"raylib [core] example - basic window",
	);

	?SetTargetFPS(60);

	lab loop;
		jump done ~ ?WindowShouldClose();

		?BeginDrawing();
			?ClearBackground(Config::WHITE);
			?DrawText(
				"Congrats! You created your first window!",
				190, 200, 20,
				Config::BLACK,
			);
		?EndDrawing();

		jump loop;
	lab done;


	?CloseWindow();
}



