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

entity brambitstream is
  port
  (
    sysclk              : in  std_logic;
    bram_rd_en          : in  std_logic;
    bramblkaddr         : in std_logic_vector(8 downto 0);
    bramaddrvalid       : in  std_logic;
    dout          : out std_logic_vector(31 downto 0);
    bramrddone          : out std_logic
  );
end brambitstream;

architecture behavioral of brambitstream is
  attribute mark_debug : string;
  attribute dont_touch : string;
  attribute keep : string;

signal douta      : std_logic_vector(15 downto 0) := X"0000";
signal doutb      : std_logic_vector(15 downto 0) := X"0000";
signal bramoutaddr  : std_logic_vector(8 downto 0) := "000000000";

begin
 
--  RAMB18E2_inst : RAMB18E2
  -- RAMB18E1: 18K-bit Configurable Synchronous Block RAM
  -- 7 Series
  -- Xilinx HDL Language Template, version 2023.2
  RAMB18E1_inst : RAMB18E1
    generic map (
    INIT_00 => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",  -- Addr x000, 32-bit each address
    INIT_01 => X"0000026B_3003E001_20000000_AA995566_ffffffff_ffffffff_11220044_000000BB",
--  INIT_02 => X"30008001__FIRST___30020001_400B98C0_30022001_20000000_00000012_30008001", 
    INIT_02 => X"30008001_00200000_30020001_400B98C0_30022001_20000000_00000012_30008001", 
    INIT_03 => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_20000000_0000000f",
    INIT_04 => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",
    INIT_05 => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",
    INIT_06 => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_11111111_ffffffff",  -- not used, ID
    INIT_07 => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",

    INIT_08 => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",  -- Addr x040 (d64)
    INIT_09 => X"0000026B_3003E001_20000000_AA995566_ffffffff_ffffffff_11220044_000000BB",
--  INIT_0A => X"30008001__SECOND__30020001_400B98C0_30022001_20000000_00000012_30008001", 
    INIT_0A => X"30008001_00400000_30020001_400B98C0_30022001_20000000_00000012_30008001", 
    INIT_0B => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_20000000_0000000f",
    INIT_0C => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",
    INIT_0D => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",
    INIT_0E => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_22222222_ffffffff",  -- not used, ID
    INIT_0F => X"ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff",

     -- INIT_A, INIT_B: Initial values on output ports
        INIT_A => "00" & X"0000",
        INIT_B => "00" & X"0000",                    
--        CASCADE_ORDER_A => "NONE",
--        CASCADE_ORDER_B => "NONE",
--        CLOCK_DOMAINS => "COMMON",
        RAM_MODE => "SDP",
        DOB_REG => 0,
        SIM_COLLISION_CHECK => "ALL",
        DOA_REG => 0,
--        ENADDRENA => "FALSE",
--        ENADDRENB => "FALSE",
--        IS_CLKARDCLK_INVERTED => '0',
--        IS_CLKBWRCLK_INVERTED => '0',
--        IS_ENARDEN_INVERTED => '0',
--        IS_ENBWREN_INVERTED => '0',
--        IS_RSTRAMARSTRAM_INVERTED => '0',
--        IS_RSTRAMB_INVERTED => '0',
--        IS_RSTREGARSTREG_INVERTED => '0',
--        IS_RSTREGB_INVERTED => '0',
--        RDADDRCHANGEA => "FALSE",
--        RDADDRCHANGEB => "FALSE",
        READ_WIDTH_A => 36,    
        READ_WIDTH_B => 0,      
        WRITE_WIDTH_A => 0,    
        WRITE_WIDTH_B => 0,   
        RSTREG_PRIORITY_A => "RSTREG",
        RSTREG_PRIORITY_B => "RSTREG",
        SRVAL_A => "00" & X"0000",
        SRVAL_B => "00" & X"0000",
      -- Simulation Device: Must be set to "7SERIES" for simulation behavior
        SIM_DEVICE => "7SERIES",
--        SLEEP_ASYNC => "FALSE",
        WRITE_MODE_A => "WRITE_FIRST",
        WRITE_MODE_B => "WRITE_FIRST" 
    )
    port map (
--        CASDOUTA => open,               
--        CASDOUTB => open,               
--        CASDOUTPA => open,             
--        CASDOUTPB => open,             
--        DOUTADOUT => douta,            
--        DOUTPADOUTP => open,         
--        DOUTBDOUT => doutb,             
--        DOUTPBDOUTP => open,         
        DOADO => douta, -- 16-bit output: A port data/LSB data
        DOPADOP => open, -- 2-bit output: A port parity/LSB parity
        DOBDO => doutb, -- 16-bit output: B port data/MSB data
        DOPBDOP => open, -- 2-bit output: B port parity/MSB parity
--        CASDIMUXA => '0',            
--        CASDIMUXB => '0',             
--        CASDINA => X"0000",                
--        CASDINB => X"0000",                
--        CASDINPA => "00",        
--        CASDINPB => "00",               
--        CASDOMUXA => '0',             
--        CASDOMUXB => '0',             
--        CASDOMUXEN_A => '1',       
--        CASDOMUXEN_B => '1',       
--        CASOREGIMUXA => '0',      
--        CASOREGIMUXB => '0',       
--        CASOREGIMUXEN_A => '1',
--        CASOREGIMUXEN_B => '1', 
        ADDRARDADDR => bramoutaddr&"00000",
--        ADDRENA => '1',                
        CLKARDCLK => sysclk,          
        ENARDEN => bram_rd_en,                
        REGCEAREGCE => '1',         
        RSTRAMARSTRAM => '0',    
        RSTREGARSTREG => '0',     
--        SLEEP => '0',                   
        WEA => "00",                         
--        DINADIN => X"0000",                 
--        DINPADINP => "00",            
        DIADI => X"0000", -- 16-bit input: A port data/LSB data
        DIPADIP => "00", -- 2-bit input: A port parity/LSB parity
        ADDRBWRADDR => "00000000000000",         
--        ADDRENB => '1',               
        CLKBWRCLK => '0',           
        ENBWREN => '0', 
        REGCEB => '1',                   
        RSTRAMB => '0',                
        RSTREGB => '0',                 
        WEBWE => X"f",                     
--        DINBDIN => X"0000",
--        DINPBDINP => "00"              
        DIBDI => X"0000", -- 16-bit input: B port data/MSB data
        DIPBDIP => "00" -- 2-bit input: B port parity/MSB parity
    );
-- End of RAMB18E1_inst instantiation

--dout <= douta(3 downto 0) & douta(7 downto 4) & douta(11 downto 8) & douta(15 downto 12) & 
--        doutb(3 downto 0) & doutb(7 downto 4) & doutb(11 downto 8) & doutb(15 downto 12);
dout <= doutb & douta;
        
BramaddrCount: process(sysclk, bramaddrvalid)
  begin
    if (rising_edge(sysclk)) then
      if (bramaddrvalid = '1') then 
        bramoutaddr <= bramblkaddr; 
        bramrddone <= '0';
      elsif (bram_rd_en = '1') then
        bramoutaddr <= bramoutaddr + 1;
        if (bramoutaddr(5 downto 0) = 63) then bramrddone <= '1'; end if;
      end if;
    end if;
end process BramaddrCount;

end architecture behavioral; 
