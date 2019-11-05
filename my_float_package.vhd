
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

use work.my_types.all;
use work.my_functions.all;

package my_float_package is

--function float(sfixed)
function sqrt(arg : float) return float;
function calc_sqrt(arg_dec : float) return float;
function join_float(l,r : float) return float;


end my_float_package;

package body my_float_package is

function join_float(l,r : float) return float is
	variable high : integer := l'length + r'high;
	variable low : integer := r'low;
	variable result : float(high downto low);
begin
	result(high downto r'high+1) := l;
	result(r'high downto low) := r;
	return result;
end function join_float;

function calc_sqrt(arg_dec : float) return float is		-- 1 downto -fract_w
	constant fract_w : integer := -arg_dec'low;
	variable cntr : integer := 0;
	variable result : float(0 downto -fract_w*2) := (others => '0');
	variable divr : float(1 downto -fract_w*4) := (others => '0');				--			 ___________
	variable temp : float(1 downto -fract_w*4) := (others => '0');				--	divr	|	temp		|	result
	variable sub : float(1 downto -fract_w*4) := (others => '0');				--			  - sub
	variable index1, index2 : integer;
	function add_carry(ar : float; cin : std_logic; index : integer) return float is
			variable res : float(ar'range) := ar;
			variable c : std_logic := cin;
		begin
			if(cin = '0') then return ar; end if;
			for i in index to ar'high loop
				res(i) := ar(i) xor c;
				c := ar(i) and c;
			end loop;
			return res;
	end function add_carry;
	function "-"(l,r : float) return float is
			variable res : float(l'high downto l'low) := l;
			variable b : std_logic := '0';
		begin
--			report "subtract"; writeproc(to_slv(l),"l "); writeproc(to_slv(r),"r ");
			for i in l'low to l'high loop
				res(i) := l(i) xor r(i) xor b;
				b := (not(l(i)) and r(i)) or (not(l(i)) and b) or (r(i) and b);
--				writeproc(to_slv(res),"res ");
			end loop;
			if(b = '1') then report "borrow not 0"; end if;
			return res;
	end function "-";
	function xsrl(arg : float) return float is
			alias xarg: float(arg'left downto arg'right) is arg;
			variable result: float(arg'left downto arg'right) := (others => '0');
--			attribute synthesis_return of result : variable is "sll" ;
		begin
			result(result'left-1 downto arg'right) := xarg(arg'left downto arg'right+1);
			return result;
	end xsrl;
begin
	for i in 0 downto -fract_w*2 loop
		index1 := 2*i+1; index2 := 2*i;
		--update temp
		if(index1 >= -fract_w) then temp(index1) := arg_dec(index1); end if;
		if(index2 >= -fract_w) then temp(index2) := arg_dec(index2); end if;
--		writeproc(to_slv(temp),"temp2 " & integer'image(i) & "  ");
		--put d_i = 1 and sub_2i = 1 and check if sub > temp
		divr(i) := '1'; sub(index2) := '1';
		if(temp < sub) then
			--if sub > temp, reset d_i and sub_2i
			divr(i) := '0';
			sub(index2) := '0';
		else
			--if sub <= temp, subtract sub from temp (magnitude-only subtraction) and update divr, sub and result
--			writeproc(to_slv(temp),"temp1 ");  writeproc(to_slv(sub),"sub1 ");
			temp := temp - sub;
			sub := add_carry(sub, '1', index2);
--			writeproc(to_slv(sub),"sub2 "); -- writeproc(to_slv(divr(i downto i)),"divr_i ");
			divr := add_carry(divr, '1', i);
			result(i) := '1';
		end if;
		--rotate sub right by 1 bit
		sub := xsrl(sub);
--		writeproc(to_slv(divr),"divr "); writeproc(to_slv(result),"result "); writeproc(to_slv(sub),"sub ");
--		writeproc(to_slv(sub),"sub3 ");
	end loop;
	return result;
end function calc_sqrt;

function sqrt(arg : float) return float is
	constant exp_w : integer := arg'high;
	constant fract_w : integer := -arg'low;
	variable result : float(exp_w downto -fract_w) := (others => '0');
	variable exp : unsigned(exp_w-1 downto 0) := unsigned(to_slv(arg(exp_w-1 downto 0)));
	variable exp_base : unsigned(exp_w-1 downto 0) := (others =>'1');
	variable lsb_exp : std_logic;
	variable arg_dec : float(1 downto -fract_w) := (others => '0');
	variable sqrt_res : float(0 downto -fract_w) := (others => '0');
	function xsll(arg: float) return float is
			alias xarg: float(arg'left downto arg'right) is arg;
			variable result: float(arg'left downto arg'right) := (others => '0');
--			attribute synthesis_return of result : variable is "sll" ;
		begin
			result(arg'left downto arg'right+1) := xarg(arg'left-1 downto arg'right);
			return result;
	end xsll;
	function xsrl(arg : unsigned) return unsigned is
			alias xarg: unsigned(arg'left downto 0) is arg;
			variable result: unsigned(arg'left downto 0) := (others => '0');
--			attribute synthesis_return of result : variable is "sll" ;
		begin
			result(result'left-1 downto 0) := xarg(arg'left downto 1);
			return result;
	end xsrl;
begin
	exp_base(exp_w-1) := '0'; exp := exp - exp_base;
	lsb_exp := exp(0); exp := xsrl(exp);
	exp(exp_w-1) := exp(exp_w-2);
	exp := exp + exp_base;
	if(lsb_exp = '1' and exp(exp_w-1) = '0') then exp := exp -1; end if;
	result(exp_w-2 downto 0) := float(std_logic_vector(exp));
	arg_dec(0) := '1'; arg_dec(-1 downto -fract_w) := arg(-1 downto -fract_w);
	if(lsb_exp = '1') then arg_dec := xsll(arg_dec); end if;
	sqrt_res := calc_sqrt(arg_dec);
	result(-1 downto -fract_w) := sqrt_res(-1 downto -fract_w);
	return result;
end function sqrt;

end my_float_package;
