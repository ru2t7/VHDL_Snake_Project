----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2023 03:04:30 PM
-- Design Name: 
-- Module Name: SSD - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SSD is
    Port ( CLK : in STD_LOGIC;
           score : in STD_LOGIC_VECTOR (7 downto 0);
           AN : out STD_LOGIC_VECTOR (1 downto 0);
           CAT : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is
signal count:std_logic_vector(15 downto 0);
signal input_decoder:std_logic_vector(3 downto 0);
begin

-- COUNTER
process(clk,count)
begin

if (clk='1' and clk'event) then  -- IF RISING_EDGE(CLK)
        count<=count +1;
end if;


end process;

--ANODES
process(count)
begin
case count(15) is
when '0'=>an<="10";
when others=>an<="01";

end case;
end process;

--for digits
process(count,score)
begin
case count(15) is
when '0'=>input_decoder<=score(3 downto 0);
when others=>input_decoder<=score(7 downto 4);


end case;
end process;

process(input_decoder)
begin
	 case input_decoder is
		when "0000" => cat<="0000001";
		when "0001" => cat<="1001111";
		when "0010" => cat<="0010010";
		when "0011" => cat<="0000110";

		when "0100" => cat<="1001100";
		when "0101" => cat<="0100100";
		when "0110" => cat<="0100000";
		when "0111" => cat<="0001111";

		when "1000" => cat<="0000000";
		when "1001" => cat<="0000100";
		when "1010" => cat<="0001000";
		when "1011" => cat<="1100000";

		when "1100" => cat<="0110001";
		when "1101" => cat<="1000010";
		when "1110" => cat<="0110000";
		when others => cat<="0111000";
	end case;


end process;



end Behavioral;