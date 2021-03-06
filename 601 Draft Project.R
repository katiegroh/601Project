

library(shiny)


library(ggiraph)
#devtools::install_github("thomasp85/patchwork")
#install.packages("devtools")
#devtools::install_github("thomasp85/patchwork")
library(patchwork) # For combining multiple plots with ggiraph
#library(cowplot)

library(plotly)
library(gapminder)
library(tidyverse)

library(ggplot2)
library(dplyr)
library(ggthemes)
library(ggrepel)




ui <- fluidPage(
  ggiraphOutput("plot", width = "100%")
)

server <- function(input, output, session) {
  output$plot <- renderggiraph({
    smart_food <- food_coded %>% 
      mutate(numeric_gpa = as.numeric(GPA)) %>% 
      filter(!is.na(numeric_gpa)) %>% 
      mutate(numeric_weight = as.numeric(weight)) %>% 
      filter(!is.na(numeric_weight))
    
    averages_food <-  summarise(smart_food, weight_average = mean(numeric_weight), gpa_average = mean(numeric_gpa), weight_median = median(numeric_weight), gpa_median = median(numeric_gpa))
    
    
    final_gpa <-  cut(smart_food$numeric_gpa, c(0,2,2.5,3,3.5,4)) 
    
    males <- filter(smart_food, Gender == 2)
    females <- filter(smart_food, Gender == 1)
    #"\n Average Weight = ", averages_food$weight_average,"\n Average GPA = ", averages_food$gpa_average, 
    
    
    smart_food$name = rownames(smart_food)
    smart_food$tooltip <- c(paste0("Rewarding Life Value ", smart_food$life_rewarding, "\n Healthy Feeling Value = ", smart_food$healthy_feeling, "\n Weight = ", smart_food$numeric_weight,  "\n Median Weight = ", averages_food$weight_median, "\n GPA = ", smart_food$numeric_gpa, "\n Median GPA = ", averages_food$gpa_median))
    
    
    agreement_plot =ggplot()+
      geom_smooth(data = smart_food,aes(numeric_gpa, healthy_feeling, color = "healthy_feeling"), alpha = 0.15, fill = "lime green")+
      geom_smooth(data = smart_food,aes(numeric_gpa,life_rewarding, color = "life_rewarding"), alpha = 0.15, fill = "violet")+
      geom_point_interactive(data = smart_food, aes(numeric_gpa, healthy_feeling, color = "healthy_feeling", data_id = name, tooltip = tooltip), alpha = 0.25)+
      geom_point_interactive(data = smart_food, aes(numeric_gpa,life_rewarding, color = "life_rewarding", data_id = name, tooltip = tooltip), alpha = 0.25)+
      theme_hc()+
      labs(x = "Grade Point Average", y = "Agreement", title = "GPA and Health Perception", cex.lab=3, cex.axis=2, cex.main=3, cex.sub=1.5)+
      scale_colour_manual(name='', breaks = c("healthy_feeling", "life_rewarding"), labels = c("healthy_feeling" = "I feel healthy", "life_rewarding" = "I live a rewarding life"), values=c("healthy_feeling" = "lime green", "life_rewarding"= "violet"))+
      theme(legend.position = "right")+
      scale_y_continuous(breaks=c(0, 2.5, 5, 7.5, 10),labels=c("0" = "Strongly Disagree"," 2.5" = "Disagree", "5.0" = "Neutral",
                                                               "7.5" = "Agree", "10" = "Strongly Agree"))
    
    changes_plot <- ggplot()+
      geom_bar_interactive(data = smart_food, aes(eating_changes_coded, fill = final_gpa, data_id = name, tooltip = tooltip))+
      theme_hc()+
      theme(legend.position = "none")+
      labs(title = "Eating Habbits", x = "Eating Changes", y = "Number of students")+
      scale_x_continuous(breaks = c(1, 2, 3, 4), labels = c("1" = "Worse", "2"="Healthier", "3" = "Same", "4" = "Other"))+
      coord_flip()
    
    
    
    current_plot <- ggplot()+
      geom_bar_interactive(data = smart_food, aes(diet_current_coded, fill = final_gpa, data_id = name, tooltip = tooltip))+
      theme_hc()+
      theme(legend.position = "right")+
      labs(caption = " Datasource: https://www.kaggle.com/rafalpanasiuk/food-choices-data-exploration-analysis", title = "Health Feeling", x = "Health Feeling", y = "Number of students", legend.title = "GPA", fill = "GPA")+
      scale_x_continuous(breaks = c(1, 2, 3, 4),  labels = c("1" = "Healthy", "2"="Unhealthy", "3" = "Same", "4" = "Unclear"))+
      coord_flip()+
      scale_colour_continuous(breaks = waiver() , labels = c("(2,2.5]"= "2.0-2.5","(2.5-3]" = "2.5-3.0", "(3-3.5]" =  "3.0-3.5", "(3.5-4]" = "3.5-4.0"))
    ggiraph(code = print(  agreement_plot - (changes_plot + current_plot) + plot_layout(ncol=1)), hover_css = "fill:black;stroke-width:10",width_svg = 8) 
    
    
  })
}

shinyApp(ui, server)

