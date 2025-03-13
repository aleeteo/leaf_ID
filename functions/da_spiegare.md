# Robe da spiegare nelle slide

## features

### forma

- features di forma base
  - compactness
  - circularity
  - eccentricity
- Hu inveriant moments

### texture

- GLCM
- edge medio interno
- No LBP
  - nonostante sia possibile rendere lbp invariate alla rotazione non è
    possibile fare lo stesso con la scala
  - In realtà è possibile, ma sarebbe necessario cono scere la la scala
    della variazione di dimensione delle fogli oppure il calcolo di LBP su
    molteplici scale, rendendolo difficile da gestire

### edge

Si tratte di features numeriche estratte dell'istogramma della signature
dell'edge. La signature è stata calcolata a partire da un cambio di coordinate
(in coordinate polari) della maschera binaria ed ha subito una normalizazione
max (per preservare la varianza).
Fetures ricavate:

- Media delle distanze
- Varianza delle distanze
- Curtosi delle distanze
- entropia delle distanze

### colore

## valutazione delle features

### visualizzazione delle features

- boxplot
  - permette di visualizzare a colpo d'occhio le distribuzioni delle features
    rispetto alle classi
- scatter Plot
  - permette di visualizzare la distribuzione delle foglie (divise per classi)
    nello spazio cartesiano delle features

### metriche di bontà delle features

- Fisher Score
- distanza di Bhattacharyya
- matrice di correlazione
