library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;	

entity Debouncer is 
	port(CLK: in std_logic;	  
	ButIN: in std_logic;
	ButOUT: out std_logic);
end Debouncer;

architecture Arch_Debouncer of Debouncer is	

signal delay1,delay2,delay3: std_logic := '0';	
signal TC: std_logic;		  

begin			   	
	process(CLK)
	variable count: std_logic_vector(21 downto 0) := (others => '0');
	begin 
		if CLK = '1' and CLK'EVENT then 
			count := count + 1;
		end if;
		
		if count = (count'range => '1') then
			TC <= '1';
		else 
			TC <= '0';
		end if;
	end process;
	
	process(CLK,ButIN) 
	begin 	  		
		if TC = '1' then 
			if CLK = '1' and CLK'EVENT then
				delay1 <= ButIN;
			end if;	  
		end if;	   			   
	end process;			   
	
	process(CLK) 
	begin 	  		
		if CLK = '1' and CLK'EVENT then
			delay2 <= delay1;
		end if;	    			   
	end process;  
	
	process(CLK) 
	begin 	  		
		if CLK = '1' and CLK'EVENT then
			delay3 <= delay2;
		end if;	    			   
	end process;

	ButOUT <= delay2 AND (NOT delay3);
	
end Arch_Debouncer;
