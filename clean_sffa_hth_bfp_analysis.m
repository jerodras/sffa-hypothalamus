clear all;
close all;

% load tmpgit;
data_mat=readtable('sFFA_MD_BFpct_covars.csv');

%%%Data Dictionary%%%

%% data_mat ~ table holding prepared data
%% z_hth ~ z-transformed hypothalamus Mean Diffusivity
%% z_wm_md ~ z-transformed whole white matter Mean Diffusivity
%% z_sa ~ z-transformed postnatal age at scan
%% z_ga ~ z-transformed gestational age at birth
%% z_ffa ~ z-transformed average concentration of saturated free fatty acids across pregnancy
%% sexBinary ~ offspring sex
%% z_qc ~ Quality control metric, mean displacement
%% ethnicity_mom ~ categorical hispanic/non-hispanic
%% z_ses ~ z-transformed 2 factor SES score (5 item household income, maternal education)
%% OBrisk_cat ~ binary (yes/no) variable reflecting any of the following conditions: hypertension, diabetes, severe anemia, severe infection, vaginal bleeding
%% z_bf ~ z-transformed age/sex corrected body fat percentage
%% z_bfstatus ~ continuous variable reflecting amount of time spent breastfeeding

%Parsimonious linear model: manuscript equation 1
mdl = fitlm(data_mat,'PredictorVars',{'z_wm_md' 'z_sa' 'z_ga' 'z_ffa' 'sexBinary' 'z_qc'},'ResponseVar','z_hth','CategoricalVars',{'sexBinary'})
%Full linear model: including covariates of non-interest
mdl = fitlm(data_mat,'PredictorVars',{'z_wm_md' 'z_sa' 'z_ga' 'z_ffa' 'sexBinary' 'z_qc' 'ethnicity_mom' 'z_ses' 'OBrisk_cat'},'ResponseVar','z_hth','CategoricalVars',{'sexBinary' 'ethnicity_mom' 'OBrisk_cat'})

%Residualizing hypothalamic MD: manuscript equation 2a
mdl = fitlm(data_mat,'PredictorVars',{'z_wm_md' 'z_sa' 'z_ga' 'sexBinary' 'z_qc'},'ResponseVar','z_hth','CategoricalVars',{'sexBinary'});
%Residual: equivalent to manuscript equation 2b
data_mat.HTH_resid=100*mdl.Residuals.Raw;
%Z-transform for standardized beta values
data_mat.z_hth_resid=(data_mat.HTH_resid-nanmean(data_mat.HTH_resid))./nanstd(data_mat.HTH_resid);

%Parsimonious linear model: manuscript equation 2c
mdl = fitlm(data_mat,'PredictorVars',{'z_hth_resid'},'ResponseVar','z_bf')
%Full linear model: including covariates of non-interest
mdl = fitlm(data_mat,'PredictorVars',{'z_hth_resid' 'ethnicity_mom' 'z_ses' 'OBrisk_cat' 'z_bfstatus'},'ResponseVar','z_bf','CategoricalVars',{'ethnicity_mom' 'OBrisk_cat' })
