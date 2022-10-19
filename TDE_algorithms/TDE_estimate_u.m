function TDE_estimate_u(IData, QData, alg)
%TDE_ESTIMATE_U: Estimate displacement using selected algorithm.

if strcmp(alg, 'scc')
    TDE_estimate_u_scc(IData, QData);

elseif strcmp(alg, 'ncc')
    TDE_estimate_u_ncc(IData, QData)

elseif strcmp(alg, 'lou')
    TDE_estimate_u_lou(IData, QData)

else
    printf("Selected algorithm does'nt exist.\n")

end
