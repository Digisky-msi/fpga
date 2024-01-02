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
library ieee;
Library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use UNISIM.vcomponents.all;

entity spi_rev_sel_k7 is
  port   (
    spiclk            : in  std_logic;
    reset             : in  std_logic;
    iSelect           : in  std_logic;
    oSys_rst          : out std_logic;
    oWR_done          : out std_logic;

    SPI_CS_L  : out std_logic;    -- 7 series directly deal with pins at fabric, not at STARTUP
    SPI_Q0    : inout std_logic;
    SPI_Q1    : inout std_logic;
    SPI_Q2    : inout std_logic;
    SPI_Q3    : inout std_logic

  );
end spi_rev_sel_k7;

architecture behavioral of spi_rev_sel_k7 is

  component brambitstream 
  port  (
    sysclk            : in  std_logic;
    bram_rd_en        : in  std_logic; 
    bramblkaddr       : in  std_logic_vector(8 downto 0); 
    bramaddrvalid     : in  std_logic;         
    dout              : out std_logic_vector(31 downto 0);
    bramrddone        : out std_logic     
  );
  end component brambitstream;

  component spiflashprogrammer_v2_k7 is
  generic (DEBUG : string := "FALSE");
  port  (
    Clk               : in std_logic;
    fifoclk           : in std_logic;
    data_to_fifo      : in std_logic_vector(31 downto 0);
    startaddr         : in std_logic_vector(31 downto 0);
    startaddrvalid    : in std_logic;
    pagecount         : in std_logic_vector(16 downto 0);
    pagecountvalid    : in std_logic;
    sectorcount       : in std_logic_vector(13 downto 0);
    sectorcountvalid  : in std_logic;
    fifowren          : in Std_logic;
    fifofull          : out std_logic;
    fifoempty         : out std_logic;
    fifoafull         : out std_logic;
    fifowrerr         : out std_logic;
    fiforderr         : out std_logic;
    writedone         : out std_logic;
    reset             : in  std_logic;
    erase             : in std_logic;
    eraseing          : out std_logic; 

    SPI_CS_L  : out std_logic;    -- 7 series directly deal with pins at fabric, not at STARTUP
    SPI_Q0    : inout std_logic;
    SPI_Q1    : inout std_logic;
    SPI_Q2    : inout std_logic;
    SPI_Q3    : inout std_logic

   ); 
  end component spiflashprogrammer_v2_k7;

  component iprog_icap  
  port  (
    go   : in  std_logic;
    clk  : in  std_logic
     
  );
  end component iprog_icap; 
  
  signal bram_rd_addr     : std_logic_vector(3 downto 0) := X"0";
  signal bramdata         : std_logic_vector(31 downto 0) := X"00000000";
  signal bramrden         : std_logic := '0';  
  signal bramrddone       : std_logic := '0';
  signal spidone          : std_logic := '1';
  signal erasingspi       : std_logic := '0';
  signal init_counter     : std_logic_vector(15 downto 0) := x"0000";
  signal starterase       : std_logic := '0';
  signal fifowren         : std_logic := '0';
  signal sys_reset        : std_logic := '1';
  signal trigsw           : std_logic := '0';
  signal progstart1       : std_logic := '0';
    
--  type init is
--  (
--    S_INIT, S_WAIT, S_ERASE, S_DATA, S_IDLE
--  );
--  signal download_state   : init := S_INIT;
constant S_INIT : std_logic_vector(4 downto 0) := "00001";
constant S_WAIT : std_logic_vector(4 downto 0) := "00010";
constant S_ERASE : std_logic_vector(4 downto 0) := "00100";
constant S_DATA : std_logic_vector(4 downto 0) := "01000";
constant S_IDLE : std_logic_vector(4 downto 0) := "10000";

signal download_state : std_logic_vector(4 downto 0) := S_INIT;
   
begin


  brambitstream_inst: brambitstream port map
  (
    sysclk        => spiclk,
    bram_rd_en    => bramrden,
    bramblkaddr   => '0' & bram_rd_addr & X"0",
    bramaddrvalid => starterase,  
    dout          => bramdata,
    bramrddone    => bramrddone
  );
  
  -- Standard instantiation. Block could be simplified for this use case     
  spiflashprogrammer_inst: spiflashprogrammer_v2_k7
  port map
  (
    Clk => spiclk,
    fifoclk           => spiclk,
    data_to_fifo      => bramdata,
    startaddr         =>  x"00000000",
    startaddrvalid    => '1',
    pagecount         =>  '0' & x"0001",
    pagecountvalid    => '1',
    sectorcount       => "00" & x"000",
    sectorcountvalid  => '1',
    fifowren          => fifowren,
    fifofull          => open,
    fifoempty         => open,
    fifoafull         => open,
    fifowrerr         => open,
    fiforderr         => open,
    writedone         => spidone,
    reset             => reset,
    erase             => starterase,
    eraseing          => erasingspi,   

    SPI_CS_L  =>  SPI_CS_L, -- 7 series directly deal with pins at fabric, not at STARTUP
    SPI_Q0    =>  SPI_Q0  ,
    SPI_Q1    =>  SPI_Q1  ,
    SPI_Q2    =>  SPI_Q2  ,
    SPI_Q3    =>  SPI_Q3  

  );

  -- Comment out the below if automatic reboot (PROG) of the FPGA is not desired
  iprog_icap_inst: iprog_icap  port map
  (
    go   => spidone,
    clk  => spiclk
  ); 
  
  process (spiclk) 
  begin
    if rising_edge(spiclk) then  
      if (reset = '1') then
        download_state <= S_INIT;
        init_counter <= x"0000";
        fifowren <= '0';
        bramrden <= '0';
        sys_reset <= '1';
        starterase <= '0';
      else
      case download_state is 
        when S_INIT =>
              fifowren <= '0';
              bramrden <= '0';
              sys_reset <= '1';
              if init_counter = x"FFFF" then    -- adjust wait 2ms for input pin stable after power up
                init_counter <= x"0000";
                if (iSelect = '1') then   -- depends on build option, use '1' or '0'
                  starterase <= '1';
                  bram_rd_addr <= X"4";   -- depends on build option, use "4" or "0"
                  download_state <= S_WAIT;
                else
                  download_state <= S_IDLE;
                end if;
              else
                init_counter <= init_counter +1;
              end if;
              
        when S_WAIT =>          -- wait a few clk cycles for the erase signal to synchronize
              if init_counter = 15 then    -- adjust wait to BRAM read clk if needed
                init_counter <= x"0000";
                download_state <= S_ERASE;
              else
                init_counter <= init_counter +1;
              end if;
             
        when S_ERASE =>  
              if (erasingspi = '0') then 
                starterase <= '0'; 
                bramrden <= '1';           -- start BRAM address counter
                download_state <= S_DATA;
              end if; 
                 
        when S_DATA =>
              fifowren  <= '1';
              if (bramrddone = '1') then
                fifowren <= '0';
                bramrden <= '0';
                init_counter <= x"0000";
                download_state <= S_IDLE;
              end if;
              
        when S_IDLE =>
              sys_reset <= '0';
              
        when others =>
              download_state <= S_INIT;
      end case;
      end if; --reset
    end if;  -- clk
  end process;
  
  oSys_rst <= sys_reset;
  oWR_done <= spidone;


end architecture behavioral;
