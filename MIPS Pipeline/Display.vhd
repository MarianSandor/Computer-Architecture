library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;	

entity Display is
	port(CLK: in std_logic;
	Data: in std_logic_vector(15 downto 0);	 
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0));
end Display;

architecture Arch_Display of Display is	

signal Digit4: std_logic_vector(3 downto 0) := Data(15 downto 12);
signal Digit3: std_logic_vector(3 downto 0) := Data(11 downto 8); 
signal Digit2: std_logic_vector(3 downto 0) := Data(7 downto 4);
signal Digit1: std_logic_vector(3 downto 0) := Data(3 downto 0);	 	 
signal Digit: std_logic_vector(3 downto 0);
signal SEL: std_logic_vector(1 downto 0);	 

begin
	
	process(CLK) 
	variable count: std_logic_vector(20 downto 0) := (others => '0');
	begin
		if CLK = '1' and CLK'EVENT then
			count := count + 1;
		end if;

		SEL <= count(20 downto 19);
	end process;
	
	process(SEL)
	begin 
		case SEL is
			when "00" => an <= "0111"; Digit <= Digit4;
			when "01" => an <= "1011"; Digit <= Digit3;
			when "10" => an <= "1101"; Digit <= Digit2;
			when "11" => an <= "1110"; Digit <= Digit1;
			when others => an <= "1111";
		end case;
	end process;  
	
	process(Digit)
	begin
		case Digit is
			when "0001" => seg <= "1111001";   --1
         	when "0010" => seg <= "0100100";   --2
         	when "0011"	=> seg <= "0110000";   --3
            when "0100" => seg <= "0011001";   --4
		    when "0101" => seg <= "0010010";   --5
		    when "0110" => seg <= "0000010";   --6
		    when "0111" => seg <= "1111000";   --7
		    when "1000" => seg <= "0000000";   --8
		    when "1001" => seg <= "0010000";   --9
		    when "1010" => seg <= "0001000";   --A
		    when "1011" => seg <= "0000011";   --b
		    when "1100" => seg <= "1000110";   --C
		    when "1101" => seg <= "0100001";   --d
		    when "1110" => seg <= "0000110";   --E
		    when "1111" => seg <= "0001110";   --F
		    when others => seg <= "1000000";   --0	
		end case;
	end process;
	
end Arch_Display;
	
	