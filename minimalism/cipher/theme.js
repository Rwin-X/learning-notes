// Runs before first paint: restores look and light/dark choice without a flash.
(function () {
  var LOOKS = ['mono', 'paper', 'swiss', 'terminal', 'soft', 'void'];
  var root = document.documentElement;
  var look = 'mono';
  try {
    var q = new URLSearchParams(location.search).get('look');
    var saved = localStorage.getItem('cipher-look');
    look = LOOKS.indexOf(q) > -1 ? q : LOOKS.indexOf(saved) > -1 ? saved : 'mono';
    var t = localStorage.getItem('cipher-theme');
    if (t === 'dark' || t === 'light') root.setAttribute('data-theme', t);
  } catch (e) {}
  root.setAttribute('data-look', look);
})();
