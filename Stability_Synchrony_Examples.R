require(reshape2)

setwd("/Users/keirajohnson/Box Sync/Keira_Johnson/SiSyn/NutrientRegimes")

all_clusters<-read.csv("Annual_Nutrient_Regimes.csv")

unique(all_clusters$site)

all_clusters_melt<-melt(all_clusters, id.vars=c("X","site","solute","year","clust"))

sync_stab<-read.csv("Annual_Pairwise_Synchrony.csv")

sync_stab <- sync_stab %>%
  separate(stream_year_char, into = c("Stream_Name", "Year"), sep = "_")

sync_stab_sum <- sync_stab %>%
  dplyr::group_by(Solute1, Solute2, Stream_Name) %>% 
  dplyr::summarise(cv_ASI=sd(ASI.JS_obs), mean_ASI=mean(ASI.JS_min))

chem_raw<-read.csv("/Users/keirajohnson/Box Sync/Keira_Johnson/SiSyn/Full_Results_WRTDS_kalman_monthly_filtered.csv")

chem_wide<-chem_raw %>%
  select(c(2,4,6,9,11)) %>%
  pivot_wider(values_from = Conc_mgL, names_from = chemical) %>%
  mutate(N = case_when(
    is.na(NOx)~NO3,
    is.na(NO3)~NOx,
    .default = NA
  )) %>%
  select(1,2,3,4,6,9)


p1<-all_clusters_melt %>%
  filter(site=="TELESKI" & solute %in% c("N", "P")) %>%
  ggplot(aes(variable, value))+geom_line(aes(group=year, col=year))+facet_wrap(~solute, scales = "free_y")+
  ggtitle("Becoming more synchronous and stable")+theme_classic()+
  theme(legend.position = "right", text = element_text(size = 15))+scale_x_discrete(labels=seq(1,12,1))+
  labs(y="Z-Score Norm Conc", x="Month", col="Year")+ylim(-2.5,3.9)+
  scale_color_gradient(low = "black", high = "grey90")

p1

p2<-sync_stab %>%
  filter(Stream_Name=="TELESKI" & Solute1=="N"& Solute2=="P") %>%
  ggplot(aes(as.numeric(Year), 1-ASI.JS_min))+geom_point()+ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="Synchrony")+
  theme(text = element_text(size = 15))+ylim(0.5,1)

p2

p3<-sync_stab %>%
  filter(Stream_Name=="TELESKI" & Solute1=="N"& Solute2=="P") %>%
  ggplot(aes(as.numeric(Year), shift))+geom_point()+ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="Shift (months)")+
  theme(text = element_text(size = 15))+
  ylim(0,6)

p3

p4<-chem_wide %>%
  select(Stream_Name, Month, Year, N, P) %>%
  filter(Stream_Name=="TELESKI", Year > 1994) %>%
  mutate(ratio = N/P) %>%
  ggplot(aes(as.numeric(Year), ratio))+geom_point(aes(col=(Month)))+
  geom_line(aes(col=(Month), group=Month))+
  ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="N:P")+
  theme(text = element_text(size = 15),
        legend.position = "right")+
  scale_color_gradientn(
    colours = cet_pal(11, "c4s"), 
    breaks = seq(1,12,1)
  ) +
  labs(col="Month")

p4

k1<-ggarrange(p2, p3, p4, nrow = 1, widths = c(0.3,0.3,0.35))  
ex1<-ggarrange(p1, k1, nrow = 2)

ex1

p1<-all_clusters_melt %>%
  filter(site=="KENT AT SEDGWICK" & solute %in% c("DSi", "P")) %>%
  ggplot(aes(variable, value))+geom_line(aes(group=year, col=year))+facet_wrap(~solute, scales = "free_y")+
  ggtitle("Asynchronous, out-of-phase, and unstable")+theme_classic()+
  theme(legend.position = "right", text = element_text(size = 15))+scale_x_discrete(labels=seq(1,12,1))+
  labs(y="Z-Score Norm Conc", x="Month", col="Year")+ylim(-2.5,3.9)+
  scale_color_gradient(low = "black", high = "grey90")

p1

p2<-sync_stab %>%
  filter(Stream_Name=="KENT AT SEDGWICK" & Solute1=="DSi"& Solute2=="P") %>%
  ggplot(aes(as.numeric(Year), 1-ASI.JS_min))+geom_point()+ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="Synchrony")+
  theme(text = element_text(size = 15))+ylim(0.5,1)

p2

p3<-sync_stab %>%
  filter(Stream_Name=="KENT AT SEDGWICK" & Solute1=="DSi"& Solute2=="P") %>%
  ggplot(aes(as.numeric(Year), shift))+geom_point()+ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="Shift (months)")+
  theme(text = element_text(size = 15))+
  ylim(0,6)

p3

p4<-chem_wide %>%
  select(Stream_Name, Month, Year, DSi, P) %>%
  filter(Stream_Name=="KENT AT SEDGWICK", Year < 2013) %>%
  mutate(ratio = DSi/P) %>%
  ggplot(aes(as.numeric(Year), ratio))+geom_point(aes(col=(Month)))+
  geom_line(aes(col=(Month), group=Month))+
  ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="DSi:P")+
  theme(text = element_text(size = 15))+
  scale_color_gradientn(
    colours = cet_pal(11, "c4s"), 
    breaks = seq(1,12,1)
  ) +
  labs(col="Month")

p4

k2<-ggarrange(p2, p3, p4, nrow = 1, widths = c(0.3, 0.3, 0.35))  
ex2<-ggarrange(p1, k2, nrow = 2)

ex2


p1<-all_clusters_melt %>%
  filter(site=="Kalixalven" & solute %in% c("DSi", "N")) %>%
  ggplot(aes(variable, value))+geom_line(aes(group=year, col=year))+facet_wrap(~solute, scales = "free_y")+
  ggtitle("Synchronous, in-phase, and stable")+theme_classic()+
  theme(legend.position = "right", text = element_text(size = 15))+scale_x_discrete(labels=seq(1,12,1))+
  labs(y="Z-Score Norm Conc", x="Month", col="Year")+ylim(-2.5,3.9)+
  scale_color_gradient(low = "black", high = "grey90")

p1

p2<-sync_stab %>%
  filter(Stream_Name=="Kalixalven" & Solute1=="DSi"& Solute2=="N") %>%
  ggplot(aes(as.numeric(Year), 1-ASI.JS_obs))+geom_point()+ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="Synchrony")+
  theme(text = element_text(size = 15))+ylim(0.5,1)+
  scale_x_continuous(breaks = c(2010, 2014, 2018, 2022), labels = c(2010, 2014, 2018, 2022))

p2

p3<-sync_stab %>%
  filter(Stream_Name=="Kalixalven" & Solute1=="DSi"& Solute2=="N") %>%
  ggplot(aes(as.numeric(Year), shift))+geom_point()+ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="Shift (months)")+
  theme(text = element_text(size = 15))+
  ylim(0,6)+
  scale_x_continuous(breaks = c(2010, 2014, 2018, 2022), labels = c(2010, 2014, 2018, 2022))

p3

p4<-chem_wide %>%
  select(Stream_Name, Month, Year, DSi, N) %>%
  filter(Stream_Name=="Kalixalven", Year < 2023) %>%
  mutate(ratio = DSi/N) %>%
  ggplot(aes(as.numeric(Year), ratio))+geom_point(aes(col=(Month)))+
  geom_line(aes(col=(Month), group=Month))+
  ggtitle(" ")+
  theme_classic()+
  labs(x="Year", y="DSi:N")+
  theme(text = element_text(size = 15))+
  scale_color_gradientn(
    colours = cet_pal(11, "c4s"), 
    breaks = seq(1,12,1)
  ) +
  labs(col="Month")+
  scale_x_continuous(breaks = c(2010, 2014, 2018, 2022), labels = c(2010, 2014, 2018, 2022))

p4

k3<-ggarrange(p2, p3, p4, nrow = 1, widths = c(0.3, 0.3, 0.35))  
ex3<-ggarrange(p1, k3, nrow = 2)

ex3

p1<-all_clusters_melt %>%
  filter(site=="TAMAR AT GUNNISLAKE" & solute %in% c("DSi", "P")) %>%
  ggplot(aes(variable, value))+geom_line(aes(group=year, col=year))+facet_wrap(~solute, scales = "free_y")+
  ggtitle("Becoming more stable, more out-of-phase, diverging stoichiometry")+theme_bw()+
  theme(legend.position = "right", text = element_text(size = 15))+scale_x_discrete(labels=seq(1,12,1))+
  labs(y="Z-Score Norm Conc", x="Month", col="Year")+ylim(-2.5,3.7)

p1

p2<-sync_stab %>%
  filter(Stream_Name=="TAMAR AT GUNNISLAKE" & Solute1=="DSi"& Solute2=="P") %>%
  ggplot(aes(as.numeric(Year), 1-ASI.JS_min))+geom_point()+ggtitle(" ")+
  theme_bw()+
  labs(x="", y="Synchrony")+
  theme(text = element_text(size = 15))+ylim(0.5,1)

p2

p3<-sync_stab %>%
  filter(Stream_Name=="TAMAR AT GUNNISLAKE" & Solute1=="DSi"& Solute2=="P") %>%
  ggplot(aes(as.numeric(Year), shift))+geom_point()+ggtitle(" ")+
  theme_bw()+
  labs(x="", y="Shift (months)")+
  theme(text = element_text(size = 15))+
  ylim(0,6)

p3

p4<-chem_wide %>%
  select(Stream_Name, Month, Year, DSi, P) %>%
  filter(Stream_Name=="TAMAR AT GUNNISLAKE", Year < 2013) %>%
  mutate(ratio = DSi/P) %>%
  ggplot(aes(as.numeric(Year), ratio))+geom_point(aes(col=as.factor(Month)))+
  geom_line(aes(col=as.factor(Month), group=Month))+
  ggtitle(" ")+
  theme_bw()+
  labs(x="", y="DSi:P")+
  theme(text = element_text(size = 15))+
  scale_color_manual(values = cet_pal(n=12, name = "c4s"))+
  labs(col="Month")

p4

k4<-ggarrange(p2, p3, p4, nrow = 1, widths = c(0.3, 0.3, 0.37))  
ex4<-ggarrange(p1, k4, nrow = 2)

ex2


pdf("Example_Lines_SynStab_Updated.pdf", width = 11, height = 18)

ggarrange(ex3, ex1, ex2, nrow = 3)

dev.off()

