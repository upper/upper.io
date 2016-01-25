var isFirefox = typeof InstallTrigger !== 'undefined';   // Firefox 1.0+

var adaptersTrigger,
  sectionsTrigger,
  sectionsMenu,
  upper;

adaptersTrigger = document.getElementById('adapters-menu-trigger');
sectionsTrigger = document.getElementById('sections-menu-trigger');
sectionsMenu = document.getElementById('sections-menu');

upper = {};
upper.touches = {};

upper.scrollto = function (target){
  var link,
    element,
    position;

  link = target.getAttribute('href');
  switch (link){
    case null:
      return;
      break;
    case '#':
      position = 0;
      break;
    default:
      link = link.replace('#', '');
      element = document.getElementsByName(link)[0];
      position = element.offsetTop - 55;
  }

  scroll(position, 300);

  function scroll (position, time){
    var difference,
      duration,
      amount;

		var scrollElement;
		if (isFirefox) {
			scrollElement = document.documentElement;
		} else {
			scrollElement = document.body;
		}

    if (time <= 0) return;
    difference = position - scrollElement.scrollTop;
    amount = difference / time * 10;

    setTimeout(function() {
      scrollElement.scrollTop = scrollElement.scrollTop + amount;
      if (scrollElement.scrollTop == position) return;
      scroll(position, time - 10);
    }, 3);
  }


};

upper.touchonly = function(){

  /* ------------ CONTEXTUAL MENU TOUCH */
  sectionsTrigger.addEventListener('touchstart', function(e) {
    document.body.classList.add('menu-sections-open');
  });

  sectionsTrigger.addEventListener('touchmove', function(e){
    e.preventDefault();
    var hovered,
      target;

    hovered = sectionsMenu.querySelector('.hover');
    if( hovered !== null){
      hovered.classList.remove('hover');
    }
    upper.touches.x = e.touches[0].clientX;
    upper.touches.y = e.touches[0].clientY;
    target = document.elementFromPoint(upper.touches.x, upper.touches.y);
    target.classList.add('hover');
  });

  sectionsTrigger.addEventListener('touchend', function(e){
    target = document.elementFromPoint(upper.touches.x, upper.touches.y);
    document.body.classList.remove('menu-sections-open');
    upper.scrollto(target);
  });

};

upper.notouch = function (){

  /* ------------ CONTEXTUAL MENU NO TOUCH */
  var sectionsMenuItems;
	if (sectionsTrigger) {
		sectionsTrigger.addEventListener('click', function(){
			document.body.classList.toggle('menu-sections-open');
		});
	}

	if (sectionsMenu) {
		sectionsMenuItems = sectionsMenu.querySelectorAll('a');
		for (i in sectionsMenuItems){
			if( isNaN(i) ) return;
			sectionsMenuItems[i].addEventListener('click', function(e){
				e.preventDefault();

				upper.scrollto(e.target);
				document.body.classList.toggle('menu-sections-open');
			});
		}
	}

};




/* ------- MAIN MENU */
adaptersTrigger.addEventListener('click', function(e) {
  document.body.classList.toggle('menu-open');
});


if ( 'ontouchstart' in document.documentElement ){

  upper.touchonly();

} else {

  upper.notouch();

}
