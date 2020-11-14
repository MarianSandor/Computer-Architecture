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
	Write_Address_In: in std_logic_vector(2 downto 0);
	Write_Data: in std_logic_vector(15 downto 0);
	RegWrite: in std_logic;
	RegDst: in std_logic;
	ExtOp: in std_logic;
	RS: out std_logic_vector(15 downto 0);
	RT: out std_logic_vector(15 downto 0);
	Ext_Imm: out std_logic_vector(15 downto 0);
	Func: out std_logic_vector(2 downto 0);	   
	Write_Address_Out: out std_logic_vector(2 downto 0);
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
--input: Instr, WriteData, Write_Address_In
--output: RS, RT, Ext_Imm, Func, Write_Address_Out, SA


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
signal Write_Address_Out: std_logic_vector(2 downto 0);

--Instruction
signal Instr, PC: std_logic_vector(15 downto 0);	

--MEM
signal ALURes_Out, MemData: std_logic_vector(15 downto 0); 		 

--Pipeline Registers
signal IF_ID: std_logic_vector(31 downto 0) := (others => '0');	
signal ID_EX: std_logic_vector(78 downto 0) := (others => '0');	 
signal EX_MEM: std_logic_vector(55 downto 0) := (others => '0');
signal MEM_WB: std_logic_vector(36 downto 0) := (others => '0');

signal Disp: std_logic_vector(15 downto 0); 
signal ButD: std_logic;	 

begin
	L1: Debouncer port map(CLK,But,ButD);
 	L2: Display port map(CLK,Disp,seg,an);	 
	
	L3: Instr_F port map(ButD, RST, EX_MEM(51 downto 36), Jmp_Addr, Jump, PCSrc, PC, Instr);	  
	L4:	ID port map(ButD, IF_ID(15 downto 0), MEM_WB(2 downto 0), WriteData, MEM_WB(35), RegDst, ExtOp, RD1, RD2, Ext_Imm, Func, Write_Address_Out, SA);
	L5: CU port map(IF_ID(15 downto 13), ExtOp, Jump, Branch, MemToReg, MemWrite, ALUSrc, ALUOp ,RegWrite, RegDst);  
	L6:	EX port map(ID_EX(69 downto 54), ID_EX(53 downto 38), ID_EX(37 downto 22), ID_EX(21 downto 6), ID_EX(5 downto 3), ID_EX(78), ID_EX(70), ID_EX(73 downto 71), Branch_Addr, ALURes, Zero);
	L7: MEM port map(ButD, EX_MEM(34 downto 19), EX_MEM(18 downto 3), EX_MEM(53), MemData, ALURes_Out); 				 
	
	process(MEM_WB(36))
	begin
		if MEM_WB(36) = '1' then	 
			WriteData <= MEM_WB(34 downto 19);  --MemData
		else 
			WriteData <= MEM_WB(18 downto 3);  --ALURes
		end if;
	end process;	   
	
	PCSrc <= EX_MEM(52) AND EX_MEM(35);  
	
	Jmp_Addr <= IF_ID(31 downto 29) & IF_ID(12 downto 0);	 
	
	process(ButD)
	begin
		if ButD = '1' and ButD'event then
		  MEM_WB(36 downto 35) <= EX_MEM(55 downto 54);
		  MEM_WB(34 downto 19) <= MemData;
		  MEM_WB(18 downto 3) <= EX_MEM(34 downto 19);
		  MEM_WB(2 downto 0) <= EX_MEM(2 downto 0);
		end if;
	end process;
	
	process(ButD) 
	begin		
		if ButD = '1' and ButD'event then
		  EX_MEM(55 downto 54) <= ID_EX(77 downto 76);
		  EX_MEM(53 downto 52) <= ID_EX(75 downto 74);
		  EX_MEM(51 downto 36) <= Branch_Addr;
		  EX_MEM(35) <= Zero;
		  EX_MEM(34 downto 19) <= ALURes;
		  EX_MEM(18 downto 3) <= ID_EX(37 downto 22);
		  EX_MEM(2 downto 0) <= ID_EX(2 downto 0);
		end if;
	end process;
	
	process(ButD)
	begin	
		if ButD = '1' and ButD'event then
		  ID_EX(78) <= SA;
		  ID_EX(77 downto 76) <= MemToReg & RegWrite;
		  ID_EX(75 downto 74) <= MemWrite & Branch;    
		  ID_EX(73 downto 70) <= ALUOp & ALUSrc;
		  ID_EX(69 downto 54) <= IF_ID(31 downto 16);
		  ID_EX(53 downto 38) <= RD1;
		  ID_EX(37 downto 22) <= RD2;
		  ID_EX(21 downto 6) <= Ext_Imm;	
		  ID_EX(5 downto 3) <= Func;
		  ID_EX(2 downto 0) <= Write_Address_Out;	
		end if;
	end process;
	
	process(ButD)
	begin		
		if ButD = '1' and ButD'event then
		  IF_ID(31 downto 16) <= PC;
		  IF_ID(15 downto 0) <= Instr;
		end if;
	end process;
	
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