const root = document.getElementById('test-sites');
const cmpTemplate = document.getElementById('test-cmp-row');
const siteTemplate = document.getElementById('test-site-row');

// dummy CMP
const button = document.createElement('button');
button.innerText = 'This should be clicked automatically.';
button.id = 'reject-all';
document.getElementById('privacy-test-page-cmp-test').appendChild(button);
button.addEventListener('click', (ev) => {
    ev.target.innerText = 'I was clicked!';
    window.results.results.push('button_clicked');
});

window.results = {
    page: 'autoconsent',
    results: []
};
