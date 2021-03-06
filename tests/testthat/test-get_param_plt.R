library(SticsRFiles)
options(warn=-1)
xml_path= file.path(get_examples_path("xml"),"file_plt.xml")
context("Getting param values")


test_that("single param option value", {
  expect_equivalent(get_param_xml(xml_path,"codetemp"), 1)
  expect_equivalent(get_param_xml(xml_path,"codegdh"), 1)
  expect_equivalent(get_param_xml(xml_path,"codephot"), 2)
})

test_that("single param value", {
  expect_equivalent(get_param_xml(xml_path,"jvcmini"),7.00000)
  expect_equivalent(get_param_xml(xml_path,"innsen"), 0.35000)
  expect_equivalent(get_param_xml(xml_path,"efcroiveg"), 4.25000)
})

test_that("two param option values, and order", {
  r <- unlist(get_param_xml(xml_path,c("codetremp","codegdh"))[[1]])
  names(r) <- NULL
  expect_equal(r, c(2,1))
  r <- unlist(get_param_xml(xml_path,c("codegdh","codetremp"))[[1]])
  names(r) <- NULL
  expect_equal(r, c(1,2))
})


test_that("a param option value and a param value, and order", {
  r <- unlist(get_param_xml(xml_path,c("codetemp","jvcmini"))[[1]])
  names(r) <- NULL
  expect_equal(r, c(1,7.00000))
  r <- unlist(get_param_xml(xml_path,c("jvcmini","codetemp"))[[1]])
  names(r) <- NULL
  expect_equal(r, c(7.00000,1))
})

