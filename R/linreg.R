linreg <- setRefClass("linreg",
                      fields = list(
                        X = "matrix",
                        y = "matrix",
                        regressions_coef = "matrix",
                        fitted_values = "matrix",
                        resi = "matrix",
                        n = "numeric",
                        p = "numeric",
                        dof = "numeric",
                        regressions_var = "matrix",
                        resi_var = "matrix",
                        t_value = "matrix",
                        m_formula ="formula",
                        m_data = "character"),
                      
                      #--------------------------------
                      methods = list
                      (
                        #This function will calculate necessary parameters
                        initialize = function(formula, data) 
                        {
                          #Generate X and y
                          X <<- model.matrix(formula, data)
                          y <<- as.matrix(data[all.vars(formula)[1]])
                          
                          #Regressions coeficients
                          regressions_coef<<- as.matrix(solve(t(X)%*%X) %*% t(X)%*%y)
                          
                          fitted_values <<- X%*%regressions_coef
                          #Residuals
                          resi <<- y - fitted_values
                          #Degrees of fredom
                          n <<- length(X[,1])
                          p <<- length(X[1,])
                          dof <<- n - p
                          
                          #Variance of the regression coecients
                          resi_var <<- var(resi)
                          #t_value
                          
                          t_value <<- regressions_coef/as.numeric(sqrt(resi_var))
                          
                          #Metadata
                          m_formula <<- formula
                          m_data <<- deparse(substitute(data))
                        },
                        
                        #The print method
                        print = function() {
                          cat(paste("Call: \n"))
                          cat(paste("linreg(formula = ",format(m_formula), ", data = ", m_data, ")\n\n", sep = ""))
                          cat(paste("Coefficients:\n"))
                          coef <- structure(as.vector(regressions_coef), names= row.names(regressions_coef))
                          my_print(coef)
                        },
                        
                        #The plot method
                        plot = function()
                        {
                          library(ggplot2)
                          
                          #Plot 1
                          residuals_vs_fitted <- ggplot(data.frame(resi, fitted_values), aes(x=fitted_values, y=resi)) +
                            geom_point() +
                            stat_smooth(method='lm', colour="red", se=FALSE, span = 1) +
                            xlab(paste("Fitted Values\n", "linreg(", format(m_formula), ")", ""))+
                            ylab("Residuals")
                          
                          #stat_summary(aes(y = resi, x = fitted_values ,group=1), fun.y=median, colour="red", geom="line",group=1)
                          
                          my_print(residuals_vs_fitted)
                          
                          #Prepare for plot 2
                          std_vs_fitted <- as.data.frame(cbind(sqrt(abs(resi-mean(resi))), fitted_values))
                          names(std_vs_fitted) = c("Standardized_residuals", "fitted_values")
                          y_plot <- std_vs_fitted[,1]
                          
                          #Plot 2
                          plot2 <- ggplot(std_vs_fitted, aes(x = fitted_values, y = y_plot))+
                            geom_point()+
                            stat_smooth(method='lm', colour="red", se=FALSE, span = 1) +
                            xlab(paste("Fitted Values\n", "linreg(", format(m_formula), ")", ""))+
                            ylab(expression(sqrt("|Standardized residuals|")))
                          #xlab(paste("Fitted Values\n", "lm(", format(l_formula), ")", ""))+
                          #ylab(expression(sqrt("|Standardized residuals|")))+
                          #stat_summary(aes(y = y_plot , x = fitted_values ,group=1),
                          #             fun.y= median,  colour="red", geom="line",group=1) 
                          
                          my_print(plot2)
                        },
                        resid = function(){
                          return(resi)
                        },
                        pred = function()
                        {
                          return(fitted_values)
                        },
                        coef = function(){
                          coef <- structure(as.vector(regressions_coef), names= row.names(regressions_coef))
                          return(coef)
                        },
                        
                        #Summary method
                        summary = function()
                        {
                          cat(paste("Call: \n"))
                          cat(paste("linreg(formula = ",format(m_formula), ", data = ", m_data, ")\n\n", sep = ""))
                          cat(paste("Coefficients:\n"))
                          
                          regressions_var <<- as.numeric(resi_var) * solve(t(X) %*% X)
                          table = data.frame(matrix(ncol = 5, nrow = 0))
                          for (i in 1:length(regressions_coef)) 
                          {
                            this_t_value = regressions_coef[i]/sqrt(regressions_var[i, i])
                            this_p_value = 2*pt(abs(this_t_value), dof, lower.tail = FALSE)
                            row = data.frame(round(regressions_coef[i], 2), round(sqrt(regressions_var[i, i]), 2), round(this_t_value, 2), formatC(this_p_value, format = "e", digits = 2))                            
                            rownames(row)[1] = rownames(regressions_coef)[i]
                            table = rbind(table, row)
                          }
                          output <- structure(table, names= c("Estimate", "Std Error", "t value", "Pr(>|t|)"))
                          my_print(output)
                          
                          cat(paste("\n"))
                          cat(paste("Residuals standard error: ",round(sd(resi),3), ", on ", dof, " degrees of freedom.", sep = ""))
                        }
                        
                      )
)

#Our own print function, because we can't call the default function inside RC object
#linreg$methods(my_show = function(x){print(x)})
my_print <- function(x){
  print(x)
}                           


#How to use:
#1. Run this file (both linreg object and the my_print function)
#2. mod_object <- linreg(Petal.Length~Species, data = iris)
#3. mod_object$print()
#4. mod_object$plot()
#5. mod_object$summary()

# a <- linreg$new(Petal.Length~Sepal.Width, data = iris)
