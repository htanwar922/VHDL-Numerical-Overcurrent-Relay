
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.my_functions.all;
use work.my_types.all;

package my_float_package is

type float_vec is (pos,neg,zero,zero_neg,inf,inf_neg,nan,empty);

--unary functions
function check_float(arg : float) return float_vec;
function "abs"(arg : float) return float;
function "-"(arg : float) return float;
function sqrt(arg : float) return float;
function sq(arg : float) return float;

--binary functions
function "+"(l,r : float) return float;
function "-"(l,r : float) return float;
function "*"(l,r : float) return float;
function "/"(l,r : float) return float;
function "="(l,r : float) return boolean;
function pow(arg : float; p : sfixed) return float;

--fraction-only functions
function round_fract(arg : float; index : integer; ch : choice := 0) return float;

--other functions and procedures
procedure print(arg : in float; ch : choice := 0);

end my_float_package;

--=================================================================================================================================================

package body my_float_package is

--type logic_ux01z_table is array (std_ulogic'low to std_ulogic'high) of ux01z;
--constant cvt_to_ux01z : logic_ux01z_table := (
--                         'U',  -- 'U'
--                         'X',  -- 'X'
--                         '0',  -- '0'
--                         '1',  -- '1'
--                         'Z',  -- 'Z'
--                         'X',  -- 'W'
--                         '0',  -- 'L'
--                         '1',  -- 'H'
--                         'X'   -- '-'
--                        );


function spcl_float(arg : float_vec; high : integer; low : integer) return float is
	variable result : float(high downto low) := (others => '0');
begin
	case arg is
		when zero		=>
		when zero_neg	=> return ('1' & result(high-1 downto low));
		when inf			=> result(high-1 downto 0) := (others => '1');
		when inf_neg	=> result(high downto 0) := (others => '1');
		when pos			=> result(high-2 downto 0) := (others => '1');
		when neg			=> result(high) := '1'; result(high-2 downto 0) := (others => '1');
		when nan			=> result := (others => '1');
		-- rtl_synthesis off
		when empty		=> return decimal(null_vec);
		-- rtl_synthesis on
		when others		=> result := (others => 'Z');
	end case;
	return result;
end function spcl_float;


function spcl_float(arg : float_vec; size_float : float) return float is
begin
	return spcl_float(arg,size_float'high,size_float'low);
end function spcl_float;


function check_float(arg : float) return float_vec is
begin
	if(arg'length = 0) then return empty;
	elsif(arg = spcl_float(zero,arg)) then return zero;
	elsif(arg = spcl_float(zero_neg,arg)) then return zero_neg;
	elsif(arg = spcl_float(inf,arg)) then return inf;
	elsif(arg = spcl_float(inf_neg,arg)) then return inf_neg;
	elsif(and_reduce(arg(arg'high-1 downto 0))='1' and or_reduce(arg(-1 downto arg'low))/='0') then return nan;	-- exp all '1' fract not all '0' case
	elsif(not(check_uxz(arg))) then
		if(arg(arg'high)='0') then return pos;
		else return neg;
		end if;
	else return nan;
	end if;
end function check_float;


function "abs"(arg : float) return float is
	variable result : float(arg'range);
begin
	result := '0' & arg(arg'high-1 downto arg'low);
	return result;
end function "abs";


function "-"(arg : float) return float is
begin
	return ((not(arg(arg'left))) & arg(arg'left-1 downto arg'right));
end function "-";


function "+"(l,r : float) return float is
	variable exp_w		: integer := l'high;
	variable fract_w 	: integer := -l'low;
	variable exp_base : unsigned(exp_w-2 downto 0) := (others => '1');
	variable l_exp		: unsigned(l'high-1 downto 0) := to_unsigned(l(l'high-1 downto 0));
	variable r_exp		: unsigned(r'high-1 downto 0) := to_unsigned(r(r'high-1 downto 0));
	variable d_exp		: integer := 0;
	variable l_smg		: smg(fract_w+1 downto 0) := smg("01" & to_unsigned(l(-1 downto l'low)));
	variable r_smg		: smg(fract_w+1 downto 0) := smg("01" & to_unsigned(r(-1 downto l'low)));
	variable res_smg	: smg(fract_w+2 downto 0);
	variable result 	: float(exp_w downto -fract_w);
begin
	-- rtl_synthesis off
	if(not(cleanvec(l,r))) then report "function ""+"" of " & my_float_package'instance_name; return decimal(null_vec); end if;
	-- rtl_synthesis on
	
	if(check_float(abs(l))=zero) then return r;
	elsif(check_float(abs(r))=zero) then return l;
	elsif(check_float(abs(l))=inf) then report "left argument inf/inf_neg in function ""+/-"" of " & my_float_package'instance_name severity warning; return (l(l'left) & spcl_float(inf,result)(result'high-1 downto result'low));
	elsif(check_float(abs(r))=inf) then report "right argument inf/inf_neg in function ""+/-"" of " & my_float_package'instance_name severity warning; return (r(r'left) & spcl_float(inf,result)(result'high-1 downto result'low));
	-- rtl_synthesis off
	elsif(check_float(abs(l))=nan or check_float(abs(l))=empty) then report "left argument nan or empty in function ""+/-"" of " & my_float_package'instance_name severity error; return decimal(null_vec);
	elsif(check_float(abs(r))=nan or check_float(abs(r))=empty) then report "right argument nan or empty in function ""+/-"" of " & my_float_package'instance_name severity error; return decimal(null_vec);
	-- rtl_synthesis on
	end if;
	
	if(l=-r) then return spcl_float(zero,l); end if;
	if(l_exp > r_exp) then
		d_exp := to_integer(l_exp)-to_integer(r_exp);
		r_smg := (r_smg srl d_exp);
		result(exp_w-1 downto 0) := to_decimal(l_exp(exp_w-1 downto 0));
	else
		d_exp := to_integer(r_exp)-to_integer(l_exp);
		l_smg := (l_smg srl d_exp);
		result(exp_w-1 downto 0) := to_decimal(r_exp(exp_w-1 downto 0));
	end if;
	l_smg(l_smg'left) := l(l'high);
	r_smg(r_smg'left) := r(r'high);
	res_smg := add_smg(l_smg,r_smg);
	result(result'left) := res_smg(res_smg'left);
	if(res_smg(res_smg'left-1)='1') then
		result(exp_w-1 downto 0) := float(to_unsigned(result(exp_w-1 downto 0)) + 1);
		res_smg := "srl"(res_smg,1);
	end if;
	result(-1 downto -fract_w) := to_decimal(res_smg(fract_w-1 downto 0));
	if(and_reduce(result(exp_w-1 downto 0))='1') then report "overflow detected in result of function ""+/-"" of " & my_float_package'instance_name severity warning; end if;
	return result;
end function "+";


function "-"(l,r : float) return float is
	variable xr : float(r'range) := -r;
begin
	-- rtl_synthesis off
	if(not(cleanvec(l,r))) then report "function ""-"" of " & my_float_package'instance_name; return decimal(null_vec); end if;
	-- rtl_synthesis on
	return (l+xr);
end function "-";


function "*"(l,r : float) return float is
	variable exp_w		: integer := l'high;
	variable fract_w 	: integer := -l'low;
	variable exp		: unsigned(exp_w downto 0) := (others => '0');
	variable exp_base : unsigned(exp_w-2 downto 0) := (others => '1');
	variable temp_base: unsigned(exp_w-1 downto 0) := (others => '1');
	variable l_exp		: unsigned(l'high downto 0) := to_unsigned('0' & l(l'high-1 downto 0));
	variable r_exp		: unsigned(r'high downto 0) := to_unsigned('0' & r(r'high-1 downto 0));
	variable l_uns		: unsigned(fract_w downto 0) := unsigned("1" & to_unsigned(l(-1 downto l'low)));
	variable r_uns		: unsigned(fract_w downto 0) := unsigned("1" & to_unsigned(r(-1 downto l'low)));
	variable res_uns	: unsigned(2*fract_w+1 downto 0);
	variable result 	: float(l'range) := (others => '0');
begin
	-- rtl_synthesis off
	if(not(cleanvec(l,r))) then report "function ""*"" of " & my_float_package'instance_name; return decimal(null_vec); end if;
	-- rtl_synthesis on
	result(result'left) := l(l'left) xor r(r'left);
	
	if(check_float(abs(l))=zero or check_float(abs(r))=zero) then return (result(result'left) & spcl_float(zero,result)(result'high-1 downto result'low));
	elsif(check_float(abs(l))=inf) then report "left argument inf/inf_neg in function ""*"" of " & my_float_package'instance_name severity warning; return (result(result'left) & spcl_float(inf,result)(result'high-1 downto result'low));
	elsif(check_float(abs(r))=inf) then report "right argument inf/inf_neg in function ""*"" of " & my_float_package'instance_name severity warning; return (result(result'left) & spcl_float(inf,result)(result'high-1 downto result'low));
	-- rtl_synthesis off
	elsif(check_float(abs(l))=nan or check_float(abs(l))=empty) then report "left argument nan or empty in function ""*"" of " & my_float_package'instance_name severity error; return decimal(null_vec);
	elsif(check_float(abs(r))=nan or check_float(abs(r))=empty) then report "right argument nan or empty in function ""*"" of " & my_float_package'instance_name severity error; return decimal(null_vec);
	-- rtl_synthesis on
	end if;
	
	res_uns := l_uns*r_uns;
	exp := exp + l_exp + r_exp - exp_base + ("0" & res_uns(res_uns'left));
	
	if(exp >= temp_base) then
		result(exp_w-1 downto 0) := (others => '1');
		report "overflow in result of function ""*"" of " & my_float_package'instance_name severity warning;
		return result;
	end if;
	
	if(res_uns(res_uns'left)='1') then res_uns := (res_uns srl 1); end if;
	result := result(result'left) & to_decimal(exp(exp'high-1 downto 0) & res_uns(res_uns'high-1-1 downto res_uns'high-1-fract_w));
	return result;
end function "*";


function "/"(l,r : float) return float is
	variable exp_w		: integer := l'high;
	variable fract_w 	: integer := -l'low;
	variable exp		: unsigned(exp_w downto 0) := (others => '0');
	variable exp_base : unsigned(exp_w-2 downto 0) := (others => '1');
	variable l_exp		: unsigned(l'high-1 downto 0) := to_unsigned(l(l'high-1 downto 0));
	variable r_exp		: unsigned(r'high-1 downto 0) := to_unsigned(r(r'high-1 downto 0));
	variable l_uns		: unsigned(fract_w+1 downto 0) := unsigned("01" & to_unsigned(l(-1 downto l'low)));
	variable r_uns		: unsigned(fract_w downto 0) := unsigned("1" & to_unsigned(r(-1 downto l'low)));
	variable res		: decimal(0 downto -fract_w) := (others => '0');
	variable result 	: float(l'range) := (others => '0');
begin
	-- rtl_synthesis off
	if(not(cleanvec(l,r))) then report "function ""/"" of " & my_float_package'instance_name; return decimal(null_vec); end if;
	-- rtl_synthesis on
	result(result'left) := l(l'left) xor r(r'left);
	
	if(check_float(abs(l))=zero) then return (result(result'left) & spcl_float(zero,result)(result'high-1 downto result'low));
	elsif(check_float(abs(r))=zero) then report "right argument zero/zero_neg in function ""/"" of " & my_float_package'instance_name severity warning; return (result(result'left) & spcl_float(inf,result)(result'high-1 downto result'low));
	elsif(check_float(abs(l))=inf) then report "left argument inf/inf_neg in function ""/"" of " & my_float_package'instance_name severity warning; return (result(result'left) & spcl_float(inf,result)(result'high-1 downto result'low));
	elsif(check_float(abs(r))=inf) then return (result(result'left) & spcl_float(zero,result)(result'high-1 downto result'low));
	-- rtl_synthesis off
	elsif(check_float(abs(l))=nan or check_float(abs(l))=empty) then report "left argument nan or empty in function ""/"" of " & my_float_package'instance_name severity error; return decimal(null_vec);
	elsif(check_float(abs(r))=nan or check_float(abs(r))=empty) then report "right argument nan or empty in function ""/"" of " & my_float_package'instance_name severity error; return decimal(null_vec);
	-- rtl_synthesis on
	end if;
	
	exp := '0' & l_exp;
	exp := exp - r_exp; 
	exp := exp + exp_base;
	if(l_uns < r_uns) then
		exp := exp - to_unsigned(1,exp'length);
		l_uns := l_uns sll 1;
	end if;
	result(exp_w-1 downto 0) := to_decimal(exp)(exp_w-1 downto 0);
	
	for i in 0 downto -fract_w loop
		if(l_uns >= r_uns) then
			res(i) := '1';
			l_uns := l_uns - r_uns;
		end if;
		l_uns := l_uns sll 1;
	end loop;
	
	result(-1 downto -fract_w) := res(-1 downto -fract_w);
	if(and_reduce(result(exp_w-1 downto 0))='1') then report "overflow detected in result of function ""/"" of " & my_float_package'instance_name severity warning; end if;
	return result;	
end function "/";

function "="(l,r : float) return boolean is
begin
	return (to_slv(l) = to_slv(r));
end function "=";


function sqrt(arg : float) return float is
	variable exp_w		: integer := arg'high;
	variable fract_w 	: integer := -arg'low;
	variable exp_base : unsigned(exp_w-2 downto 0) := (others => '1');
	variable res_exp	: unsigned(arg'high downto 0) := "0" & to_unsigned(arg(arg'high-1 downto 0));
	variable zeros		: unsigned(fract_w-1 downto 0) := (others => '0');
	variable arg_uns	: unsigned(2*fract_w+1 downto 0) := "01" & to_unsigned(arg(-1 downto arg'low)) & zeros;
	variable temp 		: unsigned(2*fract_w+1 downto 0) := (others => '0');
	variable temp_one	: unsigned(2*fract_w+1 downto 0) := (others => '0');
	variable res		: decimal(0 downto -fract_w) := (others => '0');
	variable result 	: float(arg'range) := (others => '0');
begin
	
	if(check_float(abs(arg))=zero) then return spcl_float(zero,result);
	elsif(check_float(arg)=inf) then return spcl_float(inf,result);	-- not for inf_neg
	-- rtl_synthesis off
	elsif(check_float(abs(arg))=nan or check_float(abs(arg))=empty) then report "argument nan or empty in function sqrt of " & my_float_package'instance_name severity error; return decimal(null_vec);
	-- rtl_synthesis on
	elsif(arg(arg'high)='1') then assert false report "negative arg in function sqrt of " & my_float_package'instance_name severity error;
	end if;
	
	res_exp := res_exp - exp_base;		
	if(res_exp(0)='1') then
		arg_uns := arg_uns sll 1;
	end if;
	res_exp := res_exp srl 1;
	res_exp := res_exp + exp_base;
	result(exp_w-1 downto 0) := to_decimal(res_exp(exp_w-1 downto 0)); 
	
	temp_one(2*fract_w) := '1';
	for i in res'range loop
		if(arg_uns >= temp + temp_one) then
			temp := temp + temp_one;			-- to be subtracted from dividend
			arg_uns := arg_uns - temp;
			res(i) := '1';							-- append '1' if true, else '0'
			temp := temp + temp_one;			-- add appended (in result) to divisor if the former is '1'
		end if;
		temp := temp srl 1;
		temp_one := temp_one srl 2;
	end loop;
	
	result(-1 downto -fract_w) := res(-1 downto -fract_w);
	if(and_reduce(result(exp_w-1 downto 0))='1') then report "overflow detected in result of function sqrt of " & my_float_package'instance_name severity warning; end if;
	return result;
end function sqrt;


function sq(arg : float) return float is
begin
	return arg*arg;
end function sq;


function pow(arg : float; p : sfixed) return float is
	variable exp_w		: integer := arg'high;
	variable fract_w 	: integer := -arg'low;
	variable exp_base : unsigned(exp_w-2 downto 0) := (others => '1');
	variable int_w		: integer := p'high-1;
	variable next_mult: float(arg'range);
	variable res_int	: float(arg'range) := (others => '0');
	variable res_fract: float(arg'range) := (others => '0');
	variable result	: float(arg'range) := (others => '0');
begin
	if(check_float(abs(arg))=zero) then return spcl_float(zero,result);
	elsif(check_float(arg)=inf) then return spcl_float(inf,result);	-- not for inf_neg
	-- rtl_synthesis off
	elsif(check_float(abs(arg))=nan or check_float(abs(arg))=empty) then report "argument nan or empty in function pow of " & my_float_package'instance_name severity error; return decimal(null_vec);
	-- rtl_synthesis on
	elsif(arg(arg'high)='1') then assert false report "negative arg in function pow of " & my_float_package'instance_name severity error;
	end if;
	
	if(p(p'high)='0') then
		-- integral power
		next_mult := arg;
		res_int(exp_w-2 downto 0) := (others => '1');
		for i in 0 to int_w loop
			if(p(i)='1') then res_int := res_int * next_mult; end if;
			next_mult := sq(next_mult);
		end loop;
		
		-- fractional power
		next_mult := sqrt(arg);
		res_fract(exp_w-2 downto 0) := (others => '1');
		for i in -1 downto p'low loop
			if(p(i)='1') then res_fract := res_fract * next_mult; end if;
			next_mult := sqrt(next_mult);
		end loop;
		
		-- final result
		result := res_int * res_fract;
	end if;
	if(and_reduce(result(exp_w-1 downto 0))='1') then report "overflow detected in result of function pow of " & my_float_package'instance_name severity warning; end if;
	return result;
end function pow;

---------------------------------------------------------------------------------------------------------------

function round_fract(arg : float; index : integer; ch : choice := 0) return float is
	variable inc1		: float(arg'high downto index) := (index => '1', others => '0');
	variable inc2		: float(arg'range) := (index => '1', others => '0');
	variable result1	: float(arg'high downto index) := (others => '0');
	variable result2	: float(arg'range) := (others => '0');
begin
	if(ch=0) then
		result1 := arg(arg'high downto index) + inc1;
		return result1;
	else
		result2 := arg + inc2;
		return result2;
	end if;
end function round_fract;

---------------------------------------------------------------------------------------------------------------

procedure print(arg : in float; ch : choice := 0) is
	variable exp	: integer;
	variable num	: integer;
	variable fract	: integer;
--	variable fract_w
	variable exp_base : signed(arg'high-1 downto 0) := (others => '1');
begin
	exp_base(exp_base'high) := '0';
	exp := to_integer(to_signed(arg(arg'high-1 downto 0)) - exp_base);
	num := to_integer(to_signed(arg(arg'high) & "1" & arg(-1 downto arg'low)));
	if(ch = 0) then
		if(exp > 0) then
			report integer'image(num);
			num := num * (2 ** exp);
		elsif(exp < 0) then
			num := num / (2 ** exp);
		end if;
		report integer'image(num);
		fract := (num mod (2 ** (-arg'low))) * (10 ** (-arg'low * 1000 / 2303)) / (2 ** (-arg'low));
		num := num / (2 ** (-arg'low));
		report "float (ch=0) is " & integer'image(num) & ".x" & integer'image(fract);
	else
		fract := (num mod (2 ** (-arg'low))) * (10 ** (-arg'low * 1000 / 2303)) / (2 ** (-arg'low));
		num := num / (2 ** (-arg'low));
		report "float (ch=1) is " & integer'image(num) & ".x" & integer'image(fract) & " * 2^" & integer'image(exp);
	end if;
end procedure print;

end my_float_package;
