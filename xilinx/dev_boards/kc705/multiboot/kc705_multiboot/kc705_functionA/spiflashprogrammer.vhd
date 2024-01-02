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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use UNISIM.vcomponents.all;

entity spiflashprogrammer_v2_k7 is
  port
  (
    Clk           : in  std_logic;
    fifoclk       : in std_logic;
    data_to_fifo  : in std_logic_vector(31 downto 0);
    startaddr     : in std_logic_vector(31 downto 0);
    startaddrvalid   : in std_logic;
    pagecount     : in std_logic_vector(16 downto 0);   
    pagecountvalid   : in std_logic;
    sectorcount   : in std_logic_vector(13 downto 0);
    sectorcountvalid : in std_logic;
    -----------------------------
    fifowren      : in std_logic;
    fifofull      : out std_logic;
    fifoempty     : out std_logic;
    fifoafull     : out std_logic;
    fifowrerr     : out std_logic;
    fiforderr     : out std_logic;
    writedone     : out std_logic;
    ----------------------------------
    reset         : in std_logic;
    erase         : in std_logic;
    eraseing      : out std_logic;

    SPI_CS_L  : out std_logic;    -- 7 series directly deal with pins at fabric, not at STARTUP
    SPI_Q0    : inout std_logic;
    SPI_Q1    : inout std_logic;
    SPI_Q2    : inout std_logic;
    SPI_Q3    : inout std_logic

   );   
end spiflashprogrammer_v2_k7;

architecture behavioral of spiflashprogrammer_v2_k7 is
  attribute mark_debug : string;
  attribute dont_touch : string;
  attribute keep : string;
  attribute shreg_extract : string;
  attribute async_reg     : string;
  
component SpiCsBflop is
  port (
    C : in  std_logic;
    D : in std_logic;
    Q : out std_logic
  );
end component SpiCsBflop;

component oneshot is
port (
  trigger: in  std_logic;
  clk : in std_logic;
  pulse: out std_logic
);
end component oneshot;

component fifo36e1_wrap IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC;
    prog_empty : OUT STD_LOGIC;
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END component fifo36e1_wrap;

  
  -- SPI COMMAND ADDRESS WIDTH (IN BITS): Ensure setting is correct for the target flash
  constant  AddrWidth        : integer   := 32;  -- 24 or 32 (3 or 4 byte addr mode)
  -- SPI SECTOR SIZE (IN Bits)
  constant  SectorSize       : integer := 65536; -- 64K bits
  constant  SizeSector       : std_logic_vector(31 downto 0) := X"00010000"; -- 65536 bits
  constant  SubSectorSize    : integer := 4096; -- 4K bits
  constant  SizeSubSector    : std_logic_vector(31 downto 0) := X"00001000"; -- 4K bits
  -- Total number of all sectors in part
  constant  NumberofSectors  : std_logic_vector(8 downto 0) := "000000000";  -- 512 Sectors total
  -- SPI PAGE SIZE (IN BYTES): Ensure setting is correct for the chosen device type.
  constant  PageSize         : std_logic_vector(31 downto 0) := X"00000100"; -- 
  constant  NumberofPages    : std_logic_vector(16 downto 0) := "10000000000000000"; -- 256 bytes pages = 20000h
   -- UPDATE IMAGE START (BYTE) ADDRESS
  constant  AddrUpdateStart  : std_logic_vector(31 downto 0) := X"00200000";
  -- UPDATE IMAGE END+1 (BYTE) ADDRESS
  constant  AddrUpdateEnd    : std_logic_vector(31 downto 0) := X"00400000";
  constant  AddrStart32      : std_logic_vector(31 downto 0) := X"00000000"; -- First address in SPI
  constant  AddrEnd32        : std_logic_vector(31 downto 0) := X"01FFFFFF"; -- Last bit address in SPI (256Mb)
  -- SPI flash information
  constant  Idcode25NQ256     : std_logic_vector(23 downto 0) := X"20BB19";  --RDID N256Q 256 MB
  
  -- Device command opcodes
  constant  CmdREAD24        : std_logic_vector(7 downto 0)  := X"03";
  constant  CmdFASTREAD      : std_logic_vector(7 downto 0)  := X"0B";
  constant  CmdREAD32        : std_logic_vector(7 downto 0)  := X"13";
  constant  CmdRDID          : std_logic_vector(7 downto 0)  := X"9F";
  constant  CmdFLAGStatus    : std_logic_vector(7 downto 0)  := X"70";
  constant  CmdStatus        : std_logic_vector(7 downto 0)  := X"05";
  constant  CmdWE            : std_logic_vector(7 downto 0)  := X"06";
  constant  CmdSE24          : std_logic_vector(7 downto 0)  := X"D8";
  constant  CmdSE32          : std_logic_vector(7 downto 0)  := X"DC";
  constant  CmdSSE24         : std_logic_vector(7 downto 0)  := X"20";
  constant  CmdSSE32         : std_logic_vector(7 downto 0)  := X"21";
  constant  CmdPP24          : std_logic_vector(7 downto 0)  := X"02";
  constant  CmdPP32          : std_logic_vector(7 downto 0)  := X"12";
  constant  CmdPP24Quad      : std_logic_vector(7 downto 0)  := X"32"; 
  constant  CmdPP32Quad      : std_logic_vector(7 downto 0)  := X"34"; 
  constant  Cmd4BMode        : std_logic_vector(7 downto 0)  := X"B7";
  constant  CmdExit4BMode    : std_logic_vector(7 downto 0)  := X"E9";
  
      ------------- other signals/regs/counters  ------------------------
  signal cmdcounter32     : std_logic_vector(5 downto 0) := "100111";  -- 32 bit command/addr
  signal cmdreg32         : std_logic_vector(39 downto 0) := X"1111111111";  -- avoid LSB removal
  signal data_valid_cntr  : std_logic_vector(2 downto 0) := "000";
  signal rddata           : std_logic_vector(1 downto 0) := "00";
  attribute keep of rddata: signal is "true";                -- remove/avoid warning for this use case
  signal wrdata_count     : std_logic_vector(2 downto 0) := "000"; -- SPI from FIFO Nibble count
  signal spi_wrdata       : std_logic_vector(31 downto 0) := X"00000000";
  signal page_count       : std_logic_vector(16 downto 0) := "11111111111111111";
  signal Current_Addr     : std_logic_vector(31 downto 0) := X"00000000";
  attribute keep of Current_Addr: signal is "true";           -- remove/avoid warning for this use case
  signal Current_Addr24     : std_logic_vector(23 downto 0) := X"000000";
  attribute keep of Current_Addr24: signal is "true";           -- remove/avoid warning for this use case
  signal StatusDataValid  : std_logic := '0';
  signal spi_status       : std_logic_vector(1 downto 0) := "11";
  signal write_done       : std_logic := '0';
     ------- erase ----------------------------
  signal er_cmdcounter32  : std_logic_vector(5 downto 0) := "111111";  -- 32 bit command/addr
  signal er_cmdreg32      : std_logic_vector(39 downto 0) := X"1111111111"; 
  signal er_rddata        : std_logic_vector(1 downto 0) := "00";   -- remove/avoid warning for this use case
  attribute keep of er_rddata: signal is "true";
  signal er_data_valid_cntr : std_logic_vector(2 downto 0) := "000";
  signal er_sector_count    : std_logic_vector(13 downto 0) := "11111111111111";    -- subsector count
  signal er_current_sector_addr   : std_logic_vector(31 downto 0) := X"00000000"; -- start addr of current sector
  attribute keep of er_current_sector_addr: signal is "true";
  signal er_current_sector_addr24   : std_logic_vector(23 downto 0) := X"000000"; -- start addr of current sector
  attribute keep of er_current_sector_addr24: signal is "true";
  signal er_SpiCsB        : std_logic;
  signal er_status        : std_logic_vector(1 downto 0) := "11";
  signal erase_inprogress : std_logic := '0';
  signal erase_start      : std_logic := '0';
     ------------ StartupE2 signals  ---------------------------
  signal SpiMiso         : std_logic;
  signal SpiMosi         : std_logic;
  signal SpiCsB          : std_logic := '1';
  signal SpiCsB_N        : std_logic;
  signal SpiCsB_FFDin    : std_logic := '1';
  signal di_out          : std_logic_vector(3 downto 0) := X"0";
  signal do_in           : std_logic_vector(3 downto 0) := X"0";
  signal dopin_ts        : std_logic_vector(3 downto 0) := "1110";    
  attribute keep of dopin_ts: signal is "true";      -- remove/avoid warning for this use case
  signal SpiMosi_int     : std_logic;
  ----------- FIFO signals  ---------------------
  signal fifo_rden         : std_logic := '0';
--  attribute keep of fifo_rden: signal is "true"; 
  signal fifo_empty        : std_logic := '0';
--  attribute keep of fifo_empty: signal is "true"; 
  signal fifo_full         : std_logic := '0';
--  attribute keep of fifo_full: signal is "true";
  signal fifo_almostfull   : std_logic := '0';
--  attribute keep of fifo_almostfull : signal is "true";
  signal fifo_almostempty  : std_logic := '0';
--  attribute keep of fifo_almostempty : signal is "true";
  signal fifodout          : std_logic_vector(63 downto 0) := X"0000000000000000";
  signal fifo_unconned     : std_logic_vector(63 downto 0) := X"0000000000000000";
  ----- Misc signal
  signal reset_design     : std_logic := '0';
  signal wrerr     : std_logic := '0';
  signal rderr     : std_logic := '0';
  ----  syncers
  ----  place sync regs close together and no SRLs
  signal synced_fifo_almostfull : std_logic_vector(1 downto 0) := "00";
    attribute keep of synced_fifo_almostfull : signal is "true";
    attribute async_reg of synced_fifo_almostfull : signal is "true";   
    attribute shreg_extract of synced_fifo_almostfull : signal is "no";
  signal synced_erase : std_logic_vector(1 downto 0) := "00";
    attribute keep of synced_erase : signal is "true";
    attribute async_reg of synced_erase : signal is "true";   
    attribute shreg_extract of synced_erase : signal is "no";
       
     type wrstates is
  (
    S_WR_IDLE, S_WR_ASSCS1, S_WR_WRCMD,  
    S_WR_ASSCS2, S_WR_PROGRAM, S_WR_DATA, S_WR_PPDONE, S_WR_PPDONE_WAIT, S_EXIT4BMode_ASSCS1, 
    S_EXIT4BMODE --  
  );
  signal wrstate  : wrstates := S_WR_IDLE;

    type erstates is
  (
    S_ER_IDLE, S_S4BMode_ASSCS1, S_S4BMode_WRCMD, S_S4BMode_ASSCS2, S_S4BMode_WR4BADDR, 
    S_ER_ASSCS1, S_ER_ASSCS2, S_ER_ASSCS3, S_ER_WRCMD, S_ER_ERASECMD, S_ER_RDSTAT   --  
  );
  signal erstate  : erstates := S_ER_IDLE;
  
  signal spi_wr_en : std_logic := '0';

 begin
 
  -- STARTUPE2: STARTUP Block
  -- 7 Series
  -- Xilinx HDL Libraries Guide, version 2012.2
  u_startup : STARTUPE2 
  generic map(
    PROG_USR => "FALSE",   -- Activate program event security feature. Requires encrypted bitstreams.
    SIM_CCLK_FREQ => 0.0   -- Set the Configuration Clock Frequency(ns) for simulation.
  )
  port map (
    CFGCLK => open ,      -- 1-bit output: Configuration main clock output
    CFGMCLK => open ,     -- 1-bit output: Configuration internal oscillator clock output
    EOS => open ,         -- 1-bit output: Active high output signal indicating the End Of Startup.
    PREQ => open ,        -- 1-bit output: PROGRAM request to fabric output
    CLK => '0',           -- 1-bit input: User start-up clock input
    GSR => '0',           -- 1-bit input: Global Set/Reset input  => GSR cannot be used for the port name)
    GTS => '0',           -- 1-bit input: Global 3-state input  => GTS cannot be used for the port name)
    KEYCLEARB => '1',     -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM  => BBRAM)
    PACK => '1',          -- 1-bit input: PROGRAM acknowledge input
    USRCCLKO => Clk,      -- 1-bit input: User CCLK input
    USRCCLKTS => '0',     -- 1-bit input: User CCLK 3-state enable input
    USRDONEO => '1',      -- 1-bit input: User DONE pin output control
    USRDONETS => '0'      -- 1-bit input: User DONE 3-state enable output
  );
  -- End of STARTUPE2_inst instantiation

--  STARTUPE3_inst : STARTUPE3
--  port map (
--          CFGCLK => open,
--          CFGMCLK => open,
--          EOS => open,
--          DI => di_out,  -- inSpiMiso D01 pin to Fabric
--          PREQ => open,
--          -- End outputs to fabric ports
--          DO => fifodout(3 downto 1) & SpiMosi,
--          DTS => dopin_ts,
--          FCSBO => SpiCsB_N,
--          FCSBTS =>  '0',
--          GSR => '0',
--          GTS => '0',
--          KEYCLEARB => '1',
--          PACK => '1',
--          USRCCLKO => Clk,
--          USRCCLKTS => '0',  -- Clk_ts,
--          USRDONEO => '1',
--          USRDONETS => '0'    
--  );
  
--  SpiMiso <= di_out(1);  -- Synonym 

  negedged0_flop : SpiCsBflop    -- launch D0 on neg edge
    port map (
            C => Clk,
            D => SpiMosi,  
            Q => do_in(0)   
    );
  negedged1_flop : SpiCsBflop    -- launch D1 on neg edge
    port map (
            C => Clk,
            D => fifodout(1),  
            Q => do_in(1)   
    );
  negedged2_flop : SpiCsBflop    -- launch D2 on neg edge
    port map (
            C => Clk,
            D => fifodout(2),  
            Q => do_in(2)   
    );
  negedged3_flop : SpiCsBflop    -- launch D3 on neg edge
    port map (
            C => Clk,
            D => fifodout(3),  
            Q => do_in(3)   
    );

IOBUF_inst0 : IOBUF
  port map (
    O   => open,        -- Buffer output
    IO  => SPI_Q0,      -- Buffer inout port (connect directly to top-level port)
    I   => do_in(0),    -- Buffer input
    T   => dopin_ts(0)  -- 3-state enable input, high=input, low=output
  );
IOBUF_inst1 : IOBUF
  port map (
    O   => SpiMiso,     -- Buffer output
    IO  => SPI_Q1,      -- Buffer inout port (connect directly to top-level port)
    I   => do_in(1),    -- Buffer input
    T   => dopin_ts(1)  -- 3-state enable input, high=input, low=output
  );
IOBUF_inst2 : IOBUF
  port map (
    O   => open,        -- Buffer output
    IO  => SPI_Q2,      -- Buffer inout port (connect directly to top-level port)
    I   => do_in(2),    -- Buffer input
    T   => dopin_ts(2)  -- 3-state enable input, high=input, low=output
  );
IOBUF_inst3 : IOBUF
  port map (
    O   => open,        -- Buffer output
    IO  => SPI_Q3,      -- Buffer inout port (connect directly to top-level port)
    I   => do_in(3),    -- Buffer input
    T   => dopin_ts(3)  -- 3-state enable input, high=input, low=output
  );
  
  
  negedgecs_flop : SpiCsBflop    -- launch SpicCsB on neg edge
    port map (
            C => Clk,
            D => SpiCsB_FFDin,  
            Q => SpiCsB_N   
    );
    SPI_CS_L <= SpiCsB_N;
    
    
  oneshot_inst  : oneshot
      port map (
        trigger  => synced_erase(0),
        clk   => Clk,
        pulse  => erase_start
      );
      
FIFO36E1_inst : fifo36e1_wrap
  PORT map(
    rst           => reset_design,
    wr_clk        => fifoclk,
    rd_clk        => Clk,
    din           => fifo_unconned(31 downto 0),
    wr_en         => fifowren,
    rd_en         => fifo_rden,
    dout          => fifodout(3 downto 0),
    full          => fifo_full,
    empty         => fifo_empty,
    prog_full     => fifo_almostfull,
    prog_empty    => fifo_almostempty,
    wr_rst_busy   => open,
    rd_rst_busy   => open
  );

--FIFO36_inst : FIFO36E2
--           generic map (
--              CLOCK_DOMAINS => "INDEPENDENT",     -- COMMON, INDEPENDENT
--              FIRST_WORD_FALL_THROUGH => "TRUE",  -- first word read doesn't require FIFO_EN
--              PROG_EMPTY_THRESH => 2,             -- Programmable Empty Threshold; a bit weird, but 2 = 1 clk before EMPTY
--              PROG_FULL_THRESH => 64,             -- 512+4 bytes...X64 words +1, FIFO max 512 words  
--              READ_WIDTH => 4,                    -- 
--              REGISTER_MODE => "REGISTERED",      -- 
--              RSTREG_PRIORITY => "RSTREG",        -- REGCE, RSTREG
--              WRITE_WIDTH => 36                    
--           )    
--           port map (
--              CASDOUT => open,             
--              CASDOUTP => open,           
--              CASNXTEMPTY => open,    
--              CASPRVRDEN => open,       
--              DOUT => fifodout,                   
--              DOUTP => open,                 
--              EMPTY => fifo_empty,                 
--              FULL => fifo_full,                   
--              PROGEMPTY => fifo_almostempty,         
--              PROGFULL => fifo_almostfull,           
--              RDCOUNT => open,             
--              RDERR => open,                 
--              RDRSTBUSY => open,         
--              WRCOUNT => open,             
--              WRERR => wrerr,                 
--              WRRSTBUSY => open,         
--              CASDIN => X"0000000000000000",               
--              CASDINP => X"00",             
--              CASDOMUX => '0',           
--              CASDOMUXEN => '1',       
--              CASNXTRDEN => '0',       
--              CASOREGIMUX => '0',                  
--              CASOREGIMUXEN => '1', 
--              CASPRVEMPTY => '0',     
--              RDCLK => Clk,                 
--              RDEN => fifo_rden, 
--              REGCE => '1',                 
--              RSTREG => '0',               
--              SLEEP => '0',                 
--              RST => reset_design,    -- Requires a WRCLK                    
--              WRCLK => fifoclk,       -- DRCK cable clock frequency          
--              WREN => fifowren,                   
--              DIN => fifo_unconned,                      
--              DINP => X"00",
--              INJECTDBITERR => '0',
--              INJECTSBITERR =>  '0',
--              DBITERR => open,
--              SBITERR => open,
--              ECCPARITY => open
--           );

-----------------------------  erase sectors  --------------------------------------------------
processerase : process (Clk)
  begin
  if rising_edge(Clk) then
  if (reset_design = '1') then
    erstate <= S_ER_IDLE;
    er_SpiCsB <= '1';
    erase_inprogress <= '0';
    spi_wr_en <= '0';
  else
  case erstate is 
   when S_ER_IDLE =>
        er_SpiCsB <= '1';
        if (sectorcountvalid = '1') then er_sector_count <= sectorcount; end if;  -- no sync required
--        if (startaddrvalid = '1') then er_current_sector_addr <= startaddr; end if;  -- no sync required. lots of time spent in _top
        if (startaddrvalid = '1') then er_current_sector_addr24 <= startaddr(23 downto 0); end if;  -- no sync required. lots of time spent in _top
        if (erase_start = '1') then  -- one shot based on I/F erase -> synced_erase input going high e.g. "if rising edge erase"
          er_data_valid_cntr <= "000";
          er_cmdcounter32 <= "100111";  -- 32 bit command (cmd + addr = 40 bits)
          er_rddata <= "00";
          er_cmdreg32 <=  CmdWE & X"00000000";  -- Write Enable
          erase_inprogress <= '1';
          spi_wr_en <= '0';
--          erstate <= S_S4BMode_ASSCS1;
          erstate <= S_ER_ASSCS1; -- KC705 MT25QL128 doesn't support 4 byte mode
         end if;
                       
-----------------   Set 4 Byte mode first --------------------------------------------------
   when S_S4BMode_ASSCS1 =>
        er_SpiCsB <= '0';
        erstate <= S_S4BMode_WRCMD;
          
   when S_S4BMode_WRCMD =>    -- Set WE bit
        if (er_cmdcounter32 /= 32) then er_cmdcounter32 <= er_cmdcounter32 - 1; 
          er_cmdreg32 <= er_cmdreg32(38 downto 0) & '0'; 
        else
          er_cmdreg32 <=  Cmd4BMode  & X"00000000";  -- Flag Status register
          er_cmdcounter32 <= "100111";  -- 40 bit command+addr
          er_SpiCsB <= '1';   -- turn off SPI 
          erstate <= S_S4BMode_ASSCS2; 
        end if;
        
   when S_S4BMode_ASSCS2 =>
        er_SpiCsB <= '0';
        erstate <= S_S4BMode_WR4BADDR;
                        
   when S_S4BMode_WR4BADDR =>    -- Set 4-Byte address Mode
        if (er_cmdcounter32 /= 32) then er_cmdcounter32 <= er_cmdcounter32 - 1;  
           er_cmdreg32 <= er_cmdreg32(38 downto 0) & '0';
        else 
          er_SpiCsB <= '1';   -- turn off SPI
          er_cmdcounter32 <= "100111";  -- 32 bit command
          er_cmdreg32 <=  CmdWE & X"00000000";  -- Write Enable 
          erstate <= S_ER_ASSCS1;  
        end if;  
-------------------------  end set 4 byte Mode

   when S_ER_ASSCS1 =>
        erstate <= S_ER_WRCMD;
        er_SpiCsB <= '0';
        er_status <= "11";
                  
   when S_ER_WRCMD =>    -- Set WE bit
        if (er_cmdcounter32 /= 32) then er_cmdcounter32 <= er_cmdcounter32 - 1;  
          er_cmdreg32 <= er_cmdreg32(38 downto 0) & '0';
        else 
          er_SpiCsB <= '1';   -- turn off SPI
--          er_cmdreg32 <=  CmdSSE24 & er_current_sector_addr;  -- 4-Byte Sector erase 
          er_cmdreg32 <=  CmdSSE24 & er_current_sector_addr24 & x"00";  -- 3-Byte Sector erase 
          er_cmdcounter32 <= "100111";
          erstate <= S_ER_ASSCS2;        
        end if;
                   
   when S_ER_ASSCS2 =>
        er_SpiCsB <= '0';   
        erstate <= S_ER_ERASECMD;
                      
   when S_ER_ERASECMD =>     -- send erase command
--        if (er_cmdcounter32 /= 0) then er_cmdcounter32 <= er_cmdcounter32 - 1; -- send erase + 24 bit address
        if (er_cmdcounter32 /= 8) then er_cmdcounter32 <= er_cmdcounter32 - 1; -- send erase + 24 bit address
          er_cmdreg32 <= er_cmdreg32(38 downto 0) & '0';
        else
          er_SpiCsB <= '1';   -- turn off SPI
          er_cmdcounter32 <= "100111";
          er_cmdreg32 <=  CmdStatus & X"00000000";  -- Read Status register
          erstate <= S_ER_ASSCS3;
        end if;
                                      
   when S_ER_ASSCS3 =>
        er_SpiCsB <= '0';   
        erstate <= S_ER_RDSTAT;
                  
   when S_ER_RDSTAT =>     -- read status register....X03 = Program/erase in progress 
        if (er_cmdcounter32 >= 31) then er_cmdcounter32 <= er_cmdcounter32 - 1;
            er_cmdreg32 <= er_cmdreg32(38 downto 0) & '0';
        else
          er_data_valid_cntr <= er_data_valid_cntr + 1;
          er_rddata <= er_rddata(1) & SpiMiso;  -- deser 1:8
          if (er_data_valid_cntr = 7) then  -- Check Status after 8 bits (+1) of status read
            er_status <= er_rddata;   -- Check WE and ERASE in progress one cycle after er_rddate
            if (er_status = 0) then
              if (er_sector_count = 0) then 
                erstate <= S_ER_IDLE;   -- Done. All sectors erased
                erase_inprogress <= '0';
                spi_wr_en <= '1';
              else 
--                er_current_sector_addr <= er_current_sector_addr + SubSectorSize;
                er_current_sector_addr24 <= er_current_sector_addr24 + SubSectorSize;
                er_sector_count <= er_sector_count - 1;
                er_cmdreg32 <=  CmdWE & X"00000000";   
                er_cmdcounter32 <= "100111";
                er_SpiCsB <= '1';
                erstate <= S_ER_ASSCS1;
              end if;
            end if; -- if status
          end if;  -- if rddata valid
        end if; -- cmdcounter /= 32
   end case; 
 end if; --reset   
 end if;  -- Clk
end process processerase;

------------------------------------  Write Data to Program Pages  ----------------------              
processProgram  : process (Clk)
  begin
  if rising_edge(Clk) then
  if (reset_design = '1') then
    wrstate <= S_WR_IDLE;   -- KC705 doesn't support 4 byte mode
    SpiCsB <= '1';
    write_done <= '0';
  else
  case wrstate is 
   when S_WR_IDLE =>
        SpiCsB <= '1';
        write_done <= '0';
--        if (startaddrvalid = '1') then Current_Addr <= startaddr; end if;  -- no sync required. lots of time spent in _top
        if (startaddrvalid = '1') then Current_Addr24 <= startaddr(23 downto 0); end if;  -- no sync required. lots of time spent in _top
        if (pagecountvalid = '1') then page_count <= pagecount; end if;  -- no sync required
        if (synced_fifo_almostfull(1) = '1' and spi_wr_en = '1') then         -- some  starting point              
          dopin_ts <= "1110";
          data_valid_cntr <= "000";
          cmdcounter32 <= "100111";  -- 32 bit command
          rddata <= "00";
          cmdreg32 <=  CmdWE & X"00000000";  -- Set WE bit
          fifo_rden <= '0';
          wrdata_count <= "000";
          spi_wrdata <= X"00000000";
          wrstate <= S_WR_ASSCS1;
        end if;
                     
   when S_WR_ASSCS1 =>
        if (page_count /= 0) then 
          if (synced_fifo_almostfull(1) = '1') then
            SpiCsB <= '0';
            wrstate <= S_WR_WRCMD;
          end if;
          else 
            SpiCsB <= '0';
            wrstate <= S_WR_WRCMD;
          end if;
                 
   when S_WR_WRCMD =>    -- Set WE bit
        if (cmdcounter32 /= 32) then cmdcounter32 <= cmdcounter32 - 1;  
          cmdreg32 <= cmdreg32(38 downto 0) & '0';
        elsif (page_count /= 0) then    -- Next PP
           SpiCsB <= '1';   -- turn off SPI
--           cmdreg32 <=  CmdPP24Quad & Current_Addr;  -- Program Page at Current_Addr
           cmdreg32 <=  CmdPP24Quad & Current_Addr24 & x"00";  -- Program Page at Current_Addr
           cmdcounter32 <= "100111";
           wrstate <= S_WR_ASSCS2;
        else                             -- Done with writing Program Pages. Turn off 4 byte Mode
--           cmdcounter32 <= "100111";
--           cmdreg32 <= CmdExit4BMode & X"00000000";
--           SpiCsB <= '1';
--           wrstate <= S_EXIT4BMode_ASSCS1;        
          SpiCsB <= '1';   -- turn off SPI 
          write_done <= '1';
          wrstate <= S_WR_IDLE;   -- KC705 doesn't support 4 byte mode
        end if;
              
   when S_WR_ASSCS2 =>
        SpiCsB <= '0';   
        wrstate <= S_WR_PROGRAM;
                                                 
   when S_WR_PROGRAM =>  -- send Program command
--        if (cmdcounter32 /= 0) then cmdcounter32 <= cmdcounter32 - 1;
        if (cmdcounter32 /= 8) then cmdcounter32 <= cmdcounter32 - 1;
          cmdreg32 <= cmdreg32(38 downto 0) & '0';
        else 
          fifo_rden <= '1';
          wrstate <= S_WR_DATA;
          dopin_ts <= "0000";
        end if;
                          
   when S_WR_DATA =>
        SpiCsB <= '0';
        wrdata_count <= wrdata_count +1;
        if (wrdata_count = 7) then -- 8x4 bits from FIFO.  wrdata_count rolls over to 0
--          Current_Addr <= Current_Addr + 4;  -- 4 bytes out of 256 bytes per page   
          Current_Addr24 <= Current_Addr24 + 4;  -- 4 bytes out of 256 bytes per page   
--          if (Current_Addr(7 downto 0) = 252) then   -- every 256 bytes (1 PP) written, only check lower bits = mod 256
          if (Current_Addr24(7 downto 0) = 252) then   -- every 256 bytes (1 PP) written, only check lower bits = mod 256
            SpiCsB <= '1';
            fifo_rden <= '0';
            dopin_ts <= "1110";
            cmdreg32 <=  CmdStatus & X"00000000";  -- Read Status register next
            wrstate <= S_WR_PPDONE;  -- one PP done
          end if;
        end if;
                    
   when S_WR_PPDONE =>
        dopin_ts <= "1110";
        SpiCsB <= '0';
        data_valid_cntr <= "000";
        cmdcounter32 <= "100111";
        wrstate <= S_WR_PPDONE_WAIT;
                       
   when S_WR_PPDONE_WAIT => 
        fifo_rden <= '0';  
        if (reset_design = '1') then wrstate <= S_WR_IDLE;
        else 
          if (cmdcounter32 /= 31) then cmdcounter32 <= cmdcounter32 - 1; 
            cmdreg32 <= cmdreg32(38 downto 0) & '0';
          else -- keep reading the status register
            data_valid_cntr <= data_valid_cntr + 1;  -- rolls over to 0
            rddata <= rddata(1) & SpiMiso;  -- deser 1:8    
            if (data_valid_cntr = 7) then  -- catch status byte
              StatusDataValid <= '1';    -- copy WE and Write in progress one cycle after rddate
            else 
              StatusDataValid <= '0';
            end if;
            if (StatusDataValid = '1') then spi_status <= rddata; end if;  --  rddata valid from previous cycle
            if spi_status = 0 then    -- Done with page program
              SpiCsB <= '1';   -- turn off SPI
              cmdcounter32 <= "100111";
              cmdreg32 <=  CmdWE & X"00000000";  -- Set WE bit
              data_valid_cntr <= "000";
              StatusDataValid <= '0';
              spi_status <= "11";
              page_count <= page_count - 1;
              wrstate <= S_WR_ASSCS1;
            end if;  -- spi_status
          end if;  -- cmdcounter32
        end if;  -- reset_design
                          
-----------------   Exit 4 Byte mode ------------------------------------                  
   when S_EXIT4BMode_ASSCS1 =>
        SpiCsB <= '0';   
        wrstate <= S_EXIT4BMODE;
                                               
   when S_EXIT4BMODE =>    -- Back to 3 Byte Mode
        if (cmdcounter32 /= 32) then cmdcounter32 <= cmdcounter32 - 1;  
          cmdreg32 <= cmdreg32(38 downto 0) & '0';
        else 
          SpiCsB <= '1';   -- turn off SPI 
          write_done <= '1';
          wrstate <= S_WR_IDLE;  
        end if; 
    end case;
   end if;  --reset
   end if;  -- Clk
  end process processProgram;

MuxMosi_int: process(wrstate)   -- 1 bit command/data or 4 bit data to SPI
 begin
   case wrstate is
        when S_WR_DATA =>
          SpiMosi_int <= fifodout(0);
        when others =>
          SpiMosi_int <= cmdreg32(39);
   end case;

end process MuxMosi_int;

MuxMosi: process(CLK)   -- 1 bit command/data or 4 bit data to SPI  POR_reg
 begin
     if (erase_inprogress = '1') then SpiMosi <= er_cmdreg32(39);
     else SpiMosi <= SpiMosi_int;
     end if;
end process MuxMosi;

MuxCsB: process (Clk)
 begin
     if (erase_inprogress = '1') then SpiCsB_FFDin <= er_SpiCsB;
     else SpiCsB_FFDin <= SpiCsB;
     end if;
end process MuxCsB;

process (clk)  
  begin
    if rising_edge(clk) then  
      if (reset_design = '1') then
        synced_fifo_almostfull <= "00";
        synced_erase <= "00";
      else
          synced_fifo_almostfull <= synced_fifo_almostfull(0) & fifo_almostfull;  -- sync FIFO almostfull
          synced_erase <= synced_erase(0) & erase;
      end if;
    end if;
end process;

--------------********* misc **************---------------------
reset_design <= reset;
fifo_unconned(31 downto 0) <= data_to_fifo;
    
-- to top design. Some may require syncronizers when used   
fifofull    <= fifo_full;
fifoempty   <= fifo_empty;        -- May require synconizer when used
fifoafull   <= fifo_almostfull;   -- May require synconizer when used
fifowrerr   <= wrerr;
fiforderr   <= rderr;             -- May require synconizer when used
eraseing    <= erase_inprogress;
writedone   <= write_done;


end behavioral;




--------------------------------------   Neg edge Flop ------------------------
library ieee;
use ieee.std_logic_1164.all;
   
entity SpiCsBflop is  
   port(C, D  : in std_logic; 
        Q     : out std_logic);  
end SpiCsBflop;  

architecture flop of SpiCsBflop is  -- neg edge flop
   begin  
     process (C)  
     begin  
       if falling_edge(C) then         
          Q <= D;  
       end if;  
     end process;  
end flop;
