# -*- coding: utf-8 -*-
"""
Created on Fri Nov  6 09:10:16 2020

@author: Sys10
"""


#PREPROCESAMIENTO DE DATOS
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#importación de datos
dataset = pd.read_csv('')
x = dataset.iloc[:,:-1].values
y = dataset.iloc[:,3]

#SEPARACION DE DATOS PARA TRAIN Y TEST
from sklearn.model_selection import train_test_split
x_train, x_test, y_train, y_test =  train_test_split(x, y, test_size = 0.2, random_state=0)

#Escalado de caracteristicas (escalado = sc)
#from sklearn.preprocessing import StandardScaler
#sc_x = StandardSacaler()
#x_train = sc_x.fit_transform(x_train)
#x_test = sc_x.fit_transform(x_test)
