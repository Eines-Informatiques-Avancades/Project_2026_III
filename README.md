# Project_2026_III

List of participants:

- JAVIER JORGE FERNANDEZ (jjavifdez)

-Reference to energy calculation of dihedral angule in poliethylene: https://www-sciencedirect-com.sire.ub.edu/science/article/pii/S2213138822001485


-En cada bucle de MC se realizan varios giros de ángulo dihedro. De momento son natoms-3 giros. La idea es intentar optimizar para que al principio se permitan muchos giros, y poco a poco reducir tanto el numero de giros como el ángulo de giro gradualmente.

-Lo que pasa al realizar muchos cambios aleatorios, es que la cadena puede chocar muy fácil, por lo que hay mucho rechazo.

-Ahora lo que vamos a hacer es intentar dar mas probabilidad a giros en posiciones terminales, para evitar que la molécula se quede atrapada en un mínimo dominado por el potencial de L-J, y que se exploren ángulos correspondientes a los dos mínimos de 60 y -60 del potencial del ángulo dihedro

-Observamos que este hecho no hace variar el diagrama de torsión. Un aumento de la temperatura de simulacion, forma un histograma con angulos dihedros que tienden a 0, pero no se nota una abundancia aparente en valores proximos a 0


