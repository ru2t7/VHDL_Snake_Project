--SNAK--
------------------------------------------------------------------------------------
-- Created by Ruth and Oana with <3
-- Create Date: 04/10/2023 02:59:35 PM
-----------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
--------------------------------------------------entity
entity display is

port ( clk : in std_logic;
       reset: in  std_logic;
       reset_game: in std_logic;
       UP, DOWN, LEFT, RIGHT: in std_logic;
       HSYNC: out std_logic;
       VSYNC: out std_logic;
       R: out std_logic_vector(3 downto 0);
       G: out std_logic_vector(3 downto 0);
       B: out std_logic_vector(3 downto 0);
       anod: out std_logic_vector(1 downto 0);
       catod: out std_logic_vector(6 downto 0) );
end display;
---------------------------------------------------architecutre
architecture Behavioral of display is

--------------------------------------------------- display constants horizontal
constant hD:integer :=640;
constant hFP:integer :=16;
constant hSP:integer :=96;
constant hBP:integer :=48;
constant hWL:integer :=800;
--------------------------------------------------- display constants veritcal
constant vD:integer :=480;
constant vFP:integer :=10;
constant vSP:integer :=2;
constant vBP:integer :=33;
constant vWL:integer :=525;
--------------------------------------------------- cnt is used for the frequency of movement of the snake
--------------------------------------------------- it is set at the beggining at abt per 1 sec
constant power: integer:=22;
signal cnt: std_logic_vector(power downto 0):="00000000000000000000000";
---------------------------------------------------- a is used for increasing the frequency
signal a:integer:=1;
---------------------------------------------------- div_clk2 is the frequency of the display
signal div_clk1: std_logic:='0';
signal div_clk2: std_logic:='0';
----------------------------------------------------- positions used for display
signal hpos: integer:=0;
signal vpos: integer:=0;
--------------------------------------------------- signal for checking if in valid area
signal desen: std_logic;
---------------------------------------------------- maximum lenght of snake
constant lmax: integer:=15;
type snake is array (0 to 15) of integer;
---------------------------------------------------- the snake, initially it is lenght 2, all the additional
---------------------------------------------------- leght is all in one square
signal x: snake :=(320, 300, 280, 280, 280, 280,280, 280, 280, 280,280, 280, 280, 280,280, 280);
signal y: snake := (240 ,240,240, 240, 240, 240,240 ,240,240, 240, 240, 240,240,240,240,240);
--------------------------------------------------- food coordinates
signal xf: integer:=100;
signal yf: integer:=100;
--------------------------------------------------- eyes coordinates
signal xe1: integer:=335;
signal ye1: integer:=240;

signal xe2: integer:= 335;
signal ye2: integer:= 255;
----------------------------------------------------lenght of snake
signal l:integer:=2;
----------------------------------------------------score in bcd
signal score: std_logic_vector(7 downto 0);
---------------------------------------------------- direction states
signal direction:std_logic_vector(3 downto 0);
type state_type is(O,SU,SD,SL,SR);
signal state: state_type:=O;
----------------------------------------------------- end of game

signal eof: std_logic:='0';
------------------------------------------------------ debounced buttons
signal sUP, sDOWN, sLEFT, sRIGHT: std_logic;
----------------------------------------------------- ssd
component SSD is
    Port ( CLK : in STD_LOGIC;
           score : in STD_LOGIC_VECTOR (7 downto 0);
           AN : out STD_LOGIC_VECTOR (1 downto 0);
           CAT : out STD_LOGIC_VECTOR (6 downto 0));
end component SSD;
-------------------------------------------------------- debouncer
component debouncer is
    Port ( btn : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           enable : out  STD_LOGIC);
end component debouncer;
----------------------------------------------------------- BEGIN

begin
---------------------------------------------------------- debounce clocks
l7: debouncer port map (btn=> UP, clk=>clk, enable=>sUP );
l8: debouncer port map (btn=> DOWN, clk=>clk, enable=>sDOWN );
l9: debouncer port map (btn=> LEFT, clk=>clk, enable=>sLEFT );
l10: debouncer port map (btn=> RIGHT, clk=>clk, enable=>sRIGHT );
--------------------------------------------------------- convert lenght to score in bcd
score<=std_logic_vector(to_unsigned(l-2,8));
l6: SSD port map(clk=>clk, score=>score, AN=>anod, CAT=>catod);
-------------------------------------------------------- first clk div
process (clk, reset)
begin
if (reset='1') then 
div_clk1 <= '0';
elsif(rising_edge(clk)) then
div_clk1<=not (div_clk1);
end if;
end process ;
--------------------------------------------------------- second clk div
process (div_clk1, reset)
begin
if (reset='1') then 
div_clk2 <= '0';
elsif(rising_edge(div_clk1)) then
div_clk2 <=not (div_clk2);
end if;
end process;
---------------------------------------------------------- hpos counter
process (div_clk2, reset, hpos)---hpos?
begin
if (reset='1') then
hpos<=0;
elsif(rising_edge(div_clk2))then
if(hpos=(hD+hFP+hSP+hBP-1))then --- 799 sau 800?
hpos<=0;
else
hpos<=hpos+1;
end if;
end if;
end process;
---------------------------------------------------------- vpos counter
process (div_clk2, reset, vpos)---vpos???
begin
if (reset='1') then
vpos<=0;
elsif(rising_edge(div_clk2))then
if(hpos=(hD+hFP+hSP+hBP-1))then --- 799 sau 800?
if(vpos=(vD+vFP+vSP+vBP-1))then   --- 799 sau 800?
vpos<=0;
else
vpos<=vpos+1;
end if;
end if;
end if;
end process;
--------------------------------------------------------- HSYNC clk
process(div_clk2, reset, hpos) ---hSYNC???
begin
if(reset='1') then
HSYNC<='0';
elsif(rising_edge(div_clk2)) then
if(hpos<=(hD+hFP-1) or hpos>=(hD+hFP+hSP-1))then ---=?
HSYNC<='1';
else
HSYNC<='0';
end if;
end if;
end process;
---------------------------------------------------------- VSYNC clk
process(div_clk2, reset, vpos) ---hSYNC???
begin
if(reset='1') then
VSYNC<='0';
elsif(rising_edge(div_clk2)) then
if(vpos<=(vD+vFP-1) or vpos>=(vD+vFP+vSP-1))then
VSYNC<='1';
else
VSYNC<='0';
end if;
end if;
end process;
------------------------------------------------------------ verificam daca suntem in aria de desen 
process(div_clk2, hpos, vpos)
begin
if(rising_edge(div_clk2))then
if(hpos<=(hD-1) and vpos<=(vD-1))then
desen<='1';
else
desen<='0';
end if;
end if;
end process; 
-------------------------------------------------------------- snak
-------------------------------------------------------------- direction, basically we put the input as selects in mux
direction(0)<=sUP; 
direction(1)<=sDOWN; 
direction(2)<=sLEFT;
direction(3)<=sRIGHT;
------------------------------------------------------------- decides next state based on inputs
process(direction,state,eof,reset_game) ---state?
begin
if reset_game='1'then
state<=O;
else
if eof='1' then state<=O;
elsif rising_edge(clk) then      ---- modificat aici in loc de clk cnt ( power )
case direction is
when "0001" => 
if state/=SD then
state<=SU;
else
state<=state;
end if;
when "0010" => 
if state/=SU then
state<=SD;
else
state<=state;
end if;
when "1000" => 
if state/=SL then
state<=SR;
else
state<=state;
end if;
when "0100" =>
if state/=SR and state/=O then
state<=SL;
else
state<=state;
end if;
when others => state<=state;
end case;
end if;
end if;
end process;
------------------------------------------------cnt for moving frequency
process(div_clk2)
begin
if(rising_edge(div_clk2))then
cnt<=cnt+a;
end if;
end process;
------------------------------------------------ eyes
process( x(0), y(0), state, reset_game)
begin
if(reset_game='1') then
xe1<=335;
ye1<=240;
xe2<= 335;
ye2<= 255;
else
case state is
when SL => 
xe1<=x(0);
ye1<=y(0);
xe2<=x(0);
ye2<=y(0)+15;
when SR =>
xe1<=x(0)+15;
ye1<=y(0);
xe2<=x(0)+15;
ye2<=y(0)+15;
when SU =>
xe1<=x(0);
ye1<=y(0);
xe2<=x(0)+15;
ye2<=y(0);
when SD =>
xe1<=x(0);
ye1<=y(0)+15;
xe2<=x(0)+15;
ye2<=y(0)+15;
when O=>
xe1<=xe1;
ye1<=ye1;
xe2<=xe2;
ye2<=ye2;
end case;
end if;
end process;
------------------------------------------------ snak moving
process(x(0),y(0),state,cnt,xf,yf,l,reset_game)

begin
if(reset_game='1')then
----------------------------------------------------snak coordinates
x<=(320, 300, 280, 280, 280, 280,280, 280, 280, 280,280, 280, 280, 280,280, 280);
y<= (240 ,240,240, 240, 240, 240,240 ,240,240, 240, 240, 240,240,240,240,240);
--------------------------------------------------- food coordinates
xf<=100;
yf<=100;
----------------------------------------------------lenght of snake
a<=1;
l<=2;
eof<='0';
else
if(rising_edge(cnt(power)))then
case state is
----------------------------------------------state right
when SR =>
----------------------------------------------checks if food
if((x(0)+20=xf or (x(0)+20>(hD-1) and xf=0)) and y(0)=yf) then
l<=l+1;
xf<=( (x(1)+x(3)+y(5)+7 )mod 32)*20;
yf<=( (y(7)+x(4)+x(0)+3 )mod 24)*20;
if((l mod 5)=0)then
a<=a+1;
end if;
end if;
----------------------------------------------checks if itself
l6: for i in lmax downto 1 loop
if(x(0)+20=x(i) and y(0)=y(i))then
eof<='1';
end if;
end loop l6;
-------------------------------------------- body moves
l1:for i in lmax downto 1 loop
if(i>=l) then
x(i)<=x(l-1);
y(i)<=y(l-1);
else
x(i)<=x(i-1);
y(i)<=y(i-1);
end if;
end loop l1;
------------------------------------------- head moves
if((x(0)+20)<=(hD-1)) then
x(0)<=x(0)+20;
else
x(0)<=0;
end if;
-------------------------------------------- state left
when SL =>
-------------------------------------------- checks if food
if((x(0)-20=xf or(x(0)-20<0 and xf=hD-20)) and y(0)=yf)then
xf<=( (x(1)+x(3)+y(5)+15 )mod 32)*20;
yf<=( (y(7)+x(4)+x(0)+9 )mod 24)*20;
l<=l+1;
if((l mod 5)=0)then
a<=a+1;
end if;
end if;
----------------------------------------------checks if itself
l7: for i in lmax downto 1 loop
if(x(0)-20=x(i) and y(0)=y(i))then
eof<='1';
end if;
end loop l7;
--------------------------------------------- body moves
l2:for i in lmax downto 1 loop
if(i>=l) then
x(i)<=x(l-1);
y(i)<=y(l-1);
else
x(i)<=x(i-1);
y(i)<=y(i-1);
end if;
end loop l2;
--------------------------------------------- head moves
if((x(0)-20)>=0) then
x(0)<=x(0)-20;
else
x(0)<=(hD-20);
end if;
--------------------------------------- state UP
when SU=>
--------------------------------------- checks if food
if(x(0)=xf and (y(0)-20=yf or (y(0)-20<0 and yf=vD-20)))then
xf<=( (x(1)+x(3)+y(5)+17 )mod 32)*20;
yf<=( (y(7)+x(4)+x(0)+23 )mod 24)*20;
l<=l+1;
if((l mod 5)=0)then
a<=a+1;
end if;
end if;
----------------------------------------------checks if itself
l8: for i in lmax downto 1 loop
if( x(0)=x(i) and y(0)-20=y(i))then
eof<='1';
end if;
end loop l8;
----------------------------------------- body moves
l3:for i in lmax downto 1 loop
if(i>=l) then
x(i)<=x(l-1);
y(i)<=y(l-1);
else
x(i)<=x(i-1);
y(i)<=y(i-1);
end if;
end loop l3;
-----------------------------------------head moves
if((y(0)-20)>=0)then
y(0)<=y(0)-20;
else
y(0)<=vD;
end if;
---------------------------------------- state down
when SD=>
---------------------------------------- check if food
if(x(0)=xf and (y(0)+20=yf or (y(0)+20>vD-1 and yf=0)))then
xf<=( (x(1)+x(3)+y(5)+13 )mod 32)*20;
yf<=( (y(7)+x(4)+x(0)+11 )mod 24)*20;
l<=l+1;
if((l mod 5)=0)then
a<=a+1;
end if;
end if;
----------------------------------------------checks if itself
l9: for i in lmax downto 1 loop
if(x(0)=x(i) and y(0)+20=y(i))then
eof<='1';
end if;
end loop l9;
---------------------------------------- body moves
l4:for i in lmax downto 1 loop
if(i>=l) then
x(i)<=x(l-1);
y(i)<=y(l-1);
else
x(i)<=x(i-1);
y(i)<=y(i-1);
end if;
end loop l4;
----------------------------------- head moves
if((y(0)+20)<=(vD-1)) then
y(0)<=y(0)+20;
else
y(0)<=0;
end if;
------------------------------------ initial state
when O=>
l5: for i in lmax downto 0 loop
x(i)<=x(i);
y(i)<=y(i);
end loop l5;
end case;
end if;
end if;
end process;
-------------------------------------------------------------------------- actually putting on screen
process(vpos, hpos, desen, div_clk2, x(0), y(0))
begin
if(rising_edge(div_clk2))then
if(desen='1')then
if ((hpos>=xe1 and hpos<(xe1+5) and vpos>=ye1 and vpos<(ye1+5)) or (hpos>=xe2 and hpos<(xe2+5) and vpos>=ye2 and vpos<(ye2+5))) then
R<=x"1";
G<=x"3";
B<=x"b";
elsif((hpos>=x(0) and hpos<(x(0)+20) and vpos>=y(0) and vpos<(y(0)+20))or
   (hpos>=x(1) and hpos<(x(1)+20) and vpos>=y(1) and vpos<(y(1)+20))or
   (hpos>=x(2) and hpos<(x(2)+20) and vpos>=y(2) and vpos<(y(2)+20))or
   (hpos>=x(3) and hpos<(x(3)+20) and vpos>=y(3) and vpos<(y(3)+20))or
   (hpos>=x(4) and hpos<(x(4)+20) and vpos>=y(4) and vpos<(y(4)+20)) or
   (hpos>=x(5) and hpos<(x(5)+20) and vpos>=y(5) and vpos<(y(5)+20)) or
   (hpos>=x(6) and hpos<(x(6)+20) and vpos>=y(6) and vpos<(y(6)+20)) or
   (hpos>=x(7) and hpos<(x(7)+20) and vpos>=y(7) and vpos<(y(7)+20)) or
   (hpos>=x(8) and hpos<(x(8)+20) and vpos>=y(8) and vpos<(y(8)+20)) or
   (hpos>=x(9) and hpos<(x(9)+20) and vpos>=y(9) and vpos<(y(9)+20)) or
   (hpos>=x(10) and hpos<(x(10)+20) and vpos>=y(10) and vpos<(y(10)+20)) or
   (hpos>=x(11) and hpos<(x(11)+20) and vpos>=y(11) and vpos<(y(11)+20)) or
   (hpos>=x(12) and hpos<(x(12)+20) and vpos>=y(12) and vpos<(y(12)+20)) or
   (hpos>=x(13) and hpos<(x(13)+20) and vpos>=y(13) and vpos<(y(13)+20)) or
   (hpos>=x(14) and hpos<(x(14)+20) and vpos>=y(14) and vpos<(y(14)+20)) or
   (hpos>=x(15) and hpos<(x(15)+20) and vpos>=y(15) and vpos<(y(15)+20)))then
-------------------------------------------------------------------------------- snak colour
R<=x"5";
G<=x"a";
B<=x"3";
elsif(hpos>=xf and hpos<(xf+20) and vpos>=yf and vpos<(yf+20)) then
-------------------------------------------------------------------------------- food colour
R<=x"c";
G<=x"c";
B<=x"c";
else
-------------------------------------------------------------------------------- background colour
R<=x"2";
G<=x"5";
B<=x"6";

end if;
end if;
end if;
end process;

end Behavioral;
