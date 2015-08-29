
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(twitteR)

options(httr_oauth_cache=T)
setup_twitter_oauth('9L6TAHaUvGKuHsxfmHuVRKzqb',
                    '6bwi2pM053n6xWFqQaClHyPe0BN8kThbBC5OUZbl2TmF71itYL',
                    '3314597346-ub5zOuvZ7WnGxOq1hU0VZfqLLCgkgUxQTbL7RN8',
                    'ACnu2vL5mAKhH6O1BBUnY3p9oP9q8de8ktK0yKgtp9eEy');

shinyServer(function(input, output) {
  
  userFromHandle = NULL
  userFollowers = NULL
  
  FillUserTable <- function () {
    # FETCH DATA
    if (input$twitterHandle != ""){
      userFromHandle <<- getUser(input$twitterHandle)
    
      # Data from objects:       
      userId = userFromHandle$id
      userName = userFromHandle$name
      followerCount = userFromHandle$followersCount
      
      
      #Prepare Table Infomation:
      colNames = c("User ID", "Name", "Number of Followers")
      userData = c(userId, userName, followerCount)
      
      #COnstruct Table:
      if (!is.null(userData)) {
        userTable = matrix(data = userData , ncol = length(colNames), dimnames = list('',colNames), byrow = TRUE)
        userTable = as.table(userTable) 
        return (userTable)
      }
    }
  }
  
  output$twitTable <- renderTable({
    FillUserTable()
  })

#   observeEvent(input$fetchData, {
#     if (input$twitterHandle != "" && !is.null(userFromHandle$followersCount)) {
#       
#     }
#   })
  FetchFollowers <- function () {
    if (input$maxFollowers == 0) {
      return (userFromHandle$getFollowers())
    } else {
      return (userFromHandle$getFollowers(input$maxFollowers))
    }
  }
  
  FollowerData = function () {
    #Fetch followers data
    withProgress(message = "Downloading Data Now", expr = {
      setProgress(value = 0)
      userFollowers <<- FetchFollowers()
      setProgress(value = 1)
    })
    
    # prune the user data list into a table for csv
    if (is.list(userFollowers)) {
      df = twListToDF(userFollowers)
    } else {
      df = userFollowers
    }
    return (df)
  }
  
  output$downloadData <- downloadHandler(
    filename = function (){
      paste(input$twitterHandle, '_twitter_followers.csv', sep = '')
    },
    content = function (file) {
      write.csv(FollowerData(), file)
    }
  )
})

