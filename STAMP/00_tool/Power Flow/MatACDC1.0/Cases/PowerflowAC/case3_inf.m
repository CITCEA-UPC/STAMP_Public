function [baseMVA, bus, gen, branch] = case3_inf

%case 3 nodes    data for system with 3 zones consisting of 3 infinite
%   buses.
%
%   case file can be used together with dc case files "case5_stagg_....m"
%
%   MATACDC case file data provided by Jef Beerten.

%%-----  Power Flow Data  -----%%
%% system MVA base
baseMVA = 100;

%% bus data
%	bus_i	type	Pd      Qd	Gs	Bs	area	Vm      Va	baseKV	zone	Vmax	Vmin
bus = [
	2       inf       0     0	0   0   1       1.06	0	345     1       1.1     0.9;
	3       inf       0     0	0   0   1       1       0	345     2       1.1     0.9;
	5       inf       0     0	0   0   1       1       0	345     3       1.1     0.9;
];

%% generator data
%	bus	Pg      Qg	Qmax	Qmin	Vg	mBase       status	Pmax	Pmin
gen = zeros(0, 10);

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status
branch = zeros(0, 11);

return;
