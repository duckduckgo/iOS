//
//  metadata-stripper.js
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

(function() {
    function inject(scriptText) {
        const script = document.createElement('script');
        script.textContent = scriptText;
        (document.head || document.documentElement).appendChild(script);
        (document.head || document.documentElement).removeChild(script);
    }

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
        .button-row {
            display: flex;
            flex-direction: row;
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
        <p class='header'>Would you like to strip identifying metadata from this file?</p>
        <div class='button-row'>
            <p><button id='strip-yes' class='default'>Yes</button></p>
            <p><button id='strip-no'>No</button></p>
        </div>
    </div>
    </div>
        `;

        document.body.appendChild(div);
        alertShowing = true;
    
        function close() {
            document.body.removeChild(div);
            alertShowing = false;
        }
    
        let resolve;
        const promise = new Promise((res) => resolve = res);
    
        shadowRoot.querySelector('#strip-no').addEventListener('click', () => { resolve('no'); close(); });
        shadowRoot.querySelector('#strip-yes').addEventListener('click', () => { resolve('yes'); close(); });
    
        return promise;
    }

    function catchEvent() {
        function dataURLtoFile(dataurl, filename) {

            var arr = dataurl.split(','),
                mime = arr[0].match(/:(.*?);/)[1],
                bstr = atob(arr[1]),
                n = bstr.length,
                u8arr = new Uint8Array(n);

            while(n--){
                u8arr[n] = bstr.charCodeAt(n);
            }

            return new File([u8arr], filename, {type:mime});
        }

        let alreadySeen = new WeakSet();

        window.addEventListener('load', () => {
            document.body.addEventListener('change', async (event) => {
                if (alreadySeen.has(event) || event.type !== 'change' || !(event.target instanceof HTMLInputElement) || !(event.target.type === 'file')) {
                    return;
                }

                console.log('caught event', event);
                
                event.cancelBubble = true;
                event.stopPropagation();
                /* modify event and add it to events that should be allowed so that we don't get into a loop */
                alreadySeen.add(event);
                
                if (alertShowing) {
                    console.log('Alert already showing');
                    return;
                }

                const choice = await askUser();
                if (choice !== 'yes') {
                    console.log('User declined metadata stripping');
                    event.target.dispatchEvent(event);
                    return;
                }

                /* do something async */
                let file = event.target.files[0];
                if (!file.type.includes('image/jpeg')) {
                    console.log('Not a JPEG');
                    return;
                }

                // Remove EXIF data
                const reader = new FileReader();
                reader.onload = (ev) => {
                    const dt = new DataTransfer();
                    const dataUrl = ev.target.result;
                    const modifiedUrl = piexif.remove(dataUrl);

                    dt.items.add(dataURLtoFile(modifiedUrl, file.name));
                    event.target.files = dt.files;

                    console.log('resending event');

                    event.target.dispatchEvent(event);
                };
                reader.readAsDataURL(file);

            }, {capture: true});
        });
    }
    
    inject(`(function(){
        let alertShowing = false;
        ${askUser.toString()}
        ${catchEvent.toString()}

        catchEvent();
    })();`);
    
})();
