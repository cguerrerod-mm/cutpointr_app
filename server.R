library(shiny)
library(readxl)
library(cutpointr)
library(ggplot2)
library(dplyr)  # For data manipulation

server <- function(input, output, session) {
  
  dataset <- reactive({
    req(input$file)
    tryCatch({
      data <- read_excel(input$file$datapath)
      return(data)
    }, error = function(e) {
      showNotification(paste("Error: ", e$message), type = "error")
      return(NULL)
    })
  })
  
  output$variable_selector <- renderUI({
    req(dataset())
    selectInput("variable", "Variable", choices = names(dataset()))
  })
  
  output$dependent_selector <- renderUI({
    req(dataset())
    selectInput("dependent", "Dependent", choices = names(dataset()))
  })
  
  cp_result <- eventReactive(input$run_cutpointr, {
    req(input$variable, input$dependent, input$metric, input$method, input$direction, input$boot_runs)
    
    tryCatch({
      Var <- rlang::sym(input$variable)
      Dep <- rlang::sym(input$dependent)
      
      method_func <- match.fun(input$method)
      metric_func <- match.fun(input$metric)
      
      result <- cutpointr(
        data = dataset(),
        !!Var,
        !!Dep,
        method = method_func,
        metric = metric_func,
        direction = input$direction,
        boot_runs = input$boot_runs,
        na.rm = TRUE
      )
      return(result)
    }, error = function(e) {
      showNotification(paste("Error: ", e$message), type = "error")
      return(NULL)
    })
  })
  
  output$cutpoint_plot <- renderPlot({
    req(cp_result())
    plot(cp_result())
  })
  
  output$summary_table <- renderTable({
    req(cp_result())
    result <- cp_result()
    
    # Extract the summary data manually
    summary_data <- result %>%
      dplyr::select(
        direction, optimal_cutpoint, method, sum_sens_spec, acc,
        sensitivity, specificity, AUC, pos_class, neg_class, prevalence
      ) %>%
      dplyr::rename(
        Direction = direction,
        Optimal_Cutpoint = optimal_cutpoint,
        Method = method,
        Sum_Sens_Spec = sum_sens_spec,
        Accuracy = acc,
        Sensitivity = sensitivity,
        Specificity = specificity,
        AUC = AUC,
        Positive_Class = pos_class,
        Negative_Class = neg_class,
        Prevalence = prevalence
      )
    
    return(summary_data)
  }, rownames = TRUE)
  
}
