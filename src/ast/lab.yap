

use "lib/chunk.yap"



seq Ast::Lab
{
    NAME, // Str
    INFO, // Lex::Info
}


fn Ast::Lab::Parse(stream)
{
    put node = Chunk::New(Ast::Lab);
    Lex::Expect(stream, "lab");
    put node.Ast::Lab::INFO = Lex::Info(stream);
    put node.Ast::Lab::NAME = Str::Copy(Lex::PopCheck(stream, Lex::Kind::IDEN));
    Lex::Expect(stream, ";");
    return node;
}


fn Ast::Lab::Compile(node, ctx)
{
    put local = ctx.Ctx::Global::LOCAL;

    put name  = node.Ast::Lab::NAME;
    put table = local.Ctx::Local::LAB_TABLE;

    jump already_defined_error ~ HT::Has(table, name);

    HT::Set(table, name,
        IR::Emit(ctx, IR::Op::REF, Mem::NULL),
    );


	jump done;
lab already_defined_error;
	Error::LexError(
		node.Ast::Lab::INFO,
		"Label `%s` already defined in function `%s`",
		[name, local.Ctx::Local::FN_NAME],
	);

lab done;
}

fn Ast::Lab::Void(node)
{
    Chunk::Void(node.Ast::Lab::NAME);
    Chunk::Void(node);
}
