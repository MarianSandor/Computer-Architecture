library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX is 
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
end EX;

architecture Arch_EX of EX is 

signal A, B: std_logic_vector(15 downto 0);
signal ALUCtrl: std_logic_vector(3 downto 0);
signal Result: std_logic_vector(15 downto 0);

begin 
	
	process(A, B, ALUCtrl)
	begin 
		case ALUCtrl is
			when "0000" => Result <= A + B;
			when "0001" => Result <= A - B;
			when "0010" => if SA = '0' then 
							  Result <= A;
						   else 
							  Result <= A(14 downto 0) & '0';	 
						   end if;	 
			when "0011" => if SA = '0' then 
							  Result <= A;
						   else 
							  Result <= '0' & A(15 downto 1);	 
						   end if;
			when "0100" => Result <= A AND B;
			when "0101" => Result <= A OR B;
			when "0110" => if SA = '0' then 
							  Result <= A;
						   else 
							  Result <= A(15) & A(15 downto 1);	  
						   end if;
			when "0111" => Result <= A XOR B; 
			when "1000" => if A < B then 
							   Result <= B"0000_0000_0000_0001";
						   else 
							   Result <= B"0000_0000_0000_0000";
						   end if;	
			when "1010" => Result <= Ext_Imm(15 downto 8) & Ext_Imm(7 downto 0); 
			when others => NULL;
		end case;
	end process;
	
	process(ALUOp)
	begin 
		case ALUOp is
			when "000" => ALUCtrl <= '0' & Func;
			when "010" => ALUCtrl <= "0000";
			when "100" => ALUCtrl <= "0001";
			when "110" => ALUCtrl <= "1010";
			when "001" => ALUCtrl <= "1000";
			when others => NULL;
		end case;
	end process;
	
	process(ALUSrc)
	begin 
		if ALUSrc = '1' then 
			B <= Ext_Imm;
		else 
			B <= RD2;
		end if;
	end process;
	
	process(Result)
	begin
		if Result = B"0000_0000_0000_0000" then
			Zero <= '1';
		else 
			Zero <= '0';
		end if;
	end process;  
	
	A <= RD1;
	Branch_Addr <= PC + Ext_Imm;  
	ALURes <= Result;

end Arch_Ex;