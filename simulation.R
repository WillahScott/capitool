
################
#    CapiTool Simulation Auxiliary Functions
#               by WillahScott, March 2015
################


#  I.  READ DATA
k.vivo <- read.csv("../data/k_vivo.csv")
k.moroso <- read.csv("../data/k_moroso.csv")


# II.  CAPITAL REQUIREMENTS CURVE - CRD IV

    ## DEFAULTED ASSETS
# Calculate individual specific impairment for defaulted assets
get.k.moroso <- function(k.moroso, breakdown=FALSE) {
    k.moroso$Impairment <- with(k.moroso, LGD_STD * EAD_STD)
    k.moroso$ELbe <- with(k.moroso,Impairment/EXPOSURE)
    k.moroso$RW <- with(k.moroso,LGD_DT - ELbe)
    k.moroso$RW <- (k.moroso$RW > 0) * k.moroso$RW
    k.moroso$RWA <- with(k.moroso,12.5 * RW * EXPOSURE)
    if (breakdown) {
        Capital.def <- tapply(k.moroso$RWA, k.moroso$PRODUCTO, sum)   
    } else {
        Capital.def <- sum(k.moroso$RWA)
    }
    return(Capital.def * .08)
}

    ## PERFORMING PORTOFOLIO
# Auxiliary functions
alpha <- function(x) (1 - exp(-50*x))/(1 - exp(-50))
r <- function(x)  0.12 * alpha(x) + 0.24 * (1 - alpha(x))
b <- function(PD) (.11852 - .05478*log(PD) )**2
w <- function(PD,M) (1 + (M - 2.5) * b(PD) ) / (1 - 1.5*b(PD) ) * 12.5 * 1.06

cap.vivo <- function(LGD,PD,M) LGD*(pnorm((qnorm(PD) + sqrt(r(PD))
                                           * qnorm(.999))/ (1 + r(PD)) )
                                    - PD)* w(PD,M)

get.k.vivo <- function(k.vivo, breakdown=FALSE) {
    k.vivo$RW <- with(k.vivo, cap.vivo(LGD=LGD_DT, PD=PD_TTC, M=M))
    k.vivo$RWA <- with(k.vivo, RW * EXPOSURE)
    if (breakdown) {
        Capital.perf <- tapply(k.vivo$RWA, k.vivo$PRODUCTO, sum)    
    } else {
        Capital.perf <-sum(k.vivo$RWA)
    }
    return(Capital.perf * .08)
}


# III. STRESS SCENARIO IMPACTS ON RISK PARAMETERS

# Vector with Macro economic scenario, MACRO2 has the color
MACRO <- rep(1,5)
MACRO2 <- rep("Verde",5)

PD.weights <- c(.7,1,1.25,1.6)
LGD.weights <- c(.7,1,1.15,1.35)

macro.v1 <- c(.5,.1,0,0,.4)
macro.v2 <- c(.3,.25,.25,0,.2)
macro.v3 <- c(.3,.3,.2,.2,0)

macro.AV <- c(.3,.3,0,.4,0)
macro.HP <- c(.1,0,0,.9,0)
macro.LS <- c(.1,.2,.7,0,0)
macro.PR <- c(.6,.15,0,0,.25)
macro.TR <- c(.05,.15,.8,0,0)


get.PD <- function(data,MACRO) {
    if(">250" %in% unique(data$VENTAS_CAT) ) {
        f1 <- PD.weights[MACRO[1]]*macro.v1[1] + PD.weights[MACRO[2]]*macro.v1[2] +
            PD.weights[MACRO[3]]*macro.v1[3] + PD.weights[MACRO[4]]*macro.v1[4] +
            PD.weights[MACRO[5]]*macro.v1[5]
        data[which(data$VENTAS_CAT == ">250"),]$PD_TTC <- data[which(data$VENTAS_CAT == ">250"),]$PD_TTC * f1
    }  
    if("(100, 250]" %in% unique(data$VENTAS_CAT) ) {
        f2 <- PD.weights[MACRO[1]]*macro.v2[1] + PD.weights[MACRO[2]]*macro.v2[2] +
            PD.weights[MACRO[3]]*macro.v2[3] + PD.weights[MACRO[4]]*macro.v2[4] +
            PD.weights[MACRO[5]]*macro.v2[5]
        data[which(data$VENTAS_CAT == "(100, 250]"),]$PD_TTC <- data[which(data$VENTAS_CAT == "(100, 250]"),]$PD_TTC * f2
    }
    if("<= 100" %in% unique(data$VENTAS_CAT) ) {        
        f3 <- PD.weights[MACRO[1]]*macro.v3[1] + PD.weights[MACRO[2]]*macro.v3[2] +
            PD.weights[MACRO[3]]*macro.v3[3] + PD.weights[MACRO[4]]*macro.v3[4] +
            PD.weights[MACRO[5]]*macro.v3[5]
        data[which(data$VENTAS_CAT == "<= 100"),]$PD_TTC <- data[which(data$VENTAS_CAT == "<= 100"),]$PD_TTC * f3
    }
    return(data)
}


get.LGD <- function(data,MACRO) {
    if("Guarantee" %in% unique(data$PRODUCTO) ) {
        f.AV <- LGD.weights[MACRO[1]]*macro.AV[1] + LGD.weights[MACRO[2]]*macro.AV[2] +
            LGD.weights[MACRO[3]]*macro.AV[3] + LGD.weights[MACRO[4]]*macro.AV[4] +
            LGD.weights[MACRO[5]]*macro.AV[5]
        data[which(data$PRODUCTO == "Guarantee"),]$LGD_DT <- data[which(data$PRODUCTO == "Guarantee"),]$LGD_DT * f.AV
    }
    if("Mortgage" %in% unique(data$PRODUCTO) ) {
        f.HP <- LGD.weights[MACRO[1]]*macro.HP[1] + LGD.weights[MACRO[2]]*macro.HP[2] +
            LGD.weights[MACRO[3]]*macro.HP[3] + LGD.weights[MACRO[4]]*macro.HP[4] +
            LGD.weights[MACRO[5]]*macro.HP[5]
        data[which(data$PRODUCTO == "Mortgage"),]$LGD_DT <- data[which(data$PRODUCTO == "Mortgage"),]$LGD_DT * f.HP
    }
    if("Lease" %in% unique(data$PRODUCTO) ) {
        f.LS <- LGD.weights[MACRO[1]]*macro.LS[1] + LGD.weights[MACRO[2]]*macro.LS[2] +
            LGD.weights[MACRO[3]]*macro.LS[3] + LGD.weights[MACRO[4]]*macro.LS[4] +
            LGD.weights[MACRO[5]]*macro.LS[5]
        data[which(data$PRODUCTO == "Lease"),]$LGD_DT <- data[which(data$PRODUCTO == "Lease"),]$LGD_DT * f.LS
    }
    if("Consumer Loan" %in% unique(data$PRODUCTO) ) {
        f.PR <- LGD.weights[MACRO[1]]*macro.PR[1] + LGD.weights[MACRO[2]]*macro.PR[2] +
            LGD.weights[MACRO[3]]*macro.PR[3] + LGD.weights[MACRO[4]]*macro.PR[4] +
            LGD.weights[MACRO[5]]*macro.PR[5]
        data[which(data$PRODUCTO == "Consumer Loan"),]$LGD_DT <- data[which(data$PRODUCTO == "Consumer Loan"),]$LGD_DT * f.PR
    }
    if("Credit Card" %in% unique(data$PRODUCTO) ) {
        f.TR <- LGD.weights[MACRO[1]]*macro.TR[1] + LGD.weights[MACRO[2]]*macro.TR[2] +
            LGD.weights[MACRO[3]]*macro.TR[3] + LGD.weights[MACRO[4]]*macro.TR[4] +
            LGD.weights[MACRO[5]]*macro.TR[5]
        data[which(data$PRODUCTO == "Credit Card"),]$LGD_DT <- data[which(data$PRODUCTO == "Credit Card"),]$LGD_DT * f.TR    
    }
    return(data)
}





