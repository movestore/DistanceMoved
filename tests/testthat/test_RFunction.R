library('move2')

test_data <- test_data("input3_move2.rds") #file must be move2!

test_that("happy path", {
  actual <- rFunction(data = test_data, distMeasure="cumulativeDist",time_numb=12,time_unit="month",dist_unit="km")
  expect_equal(test_data,actual)
})


