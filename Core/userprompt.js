function askUser() {
    const div = document.createElement('div');
    const shadowRoot = div.attachShadow({ mode: 'closed' });
    shadowRoot.innerHTML = `
<style>
    .wrapper {
        position: absolute;
        left: 0;
        top: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(255,255,255,0.65);
        backdrop-filter: blur(5px);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 2147483647; /*max*/
    }
    .form {
        display: inline-block;
        width: 80%;
        font-size: 16px;
        font-family: sans-serif;
        color: #333;
        background: white;
        border-radius: 15px;
        box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.08), 0px 2px 4px rgba(0, 0, 0, 0.1);
        padding: 15px;
    }
    button {
        border-radius: 8px;
        padding: 11px 22px;
        font-weight: bold;
        margin: auto;
        border-color: #3969EF;
        border: none;
        font-size: 14px;
        position: relative;
        cursor: pointer;
        box-shadow: none;
        z-index: 2147483646;
        background: rgba(34, 34, 34, 0.1);
        margin-right: 10px;
    }
    button.default {
        background: #3969EF;
        color: #FFFFFF;
    }
    .header {
        font-size: 20px;
    }
</style>
<div class='wrapper'>
<div class='form'>
    <p class='header'>This site requested your location. Would you like to share it?</p>
    <p><button id='share-no' class='default'>No</button></p>
    <p><button id='share-city'>Share my city</button></p>
    <p><button id='share-country'>Share my country</button></p>
    <p><button id='share-precise'>Share my precise location</button>
    <br/><input type='radio' name='precise-time' value='24' checked> temporarily <input type='radio' name='precise-time' value='forever'> forever</p>
</div>
</div>
    `;

    document.body.appendChild(div);

    function close() {
        document.body.removeChild(div);
    }

    let resolve;
    const promise = new Promise((res) => resolve = res);

    shadowRoot.querySelector('#share-no').addEventListener('click', () => { resolve('no'); close(); });
    shadowRoot.querySelector('#share-city').addEventListener('click', () => { resolve('city'); close(); });
    shadowRoot.querySelector('#share-country').addEventListener('click', () => { resolve('country'); close(); });
    shadowRoot.querySelector('#share-precise').addEventListener('click', () => { resolve('precise'); close(); });

    return promise;
}
