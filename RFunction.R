library('move2')
library('lubridate')
library("ggplot2")
library("viridis")
library('sf')
library("units")

# ToDo: add posibility to split track into "column X" 
# ToDo: write it using more the dplyr functions

rFunction <-  function(data, distMeasure=c("cumulativeDist","netDisplacement","maxNetDisplacement"),time_numb=1,time_unit="day",dist_unit="m") { # second, minute, hour, day, month, year, all
  logger.info(paste0("The timezone of your data is: ",tz(mt_time(data))))
## sum of all step lenghts per time interval selected  
  if(distMeasure=="cumulativeDist"){
    if(time_unit != "all"){
      dataL <- lapply(split(data,mt_track_id(data)), function(moveObj){
        if(time_unit %in% c("second", "minute", "hour")){roundTS <- round_date(mt_time(moveObj), paste0(time_numb," ",time_unit))}
        if(time_unit %in% c("day","month","year")){roundTS <- floor_date(mt_time(moveObj), paste0(time_numb," ",time_unit))}
        
        moveObjSplitTime <- split(moveObj, roundTS)
        distSplitL <- lapply(moveObjSplitTime, function(x){sum(mt_distance(x, units=dist_unit),na.rm=T)})
        distSplitTab <- do.call("rbind",distSplitL)
        distSplitDF <- data.frame(track_id=unique(mt_track_id(moveObj)),
                                  rounded_timestamp=unique(roundTS),
                                  distanceSUM=distSplitTab[,1],
                                  first_realTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) mt_time(x)[1])),
                                  last_realTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) mt_time(x)[nrow(x)])),
                                  row.names = NULL)
        return(distSplitDF)
      })
      distSplitDFall <- do.call("rbind",dataL)
      
      distSplitDFall$distanceSUM <- set_units(distSplitDFall$distanceSUM,dist_unit,mode="standard")
      
      data$distanceMoved <- NA
      for(i in 1:nrow(distSplitDFall)){
      data$distanceMoved[mt_track_id(data)==distSplitDFall$track_id[i] &  
                           mt_time(data)>=distSplitDFall$first_realTimestamp[i] & 
                           mt_time(data)<=distSplitDFall$last_realTimestamp[i]] <- distSplitDFall$distanceSUM[i]
      }
      data$distanceMovedDetails <- paste0(distMeasure,"_per_",time_numb,time_unit,"_in_",dist_unit)
      
      
      pdf(appArtifactPath(paste0("plot_DistanceMoved_cumulativeDist_per_",time_numb,time_unit,".pdf")))
      lapply(split(distSplitDFall,distSplitDFall$track_id), function(z){
        plotDist <- ggplot(z,aes(rounded_timestamp,distanceSUM))+
          geom_line(color="grey")+
          geom_point()+
          facet_grid(~track_id)+
          theme_bw()+
          labs(x="", y="Cumulative Distance")
        print(plotDist)
      })
      dev.off()

      colnames(distSplitDFall)[colnames(distSplitDFall)=="distanceSUM"] <- paste0("distanceSUM","_",units(distSplitDFall$distanceSUM)$numerator)
      write.csv(distSplitDFall, row.names=F, file = appArtifactPath(paste0("DistanceMoved_cumulativeDist_per_",time_numb,time_unit,".csv")))
      
    }
    ## cumulativeDist for all the track
    if(time_unit == "all"){
      dataL <- lapply(split(data,mt_track_id(data)), function(moveObj){
        dist <- sum(mt_distance(moveObj, units=dist_unit),na.rm=T)
        distDF <- data.frame(track_id=unique(mt_track_id(moveObj)),
                             distanceSUM=dist,
                             first_realTimestamp=mt_time(moveObj)[1],
                             last_realTimestamp=mt_time(moveObj)[nrow(moveObj)],
                             totalTrackingTime_days=round(as.numeric(mt_time(moveObj)[nrow(moveObj)]-mt_time(moveObj)[1],unit="days"),2),
                             row.names = NULL)
        return(distDF)
      })
      distDFall <- do.call("rbind",dataL)
      
      data$distanceMoved <- NA
      for(i in 1:nrow(distSplitDFall)){
        data$distanceMoved[mt_track_id(data)==distSplitDFall$track_id[i]] <- distSplitDFall$distanceSUM[i]
      }
      data$distanceMovedDetails <- paste0(distMeasure,"_per_","entire_track","_in_",dist_unit)

      pdf(appArtifactPath("plot_DistanceMoved_cumulativeDist_in_total.pdf"),width=10)
      plotDist <- ggplot(distDFall,aes(track_id,distanceSUM, color=totalTrackingTime_days))+
        geom_point()+
        theme_bw()+
        labs(x="Individuals", y="Cumulative Distance")+
        theme(axis.text.x = element_text(angle = 90,vjust = 0.5, hjust=1))+
        scale_color_viridis("tracking time (days)",option="B",end = 0.9, direction=-1)
      print(plotDist)
      dev.off()
      
      colnames(distDFall)[colnames(distDFall)=="distanceSUM"] <- paste0("distanceSUM","_",units(distDFall$distanceSUM)$numerator)
      write.csv(distDFall, row.names=F, file = appArtifactPath("DistanceMoved_cumulativeDist_in_total.csv"))
    }
  }
  
## straight line (1st-last pt) distance per time step selected  
  if(distMeasure=="netDisplacement"){
    if(time_unit != "all"){
      dataL <- lapply(split(data,mt_track_id(data)), function(moveObj){
        if(time_unit %in% c("second", "minute", "hour")){roundTS <- round_date(mt_time(moveObj), paste0(time_numb," ",time_unit))}
        if(time_unit %in% c("day","month","year")){roundTS <- floor_date(mt_time(moveObj), paste0(time_numb," ",time_unit))}
        
        moveObjSplitTime <- split(moveObj, roundTS)
        distSplitL <- lapply(moveObjSplitTime, function(x){mt_distance(x[c(1,nrow(x)),],units=dist_unit)})
        distSplitTab <- do.call("rbind",distSplitL)
        distSplitDF <- data.frame(track_id=unique(mt_track_id(moveObj)),
                                  rounded_timestamp=unique(roundTS),
                                  netDisplacement=distSplitTab[,1],
                                  first_realTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) mt_time(x)[1])),
                                  last_realTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) mt_time(x)[nrow(x)])),
                                  row.names = NULL)
        return(distSplitDF)
      })
      distSplitDFall <- do.call("rbind",dataL)
      
      distSplitDFall$netDisplacement <- set_units(distSplitDFall$netDisplacement,dist_unit,mode="standard")
      
      data$distanceMoved <- NA
      for(i in 1:nrow(distSplitDFall)){
        data$distanceMoved[mt_track_id(data)==distSplitDFall$track_id[i] &  
                             mt_time(data)>=distSplitDFall$first_realTimestamp[i] & 
                             mt_time(data)<=distSplitDFall$last_realTimestamp[i]] <- distSplitDFall$netDisplacement[i]
      }
      data$distanceMovedDetails <- paste0(distMeasure,"_per_",time_numb,time_unit,"_in_",dist_unit)
      
      pdf(appArtifactPath( paste0("plot_DistanceMoved_netDisplacement_per_",time_numb,time_unit,".pdf")))
      lapply(split(distSplitDFall,distSplitDFall$track_id), function(z){
        plotDist <- ggplot(z,aes(rounded_timestamp,netDisplacement))+
          geom_line(color="grey")+
          geom_point()+
          facet_grid(~track_id)+
          theme_bw()+
          labs(x="", y="Net Displacement")
        print(plotDist)
      })
      dev.off()
      
      colnames(distSplitDFall)[colnames(distSplitDFall)=="netDisplacement"] <- paste0("netDisplacement","_",units(distSplitDFall$netDisplacement)$numerator)
      write.csv(distSplitDFall, row.names=F, file = appArtifactPath(paste0("DistanceMoved_netDisplacement_per_",time_numb,time_unit,".csv")))
    }
    ## netDisplacement for all the track
    if(time_unit == "all"){
      dataL <- lapply(split(data,mt_track_id(data)), function(moveObj){
        dist <- mt_distance(moveObj[c(1,nrow(moveObj)),],units=dist_unit)
        distDF <- data.frame(track_id=unique(mt_track_id(moveObj)),
                             netDisplacement=dist[1],
                             first_realTimestamp=mt_time(moveObj)[1],
                             last_realTimestamp=mt_time(moveObj)[nrow(moveObj)],
                             totalTrackingTime_days=round(as.numeric(mt_time(moveObj)[nrow(moveObj)]-mt_time(moveObj)[1],unit="days"),2),  
                             row.names = NULL)
        return(distDF)
      })
      distDFall <- do.call("rbind",dataL)
      
      data$distanceMoved <- NA
      for(i in 1:nrow(distSplitDFall)){
        data$distanceMoved[mt_track_id(data)==distSplitDFall$track_id[i]] <- distSplitDFall$netDisplacement[i]
      }
      data$distanceMovedDetails <- paste0(distMeasure,"_per_","entire_track","_in_",dist_unit)
      
      pdf(appArtifactPath( "plot_DistanceMoved_netDisplacement_in_total.pdf"),width=10)
      plotDist <- ggplot(distDFall,aes(track_id,netDisplacement, color=totalTrackingTime_days))+
        geom_point()+
        theme_bw()+
        labs(x="Individuals", y="Net Displacement")+
        theme(axis.text.x = element_text(angle = 90,vjust = 0.5, hjust=1))+
        scale_color_viridis("tracking time (days)",option="B",end = 0.9, direction=-1)
      print(plotDist)
      dev.off()
      
      colnames(distDFall)[colnames(distDFall)=="netDisplacement"] <- paste0("netDisplacement","_",units(distDFall$netDisplacement)$numerator)
      write.csv(distDFall, row.names=F, file = appArtifactPath("DistanceMoved_netDisplacement_in_total.csv"))
    }
  }
  
  ## maximum distance between any 2 locations per time step selected  
  if(distMeasure=="maxNetDisplacement"){
    if(time_unit != "all"){
      dataL <- lapply(split(data,mt_track_id(data)), function(moveObj){
        if(time_unit %in% c("second", "minute", "hour")){roundTS <- round_date(mt_time(moveObj), paste0(time_numb," ",time_unit))}
        if(time_unit %in% c("day","month","year")){roundTS <- floor_date(mt_time(moveObj), paste0(time_numb," ",time_unit))}
        
        moveObjSplitTime <- split(moveObj, roundTS)
        distSplitL <- lapply(moveObjSplitTime, function(x){max(st_distance(x=x[-nrow(x),],y=x[-1,], by_element=T),na.rm=T)})
        distSplitTab <- do.call("rbind",distSplitL)
        distSplitDF <- data.frame(track_id=unique(mt_track_id(moveObj)),
                                  rounded_timestamp=unique(roundTS),
                                  maxNetDisplacement=distSplitTab[,1],
                                  first_realTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) mt_time(x)[1])),
                                  last_realTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) mt_time(x)[nrow(x)])),
                                  row.names = NULL)
        distSplitDF$maxNetDisplacement <- set_units(distSplitDF$maxNetDisplacement,units(distSplitL[[1]])$numerator,mode="standard")
        return(distSplitDF)
      })
      distSplitDFall <- do.call("rbind",dataL)
      
      distSplitDFall$maxNetDisplacement <- set_units(distSplitDFall$maxNetDisplacement,dist_unit,mode="standard")    
      
      data$distanceMoved <- NA
      for(i in 1:nrow(distSplitDFall)){
        data$distanceMoved[mt_track_id(data)==distSplitDFall$track_id[i] &  
                             mt_time(data)>=distSplitDFall$first_realTimestamp[i] & 
                             mt_time(data)<=distSplitDFall$last_realTimestamp[i]] <- distSplitDFall$maxNetDisplacement[i]
      }
      data$distanceMovedDetails <- paste0(distMeasure,"_per_",time_numb,time_unit,"_in_",dist_unit)
      
      
      pdf(appArtifactPath( paste0("plot_DistanceMoved_maxNetDisplacement_per_",time_numb,time_unit,".pdf")))
      lapply(split(distSplitDFall,distSplitDFall$track_id), function(z){
        plotDist <- ggplot(z,aes(rounded_timestamp,maxNetDisplacement))+
          geom_line(color="grey")+
          geom_point()+
          facet_grid(~track_id)+
          theme_bw()+
          labs(x="", y="Max Net Displacement")
        print(plotDist)
      })
      dev.off()
      
      colnames(distSplitDFall)[colnames(distSplitDFall)=="maxNetDisplacement"] <- paste0("maxNetDisplacement","_",units(distSplitDFall$maxNetDisplacement)$numerator)
      write.csv(distSplitDFall, row.names=F, file = appArtifactPath(paste0("DistanceMoved_maxNetDisplacement_per_",time_numb,time_unit,".csv")))
    }
    ## maxNetDisplacement for all the track
    if(time_unit == "all"){
      dataL <- lapply(split(data,mt_track_id(data)), function(moveObj){
        dist <- max(st_distance(x=moveObj[-nrow(moveObj),],y=moveObj[-1,], by_element=T),na.rm=T)
        distDF <- data.frame(track_id=unique(mt_track_id(moveObj)),
                             maxNetDisplacement=dist,
                             first_realTimestamp=mt_time(moveObj)[1],
                             last_realTimestamp=mt_time(moveObj)[nrow(moveObj)],
                             totalTrackingTime_days=round(as.numeric(mt_time(moveObj)[nrow(moveObj)]-mt_time(moveObj)[1],unit="days"),2),     
                             row.names = NULL)
        return(distDF)
      })
      distDFall <- do.call("rbind",dataL)
      
      distDFall$maxNetDisplacement <- set_units(distDFall$maxNetDisplacement,dist_unit,mode="standard")    
      
      data$distanceMoved <- NA
      for(i in 1:nrow(distSplitDFall)){
        data$distanceMoved[mt_track_id(data)==distSplitDFall$track_id[i]] <- distSplitDFall$maxNetDisplacement[i]
      }
      data$distanceMovedDetails <- paste0(distMeasure,"_per_","entire_track","_in_",dist_unit)
      
      pdf(appArtifactPath( "plot_DistanceMoved_maxNetDisplacement_in_total.pdf"),width=10)
      plotDist <- ggplot(distDFall,aes(track_id,maxNetDisplacement, color=totalTrackingTime_days))+
        geom_point()+
        theme_bw()+
        labs(x="Individuals", y="Max Net Displacement")+
        theme(axis.text.x = element_text(angle = 90,vjust = 0.5, hjust=1))+
        scale_color_viridis("tracking time (days)",option="B",end = 0.9, direction=-1)
      print(plotDist)
      dev.off()
      
      colnames(distDFall)[colnames(distDFall)=="maxNetDisplacement"] <- paste0("maxNetDisplacement","_",units(distDFall$maxNetDisplacement)$numerator)
      write.csv(distDFall, row.names=F, file = appArtifactPath("DistanceMoved_maxNetDisplacement_in_total.csv"))
    }
  }
  
  return(data)
}

