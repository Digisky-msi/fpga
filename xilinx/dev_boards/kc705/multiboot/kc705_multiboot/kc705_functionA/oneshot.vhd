--/*
--*
--* Copyright (C) Digisky Media Solutions Inc.  All rights reserved.
--*
--* Permission is hereby granted, free of charge, to any person
--* obtaining a copy of this software and associated documentation
--* files (the "Software"), to deal in the Software without restriction,
--* including without limitation the rights to use, copy, modify, merge,
--* publish, distribute, sublicense, and/or sell copies of the Software,
--* and to permit persons to whom the Software is furnished to do so,
--* subject to the following conditions:
--*
--* The above copyright notice and this permission notice shall be included
--* in all copies or substantial portions of the Software.
--*
--* Use of the Software is limited solely to applications:
--* (a) running on a Xilinx device, or (b) that interact
--* with a Xilinx device through a bus or interconnect.
--*
--* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
--* IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
--* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
--* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--*
--*
--* Modified for KC705 multiboot demo 2023/12/12
--*/
-- Oneshot for one clk cycle – R.K.

Library UNISIM;
library ieee;
use UNISIM.vcomponents.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity oneshot is
  port (
    trigger: in  std_logic;
    clk : in std_logic;
    pulse: out std_logic
  );
end oneshot;

architecture behavioral of oneshot is
    signal QA: std_logic := '0';
    signal QB: std_logic := '0';

begin   -- one shot
  process (trigger,QB)
     begin
       if QB='1' then
         QA <= '0';
       elsif (trigger'event and trigger='1') then
         QA <= '1';
       end if;
   end process;
   
   process (clk)
     begin
       if clk'event and clk ='1' then
        QB <= QA;
       end if;
   end process;

  pulse  <= QB;

end behavioral;

