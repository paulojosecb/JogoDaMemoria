# JogoDaMemoria

Este projeto faz parte do trabalho final da disciplina de Redes de Computadores do curso de Sistemas e Mídias Digitais da Universidade Federal do Ceará.

Aluno: Paulo José

O projeto trata-se de um jogo da memória multiplayer para iOS utilizando TCP Sockets. Em conjunto com este projeto também o repositório https://github.com/paulojosecb/jogoDaMemoriaServer que contem o código para o servidor em Node.js que gerencia toda as conexões sockets e toda a lógica do jogo. 

Neste repositório encontra-se o código do projeto iOS do jogo. Tal projeto foi estruturado da seguinte maneira:

- ViewController: Responsável por gerenciar as ações na interface e realizar a ponte entre o GameState(que vem do servidor Node.js) e o GridView, que gerencia os cartões na tela e as respectivas ações e animações
- GridView: Responsável por mostrar os cartões e gerenciar toques e animações nos mesmos, além de notificar a ViewController de erros e acertos dos jogadores. 
- GameState: Classe responsável por realizar a ponte entre a ViewController e o estado do jogo conectado via Socket. 
- SocketManager: Classe responsável por enviar e receber as mensagens Socket assim como realizar a conexão com o servidor. 