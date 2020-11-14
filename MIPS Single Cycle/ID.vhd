library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;   

entity ID is
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
end ID;

architecture Arch_ID of ID is

type mem is array(0 to 7) of std_logic_vector(15 downto 0);
signal reg_file: mem := ("0000000000000000", "0000000000000001", "0000000000000111", "0000000000001111", "0000000000011111",
							"0000000000111111", "0000000001111111", "0000000011111111"); 

signal RS_Address: std_logic_vector(2 downto 0);			
signal RT_Address: std_logic_vector(2 downto 0);
signal RD_Address: std_logic_vector(2 downto 0);	

signal Write_Address: std_logic_vector(2 downto 0);	

signal Imm: std_logic_vector(6 downto 0);

begin 	
	
	RS_Address <= Instr(12 downto 10);	
	RT_Address <= Instr(9 downto 7); 
	RD_Address <= Instr(6 downto 4);	
	Imm <= Instr(6 downto 0);
	
	process(RegDst)
	begin
		if RegDst = '1' then
			Write_Address <= RD_Address;
		else
			Write_Address <= RT_Address;
		end if;
	end process;
	
	process(CLK,RegWrite,RS_Address,RT_Address)
	begin
		if CLK = '1' and CLK'event then
			if RegWrite = '1' then
				reg_file(conv_integer(Write_Address)) <= Write_Data;
			end if;
		end if;
		
		RS <= reg_file(conv_integer(RS_Address));
		RT <= reg_file(conv_integer(RT_Address));
	end process;   
	
	process(ExtOp,Imm)
	begin		
		if ExtOp = '1' then
			Ext_Imm <= Imm(6)&Imm(6)&Imm(6)&Imm(6)&Imm(6)&Imm(6)&Imm(6)&Imm(6)&Imm(6)&Imm;
		else  
			Ext_Imm <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&Imm;
		end if;
	end process;  
	
	SA <= Instr(3);
	
	Func <= Instr(2 downto 0);

end Arch_ID;