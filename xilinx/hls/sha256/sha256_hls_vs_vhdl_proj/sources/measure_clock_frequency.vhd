-- 
-- 
-- 
-- Copyright (C) Digisky Media Solutions Inc.  All rights reserved.
-- 
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without restriction,
-- including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software,
-- and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included
-- in all copies or substantial portions of the Software.
-- 
-- Use of the Software is limited solely to applications:
-- (a) running on a Xilinx device, or (b) that interact
-- with a Xilinx device through a bus or interconnect.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- 
-- 
-- Modified for SHA256 HLS demo test 2023/08/17
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity measure_clk_frequency is
    generic (
        C_REF_FREQ        : integer := 100000000               -- reference frequency in Hertz
--        C_PPM_THRESHOLD   : integer := 1000                    -- reference frequency in Hertz
        );
        port (
        i_reset           : in  std_logic;                     -- active high reset
        i_ref_clk         : in  std_logic;                     -- fixed reference clock
        i_meas_clk        : in  std_logic;                     -- clock to be measured
        o_meas_clk_freq   : out std_logic_vector(19 downto 0); -- frequency in kHz
        o_ten_miliseconds : out std_logic                      -- ten milisecond pulse (in ref_clk domain)
--        o_meas_clk_low    : out std_logic                      -- ten milisecond pulse (in ref_clk domain)
--        o_meas_clk_high   : out std_logic                      -- ten milisecond pulse (in ref_clk domain)
    );
end measure_clk_frequency;

architecture arch of measure_clk_frequency  is 

constant C_REF_FREQ_DIV_100_MINUS_1 : integer := C_REF_FREQ/100 - 1;

signal meas_clk_div_cnt      : std_logic_vector(3 downto 0);
signal meas_clk_div_10       : std_logic;
signal meas_clk_div_10_sync  : std_logic_vector(2 downto 0);
signal meas_clk_cnt         : std_logic_vector(19 downto 0);
signal ref_clk_cnt          : std_logic_vector(19 downto 0);
signal meas_clk_freq        : std_logic_vector(19 downto 0);
signal ten_miliseconds      : std_logic;


begin

-- divide by 10 the measured clock
process (i_meas_clk, i_reset)
begin
	if i_reset='1' then
        meas_clk_div_cnt <= (others => '0');
        meas_clk_div_10 <= '0';
    elsif rising_edge(i_meas_clk) then
        if meas_clk_div_cnt > 8 then
            meas_clk_div_cnt <= (others => '0');
        else
            meas_clk_div_cnt <= meas_clk_div_cnt + 1;
        end if;
        if meas_clk_div_cnt > 8 then
            meas_clk_div_10 <= '0';
        elsif meas_clk_div_cnt = 4 then
            meas_clk_div_10 <= '1';
        end if;
    end if;
end process;

-- sync the meas_clk_div_10 into ref_clk domain
process (i_ref_clk, i_reset)
begin
	if i_reset='1' then
        meas_clk_div_10_sync <= (others => '0');
    elsif rising_edge(i_ref_clk) then
        meas_clk_div_10_sync <= meas_clk_div_10_sync(1 downto 0) & meas_clk_div_10;
    end if;
end process;

-- process the measuring counter in ref_clk domain
process (i_ref_clk, i_reset)
begin
	if i_reset='1' then
        meas_clk_cnt <= (others => '0');
        ref_clk_cnt <= (others => '0');
        ten_miliseconds <= '0';
        meas_clk_freq <= (others => '0');
    elsif rising_edge(i_ref_clk) then

        -- reset reference clock counter every 10 ms
        if (ref_clk_cnt = C_REF_FREQ_DIV_100_MINUS_1) then
            ref_clk_cnt <= (others => '0');
        else
            ref_clk_cnt <= ref_clk_cnt + 1;
        end if;

        -- determine the 10ms tick
        if (ref_clk_cnt = C_REF_FREQ_DIV_100_MINUS_1) then
            ten_miliseconds <= '1';
        else
            ten_miliseconds <= '0';
        end if;

        -- use 10ms tick to clear the measuring counter and capture the reading as "measured frequency"
        if ten_miliseconds='1' then
            meas_clk_freq <= meas_clk_cnt;
            meas_clk_cnt <= (others => '0');
        elsif (meas_clk_div_10_sync(1) and not meas_clk_div_10_sync(2))='1' then -- rising edge
            meas_clk_cnt <= meas_clk_cnt + 1;
        end if;
    end if;
end process;

o_ten_miliseconds <= ten_miliseconds;
o_meas_clk_freq   <= meas_clk_freq;

end arch;
