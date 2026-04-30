# Projeto de Processamento Digital de Imagens (PDI) 📸

Este repositório foi desenvolvido como parte da disciplina de **Processamento Digital de Imagens**. O projeto consiste em uma aplicação desktop funcional construída em **Pascal (Lazarus IDE)** que implementa os principais algoritmos de manipulação, realce e filtragem de imagens digitais.

---

##  Organização do Repositório

O projeto está estruturado da seguinte forma:

* **`/Ex PDI`**: Pasta principal contendo o código-fonte.
    * `unit1.pas`: Lógica de implementação de todos os filtros e funções.
    * `unit1.lfm`: Arquivo de definição da interface gráfica (botões, campos de texto e canvas).
    * `project1.lpi`: Arquivo de projeto do Lazarus.
* **`/ImagemPDI`**: Pasta que contém as imagens de teste.
    * Utilize a imagem **`lena.bmp`** para validar a maioria dos filtros, especialmente os de detecção de bordas e remoção de ruído.

---

## 🛠️ Funcionalidades e Filtros

As funções implementadas podem ser acessadas através da interface do usuário e estão codificadas na pasta `/Ex PDI`. Abaixo, a descrição de cada funcionalidade:

###  Realce e Ajustes Radiométricos
* **Inverter:** Gera o negativo da imagem, invertendo os valores de brilho.
* **Equalizar Histograma:** Recompõe a distribuição de tons de cinza para maximizar o contraste global.
* **Escala Dinâmica ($S = c \cdot r^\gamma$):** Ajusta a intensidade luminosa. Use o campo `EditC` para a constante e `EditGama` para o expoente (valores < 1 clareiam a imagem).

###  Suavização e Tratamento de Ruído
* **Gerar Ruído (10%):** Adiciona ruído aleatório do tipo "Sal e Pimenta" na `Image2`.
* **Filtro Média:** Reduz o ruído através da média dos vizinhos, causando um efeito de leve desfoque (blur).
* **Filtro Mediana:** Filtro robusto que remove ruídos pontuais preservando as bordas da imagem original.

### Segmentação e Bordas
* **Binarizar:** Converte a imagem para preto e branco usando um limiar fixo de 128.
* **Limiar (T):** Permite binarizar a imagem com um valor personalizado inserido na caixa de texto.
* **Sobel:** Identifica bordas horizontais e verticais. O programa exibe a Magnitude e o Ângulo da borda sob o cursor do mouse.
* **Laplaciano:** Realça bordas através de um operador de segunda derivada, destacando transições bruscas.

---

##  Como Utilizar

1.  Abra o **Lazarus IDE**.
2.  Vá em `Projeto > Abrir Projeto` e selecione o arquivo `project1.lpi` dentro da pasta `Ex PDI`.
3.  Pressione `F9` para compilar e rodar.
4.  No programa, clique em **Carregar** e selecione uma imagem na pasta `ImagemPDI`.
5.  Aplique os filtros desejados e observe o resultado na imagem à direita.

---
*Desenvolvido como critério de avaliação para a disciplina de Processamento Digital de Imagens.*
