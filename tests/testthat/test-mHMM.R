context("function mHMM and S3 print and summary methods")


################
### CREATE OUTPUT OBJECTS TO TEST
################

## general properties tested model
n_t <- 100
n <- 10
m <- 3
J = 11
burn_in = 5
n_dep <- 2
q_emiss <- c(4,2)

gamma <- matrix(c(0.8, 0.1, 0.1,
                  0.2, 0.6, 0.2,
                  0.1, 0.2, 0.7), ncol = m, byrow = TRUE)
emiss_distr <- list(matrix(c(0.5, 0.5, 0.0, 0.0,
                        0.1, 0.1, 0.8, 0.0,
                        0.1, 0.1, 0.2, 0.6), nrow = m, ncol = q_emiss[1], byrow = TRUE),
                    matrix(c(0.7, 0.3,
                             0.9, 0.1,
                             0.8, 0.2), nrow = m, ncol = q_emiss[2], byrow = TRUE)
                )

set.seed(4231)
data_sim <- sim_mHMM(n_t = n_t, n = n, gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss), gamma = gamma,
                  emiss_distr = emiss_distr, var_gamma = .5, var_emiss = c(.5, 0.5))
colnames(data_sim$obs) <- c("subj", "output_1", "output_2")

# Fit the mHMM on 2 dep variable data
set.seed(3523)
out_2st_simb <- mHMM(s_data = data_sim$obs,
                     gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                     start_val = c(list(gamma), emiss_distr),
                     mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE)


##### Create model with covariates
xx <- rep(list(matrix(1, ncol = 1, nrow = n)), (n_dep + 1))
for(i in 2:(n_dep + 1)){
  xx[[i]] <- cbind(xx[[i]], nonverbal_cov$std_CDI_change)
}
set.seed(3523)
out_2st_sim_cov1 <- mHMM(s_data = data_sim$obs, xx = xx,
                     gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                     start_val = c(list(gamma), emiss_distr),
                     mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE)

xx_gamma_only <- rep(list(matrix(1, ncol = 1, nrow = n)), (n_dep + 1))
xx_gamma_only[[1]] <- cbind(xx_gamma_only[[i]], nonverbal_cov$std_CDI_change)
set.seed(3523)
out_2st_sim_cov2 <- mHMM(s_data = data_sim$obs, xx = xx_gamma_only,
                         gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                         start_val = c(list(gamma), emiss_distr),
                         mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE)

xx_gamma_only_V2 <- rep(list(NULL),  (n_dep + 1))
xx_gamma_only_V2[[1]] <- cbind(rep(1,n), nonverbal_cov$std_CDI_change)
set.seed(3523)
out_2st_sim_cov3 <- mHMM(s_data = data_sim$obs, xx = xx_gamma_only_V2,
                         gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                         start_val = c(list(gamma), emiss_distr),
                         mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE)

xx_dep1_only <- rep(list(matrix(1, ncol = 1, nrow = n)), (n_dep + 1))
xx_dep1_only[[2]] <- cbind(xx_dep1_only[[i]], nonverbal_cov$std_CDI_change)
set.seed(3523)
out_2st_sim_cov4 <- mHMM(s_data = data_sim$obs, xx = xx_dep1_only,
                         gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                         start_val = c(list(gamma), emiss_distr),
                         mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE)

xx_wrong1 <- rep(list(NULL),  (n_dep + 1))
for(i in 2:(n_dep + 1)){
  xx_wrong1[[i]] <- matrix(nonverbal_cov$std_CDI_change, ncol = 1)
}
xx_wrong2 <- rep(list(NULL),  (n_dep + 1))
xx_wrong2[[1]] <- matrix(nonverbal_cov$std_CDI_change, ncol = 1)
xx_wrong3 <- list(cbind(rep(1,n), nonverbal_cov$std_CDI_change))
xx_wrong4 <- cbind(rep(1,n), nonverbal_cov$std_CDI_change)
xx_wrong5 <- rep(list(NULL),  (n_dep + 1))
xx_wrong5[[1]] <- cbind(rep(1,n), c(rep(2,n/2), rep(1, n/2)))
xx_wrong6 <- rep(list(NULL),  (n_dep + 1))
xx_wrong6[[1]] <- data.frame(rep(1,n), as.factor(c(rep(2,n/2), rep(1, n/2))))

####################
## TESTING
###############


test_that("errors mHMM input", {
  expect_error(mHMM(s_data = data_sim$obs,
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = list(gamma, list(emiss_distr)),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "number of elements in the list start_val")
  expect_error(mHMM(s_data = data.frame(data_sim$obs[,1], as.factor(data_sim$obs[,2]), data_sim$obs[,3]),
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = c(list(gamma), emiss_distr),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "factorial variables")
  expect_error(mHMM(s_data = data_sim$obs, xx = xx_wrong1,
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = c(list(gamma), emiss_distr),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "first column in each element of xx has to represent the intercept")
  expect_error(mHMM(s_data = data_sim$obs, xx = xx_wrong2,
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = c(list(gamma), emiss_distr),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "first column in each element of xx has to represent the intercept")
  expect_error(mHMM(s_data = data_sim$obs, xx = xx_wrong3,
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = c(list(gamma), emiss_distr),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "xx should be a list, with the number of elements")
  expect_error(mHMM(s_data = data_sim$obs, xx = xx_wrong4,
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = c(list(gamma), emiss_distr),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "xx should be a list, with the number of elements")
  expect_error(mHMM(s_data = data_sim$obs, xx = xx_wrong5,
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = c(list(gamma), emiss_distr),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "Dichotomous covariates")
  expect_error(mHMM(s_data = data_sim$obs, xx = xx_wrong6,
                    gen = list(m = m, n_dep = n_dep, q_emiss = q_emiss),
                    start_val = c(list(gamma), emiss_distr),
                    mcmc = list(J = J, burn_in = burn_in), show_progress = FALSE),
               "Factors currently cannot be used as covariates")
})


test_that("class inherit", {
  expect_s3_class(out_2st_simb, "mHMM")
  expect_s3_class(out_2st_sim_cov2, "mHMM")
})

test_that("print mHMM", {
  # 2 dependent var, no covariates
  expect_output(print(out_2st_simb), paste("Number of subjects:", n))
  expect_output(print(out_2st_simb), paste(J, "iterations"))
  expect_output(print(out_2st_simb), paste("likelihood over all subjects:", -167))
  expect_output(print(out_2st_simb), paste("AIC over all subjects:", 371))
  expect_output(print(out_2st_simb), paste("states used:", m))
  expect_output(print(out_2st_simb), paste("dependent variables used:", n_dep))
})

test_that("summary mHMM", {
  # 2 dependent var, no covariates
  expect_output(summary(out_2st_simb), "From state 1      0.656      0.162      0.182")
  expect_output(summary(out_2st_simb), "From state 3      0.168      0.244      0.589")
  expect_output(summary(out_2st_simb), "output_1")
  expect_output(summary(out_2st_simb), "output_2")
})


test_that("output PD_subj", {
  # test output dimensions
  expect_equal(length(out_2st_simb$PD_subj), n)
  expect_equal(dim(out_2st_simb$PD_subj[[1]]), c(J, m*q_emiss[1] + m*q_emiss[2] + m * m + 1))
  expect_equal(dim(out_2st_simb$PD_subj[[1]]), dim(out_2st_simb$PD_subj[[n]]))
  # start values
  expect_equal(as.vector(out_2st_simb$PD_subj[[2]][1,]), c(as.vector(t(emiss_distr[[1]])),
                                                           as.vector(t(emiss_distr[[2]])),as.vector(t(gamma)), NA))
  # calculations
  expect_equal(as.numeric(out_2st_simb$PD_subj[[2]][10,(m*q_emiss[1] + 2)]), 0.2119, tolerance=1e-4)
  expect_equal(as.numeric(out_2st_simb$PD_subj[[2]][10,( m*q_emiss[1] + m*q_emiss[2] + m * m + 1)]), -175.6027, tolerance=1e-4)
})

test_that("output emis_cov_bar", {
  # test output dimensions
  expect_match(out_2st_simb$emiss_cov_bar, "predict the emission probabilities")
  expect_equal(dim(out_2st_sim_cov1$emiss_cov_bar[[1]]), c(J, m * (q_emiss[1] - 1)))
  expect_equal(dim(out_2st_sim_cov1$emiss_cov_bar[[2]]), c(J, m * (q_emiss[2] - 1)))
  expect_match(out_2st_sim_cov2$emiss_cov_bar, "predict the emission probabilities")
  expect_match(out_2st_sim_cov3$emiss_cov_bar, "predict the emission probabilities")
  expect_match(out_2st_sim_cov3$emiss_cov_bar, "predict the emission probabilities")
  expect_equal(dim(out_2st_sim_cov4$emiss_cov_bar[[1]]), c(J, m * (q_emiss[1] - 1)))
  expect_match(out_2st_sim_cov4$emiss_cov_bar[[2]], "predict the emission probabilities")
  # test calcultations
  expect_equal(as.numeric(out_2st_sim_cov1$emiss_cov_bar[[1]][11,  m * (q_emiss[1] - 1)]), -0.03732154, tolerance=1e-4)
  expect_equal(as.numeric(out_2st_sim_cov1$emiss_cov_bar[[2]][11,  m * (q_emiss[2] - 1)]), -0.1561908, tolerance=1e-4)
})

test_that("output emiss_int_bar", {
  # test output dimensions
  expect_equal(dim(out_2st_simb$emiss_int_bar[[1]]), c(J, m * (q_emiss[1] - 1)))
  expect_equal(dim(out_2st_simb$emiss_int_bar[[2]]), c(J, m * (q_emiss[2] - 1)))
  expect_equal(dim(out_2st_sim_cov1$emiss_int_bar[[1]]), c(J, m * (q_emiss[1] - 1)))
  # calculations
  expect_equal(as.numeric(out_2st_simb$emiss_int_bar[[1]][10,m * (q_emiss[1] - 1)]), 1.547461, tolerance=1e-4)
  expect_equal(as.numeric(out_2st_simb$emiss_int_bar[[2]][11,m * (q_emiss[2] - 1) - 1]), -1.519971, tolerance=1e-4)
})

test_that("output emiss_int_subj", {
  # test output dimensions
  expect_equal(length(out_2st_simb$emiss_int_subj), n)
  expect_equal(dim(out_2st_simb$emiss_int_subj[[1]][[1]]), dim(out_2st_simb$emiss_int_subj[[n]][[1]]))
  expect_equal(dim(out_2st_simb$emiss_int_subj[[1]][[2]]), c(J, m * (q_emiss[2] - 1)))
  # calculations
  expect_equal(as.numeric(out_2st_simb$emiss_int_subj[[1]][[1]][2,1]), -0.8574116, tolerance = 1e-4)
})

test_that("output emiss_naccept", {
  # test output dimensions
  expect_equal(length(out_2st_simb$emiss_naccept), n_dep)
  expect_equal(dim(out_2st_simb$emiss_naccept[[1]]), c(J-1, m))
  expect_equal(dim(out_2st_simb$emiss_naccept[[2]]), c(J-1, m))
  # calculations
  expect_equal(out_2st_simb$emiss_naccept[[1]][9,2], 6)
  expect_equal(out_2st_simb$emiss_naccept[[2]][10,3], 3)
})

test_that("output emiss_prob_bar", {
  # test output dimensions
  expect_equal(dim(out_2st_simb$emiss_prob_bar[[1]]),c(J, m * q_emiss[1]))
  expect_equal(dim(out_2st_simb$emiss_prob_bar[[2]]),c(J, m * q_emiss[2]))
  # start values
  expect_equal(as.vector(out_2st_simb$emiss_prob_bar[[1]][1,]), as.vector(t(emiss_distr[[1]])))
  expect_equal(as.vector(out_2st_simb$emiss_prob_bar[[2]][1,]), as.vector(t(emiss_distr[[2]])))
  # calculations
  expect_equal(as.numeric(out_2st_simb$emiss_prob_bar[[1]][11, q_emiss[1]]),  0.07300545, tolerance = 1e-4)
  expect_equal(as.numeric(out_2st_sim_cov1$emiss_prob_bar[[2]][10, q_emiss[2]]),0.3836453, tolerance = 1e-4)
})

test_that("output gamma_cov_bar", {
  # test output dimensions
  expect_match(out_2st_simb$gamma_cov_bar, "predict the transition probability")
  expect_match(out_2st_sim_cov1$gamma_cov_bar, "predict the transition probability")
  expect_equal(dim(out_2st_sim_cov2$gamma_cov_bar), c(J, m * (m-1)))
  expect_equal(dim(out_2st_sim_cov3$gamma_cov_bar), c(J, m * (m-1)))
  expect_match(out_2st_sim_cov4$gamma_cov_bar, "predict the transition probability")
  # calculations
  expect_equal(as.numeric(out_2st_sim_cov2$gamma_cov_bar[10, m * (m-1) - 1]), 0.64298, tolerance = 1e-4)
})

test_that("output gamma_int_bar", {
  # test output dimensions
  expect_equal(dim(out_2st_simb$gamma_int_bar), c(J, m * (m - 1)))
  expect_equal(dim(out_2st_sim_cov2$gamma_int_bar), c(J, m * (m - 1)))
  # calculations
  expect_equal(as.numeric(out_2st_sim_cov2$gamma_int_bar[11, m - 1]), -1.643041, tolerance = 1e-4)
})


test_that("output gamma_int_subj", {
  # test output dimensions
  expect_equal(length(out_2st_simb$gamma_int_subj), n)
  expect_equal(dim(out_2st_simb$gamma_int_subj[[1]]), dim(out_2st_simb$gamma_int_subj[[n]]))
  expect_equal(dim(out_2st_simb$gamma_int_subj[[1]]), c(J, m * (m - 1)))
  # calculations
  expect_equal(as.numeric(out_2st_simb$gamma_int_subj[[1]][11, 2 * (m-1)]), 1.131609, tolerance = 1e-4)
})

test_that("output gamma_naccept", {
  # test output dimensions
  expect_equal(dim(out_2st_simb$gamma_naccept), c((J-1), m))
  # calculations
  expect_equal(out_2st_simb$gamma_naccept[8,3], 0)
})

test_that("output gamma_prob_bar", {
  # test output dimensions
  expect_equal(dim(out_2st_simb$gamma_prob_bar),c(J, m * m))
  # start values
  expect_equal(as.vector(out_2st_simb$gamma_prob_bar[1,]), as.vector(t(gamma)))
  # calculations
  expect_equal(as.numeric(out_2st_simb$gamma_prob_bar[11,1]),0.648415, tolerance = 1e-4)
  expect_equal(as.numeric(out_2st_simb$gamma_prob_bar[10,8]), 0.2822081, tolerance = 1e-4)
})

test_that("output input", {
  # test output dimensions
  expect_equal(length(out_2st_simb$input), 8)
  # test correct output
  expect_equal(out_2st_simb$input[[1]], m)
  expect_equal(out_2st_simb$input[[2]], n_dep)
  expect_equal(out_2st_simb$input[[3]], q_emiss)
  expect_equal(out_2st_simb$input[[4]], J)
  expect_equal(out_2st_simb$input[[5]], burn_in)
  expect_equal(out_2st_simb$input[[6]], n)
  expect_equal(out_2st_simb$input[[7]], rep(n_t, n))
  expect_equal(out_2st_simb$input[[8]], c("output_1", "output_2"))
})








