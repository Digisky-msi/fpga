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

package sha256_types is

	-- Type for storing the expanded message blocks, W_j:
	type expanded_message_block_array is array(0 to 63) of std_logic_vector(31 downto 0);

	-- Type for storing the constant array, K_j:
	type constant_array is array(0 to 63) of std_logic_vector(31 downto 0);

end package;
