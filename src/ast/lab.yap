

use "lib/chunk.yap"



seq Ast::Lab
{
    NAME, // Str
}


fn Ast::Lab::Parse(stream)
{
    put node = Chunk::New(Ast::Lab);
    Lex::Expect(stream, "lab");
    put node.Ast::Lab::NAME = Str::Copy(Lex::PopCheck(stream, Lex::Kind::IDEN));
    Lex::Expect(stream, ";");
    return node;
}


fn Ast::Lab::Compile(node, ctx)
{
    put local = ctx.Ctx::Global::LOCAL;

	// this is quite questionable.
	// symbol name for debugging.
	static 4096 ~ symbol;
	Str::Format(symbol, "%s/%s", [
		(ctx.Ctx::Global::LOCAL).Ctx::Local::FN_NAME,
		node.Ast::Lab::NAME,
	]);

    HT::Set(
        local.Ctx::Local::LAB_TABLE,
        node.Ast::Lab::NAME,
        IR::Emit(ctx, IR::Op::REF,
        	// TODO: fix this leaking memory
        	Str::Copy(symbol),
        ),
    );
}

fn Ast::Lab::Void(node)
{
    Chunk::Void(node.Ast::Lab::NAME);
    Chunk::Void(node);
}
