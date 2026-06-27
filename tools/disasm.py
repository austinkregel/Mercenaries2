import struct
import sys

OPCODES = [
    "MOVE", "LOADK", "LOADBOOL", "LOADNIL", "GETUPVAL",
    "GETGLOBAL", "GETTABLE", "SETGLOBAL", "SETUPVAL", "SETTABLE",
    "NEWTABLE", "SELF", "ADD", "SUB", "MUL", "DIV", "MOD", "POW",
    "UNM", "NOT", "LEN", "CONCAT", "JMP", "EQ", "LT", "LE", "TEST",
    "TESTSET", "CALL", "TAILCALL", "RETURN", "FORLOOP", "FORPREP",
    "TFORLOOP", "SETLIST", "CLOSE", "CLOSURE", "VARARG"
]

def parse_header(f):
    magic = f.read(4)
    assert magic == b'\x1bLua', "Invalid Lua file"
    version = f.read(1)
    format = f.read(1)
    endian = f.read(1)
    size_int = ord(f.read(1))
    size_size_t = ord(f.read(1))
    size_instruction = ord(f.read(1))
    size_number = ord(f.read(1))
    integral = ord(f.read(1))
    return endian, size_int, size_size_t, size_instruction, size_number

def read_string(f, size_size_t):
    if size_size_t == 4:
        size = struct.unpack('<I', f.read(4))[0]
    else:
        size = struct.unpack('<Q', f.read(8))[0]
    if size == 0:
        return ""
    s = f.read(size)
    return s[:-1].decode('utf-8', errors='replace')

def read_number(f, size_number):
    if size_number == 8:
        return struct.unpack('<d', f.read(8))[0]
    elif size_number == 4:
        return struct.unpack('<f', f.read(4))[0]
    else:
        raise Exception("Unsupported number size")

def parse_function(f, endian, size_int, size_size_t, size_instruction, size_number):
    source = read_string(f, size_size_t)
    line_defined = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    last_line_defined = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    num_upvalues = ord(f.read(1))
    num_params = ord(f.read(1))
    is_vararg = ord(f.read(1))
    max_stack_size = ord(f.read(1))
    
    # Read instructions
    num_instructions = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    instructions = []
    for _ in range(num_instructions):
        inst = struct.unpack('<I', f.read(4))[0]
        instructions.append(inst)
        
    # Read constants
    num_constants = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    constants = []
    for _ in range(num_constants):
        t = ord(f.read(1))
        if t == 0: # TNIL
            constants.append(None)
        elif t == 1: # TBOOLEAN
            constants.append(ord(f.read(1)) != 0)
        elif t == 3: # TNUMBER
            constants.append(read_number(f, size_number))
        elif t == 4: # TSTRING
            constants.append(read_string(f, size_size_t))
        else:
            raise Exception(f"Unknown constant type {t}")
            
    # Read prototypes
    num_prototypes = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    prototypes = []
    for _ in range(num_prototypes):
        proto = parse_function(f, endian, size_int, size_size_t, size_instruction, size_number)
        prototypes.append(proto)
        
    # Read debug info (source lines, locals, upvalues) - skip or read
    # Line info
    num_line_info = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    f.read(num_line_info * size_int)
    # Locals info
    num_locals = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    for _ in range(num_locals):
        read_string(f, size_size_t)
        f.read(2 * size_int)
    # Upvalues info
    num_upvalues_info = struct.unpack('<I' if size_int==4 else '<Q', f.read(size_int))[0]
    for _ in range(num_upvalues_info):
        read_string(f, size_size_t)
        
    return {
        'source': source,
        'line_defined': line_defined,
        'last_line_defined': last_line_defined,
        'num_upvalues': num_upvalues,
        'num_params': num_params,
        'is_vararg': is_vararg,
        'max_stack_size': max_stack_size,
        'instructions': instructions,
        'constants': constants,
        'prototypes': prototypes
    }

def decode_instruction(inst):
    opcode = inst & 0x3F
    a = (inst >> 6) & 0xFF
    c = (inst >> 14) & 0x1FF
    b = (inst >> 23) & 0x1FF
    bx = (inst >> 14) & 0x3FFFF
    sbx = bx - 131071
    return opcode, a, b, c, bx, sbx

def print_function(proto, indent=0):
    ind = "  " * indent
    print(f"{ind}Source: {proto['source']} ({proto['line_defined']}-{proto['last_line_defined']})")
    print(f"{ind}Params: {proto['num_params']}, Stack: {proto['max_stack_size']}, Upvalues: {proto['num_upvalues']}")
    
    print(f"{ind}Constants:")
    for i, c in enumerate(proto['constants']):
        print(f"{ind}  K[{i}] = {repr(c)}")
        
    print(f"{ind}Instructions:")
    for idx, inst in enumerate(proto['instructions']):
        op, a, b, c, bx, sbx = decode_instruction(inst)
        op_name = OPCODES[op] if op < len(OPCODES) else f"UNKNOWN_{op}"
        
        # Format operands
        if op_name in ("MOVE", "LOADBOOL", "LOADNIL", "GETUPVAL", "SETUPVAL", "UNM", "NOT", "LEN", "RETURN", "VARARG"):
            # A B
            args = f"r{a} r{b}" if op_name not in ("LOADBOOL", "LOADNIL", "RETURN") else f"r{a} {b} {c}"
        elif op_name == "LOADK":
            args = f"r{a} K[{bx}]"
        elif op_name in ("GETGLOBAL", "SETGLOBAL"):
            args = f"r{a} K[{bx}]"
        elif op_name in ("GETTABLE", "SETTABLE", "ADD", "SUB", "MUL", "DIV", "MOD", "POW", "EQ", "LT", "LE"):
            # B and C can be constants if >= 256
            b_val = f"K[{b-256}]" if b >= 256 else f"r{b}"
            c_val = f"K[{c-256}]" if c >= 256 else f"r{c}"
            args = f"r{a} {b_val} {c_val}"
        elif op_name == "SELF":
            c_val = f"K[{c-256}]" if c >= 256 else f"r{c}"
            args = f"r{a} r{b} {c_val}"
        elif op_name in ("JMP", "FORLOOP", "FORPREP"):
            args = f"r{a} to {idx + 1 + sbx}"
        elif op_name in ("CALL", "TAILCALL"):
            args = f"r{a} {b-1} {c-1}"
        else:
            args = f"r{a} {b} {c}"
            
        print(f"{ind}  {idx:03d}: {op_name:<10} {args}")
        
    for i, p in enumerate(proto['prototypes']):
        print(f"\n{ind}Prototype {i}:")
        print_function(p, indent + 1)

def main():
    filename = sys.argv[1] if len(sys.argv) > 1 else 'out/textwidget_new.bc'
    with open(filename, 'rb') as f:
        endian, size_int, size_size_t, size_instruction, size_number = parse_header(f)
        proto = parse_function(f, endian, size_int, size_size_t, size_instruction, size_number)
        print_function(proto)

if __name__ == '__main__':
    main()
