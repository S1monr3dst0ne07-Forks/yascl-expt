
// this module is responsible for generating
// the elf symbol table needed for debugging.
// the symtab is not required to produce a working
// executable, hence why it's been confined to
// this file. 


seq Symtab::Stuff
{
	STR_TAB_BASE_PTR, // vaddr pointer to start of string table
	STR_TAB_END_PTR , // vaddr pointer to end   of string table
	SYM_TAB_BASE_PTR, // vaddr pointer to start of symbol table
	SYM_TAB_END_PTR,  // vaddr pointer to end   of symbol table

	SECT_HDR_BASE_PTR, // vaddr pointer to start of section headers
	STR_TAB_MAP,       // map from symbol to offset into string table
}

fn Symtab::GenStrTab(ctx, stuff)
{
	// generates the string table
	// with all of the function / label
	// names.

	put stuff.Symtab::Stuff::STR_TAB_BASE_PTR = IR::Addr(ctx);
	put map = stuff.Symtab::Stuff::STR_TAB_MAP;

	// the elf64 string table starts with an empty string.
	// don't ask me why, it's just like that...
	IR::Push8(ctx, '\0');

	// the string table works based on offsets.
	put offset = 0;

	put iter = ctx.Ctx::Global::IR_ROOT;
	lab ir_loop;
		put iter = iter.IR::Node::NEXT;
		jump ir_done ~ iter == Mem::NULL;
		jump ir_loop ~ (iter.IR::Node::OPCODE) != IR::Op::REF;

		put symbol = iter.IR::Node::ARG;
		jump ir_loop ~ HT::Has(map, symbol);
		
		// if symbol is not yet present in table,
		// put it there and record it.
		HT::Set(map, symbol, offset);

		put i = 0;
		lab symbol_loop;
			put char = symbol.i;
			put i = i + 1;

			put offset = offset + 1;
			IR::Push8(ctx, char);
		jump symbol_loop ~ char;

		jump ir_loop;
	lab ir_done;

	put stuff.Symtab::Stuff::STR_TAB_END_PTR = IR::Addr(ctx);
}

fn Symtab::GenSymTab(ctx, stuff)
{
	put stuff.Symtab::Stuff::SYM_TAB_BASE_PTR = IR::Addr(ctx);
	put map = stuff.Symtab::Stuff::STR_TAB_MAP;

	//typedef struct {
	//    uint32_t      st_name ;
	//    uint8_t   	st_info ;
	//    uint8_t 		st_other;
	//    uint16_t      st_shndx;
	//    uintptr_t     st_value;
	//    uint64_t      st_size ;
	//} Elf64_Sym;

	// empty symbol entry for some reason...
	IR::Push32(ctx, 0); // st_name
	IR::Push8 (ctx, 0); // st_info
	IR::Push8 (ctx, 0); // st_other
	IR::Push16(ctx, 0); // st_shndx
	IR::Push64(ctx, 0); // st_value
	IR::Push64(ctx, 0); // st_size


	put iter = ctx.Ctx::Global::IR_ROOT;
	lab ir_loop;
		put iter = iter.IR::Node::NEXT;
		jump ir_done ~ iter == Mem::NULL;
		jump ir_loop ~ (iter.IR::Node::OPCODE) != IR::Op::REF;

		put symbol = iter.IR::Node::ARG;
		put addr   = iter.IR::Node::ADDR;
		put offset = HT::Get(map, symbol);

		IR::Push32(ctx, offset); // st_name
		IR::Push8 (ctx, 16    ); // st_info  = STT_NOTYPE | STB_GLOBAL
		IR::Push8 (ctx, 0     ); // st_other = STV_DEFAULT
		IR::Push16(ctx, 65521 ); // st_shndx = SHN_ABS
		IR::Push64(ctx, addr  ); // st_value
		IR::Push64(ctx, 0     ); // st_size  = 0

		jump ir_loop;
	lab ir_done;

	put stuff.Symtab::Stuff::SYM_TAB_END_PTR = IR::Addr(ctx);
}

fn Symtab::GenSectHdrs(ctx, stuff)
{
	put stuff.Symtab::Stuff::SECT_HDR_BASE_PTR = IR::Addr(ctx);

	// --- null section header ---
	IR::Push32(ctx, 0); // sh_name      = 0
	IR::Push32(ctx, 0); // sh_type      = SHT_NULL
	IR::Push64(ctx, 0); // sh_flags     = 0
	IR::Push64(ctx, 0); // sh_addr      = 0
	IR::Push64(ctx, 0); // sh_offset    = 0
	IR::Push64(ctx, 0); // sh_size      = 0
	IR::Push32(ctx, 0); // sh_link      = 0
	IR::Push32(ctx, 0); // sh_info      = 0
	IR::Push64(ctx, 0); // sh_addralign = 0
	IR::Push64(ctx, 0); // sh_ent_size  = 0

	// --- section header for string table ---
	put str_tab_base_ptr = stuff.Symtab::Stuff::STR_TAB_BASE_PTR;
	put str_tab_end_ptr  = stuff.Symtab::Stuff::STR_TAB_END_PTR;

	put str_tab_offset = str_tab_base_ptr - Tmpl::Config::LOAD_ADDR;
	put str_tab_size   = str_tab_end_ptr  - str_tab_base_ptr;

	IR::Push32(ctx, 0             ); // sh_name      = 0
	IR::Push32(ctx, 3             ); // sh_type      = SHT_STRTAB
	IR::Push64(ctx, 0             ); // sh_flags     = 0
	IR::Push64(ctx, 0             ); // sh_addr      = 0 (don't load)
	IR::Push64(ctx, str_tab_offset); // sh_offset
	IR::Push64(ctx, str_tab_size  ); // sh_size
	IR::Push32(ctx, 0             ); // sh_link      = 0
	IR::Push32(ctx, 0             ); // sh_info      = 0
	IR::Push64(ctx, 0             ); // sh_addralign = 0
	IR::Push64(ctx, 0             ); // sh_ent_size  = 0

	// --- section header for symbol table ---
	put sym_tab_base_ptr = stuff.Symtab::Stuff::SYM_TAB_BASE_PTR; 
	put sym_tab_end_ptr  = stuff.Symtab::Stuff::SYM_TAB_END_PTR; 

	put sym_tab_offset = sym_tab_base_ptr - Tmpl::Config::LOAD_ADDR;
	put sym_tab_size   = sym_tab_end_ptr  - sym_tab_base_ptr;

	IR::Push32(ctx, 0             ); // sh_name      = 0
	IR::Push32(ctx, 2             ); // sh_type      = SHT_SYMTAB
	IR::Push64(ctx, 0             ); // sh_flags     = 0
	IR::Push64(ctx, 0             ); // sh_addr      = 0 (don't load)
	IR::Push64(ctx, sym_tab_offset); // sh_offset
	IR::Push64(ctx, sym_tab_size  ); // sh_size
	IR::Push32(ctx, 1             ); // sh_link      = 1
	IR::Push32(ctx, 1             ); // sh_info      = 1
	IR::Push64(ctx, 0             ); // sh_addralign = 0
	IR::Push64(ctx, 24            ); // sh_ent_size  = 0
}

fn Symtab::PatchMainTable(ctx, stuff)
{
	// patch main elf table to make 
	// section header accessible.
	put sect_hdr_base_ptr    = stuff.Symtab::Stuff::SECT_HDR_BASE_PTR;
	put sect_hdr_base_offset = sect_hdr_base_ptr - Tmpl::Config::LOAD_ADDR;

	IR::PatchDyn(ctx, 58 + Tmpl::Config::LOAD_ADDR, 64, 2); // e_shentsize = 0x40
	IR::PatchDyn(ctx, 60 + Tmpl::Config::LOAD_ADDR, 3 , 2); // e_shnum     = 3
	IR::Patch64 (ctx, 40 + Tmpl::Config::LOAD_ADDR, sect_hdr_base_offset);
}


fn Symtab::Gen(ctx)
{
	put stuff = Chunk::New(Symtab::Stuff);
	put stuff.Symtab::Stuff::STR_TAB_MAP = HT::Create();

	Symtab::GenStrTab     (ctx, stuff);
	Symtab::GenSymTab     (ctx, stuff);
	Symtab::GenSectHdrs   (ctx, stuff);
	Symtab::PatchMainTable(ctx, stuff);
	
}


