library(shiny)
library(ggplot2)

# Data pre-processing ----
## RNA-seq
rna <- read.table("/srv/shiny-server/data/RNAseq_counts_for_visualisation.txt", header=T, stringsAsFactors = F)
rna$cytokine <- factor(rna$cytokine, levels = c("Resting","Th0","Th1","Th2","Th17","iTreg","IFNB"))
rna$cell_type <- factor(rna$cell_type, levels = c("Naive","Memory"))
geneNames <- sort(unique(rna$gene))
names(geneNames) <- geneNames

## Proteomics
protein <- read.table("/srv/shiny-server/data/Protein_counts_for_visualisation.txt", header=T, stringsAsFactors = F)
protein$cytokine <- factor(protein$cytokine, levels = c("Resting","Th0","Th1","Th2","Th17","iTreg","IFNB"))
protein$cell_type <- factor(protein$cell_type, levels = c("Naive","Memory"))
proteinNames <- sort(unique(protein$protein))
names(proteinNames) <- proteinNames

# Define UI ----
ui <- fluidPage(
  
  titlePanel("Gene expression in cytokine-polarised CD4+ T cells"),
  
  helpText("Visualise the expression of genes and proteins of interest 
           in different cytokine-induced CD4+ T cell states."),
  
  navbarPage(
    
    "Molecular assay",
    
    tabPanel("RNA-seq", {
      
      sidebarLayout(position = "left",
                    sidebarPanel(
                      
                      selectInput("geneName",
                                  h4("Select a gene"),
                                  choices = geneNames,
                                  selected = geneNames[1])
                    ),
                    
                    mainPanel(
                      h4("Expression level", 
                         plotOutput("rnaPlot"),
                         img(src = "Open_targets_logo.png", height = 80, width = 220),
                         align="center")
                    )
      ) 
      
    }),
    
    tabPanel("Proteomics", {
      
      sidebarLayout(position = "left",
                    sidebarPanel(
                      
                      selectInput("proteinName",
                                  h4("Select a protein"),
                                  choices = proteinNames,
                                  selected = proteinNames[1])
                      
                    ),
                    mainPanel(
                      
                      h4("Expression level", 
                         plotOutput("proteinPlot"),
                         img(src = "Open_targets_logo.png", height = 80, width = 220),
                         align="center")
                      
                    )
      )
      
    })
    
  )
  )



# Define server logic ----
server <- function(input, output) {
  
  output$rnaPlot <- renderPlot({
    
    ggplot(rna[rna$gene == input$geneName,], aes(x=cytokine, y=value)) +
      geom_boxplot(aes(color=time_point), position=position_dodge(1)) +
      scale_color_brewer(palette = "Paired", name="", labels=c("16 hours", "5 days")) +
      facet_grid(~cell_type) +
      ggtitle(input$geneName) + 
      ylab("rlog RNA counts") + 
      xlab("Cytokine-induced cell state") + 
      ylim(0,max(rna[rna$gene == input$geneName,]$value)*1.1) + 
      theme_bw() + 
      theme(panel.grid = element_blank(), 
            plot.title = element_text(hjust=0.5, size=16), 
            axis.title = element_text(size=14),  
            axis.text = element_text(size=14),
            axis.text.x = element_text(angle=90),
            legend.position = "bottom",
            legend.text = element_text(size=14))
    
  })
  
  output$proteinPlot <- renderPlot({
    
    ggplot(protein[protein$protein == input$proteinName,], aes(x=cytokine, y=value)) +
      geom_boxplot(aes(color=time_point), position=position_dodge(1)) +
      scale_color_manual(values = c("#1F78B4"), name="", labels="5 days") +
      facet_grid(~cell_type) +
      ggtitle(input$proteinName) + 
      ylab("Relative protein abundance") + 
      xlab("Cytokine-induced cell state") + 
      ylim(0,max(protein[protein$protein == input$proteinName,]$value)*1.1) + 
      theme_bw() + 
      theme(panel.grid = element_blank(), 
            plot.title = element_text(hjust=0.5, size=16), 
            axis.title = element_text(size=14),  
            axis.text = element_text(size=14),
            axis.text.x = element_text(angle = 90),
            legend.position = "bottom", 
            legend.text = element_text(size=14))
    
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)