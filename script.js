// script.js
document.addEventListener('DOMContentLoaded', function() {
  const menuButton = document.getElementById('menuButton');
  const drawer = document.querySelector('.drawer');

  menuButton.addEventListener('click', function() {
    drawer.classList.toggle('open');
  });

  // Initialize the map
  const map = L.map('map').setView([51.509364, -0.128], 13);

  // Add a tile layer to the map (you can use different tile providers)
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  // Add a marker to the map
  L.marker([51.509364, -0.128]).addTo(map)
    .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
    .openPopup();
});







//// script.js
//document.addEventListener('DOMContentLoaded', function() {
//  const menuButton = document.getElementById('menuButton');
//  const drawer = document.querySelector('.drawer');
//
//  menuButton.addEventListener('click', function() {
//    drawer.classList.toggle('open');
//  });
//});