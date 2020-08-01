# Directional Overcurrent Relay

The Overcurrent relay characteristics can be described with the formula:

For trip-time : <br>
![formula](https://render.githubusercontent.com/render/math?math=t=TDS*(\frac{A}{M^p-1}%20%2B%20B)) <br>

For reset-time : <br>
![formula](https://render.githubusercontent.com/render/math?math=t=TDS*(\frac{t_r}{M^2-1}))

### Fixed-float types
#### Functions:
These are few utility functions implemented. The file has a function (self-implemented) to print the signals (std_logic_vectors) to ISim console while running simulations through ISE.

#### Types:
This package has a basic definition of decimal point numbers which apply to both fixed-point and floating-point numbers.

#### Fixed Package:
The v0 package implements fixed-point numbers. These are not yet made synthesizeable as they aren't needed yet in the DOCR module. The normal version is empty package, so it may be used for now.

#### Float Package:
This package has various mathematical functions implemented for calculation of tripping time and reset time of the relay. This has a (sel-implemented) synthesizeable power (exponentiation) function for calculating a float number raised to a signed-fixed number exponent.

#### Check and t-Check:
These are temporary module and test-bench for testing of implemented functions.

## References:
[SOPC design for implementation of overcurrent relay](https://ieeexplore.ieee.org/document/1632525/)
