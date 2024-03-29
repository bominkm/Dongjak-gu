library(dplyr)
library(fpc)
library(cluster)
library(stringr)
library(clusterSim)
library(factoextra)

dat0 <- read.csv( "C:/Users/user/Desktop/BOAZ/동작구 공모전/사용데이터/reallyfinal.csv", encoding = 'CP949')

sum(is.na(dat0))
dat0[!complete.cases(dat0),]
dat0 <- na.omit(dat0)

data <- dat0 %>% mutate(길이 = 길이/100) %>% 
  mutate(시설 = (아파트+치안센터)/길이, 
           CCTV = CCTV/길이, 
           비상벨 = 비상벨/길이, 
           보안등 = (가로등 + 보안등)/길이) %>% 
  dplyr::select(도로명,시설, CCTV, 비상벨, 보안등) 

#'로' 제외
data_ <- data %>% filter(!(data$도로명 %in% grep("로$",data$도로명, value = T)))
str(data_)

# Ward's method clustering
data1 <- data_[2:5]
data1 <- scale(data1, center = T, scale = T)
d.data <- dist(data1, method = "euclidean")
data.ward <- hclust(d.data, method = "ward.D2")
c1.data <- cutree(data.ward, 6)
table(c1.data)
which(c1.data == 1)

par(mfrow = c(1,1))
plot(data.ward, hang = -1)
rect.hclust(data.ward, 5, border = 1:5)

# k-means clustering
for (i in 1:20){
set.seed(1)
data.k <- kmeans(data1, i, nstart = 50)
result <- index.G1 (data1,data.k$cluster,centrotypes="centroids")
print(result)
}

set.seed(1)
data.k <- kmeans(data1, 6, nstart = 50)
data.k
which(data.k$cluster == 4)

data.pr <- prcomp(data1, retx = T, center = T, scale. = T)
summary(data.pr)

data.loading <- data.pr$rotation %*% diag(data.pr$sdev)
round(data.loading[,1:2],3)
data.k$centers
fviz_cluster(data.k, data1, cluster = data.k)

tab_cluster <- cbind(data_, data.k$cluster)
write.csv(tab_cluster, "final.csv")
