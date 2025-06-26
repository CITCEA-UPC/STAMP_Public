% DEFINE NAMES OF GLOBAL VARIABLES TO BE IMPORTED BY THE REST OF THE FILES

% In case you are here thinking it is better to work with a struct the
% answer is NO. I tried, and it is a nightmare to make sure you are
% updating the tables inside the struct.

global T_global T_NET T_DC_NET T_trafo T_load T_shunt T_TH T_SG T_VSC T_IPC T_b2b T_user T_PF T_PF_DC
global T_NET_0 T_DC_NET_0 T_trafo_0 T_load_0 T_shunt_0 T_TH_0 T_SG_0 T_VSC_0 T_MMC_0 T_user_0 T_PF_0
global T_nodes

% This to be deleted once T_MMC NAMES & T_STATCOM have been replaced in old scripts
global T_MMC_Pac_GFll T_MMC_Vdc_GFll T_STATCOM