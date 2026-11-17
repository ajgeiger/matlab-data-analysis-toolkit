% test class:
name = {'Acceleration','Cylinders','MPG','Weight','Horsepower','Displacement'};
data = [Acceleration,Cylinders,MPG,Weight,Horsepower,Displacement];

data = factorMethods('gen',name,data,2);
figure(1)
factorMethods('plot',data)

figure(2)
factorMethods('bar',data)