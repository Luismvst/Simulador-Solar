# Simulador-Solar
Simulador Solar llevado a cabo en el Instituto de Energía Solar. Trabajo de final de grado. 

Objetivo: Medir células multiunión (semiconductores III-V).
Obtener información de cada unión por separado y automatizar los cálculos y la manera de realizar las medidas que actualmente se llevaban a cabo en el laboratorio

Se pretenden controlar mediante un ordenador con IGORPro un simulador solar con cierto grado de automatización.
En él se encuentra el simulador solar, el cuál se podrá controlar para subir o bajar mediante un motor de DC. 
Tendrá unos LED's que actúen para variar el espectro de la luz que reciben las células y podremos dar o quitar energía para regular las fotocorrientes generadas. 
Además nos proponemos a realizar en paralelo la estructura la cual se servirá del software programado en IGORPro. Dispondrá de dos/tres Láseres Led y un puntero láser que les servirá de guía.

Este software realizado en IGORPro nos mostrará los distintos espectros a ajustar de cada subcélula con el del simulador y el legislativo actual, con su Jsc Objetivo según qué célula DUT y REF hayamos escogido. Mediante una medida de la célula de referencia, obtendremos gracias a su espectro teórico cómo afectan condiciones actuales del laboratorio a la célula REF y por tanto al medir la DUT podremos realizar un ajuste real teórico de condiciones, y hallar la cantidad de fotocorriente que será necesaria que los leds produzcan para no saturar la célula y medir correctamente cada SubCélula.

Por último controlaremos una fuente Keithley 2602A, la cual nos aportará las medidas a cuatro puntas necesarias para la toma de datos recibidos de nuestras células (tanto de referencia como DUT). Ideal sería tener varias Keithley 2602A, para poder realizar varias tomas de datos en paralelo. Tendremos que cambiar las punas y la célula cada vez que realicemos una medida.

Autor: Luis Martínez de Velasco Sánchez-Tembleque

NºMatrícula:51747

Escuela Técnica Superior de Ingeniería y Diseño Industrial 

Universidad Politécnica de Madrid
