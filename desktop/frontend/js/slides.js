/* Controle do Carrossel de Banners - Nutriesportiva São Camilo
    Este script gerencia a transição automática de slides, a atualização
    dos indicadores (pontos) e a interatividade de pausa ao pairar o mouse.
*/

let slideAtual = 0;
const totalSlides = document.querySelectorAll('.slide').length;
const wrapper = document.querySelector('.slides-wrapper');
const pontos = document.querySelectorAll('.ponto');
const sliderContainer = document.querySelector('.slider-container');

// Define o tempo de permanência em cada slide (5 segundos)
const tempoTroca = 5000; 
let intervalo;

/**
 * Move o wrapper dos slides para a posição correspondente ao índice informado.
 * @param {number} index - O índice do slide para o qual deseja navegar.
 */
function irParaSlide(index) {
    slideAtual = index;
    
    // Calcula o percentual de deslocamento com base no número total de slides
    const tamanhoSlide = 100 / totalSlides;
    const deslocamento = -(slideAtual * tamanhoSlide);
    
    // Aplica a transformação CSS para mover o banner horizontalmente
    wrapper.style.transform = `translateX(${deslocamento}%)`;
    
    // Atualiza o estado visual dos pontos indicadores
    pontos.forEach(ponto => ponto.classList.remove('ativo'));
    if (pontos[slideAtual]) {
        pontos[slideAtual].classList.add('ativo');
    }
}

/**
 * Incrementa o índice do slide e reinicia a contagem ao chegar no último.
 */
function proximoSlide() {
    slideAtual++;
    if (slideAtual >= totalSlides) {
        slideAtual = 0; 
    }
    irParaSlide(slideAtual);
}

/**
 * Inicia o temporizador para a troca automática de slides.
 */
function iniciarCarrossel() {
    intervalo = setInterval(proximoSlide, tempoTroca);
}

/**
 * Interrompe o temporizador da troca automática.
 */
function pausarCarrossel() {
    clearInterval(intervalo);
}

/* Eventos para pausar o carrossel quando o usuário interage com o banner */
if (sliderContainer) {
    sliderContainer.addEventListener('mouseenter', pausarCarrossel);
    sliderContainer.addEventListener('mouseleave', iniciarCarrossel);
}

/* Inicialização do componente */
document.addEventListener('DOMContentLoaded', () => {
    // Garante que o primeiro ponto comece ativo
    if (pontos.length > 0) {
        pontos[0].classList.add('ativo');
    }
    iniciarCarrossel();
});