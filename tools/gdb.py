import gdb
import os
import re


class YasclBacktrace(gdb.Command):
	def __init__(self):
		super().__init__("bt", gdb.COMMAND_STACK)

	def read_dyn(self, addr, n, signed=False):
		inf = gdb.selected_inferior()
		return int.from_bytes(inf.read_memory(addr, n), 'little', signed=signed)
	def read8(self, addr):
		return self.read_dyn(addr, 8)
	def read4(self, addr, signed=False):
		return self.read_dyn(addr, 4, signed)

	def param_count(self, frame):
		rbp = int(frame.read_register("rbp"))
		fn_name = frame.name()

		if fn_name == 'main': return 0

		ret_addr    = frame.older().pc()
		call_offset = self.read4(ret_addr - 4, signed=True)
		call_target = ret_addr + call_offset
		if call_target < 0: return 0

		inf = gdb.selected_inferior()
		insts = inf.architecture().disassemble(call_target, call_target + 1000)
		disasm = [x["asm"] for x in insts]
		match_dis = lambda pattern: re.match(pattern, disasm.pop(0))
		
		assert match_dis(r'push   %rbp'     )
		assert match_dis(r'mov    %rsp,%rbp')
		assert match_dis(r'sub    .*,%rsp'  )

		LOAD_PATTERN  = r'mov    %r..,%rax'
		STORE_PATTERN = r'mov    %rax,.*\(%rbp\)'
	
		count = 1 if match_dis(STORE_PATTERN) else 0

		while True:
			if match_dis(LOAD_PATTERN ) is None: break
			if match_dis(STORE_PATTERN) is None: break

			count += 1

		return count

	def invoke(self, arg, from_tty):
		frame = gdb.newest_frame()
		inf = gdb.selected_inferior()

		# for nice formatting...
		# (base_line, params)
		lines : list[tuple] = []
		
		number = 1
		while frame:
			if frame.type() == gdb.NORMAL_FRAME:
				rip = int(frame.read_register("rip"))
				rbp = int(frame.read_register("rbp"))
				fn_name = frame.name()

				param_count = self.param_count(frame)

				params = [
					self.read8(rbp - (x+1)*8)
					for x in range(param_count)
				]

				lines.append((
					f"#{number}\t{rip:016x} in {fn_name}",
					params
				))
				number += 1

			frame = frame.older()

		max_line_len = max(len(x) for x, _ in lines) + 2
		for line_base, params_raw in lines:
			padding = ' ' * (max_line_len - len(line_base))
			params  = ', '.join(str(x) for x in params_raw)
			print(f"{line_base}{padding}({params})")


YasclBacktrace()

