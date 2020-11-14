library	 IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  

entity CU is
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
end CU;	   

architecture Arch_CU of CU is

begin
	
	process(Instr) 
	begin
		case(Instr) is
			when "000" => ExtCtrl<='0'; Jump<='0'; Branch<='0'; MemToReg<='0'; MemWrite<='0'; ALUSrc<='0'; ALUOp<="000"; RegWrite<='1'; RegDst<='1';	  
			when "001" => ExtCtrl<='1'; Jump<='0'; Branch<='0'; MemToReg<='0'; MemWrite<='0'; ALUSrc<='1'; ALUOp<="010"; RegWrite<='1'; RegDst<='0';
			when "010" => ExtCtrl<='1'; Jump<='0'; Branch<='0'; MemToReg<='1'; MemWrite<='0'; ALUSrc<='1'; ALUOp<="010"; RegWrite<='1'; RegDst<='0';
			when "011" => ExtCtrl<='1'; Jump<='0'; Branch<='0'; MemToReg<='0'; MemWrite<='1'; ALUSrc<='1'; ALUOp<="010"; RegWrite<='0'; RegDst<='0';
			when "100" => ExtCtrl<='1'; Jump<='0'; Branch<='1'; MemToReg<='0'; MemWrite<='0'; ALUSrc<='0'; ALUOp<="100"; RegWrite<='0'; RegDst<='0';	
			when "101" => ExtCtrl<='1'; Jump<='0'; Branch<='0'; MemToReg<='0'; MemWrite<='0'; ALUSrc<='1'; ALUOp<="001"; RegWrite<='1'; RegDst<='0'; 
			when "110" => ExtCtrl<='0'; Jump<='0'; Branch<='0'; MemToReg<='0'; MemWrite<='0'; ALUSrc<='1'; ALUOp<="110"; RegWrite<='1'; RegDst<='0';
			when "111" => ExtCtrl<='0'; Jump<='1'; Branch<='0'; MemToReg<='0'; MemWrite<='0'; ALUSrc<='0'; ALUOp<="000"; RegWrite<='0'; RegDst<='0';
			when others => NULL;
		end case;
	end process;
	
end Arch_CU;