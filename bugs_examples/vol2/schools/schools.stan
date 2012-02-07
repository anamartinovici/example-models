
# Schools: ranking school examination resutls using 
# multivariate hierarcical models 
#  http://www.openbugs.info/Examples/Schools.html

## status: not work (adaption hangs, but not sure it is 
## code correctly). 

data {
  int(0,) N; 
  int(0,) M; 
  double LRT[N]; 
  int school[N]; 
  int School_denom[N, 3]; 
  int School_gender[N, 2]; 
  int VR[N, 2]; 
  double Y[N]; 
  int Gender[N]; 
  cov_matrix(3) R; 
} 

transformed data {
  vector(3) gamma_mu; 
  cov_matrix(3) gamma_Sigma; 
  gamma_mu[1] <- 0; 
  gamma_mu[2] <- 0; 
  gamma_mu[3] <- 0; 
  for (i in 1:3) for (j in 1:3) gamma_Sigma[i, j] <- 0; 
  for (i in 1:3) gamma_Sigma[i, i] <- 100; 
} 

parameters {
  double beta[8]; 
  vector(3) alpha[M]; 
  vector(3) gamma; 
  cov_matrix(3) Sigma; 
  double theta; 
  double phi; 
} 


transformed parameters {
  double alpha1[M]; 
  for (m in 1:M)  alpha1[m] <- alpha[m, 1]; 
} 


model {
  for(p in 1:N) {
     Y[p] ~ normal(alpha[school[p], 1] + alpha[school[p], 2] * LRT[p] + 
                   alpha[school[p], 3] * VR[p, 1] + beta[1] * LRT[p] * LRT[p] + 
                   beta[2] * VR[p, 2] + beta[3] * Gender[p] + 
                   beta[4] * School_gender[p, 1] + beta[5] * School_gender[p, 2] + 
                   beta[6] * School_denom[p, 1] + beta[7] * School_denom[p, 2] + 
                   beta[8] * School_denom[p, 3],  exp(-.5 * (theta + phi * LRT[p]))); 
  }
  // min.var <- exp(-(theta + phi * (-34.6193))) # lowest LRT score = -34.6193
  // max.var <- exp(-(theta + phi * (37.3807)))  # highest LRT score = 37.3807

  # Priors for fixed effects:
  beta ~ normal(0, 100); 
  // for (k in 1:8)  beta[k] ~ normal(0.0, 100); 
  theta ~ normal(0.0, 100); 
  phi ~ normal(0.0, 100); 

  # Priors for random coefficients:
  for (m in 1:M) alpha[m] ~ multi_normal(gamma, Sigma); 

  # Hyper-priors:
  gamma ~ multi_normal(gamma_mu, gamma_Sigma); 
  Sigma ~ inv_wishart(3, R); 
}

