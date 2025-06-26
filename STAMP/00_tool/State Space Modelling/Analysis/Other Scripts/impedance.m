% SPLITS SYSTEM AT B2B 

%   MMC-Pac ---------------------------------------------------------------
nodeAC = T_MMC_Pac_GFll.NodeAC;
number = T_MMC_Pac_GFll.Number;
T_MMC = T_MMC_Pac_GFll;
SS_nus2_imped = build_sum_currents_trafoVSC(nodeAC, number);
MMC_trafo2_imped = build_MMC_trafo_trafoVSC(nodeAC, number,T_MMC.f, T_MMC.Rtrafo, T_MMC.Ltrafo); 

%   MMC-Vdc ---------------------------------------------------------------
nodeAC = T_MMC_Vdc_GFll.NodeAC;
number = T_MMC_Vdc_GFll.Number;
T_MMC = T_MMC_Vdc_GFll;
SS_nus3_imped = build_sum_currents_trafoVSC(nodeAC, number);
MMC_trafo3_imped = build_MMC_trafo_trafoVSC(nodeAC, number,T_MMC.f, T_MMC.Rtrafo, T_MMC.Ltrafo); 




FINF = 0.1;
FSUP = 1000;
STEP = 0.05;

% Split at  b2b
ss_ysystem = connect(Vdc_GFll_MMC, Pac_GFll_MMC, DC_NET, MMC_trafo2_imped, MMC_trafo3_imped, SS_nus2_imped, SS_nus3_imped, {'NET.vn2q' 'NET.vn2d' 'NET.vn3q' 'NET.vn3d'}, {'NET.iq2' 'NET.id2' 'NET.iq3' 'NET.id3'});
ss_zsystem = connect(T_SG.ss{:}, T_Rsnub.ss{:}, NET.SS, T_STATCOM.ss{:}, SS_nus2, SS_nus3, {'NET.vn2q' 'NET.vn2d' 'NET.vn3q' 'NET.vn3d'}, {'NET.iq2' 'NET.id2' 'NET.iq3' 'NET.id3'});
                                                
DERROR   = 1E10;   

figure
lbd = FCLFRYY(ss_ysystem,ss_zsystem,FINF,FSUP,STEP,DERROR,'Z','NYQ',1);  

