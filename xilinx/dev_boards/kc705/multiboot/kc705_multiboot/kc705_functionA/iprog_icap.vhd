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
------------------------------------------------------------------------
--    Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
--                 INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
--                 PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
--                 PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
--                 ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
--                 APPLICATION OR STANDARD, XILINX IS MAKING NO
--                 REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
--                 FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
--                 RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
--                 REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
--                 EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
--                 RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
--                 INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
--                 REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
--                 FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
--                 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
--                 PURPOSE.
-- 
--                 (c) Copyright 2013-2016 Xilinx, Inc.
--                 All rights reserved.
------------------------------------------------------------------------

library ieee;
Library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use UNISIM.vcomponents.all;

entity iprog_icap is
  port (
    go    : in  std_logic;
    clk   : in  std_logic
  );
end iprog_icap;

architecture iprog of iprog_icap is

  attribute mark_debug : string;
  attribute keep : string;
  
   constant  CCOUNT      : integer := 8;
   
   signal    cnt_bitst   : integer range 0 to CCOUNT := 0;
   attribute keep of cnt_bitst: signal is "true";
   signal    reboot      : std_logic := '0';
   attribute keep of reboot: signal is "true";
   signal    reprog      : std_logic := '0';
   attribute keep of reprog: signal is "true";
   signal    icap_cs     : std_logic := '1';
   signal    icap_rw     : std_logic := '1';
   signal    d           : std_logic_vector(31 downto 0) :=X"FBFFFFAC";
   signal    bit_swapped : std_logic_vector(31 downto 0) :=X"FFFFFFFF";
  
begin

--ICAPE3_inst: ICAPE3
ICAPE2_inst: ICAPE2
port map (
--   AVAIL   => open,
   O       => open,
--   PRDONE  => open,
--   PRERROR => open,
   CLK     => clk,           -- Icap Clock Input
   CSIB    => icap_cs,       -- Active-Low ICAP Enable
   I       => bit_swapped,   -- Configuration data input bus
   RDWRB   => icap_rw        -- Read/Write Select input 1= Write
);

process(clk)
begin
   if rising_edge (clk) then
      if (go = '1') then reboot <= '1'; end if;
      
      if (reboot = '0') then
        icap_cs  <= '1';
        icap_rw  <= '1';
        cnt_bitst  <= 0;
      else
        if(cnt_bitst /= CCOUNT)  then
            cnt_bitst <= cnt_bitst + 1;
        end if;

        case cnt_bitst is
            when  0 => icap_cs <= '0'; icap_rw <= '0';
            -- using registers for now
            when  1 => d <= x"FFFFFFFF";   -- Dummy Word
            when  2 => d <= x"AA995566";   -- Sync Word
            when  3 => d <= x"20000000";   -- Type 1 NO OP
            when  4 => d <= x"30020001";   -- Type 1 Write 1 Word to WBSTAR
            when  5 => d <= x"00000000";   -- Warm Boot Start Address
            when  6 => d <= x"20000000";   -- Type 1 NO OP
            when  7 => d <= x"30008001";   -- Type 1 Write 1 Words to CMD
            when  8 => d <= x"0000000F";   -- IPROG Command
            -- Bye, bye
            when others => icap_cs <= '1'; icap_rw <= '1';
        end case;
      end if;  -- if go
   end if;
end process;

-- Bit swap the ICAP bytes
bit_swapped(31 downto 24) <= d(24)&d(25)&d(26)&d(27)&d(28)&d(29)&d(30)&d(31);
bit_swapped(23 downto 16) <= d(16)&d(17)&d(18)&d(19)&d(20)&d(21)&d(22)&d(23);
bit_swapped(15 downto 8)  <= d(8)&d(9)&d(10)&d(11)&d(12)&d(13)&d(14)&d(15);
bit_swapped(7 downto 0)   <= d(0)&d(1)&d(2)&d(3)&d(4)&d(5)&d(6)&d(7);

end iprog;

