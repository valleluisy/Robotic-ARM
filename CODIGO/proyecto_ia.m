%% VARIABLES %%
%Declaracion de posiciones del Robot.
casa1=rpoint(421, 282, 14, -84, 179, 92, 'pose', 'abs', 'lin','speed',20);
casa2=rpoint(-93, 481, 12, -86, 179, 92, 'pose', 'abs', 'lin','speed',20);
pieza1=rpoint(3, 488, -140, -90, 179, 87, 'pose', 'abs', 'lin','speed',20);
pieza2=rpoint(-201, 474, -140, -84, 179, 94, 'pose', 'abs', 'lin','speed',20);
pieza=rpoint(421, 280, -140, -84, 179, 92, 'pose', 'abs', 'lin','speed',20);

%Variables de tiempos de espera.
pau1=5;
pau2=5;

%Variables de estados de captura de imagen.
estado1=0;
estado2=0;
cap2=1;
cap1=1;

%Variables de deteccion de objetos en las img capturadas.
P1=0;
P2=0;
A1=0;
A2=0;

%% CONFIGURACIONES %%

%%configuracion de camara Laptop
vid = videoinput('winvideo', 1,'MJPG_640x480');

%Configuracion de camara exterior
%vid = videoinput('winvideo', 1,'RGB24_640x480');

%Cargamos los archivos de configuracion relacionados a nuestra red neuronal entrenada.
load('matlab.mat')

%% PROGRAMA %% 

%Incialmente movemos el robot a la posicion CASA2, en donde observara la
%paleta de almacenamiento.
rmove(r1, casa2);
disp('moviendo a casa2 posicion inicial')
%Le damos tiempo a que el robot tome la posicion
pause(5) 


% MANTENDREMOS ESTE CICLO REPETITIVO, PUES SIMULARA QUE EL ROBOT ESTE EN
% UN MODO "REPEAT"
while(true)
   
 % Si el robot esta en casa2 procedera a tomar la foto y retornar los objetos detectados    
 if cap2==1
     
       cap2=0;
       estado2=1;
       % con este comando tomamos un fotograma y lo almacenamos en data.
       disp('capturando imagen en casa2')
       pause(1)
       data = getsnapshot(vid);
       
       % con imsubtract extraemos la componente azul de data y la guardamos en diff_im 
       diff_im = imsubtract(data(:,:,3), rgb2gray(data));
       % con imsubtract extraemos la componente roja de data y la guardamos en diff_im 
       diff_im2 = imsubtract(data(:,:,1), rgb2gray(data));
       
       % Binarizamos la imagen con un umbral de 0.18 y se sobreecribe
       diff_im = im2bw(diff_im,0.18);
       % Binarizamos la imagen con un umbral de 0.18 y se sobreecribe
       diff_im2 = im2bw(diff_im2,0.18);
      
       % Elimina todas aquellas detecciones cuyo valor sea menor a 300
       % pixeles (ruido)
       diff_im = bwareaopen(diff_im,300);
       diff_im2 = bwareaopen(diff_im2,300);
      
       % Etiqueta los objetos que poseen conectividad8 
       bw = bwlabel(diff_im, 8);
       bw2 = bwlabel(diff_im2, 8);
      
       % Retorna algunas propiedades importantes para enmarcar los objetos
       % etiquetados anteriormente.
       stats = regionprops(bw, 'BoundingBox', 'Centroid');
       stats2 = regionprops(bw2, 'BoundingBox', 'Centroid');
       
       %Mostramos el fotograma contenido en la variable data
       imshow(data)
    
       % Mantiene en la ventana gráfica la imagen data.
       hold on
    
       % Primer for sirve para enmarcar en un recuadro los objetos,
       % utilizando para ello los parametros devueltos por el comando regionprops
       % En este primer for enmarcamos los objetos de color rojo, aquimismo
       % se indica la posicion de la pieza, tomando como referencia su
       % centro de masa
       for object2 = 1:length(stats2)
         bb = stats2(object2).BoundingBox;
         bc = stats2(object2).Centroid;
         rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
         plot(bc(1),bc(2), '-m+')
         tex3=text(bc(1)+15,bc(2), strcat('Pieza Roja X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
         set(tex3, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
       end
       
       % Segundo for sirve para enmarcar en un recuadro los objetos,
       % utilizando para ello los parametros devueltos por el comando regionprops
       % En este segundo for enmarcamos los objetos de color azul, aqui mismo
       % se indica la posicion de la pieza, tomando como referencia su
       % centro de masa
       for object = 1:length(stats)
         bb = stats(object).BoundingBox;
         bc = stats(object).Centroid;
         rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
         plot(bc(1),bc(2), '-m+')
         tex4=text(bc(1)+15,bc(2), strcat('Pieza Azul X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
         set(tex4, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
       end
       
       % Procedemos a almacenar los datos en nuestras variables, en object
       % se almacenan la cantidad de objetos detectados.
       if object == 1
       A1=1;
       else
       A1=0;
       end
       if object2 == 1
       A2=1;
       else
       A2=0;
       end
       
       hold off   
 end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%luego se movera a casa1 para tomar la siguiente foto
rmove(r1, casa1);
disp('moviendo a casa1')
pause(5)

%procedemos a tomar foto de pieza e identificar si es del tipo rojo o azul,
%parte es una capia de la seccion anterior asi que no sera necesario
%documentarla.
if cap1==1
    
       cap1=0;
       estado1=1;
       disp('capturando imagen en casa1')
       pause(1)
       data = getsnapshot(vid);
    
       diff_im = imsubtract(data(:,:,3), rgb2gray(data));
       diff_im2 = imsubtract(data(:,:,1), rgb2gray(data));
       
       diff_im = im2bw(diff_im,0.18);
       diff_im2 = im2bw(diff_im2,0.18);
      
       diff_im = bwareaopen(diff_im,300);
       diff_im2 = bwareaopen(diff_im2,300);
      
       bw = bwlabel(diff_im, 8);
       bw2 = bwlabel(diff_im2, 8);
      
       stats = regionprops(bw, 'BoundingBox', 'Centroid');
       stats2 = regionprops(bw2, 'BoundingBox', 'Centroid');
       
       imshow(data)
    
       hold on
    
       for object2 = 1:length(stats2)
         bb = stats2(object2).BoundingBox;
         bc = stats2(object2).Centroid;
         rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
         plot(bc(1),bc(2), '-m+')
         tex=text(bc(1)+15,bc(2), strcat('Pieza Roja X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
         set(tex, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
       end
       for object = 1:length(stats)
         bb = stats(object).BoundingBox;
         bc = stats(object).Centroid;
         rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
         plot(bc(1),bc(2), '-m+')
         tex2=text(bc(1)+15,bc(2), strcat('Pieza Azul X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
         set(tex2, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
       end
       
       if object == 1
       P1=1;
       else
       P1=0;
       end
       if object2 == 1
       P2=1;
       else
       P2=0;
       end
       
       hold off   
     
 end
 
 
 
%%%%%%% una vez teniendo los valores iniciales A1,A2,P1 Y P2 se introducen 
%%%%%%% a la red neuronal 
if estado1==1 && estado2==1
    estado1=0;
    estado2=0;
    cap2=1;
    cap1=1;

% Llamamos a nuestras 3 redes neuronales y almacenamos sus respuestas (z y x) para las 
% entradas (A2;A1;P1;P2).
z = sim(network1,[A2;A1;P1;P2]);
y = sim(network2,[A2;A1;P1;P2]);
x = sim(network3,[A2;A1;P1;P2]);

%Concatenamos los valores, aunque no es necesario, o se pudo haber hecho
%con otra logica ya que en un principio el programa estaba hecho para arduino.
union=(x*100)+(y*10)+(z*1);


% con case se selecciona el movimiento a ejecutar
 switch union
    case 0
        disp('casa1')
        cap2=0;
        estado2=1;
        rmove(r1, casa1);
        pause(5)
        
    case 1
        disp('casa2')
        
        rmove(r1, casa2);
        pause(5)
        
    case 10
        disp('pieza')
       
        rmove(r1, pieza);
        pause(5)
        
    case 11
        disp('mover a 1')
        
        rmove(r1, pieza);
        pause(3)
        rmove(r1, casa1);
        pause(3)
        rmove(r1, pieza1);
        pause(5)
        rmove(r1, casa2);
        pause(5)
        
    case 100
        disp('mover a 2')
        
        rmove(r1, pieza);
        pause(3)
        rmove(r1, casa1);
        pause(3)
        rmove(r1, pieza2);
        pause(5)
        rmove(r1, casa2);
        pause(5)
 end
end

end