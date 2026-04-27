
let slideAtual = 0;
const totalSlides = document.querySelectorAll('.slide').length;
const wrapper = document.querySelector('.slides-wrapper');
const pontos = document.querySelectorAll('.ponto');
const sliderContainer = document.querySelector('.slider-container');
let tempoTroca = 5000; 
let intervalo;

function irParaSlide(index) {
    slideAtual = index;
    
    const tamanhoSlide = 100 / totalSlides;
    const deslocamento = -(slideAtual * tamanhoSlide);
    
    wrapper.style.transform = `translateX(${deslocamento}%)`;
    
    pontos.forEach(ponto => ponto.classList.remove('ativo'));
    pontos[slideAtual].classList.add('ativo');
}


function proximoSlide() {
    slideAtual++;
    if (slideAtual >= totalSlides) {
        slideAtual = 0; 
    }
    irParaSlide(slideAtual);
}

function iniciarCarrossel() {
    intervalo = setInterval(proximoSlide, tempoTroca);
}

function pausarCarrossel() {
    clearInterval(intervalo);
}

sliderContainer.addEventListener('mouseenter', pausarCarrossel);
sliderContainer.addEventListener('mouseleave', iniciarCarrossel);

// Dá o start inicial
iniciarCarrossel();