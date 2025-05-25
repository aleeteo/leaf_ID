% I seguenti valori sono stati estratti da un analisi
% dell'esecuzione di extract_data tramite profiler matlab
mean_times = [4.937, 0.038, 0.529, 0.245, 1.628, 0.166, 0.025];
figure;
barh(mean_times);  % Uso di barh per barre orizzontali
yticklabels({'HuGray', 'RILBP', 'edge histogram stats', 'Zernike momente', 'color stats', 'edge signature stats', 'Fourier descriptors'});
xlabel('Tempo medio (s)');
title('Tempo medio di calcolo per modulo di descrittori');
grid on;
