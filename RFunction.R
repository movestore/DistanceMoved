library('move')
library('lubridate')
library("ggplot2")
library("viridis")
library('sf')
library("units")
library("ggforce") # to be able to use unit class in ggplot

## ToDo
## ? ´add possibility to use local timezone, with "convert Times" app, when all data are in one timezone


rFunction <-  function(data, distMeasure=c("cumulativeDist","netDisplacement"),time_numb=1,time_unit="day",displayUnits=NULL) { # second, minute, hour, day, month, year, all
  logger.info(paste0("The timezone of your data is: ",tz(timestamps(data))))
 
## getting units 
  if(st_crs(crs(data))$IsGeographic){
    unts <- as_units("m")
  }else{
    udunits_from_proj = list( ## function borrowed from R library "sf"
      #   PROJ.4     UDUNITS
      `km` =    as_units("km"),
      `m` =      as_units("m"),
      `dm` =     as_units("dm"),
      `cm` =     as_units("cm"),
      `mm` =     as_units("mm"),
      `kmi` =    as_units("nautical_mile"),
      `in` =     as_units("in"),
      `ft` =     as_units("ft"),
      `yd` =     as_units("yd"),
      `mi` =     as_units("mi"),
      `fath` =   as_units("fathom"),
      `ch` =     as_units("chain"),
      `link` =   as_units("link", check_is_valid = FALSE), # not (yet) existing; set in .onLoad()
      `us-in` =  as_units("us_in", check_is_valid = FALSE),
      `us-ft` =  as_units("US_survey_foot"),
      `us-yd` =  as_units("US_survey_yard"),
      `us-ch` =  as_units("chain"),
      `us-mi` =  as_units("US_survey_mile"),
      `ind-yd` = as_units("ind_yd", check_is_valid = FALSE),
      `ind-ft` = as_units("ind_ft", check_is_valid = FALSE),
      `ind-ch` = as_units("ind_ch", check_is_valid = FALSE)
    )
    unts <- udunits_from_proj[[st_crs(crs(data))$units]]
  }
  
## sum of all step lenghts per time interval selected  
  if(distMeasure=="cumulativeDist"){
    if(time_unit != "all"){
      dataL <- lapply(split(data), function(moveObj){
        if(time_unit %in% c("second", "minute", "hour")){roundTS <- round_date(timestamps(moveObj), paste0(time_numb," ",time_unit))}
        if(time_unit %in% c("day","month","year")){roundTS <- floor_date(timestamps(moveObj), paste0(time_numb," ",time_unit))}
        
        moveObjSplitTime <- split(moveObj, roundTS)
        distSplitL <- lapply(moveObjSplitTime, function(x){sum(distance(x))})
        distSplitTab <- do.call("rbind",distSplitL)
        distSplitDF <- data.frame(individualID=namesIndiv(moveObj),
                                  RoundedTimestamp=unique(roundTS),
                                  DistanceSUM=distSplitTab[,1],
                                  first_RealTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) timestamps(x)[1])),
                                  last_RealTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) timestamps(x)[n.locs(x)])),
                                  row.names = NULL)
        return(distSplitDF)
      })
      distSplitDFall <- do.call("rbind",dataL)
      
      units(distSplitDFall$DistanceSUM) <- as_units(unts)
      if(!is.null(displayUnits)){units(distSplitDFall$DistanceSUM) <- as_units(displayUnits)}
      
      pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), paste0("plot_DistanceMoved_cumulativeDist_per_",time_numb,time_unit,".pdf")))
      lapply(split(distSplitDFall,distSplitDFall$individualID), function(z){
        plotDist <- ggplot(z,aes(RoundedTimestamp,DistanceSUM))+
          geom_line(color="grey")+
          geom_point()+
          facet_grid(~individualID)+
          theme_bw()+
          labs(x="", y="Cumulative_Distance")
        print(plotDist)
      })
      dev.off()
      
      colnames(distSplitDFall)[colnames(distSplitDFall)=="DistanceSUM"] <- paste0("DistanceSUM","_",units(distSplitDFall$DistanceSUM)$numerator)
      write.csv(distSplitDFall, row.names=F, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),paste0("DistanceMoved_cumulativeDist_per_",time_numb,time_unit,".csv")))
    }
    
    if(time_unit == "all"){
      dataL <- lapply(split(data), function(moveObj){
        dist <- sum(distance(moveObj))
        distDF <- data.frame(individualID=namesIndiv(moveObj),
                             DistanceSUM=dist,
                             first_RealTimestamp=timestamps(moveObj)[1],
                             last_RealTimestamp=timestamps(moveObj)[n.locs(moveObj)],
                             totalTrackingTime_days=round(as.numeric(timestamps(moveObj)[n.locs(moveObj)]-timestamps(moveObj)[1],unit="days"),2),
                             row.names = NULL)
        return(distDF)
      })
      distDFall <- do.call("rbind",dataL)
      
      units(distDFall$DistanceSUM) <- as_units(unts)
      if(!is.null(displayUnits)){units(distDFall$DistanceSUM) <- as_units(displayUnits)}
      
      pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), "plot_DistanceMoved_cumulativeDist_in_total.pdf"),width=10)
      plotDist <- ggplot(distDFall,aes(individualID,DistanceSUM, color=totalTrackingTime_days))+
        geom_point()+
        theme_bw()+
        labs(x="Individuals", y="Cumulative_Distance")+
        theme(axis.text.x = element_text(angle = 90,vjust = 0.5, hjust=1))+
        scale_color_viridis("tracking time (days)",option="D")
      print(plotDist)
      dev.off()
      
      colnames(distDFall)[colnames(distDFall)=="DistanceSUM"] <- paste0("DistanceSUM","_",units(distDFall$DistanceSUM)$numerator)
      write.csv(distDFall, row.names=F, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"DistanceMoved_cumulativeDist_in_total.csv"))
    }
  }
  
## straight line (1st-last pt) distance per time step selected  
  if(distMeasure=="netDisplacement"){
    if(time_unit != "all"){
      dataL <- lapply(split(data), function(moveObj){
        if(time_unit %in% c("second", "minute", "hour")){roundTS <- round_date(timestamps(moveObj), paste0(time_numb," ",time_unit))}
        if(time_unit %in% c("day","month","year")){roundTS <- floor_date(timestamps(moveObj), paste0(time_numb," ",time_unit))}
        
        moveObjSplitTime <- split(moveObj, roundTS)
        distSplitL <- lapply(moveObjSplitTime, function(x){distance(x[c(1,n.locs(x))])})
        distSplitTab <- do.call("rbind",distSplitL)
        distSplitDF <- data.frame(individualID=namesIndiv(moveObj),
                                  RoundedTimestamp=unique(roundTS),
                                  netDisplacement=distSplitTab[,1],
                                  first_RealTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) timestamps(x)[1])),
                                  last_RealTimestamp=do.call("c",lapply(moveObjSplitTime, function(x) timestamps(x)[n.locs(x)])),
                                  row.names = NULL)
        return(distSplitDF)
      })
      distSplitDFall <- do.call("rbind",dataL)
      
      units(distSplitDFall$netDisplacement) <- as_units(unts)
      if(!is.null(displayUnits)){units(distSplitDFall$netDisplacement) <- as_units(displayUnits)}
      
      pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), paste0("plot_DistanceMoved_netDisplacement_per_",time_numb,time_unit,".pdf")))
      lapply(split(distSplitDFall,distSplitDFall$individualID), function(z){
        plotDist <- ggplot(z,aes(RoundedTimestamp,netDisplacement))+
          geom_line(color="grey")+
          geom_point()+
          facet_grid(~individualID)+
          theme_bw()+
          labs(x="", y="Net_Displacement")
        print(plotDist)
      })
      dev.off()
      
      colnames(distSplitDFall)[colnames(distSplitDFall)=="netDisplacement"] <- paste0("netDisplacement","_",units(distSplitDFall$netDisplacement)$numerator)
      write.csv(distSplitDFall, row.names=F, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),paste0("DistanceMoved_netDisplacement_per_",time_numb,time_unit,".csv")))
    }
    
    if(time_unit == "all"){
      dataL <- lapply(split(data), function(moveObj){
        dist <- distance(moveObj[c(1,n.locs(moveObj))])
        distDF <- data.frame(individualID=namesIndiv(moveObj),
                             netDisplacement=dist,
                             first_RealTimestamp=timestamps(moveObj)[1],
                             last_RealTimestamp=timestamps(moveObj)[n.locs(moveObj)],
                             totalTrackingTime_days=round(as.numeric(timestamps(moveObj)[n.locs(moveObj)]-timestamps(moveObj)[1],unit="days"),2),
                             row.names = NULL)
        return(distDF)
      })
      distDFall <- do.call("rbind",dataL)
      
      units(distDFall$netDisplacement) <- as_units(unts)
      if(!is.null(displayUnits)){units(distDFall$netDisplacement) <- as_units(displayUnits)}
      
      pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), "plot_DistanceMoved_netDisplacement_in_total.pdf"),width=10)
      plotDist <- ggplot(distDFall,aes(individualID,netDisplacement, color=totalTrackingTime_days))+
        geom_point()+
        theme_bw()+
        labs(x="Individuals", y="Net_Displacement")+
        theme(axis.text.x = element_text(angle = 90,vjust = 0.5, hjust=1))+
        scale_color_viridis("tracking time (days)",option="D")
      print(plotDist)
      dev.off()
      
      colnames(distDFall)[colnames(distDFall)=="netDisplacement"] <- paste0("netDisplacement","_",units(distDFall$netDisplacement)$numerator)
      write.csv(distDFall, row.names=F, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"DistanceMoved_netDisplacement_in_total.csv"))
    }
  }
  
  return(data)
}

