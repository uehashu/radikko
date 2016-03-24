// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$(window).load(function(){
    $('.multiple-items').slick({
	dots: true,
	infinite: true,
	slidesToShow: 4,
	slidesToScroll: 1,
	draggable: true,
	arrows: true
    });
});
