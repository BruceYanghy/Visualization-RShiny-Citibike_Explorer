#build route
bike<-readRDS("~/Desktop/[ADS]Advanced Data Science/fall2017-project5-group5/data/whole_bike.rds")
load("~/Desktop/[ADS]Advanced Data Science/fall2017-project5-group5/data/station_info.RData")
lecy.list <- readRDS(gzcon(url("https://github.com/lecy/CityBikeNYC/raw/master/DATA/ALL_ROUTES_LIST.rds")))

rownames(stations_info)<-stations_info$id
library(dplyr)



#route<-route[,c("start station id","end station id","route.id2")]

route_fromto<-bike%>%group_by(route.id)%>%
  dplyr::summarise(count=n(),start=`start station id`[1],end=`end station id`[1],general.id=route.id2[1])
rownames(route_fromto)<-route_fromto$route.id

route<-route_fromto%>%group_by(general.id)%>%
  dplyr::summarise(count=sum(count),start=start[1],end=end[1])

x=t(apply(route[,c("start","end")],1,function(vec){sort(vec,decreasing = T)}))
route[,c("start","end")]=x

#save(route,route_fromto,route.list,file="~/Desktop/[ADS]Advanced Data Science/fall2017-project5-group5/data/route.RData")

###use the routes extracted by Lecy
#df<-route[route$general.id%in%names(routes.list),]
df<-route_fromto[route_fromto$route.id%in%names(lecy.list),]
#df<-df[!duplicated(df$general.id),]
route.list1<-lecy.list[df$route.id]
# names(route.list1)<-df$general.id
extracted_index<-df$route.id

route_update<-route_fromto[!route_fromto$route.id%in%extracted_index,]
##delte the routes with frequency lower than 3
route_update<-route_update[route_update$count>=3,]
route_fromto2<-rbind(df,route_update)
write.csv(route_update,"~/Desktop/route_update.csv",row.names = F)
write.csv(stations_info,"~/Desktop/station_info.csv",row.names = F)

library(readr)
library(ggmap)
routename=list.files("~/Desktop/routes/")

for(i in 1:length(routename)){
  print(i)
  j<-routename[i]
  rt<-read.csv(paste("~/Desktop/routes/",j,sep=""))[-1]
  colnames(rt)<-c("lat"   ,"lon" ,  "time" , "start", "end"  )
  jj<-strsplit(j,"")[[1]]
  nn<-length(jj)
  jj<-paste(jj[1:(nn-4)],collapse ="")
  route.list1[[jj]]<-rt
}
length(route.list1)
all_routes<-route.list1
save(all_routes,file="~/Desktop/[ADS]Advanced Data Science/fall2017-project5-group5/data/all_routes.RData")
route_fromto2<-route_fromto2[route_fromto2$route.id%in%names(route.list1),]



for( i in 820:nrow(route_update)){
  
  print( paste( "LOOP NUMBER", i ) )
  flush.console()
  start<-route_update$start[i]
  end<-route_update$end[i]
    rt <-  route( from=c(stations_info[as.character(start),"lng"], stations_info[as.character(start),"lat"]), 
                      to=c(stations_info[as.character(end),"lng"], stations_info[as.character(end),"lat"]), 
                      mode="bicycling",
                      structure="route" 
    ) 
    
    route.name <-route_update$general.id[i]
    
    rt <- cbind( rt, from.to=route.name )
    
    routes.list[[route.name]] <- rt
    #names(routes)[i] <- route.name
}
#i=41 route.name="S.253_to_S.157"




