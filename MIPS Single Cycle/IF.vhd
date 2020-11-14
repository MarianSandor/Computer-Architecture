library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Instr_F is
	port(CLK: in std_logic;
	RST: in std_logic;
	Branch_Addr: in std_logic_vector(15 downto 0);
	Jmp_Addr: in std_logic_vector(15 downto 0);
	Jmp_Ctrl: in std_logic;
	PCSrc_Ctrl: in std_logic;	
	PC_Out: out std_logic_vector(15 downto 0);
	Instr: out std_logic_vector(15 downto 0));
end Instr_F;

architecture Arch_Instr_F of Instr_F is

type mem is array(0 to 255) of std_logic_vector(15 downto 0);   
signal ROM: mem := (B"001_000_100_0000101", B"001_000_001_0000001", B"000_000_001_010_0_000", B"000_000_001_011_0_000", B"101_100_101_0000011",
					B"100_101_000_0000001", B"111_0000000001111", B"000_100_001_100_0_001", B"000_100_001_100_0_001", B"000_010_011_101_0_000", 
					B"000_000_011_010_0_000", B"000_000_101_011_0_000", B"000_100_001_100_0_001", B"100_100_000_0000001", B"111_0000000001001",
					B"011_000_011_0000111", others => B"0000_0000_0000_0000");		

signal PC: std_logic_vector(15 downto 0) := (others=>'0');

begin
	
	process(CLK, PCSrc_Ctrl, Jmp_Ctrl, Jmp_Addr, Branch_Addr, PC)
	begin
		if RST = '1' then
			PC <= (others => '0');
		elsif CLK = '1' and CLK'event then
			if Jmp_Ctrl = '1' then 	
				PC <= Jmp_Addr; 
			else
				if PCSrc_Ctrl = '1' then 
					PC <= Branch_Addr;
				else 
					PC <= PC + 1;
				end if;
			end if;
		end if;
	end process;  
	
	Instr <= ROM(conv_integer(PC(7 downto 0)));
	PC_Out <= PC + 1;
	
end Arch_Instr_F;


	
	