library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is 
	port(CLK: in std_logic;
	ALURes: in std_logic_vector(15 downto 0);
	RD2: in std_logic_vector(15 downto 0);
	MemWrite: in std_logic;		
	Data: out std_logic_vector(15 downto 0);
	ALUResOut: out std_logic_vector(15 downto 0));
end MEM;

architecture Arch_MEM of MEM is 

type mem is array(0 to 255) of std_logic_vector(15 downto 0);
signal ram_mem: mem := (others=>B"0000_0000_0000_0000");		
						
begin 	 
	
	process(CLK,MemWrite,ALURes,RD2)
	begin
		if CLK = '1' and CLK'event then	
			if MemWrite = '1' then
				ram_mem(conv_integer(ALURes(7 downto 0))) <= RD2;
			end if;
		end if;	 
		
		Data <= ram_mem(conv_integer(ALURes(7 downto 0)));
	end process;	
	
	ALUResOut <= ALURes;

end Arch_MEM;