
/*
 * Toggle display of element by ID
 */
function toggleDisplay(id) {
  var el = document.getElementById(id);
  
  if (el.style.display == '') {
    el.style.display = 'none';
  } else {
    el.style.display = '';
  }
}


function toggleMobileMenu() {
  toggleDisplay('site-mobile-menu-icon-open');
  toggleDisplay('site-mobile-menu-icon-close');
  toggleDisplay('site-mobile-menu');
}


window.addEventListener('resize', function (event) {
  var el = document.getElementById('site-mobile-menu');
  el.style.display = 'none';
  
  el = document.getElementById('site-mobile-menu-icon-open');
  el.style.display = '';
  
  el = document.getElementById('site-mobile-menu-icon-close');
  el.style.display = 'none';
});


// Attach FastClick to mobile menu buttons
FastClick.attach(document.getElementById('site-nav-mobile'));
