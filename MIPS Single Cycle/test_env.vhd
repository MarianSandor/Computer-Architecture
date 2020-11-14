library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test is
	port(CLK: in std_logic;
	But: in std_logic;
	RST: in std_logic;
	Disp_Ctrl: in std_logic_vector(2 downto 0);	
	Ctrl: in std_logic;
	led: out std_logic_vector(7 downto 0);
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0));
end test;

architecture Arch_test of test is

component Display is
	port(CLK: in std_logic;
	Data: in std_logic_vector(15 downto 0);	 
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0));
end component;

component Debouncer is 
	port(CLK: in std_logic;	  
	ButIN: in std_logic;
	ButOUT: out std_logic);
end component;

component Instr_F is
	port(CLK: in std_logic;	   
	RST: in std_logic;
	Branch_Addr: in std_logic_vector(15 downto 0);
	Jmp_Addr: in std_logic_vector(15 downto 0);
	Jmp_Ctrl: in std_logic;
	PCSrc_Ctrl: in std_logic;		  
	PC_Out: out std_logic_vector(15 downto 0);
	Instr: out std_logic_vector(15 downto 0));
end component;	 

component ID is
	port(CLK: in std_logic;
	Instr: in std_logic_vector(15 downto 0);
	Write_Data: in std_logic_vector(15 downto 0);
	RegWrite: in std_logic;
	RegDst: in std_logic;
	ExtOp: in std_logic;
	RS: out std_logic_vector(15 downto 0);
	RT: out std_logic_vector(15 downto 0);
	Ext_Imm: out std_logic_vector(15 downto 0);
	Func: out std_logic_vector(2 downto 0);
	SA: out std_logic);
end component;

component CU is
	port(Instr: in std_logic_vector(2 downto 0);
	ExtCtrl: out std_logic;
	Jump: out std_logic;
	Branch: out std_logic;
	MemToReg: out std_logic;
	MemWrite: out std_logic;
	ALUSrc: out std_logic;
	ALUOp: out std_logic_vector(2 downto 0);
	RegWrite: out std_logic;
	RegDst: out std_logic);
end component; 

component EX is 
	port(PC: in std_logic_vector(15 downto 0);
	RD1: in std_logic_vector(15 downto 0);
	RD2: in std_logic_vector(15 downto 0);
	Ext_Imm: in std_logic_vector(15 downto 0);
	Func: in std_logic_vector(2 downto 0);
	SA: in std_logic;
	ALUSrc: in std_logic;
	ALUOp: in std_logic_vector(2 downto 0);
	Branch_Addr: out std_logic_vector(15 downto 0);
	ALURes: out std_logic_vector(15 downto 0);
	Zero: out std_logic);
end component;

component MEM is 
	port(CLK: in std_logic;
	ALURes: in std_logic_vector(15 downto 0);
	RD2: in std_logic_vector(15 downto 0);
	MemWrite: in std_logic;		
	Data: out std_logic_vector(15 downto 0);
	ALUResOut: out std_logic_vector(15 downto 0));
end component;	 

--Instruction Fetch signals	   
---------------------------------
--control: Jump, PCSrc 
--input: Jump_Addr, Branch_Addr	
--output: PC, Instr	  


--Instruction Decode signal
---------------------------------	 
--control: RegWrite, RegDst, ExtOp
--input: Instr, WriteData
--output: RS, RT, Ext_Imm, Func, SA


--Execution Unit
---------------------------------
--control: ALUSrc, ALUOp
--intput: PC, RD1, RD2, Ext_Imm, SA, Func 
--output: Branch_Address, ALURes_Out, Zero	   


--Memory
---------------------------------
--control: MemWrite
--input: ALURes_Out, RT
--output: MemData, ALURes


--Control Unit
---------------------------------
--input: Instr[15 downto 13]
--output: RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemToReg, RegWrite



--Singals
-----------------
--Control 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemToReg, RegWrite: std_logic;   
signal PCSrc: std_logic; 

--ALU Control
signal ALUOp: std_logic_vector(2 downto 0);
signal Func: std_logic_vector(2 downto 0);

--Register
signal RD1, RD2, WriteData: std_logic_vector(15 downto 0);  
signal Ext_Imm: std_logic_vector(15 downto 0);  

--ALU
signal ALURes: std_logic_vector(15 downto 0);
signal Zero, SA: std_logic;		

--Address
signal Branch_Addr, Jmp_Addr: std_logic_vector(15 downto 0);   

--Instruction
signal Instr, PC: std_logic_vector(15 downto 0);	

--MEM
signal ALURes_Out, MemData: std_logic_vector(15 downto 0); 

signal Disp: std_logic_vector(15 downto 0); 
signal ButD: std_logic;	 

begin
	L1: Debouncer port map(CLK,But,ButD);
 	L2: Display port map(CLK,Disp,seg,an);	 
	
	L3: Instr_F port map(ButD, RST, Branch_Addr, Jmp_Addr, Jump, PCSrc, PC, Instr);	  
	L4:	ID port map(ButD, Instr, WriteData, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_Imm, Func, SA);
	L5: CU port map(Instr(15 downto 13), ExtOp, Jump, Branch, MemToReg, MemWrite, ALUSrc, ALUOp ,RegWrite, RegDst);  
	L6:	EX port map(PC, RD1, RD2, Ext_Imm, Func, SA, ALUSrc, ALUOp, Branch_Addr, ALURes, Zero);
	L7: MEM port map(ButD, ALURes, RD2, MemWrite, MemData, ALURes_Out); 				 
	
	process(MemToReg)
	begin
		if MemToReg = '1' then	 
			WriteData <= MemData;
		else 
			WriteData <= ALURes_Out;
		end if;
	end process;	   
	
	PCSrc <= Branch AND Zero;  
	
	Jmp_Addr <= PC(15 downto 13) & Instr(12 downto 0);
	
	process(Disp_Ctrl)
	begin
		case Disp_Ctrl is
			when "000" => Disp <= Instr;
			when "001" => Disp <= PC;
			when "010" => Disp <= RD1;
			when "011" => Disp <= RD2;
			when "100" => Disp <= Ext_Imm;	 
			when "101" => Disp <= ALURes;
			when "110" => Disp <= MemData;
			when "111" => Disp <= WriteData;
			when others => NULL;
		end case;	  
	end process;  
	
	process(Ctrl)
	begin 
		if Ctrl = '1' then 
			led <= ExtOp & Jump & Branch & MemToReg & MemWrite & ALUSrc & RegWrite & RegDst;
		else
			led <= "00000" & ALUOp;	
		end if;
	end process;
	
end Arch_test;