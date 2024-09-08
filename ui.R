library(shiny)

# Define UI for the app
ui <- fluidPage(
  titlePanel("Calculate Optimal Cutoff for a Variable Using cutpointr"),
  
  # Include instructions and a reference link in the header
  div(
    id = "instructions",
    h3("Instructions:"),
    p("1. Upload an Excel file containing your dataset. The file must have two columns named 'variable' for the var you want to calculate the cutoff for (numerical) and 'dependent' (i.e., PFS_c, MRD - in the format 0 or 1)."),
    p("2. Select the column for the variable and the dependent variable from the dropdown menus."),
    p("3. Choose the method and metric for calculating the optimal cutpoint. Read the manual for more info."),
    p("4. Specify the number of bootstrap runs and the direction for the cutoff. Default is 100"),
    p("5. Click 'Run Cutpointr' to generate the results."),
    p("For more details on the cutpointr package, refer to the ", 
      a("cutpointr reference manual", href = "https://cran.r-project.org/web/packages/cutpointr/cutpointr.pdf"), "."
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose Excel File", accept = c(".xlsx")),
      uiOutput("variable_selector"),
      uiOutput("dependent_selector"),
      selectInput("method", "Method", choices = c("maximize_metric", "minimize_metric", "maximize_loess_metric","minimize_loess_metric", "maximize_spline_metric","minimize_spline_metric", "maximize_boot_metric","minimize_boot_metric", "oc_youden_kernel","oc_youden_normal","oc_manual")),
      selectInput("metric", "Metric", choices = c("sum_sens_spec", "youden", "accuracy", "sum_ppv_npv", "prod_sens_spec", "prod_ppv_npv", "cohens_kappa", "p_chisquared","odds_ratio","risk_ratio", "F1_score")),
      selectInput("direction", "Direction", choices = c(">=", "<=")),
      numericInput("boot_runs", "Number of Bootstrap Runs", value = 100, min = 1),
      actionButton("run_cutpointr", "Run Cutpointr")
    ),
    
    mainPanel(
      plotOutput("cutpoint_plot"),
      tableOutput("summary_table")  # Add a table output for the summary
    )
  )
)
