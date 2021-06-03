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
            display: flex;
            flex-direction: row;
            align-items: center;
        }

        .logo {
            margin-right: 20px;
        }
    </style>
    <div class='wrapper'>
    <div class='form'>
        <div class='header'>
            <img width="50px" height="50px" class='logo' src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAB6JSURBVHgB5V0LdFRnnf/fO5NkMkkgkEB4tM1QXi3lEV5aOZWGWm319IHWKrAqsq60PatApbpyVg9hq26PpyjUs6V1j7Z1q9CtPYLU1WrXQutau1CMLdLynpTyCBCSkGQySebeb7/fN7np5M53Z+6duXdy4/7OuZnJnTuZyf2/H9//U+hvECeX1UU0neqUgBpRdbWWFFbJT0cYsUjyCiUifyeLElPaFIXaiPGDlKiu6k060xuZRm3Tnm1spL8xKDTMIYhNVB9gwTmcwPWkUoQTr5K8AGcMhVEjZ5JGjSX29qnUeO2OxigNYww7Bvjz0rrK8hDVBVnwTqboS62luUDgDMEUatRJe2rqjsY9NMwwbBjg6LK6+iAFVvKbvdQzCc8XXEMwRjuZru2a8p+NO2kYwNcMcHJFXR3pKpd0ZZ1viW6NKCPa00vaJj+bCV8yQL+0b+Q3sJ7ygBquoOCY8fyYwJ+XJx/LKijAn8ugxTpJ7+ogPdZBiQtn+XFGPOL3fMBv8p4EZwQ/mghfMUA+hAexwwtupOLIdCriRC+unS6I7wbAAL3RI9TTdITih16n3qbDgjFyQFQntmnKjgNPkk/gCwbIhfAgeHHtNAovrKeyBfWuEdsuwADxQ/upa/9ewRQOtYRvGGFIGeAtHsKFKPCEXcIbUl5x4+1c0qeJ3/2C2P491LVvL3W+vNv2e+Aw9ira/UPpIwwJAyCUqwypaxkpDXauD107X0h6xY23+YroMkATxPbtofZfb+em4oit9yjEGtri+ta5OxvbqMAoOANA3Qe41POnkWzXgvCjPrmaQjPmU66AqobNhnPX1+/QWalrMBeOIsNxLEuamVwB09Cx93m7WiGqkbJq6g6uSgqIgjGAkPpSdSNjPKTLgvLFt3HC3+PYrkPiuvudNNz8HB21NIAJwBBgxBL+3ClD4nu0/vyHthiBh7xbJm/ffz8VCAVhANj6Egq8RFmk3qnEQ5IhYSB2Do5YzoCWwHeEP1I6Y4FtRnXACNEe0pYUwjfwnAFOLp+/kjt5WzIlciBdY+7daIvwBtHhdIHofgC+N7RWGfdT7PgonXt3U+tzP8ysoZBV5JHC5O0HtpCH8JQBTi6f9/1sKn/UXatpxMeWZ71xIHYXJ3onJ36hJD0XlHNHddRd9sxXG9cGYIRMgIM4aceBTeQRPGEA2PsRpYEneOVsqdU1sKtj7mvI6mSB8LhJfpF2u4BWAHNn02rQAmcfXJ1RGyBcvNyjrfIiSnCdAYS9Z8Ff8Bp8ndU1Iz+6nEZ/bn3GvzNcCW8GGKCK/6/ZGN2GNvDEL3CVAbI5e1DzNesfzigVkIQLjzUMe8KbYcc0wK9p+cnmTNrAdSZwjQGyER+O3vhvPp7xBkACLv/Xdl/b+HxRyaMcmAYr2DAJrjKBKwyQjfgI72oeeNjS0UP8fmFbg+3M2XBHNmGAAFzYtkloBAu4xgR5M0A24mez90iZXuJq7/8jsmkDmIPL/P5YwBUmyIsB4O2PDAX+TBbExz+Hf1IGcHnz5gektp6FwkQz3kdVM+eL2j0kRvb+vv6aPUq18beGp88Q5pVMOIlW2iCjc8iosb1HW5JPdBCkPIBQj3+JiOy1TMTPZOdAfK1uMSXefyud54SPXHUlFRUVkR0YuQKoTrfSwF4D3xWmz8okGPdQygQK1Y0oEXWVj1OOCFCOOLls3kb+De6VvZaJ+CDS2QfvIa29Rfq6kugj9d1jFHztN8QuNVNLrJcSFaOppKSYAoHMXxeaIjxnETc7K3iKFpGGMiz8CmgzJLhCU2dJtR2iJqhqmZZTFLpmzayJlY8cPPMC5YCcGODkivlreYbvIdlrsPmjln9Z+r4OngM/z9U+6+slO1DPNVHo9FFO/BJSI9dQsU1NAOBGlokS8u28Etjpe0bAPel8+XmhBUoi09NeBxOAUXqOHUx7jTPH9etmTYhuPXj2L+QQjn0A4fQp3O5LcvuwZ4jzZYAKgz2zA1Y5hkbcupzKp16XVyk4FU4qckONTM4htKc0R8JrBz1Mm+vUKXTMACeWzT9JEqcPEjfxoZ9KQz2nxC9d810af+0s8gK2CjE+ACInaFMzoAVOf32F1fePtse1uU6cQkcmAMUdzjO3ms8bcW2gsirtPVD7l37yPbKLxC2fpfjEKXSx5RKdv3CRLlxsEUfLpVZqbWunzs5OisW6qbevTyTJ4Rcoin0+RtNo2YIlwvnSY53kV3T/5VWpOVCKSsT3h88gMaWVJUWBkBN/wPad6+/keUn2GtQ+1L8ZhsPnBHpkBtcC1aS0XUh7DdpBXDOyWjwXx7haCo+uppEjR1JZuNR2xAAJav7eehFC+hkQLJkZzHRvNVKW2O0sssUAmeJ9K48fNxiqqhBpXYSOeuRaCiz4EI264Raq5MxgB3YqcUMNmNSJD/1MGiJmSBTZNgW2GAAhn6yBE6r/ykd+mXZ9IW5sals4Qj7coFwbRhEh9EYPJ7uLfJhQyuRfnd6wQqrFRDPJjgMNlAVZGaA/1XtS9tqVj+yWciYyfDGPehtRV0B3cNhm941TGNFC0kfwT1EKZgDmwAwwLzStDDxVPClbVJDVCXxg1kRkmq4xn4fqBxHMgIfd8eJz5DZAeDSQoGcQjhycIS+ATmDkD8oX3eKr/AEYE98NyaJUGI63THMVkVrHcwNPZfizmTXAsWXzPq+S8oT5fCbVf2rN7eQm4OiNXv1Nqpy7iIYCdtq2Cgn4A+bmkkyhYTaHUKUM4MTfKDtfedcXpdfD7rsJNq9e2L6hIj6QrWJXaKBsbgZM4Zh7G6TXB4lJaTjwXqsXIP0k8frR/Yr0qhluJ1f0m+6mCV/+FpWMHE1DDTDBCElSZigAk9QqSarBR5CFi1h2d3SZJEbvh2r9glz6sWDDDBDebqbPDhLX35psqAyFyC8QfX2R3FcJuQmEfjJhs9JUmbSAlAGQ9CEL6Zd5/W7aSNj88jtW0ejRo8hvqPnKZl+sTRQdQ481pJ1Prk9I186ZtICUAbBUW3ZeJv1QScivu4Welf9M1VdcRX4EmH/UJ/3hDxirocyw+n5WWiCNARD3y5ZrW0l/i4vtXNqcxTSydortdO5QAL6AX0yBTPOCRla+wJG769Ja9dMYoNhC+mWOnxUX5oq++k9QRXk5+QUHD1+kXS8cpZ88+ya98topOns+WTyq+ux68gMstYCFLxAIqGkLddJawhSJ9BdbrIh10/Zr0+cL+x8uC2e9trOLVwI5T5eXFZNXeO7XR+hnOw9RT3cf9fQkqCeeoDFVpbR29fto8fVJj9sPaxdAg/EzBmcIjYjA/P141XQtf2hIPTeIAY59aj44JGL+EFkIlByR4t4NQB8gqnkBVR6YxGJ9tOt3x+iFPcfp1LuXOVH6qKa6jD51xwz69NIZ5CZe2XeaLrZ207+sv4EiV6DKWMSZrpeOnrhEv3rxmGC8GVzKzh5yVun0AoYWMAsoqrNp9GFUCWcwNTE0iAEUle6UfUiZRcrXTaAMbBX2HTrWQt/d9r/U16vRx5ZMoptviFDN2DLx2tnmTurgxKlwURvUThxBH1w4cdA5EH3urHHiSGKcb7QAGmHNDIB6CUJzcz2DO4Mr+cMe4/dB4qYo6Ys54fyZQ59kE6N7nr/GS7ko6aoS6Yckbv3xARpbHabvN9xEf/eJ6waID4yvKXeV+MBVE+yFen7JEMpWTCfnKdWnXYtBmyjvD1xnPBGxv6TPTyb9mIHjJtDUAci8/7ePt1L16FJqWLuIxlZl9w8KCUidX/ICKGWbAS2QBk7j8lBwIBpQ33sSWGm+1oqLOl5O/7B8oNckGSCgphcnu+N9dP/fz6dw2J+hoV9SxLLyu9UkNZXpA5p+gAEURmkxoszzd9v5A4xWLx6mpL0297qxQgP4FVIpGwLIRuSIphlJzoJHAwO+nrjjSP5glYn5QszASf+g/eQ6QkkCi0ZPE6pH+Zf4gDE8yg+QmYGwPAMcObNirlC7ggGK9IB0mAMGIJmByZiuI+Sf5I8MZ85fpu/+aA+t/ddfikf8ngo0q/gBMs1cJhFiIKYrS/AowkAlwOrhHqYCnC1L/XoZ9uiaTn4DiH33/U/zULNH/F5RVkJvn7xA31pzC00YO0KcQ09im/tNUI4ho01yUHZFmnkwTL5gAJUpc5jpjbKRJl6PYutL9Nm+9vevHaOnd/9ZEGgiJ8QdN11Hd97kbkII+MYjLwwQH/jxt+4WhF/HtcGP+HPAcLaGuodQDLXmxTkz7WAGzCuiFFURqkEwAIP9N3GAzK71eNwfp9nUANt2/Ikfrw78DgKx3/+VM0M73bfsA+QmDp8cvD7hUf65I/q1gAHD2fJDUgiDMs0MIBzBl9MujeCHKipEkvi/xEIDeIL+RSDxeDzrpZD4VOIDX/tCvZDMfQffpf38cBNQ+al46bXjtOv3h9LO5zNS1k2gvd0M6ewBTnM4gqoSkA9wlIUPiYtnyAsYq4D6+rKbgF1c0s04fPK8kFQwx9v8uZu4k5sW+fnB5ka2rHsoIOsOLrFgzhhT5wZVRU1T/8bQZDO8WkZlMICm64IJnPYDwBfAAaTaazdw37Lr+d+MD/x94DO3z00zNYXer8AKslYxS0eQWAQ+QCT9Den/jJf98WrbxYHnXbFYxqVdC2deSdvoT5avT580ltwGTAwIDi0zfdKYNPUPBHw0xh5MYKZhcOx4LsAmJ1UnzgC6UmteHSCdydPlnYerNr018LynJ7MEL5h5hThkth7Euen9k8kLgOj4XCvkowGKa+IUuqqLPyb/dy0eIK09SL3nQxRvKnP89zAtPY0BqiekaXBVUUZyE0CV5hBQ9s9gGJNXgAlQ4jFREYzHs6twxOBwBOGMGVjIibNlwx00VHDaEq+GdCqf1Uql0zopVBuz/rvtRdT+SjV1vmF/0zStK33Zu0XRKhJkiACU7Bf3ebyCVmk7z6uCEVuRAOLwBzkTQDVnUst+Q6i2i0quinFpj2UkeiqCI/uo6rbkvbfLBDJhlQk1AwMk99UdzAFYg2aG10kONfoW6ZwBnDiC2dRyIaFJ7k+wso/CUy9zondTKNJFakkemU5mfwiGjFYymgJB2darMg2gd3k7TUM9987A82yOoB+BHIlBcNjy0ukd+RE8BW0wAW/avx8yf81ir8RIXnMC3YTS3DTwPJsj6Av08e/b+w6x7jc4x75Moxb8gUbNdXeaux5XqeX5iRQ74l2xzDcMgJFwThxBT6G3E7XvJhbnxNU4UbX2QQfD65p3G3yB8B37qujyvtHiuZfwDQMAThxBT9D1CrHmbxPjj0OBeFOYurijFzta4TnhDfiKAXJxBF1BH1flp1YPCeFBaHj33UcqKP5O4Xse/cUAQ+AIsov/Ruz8dzxV6TJA2kH0zjcrCybtMnAGYFFzJCAPI7zv2im0I8hO3UOs7WkqFAzbDuJ7Ke2ykE+Tz0SMSjWALIwoRPtzIR3BQhF/KFS8PIyX5HEUagsqpESZqSAkyyQVFajapXAmYJFrPXUEWfN3PCX+kNt1i/0VzFAYZwBGepN5kbBshKpSVphql3ouKoY+euYIIow7/23blyMG7z5cwXPyxTwt20sBnuwp4cUbhSd5kKYF9J7+4k1zqefq3Q6KpLUcyd4MjNqDTFHaFGa+OF0DlBSo48VzR7CvyfalyMC1vzIm5Yy/ViZZQeYDyJp5GPf/IPrRtIstmgoKASel4dw+wD5DdTmowPkJsva0xHlJMU+lqMo0JWo+D3shZwLv/QCjNAx0ddmrmDlCcS1PjGdnAqhylGKHG2TEBz1lPoDO1EY1oGqNsj+EpgIzQtcuoEIAjiBgp0cwp79f9aWs1xjNGcMNMk1t1coX1BJt6iTMkuXhgPlFWf2/ULNx4AgCcAS9MANK9T9yTynzICo1pFHFwktUKKCSiCNf2G7n5zSf9GxjYzIPoFPUvDZQ1l5cWqA1cEgJ0/UfFc9hBrBnkKvgJkCJPEPsaOY1BKM/3CwYYbAjmD/QDYQWMDSHoB2seFx8oHQMs3P2R1fnnB20287PHX+h+ZMLQ1S2V2HKIAaISdYAwr4UYgWM2vxeJBD3KCOohGYTXfE4sbNfS1b5LFD5wYtUPrtdtGWhP8+pXwBiI3w0ev5A9EySjtCyeGw3DyWd9wKCNjINIDPnOmNig6kkA3BuMPebGI6g2fHDB3g1Ct5Aao8gQkHPPmfUZ6j3Yg1pJ1ZkbNFKbcvqbQ5Roq2Ies+X8HKxKnIAqQjwa4v4gTwBpNupWkfeIRfiA1bL+aU5AFXZg0fBAAHS9zDJ5HjMnjFvXFQIBgDU6CHSrlkgHEH4AlbDo/JF/NhFuvTTWtGnVza7jcLTOoTUWkGobH6Ep7uvBTvfGEmtL46jXOFkOX+AJZ1/cVeFIyiKQoMhI3ShBiIMygd4mBY2kl7I3rU8P4FOPzqVWnZP4Gncwi1ZR8jZ/HSt+Px8KoO2l/Mr1DipfyOJgWIQU2gXdwzWpl6H8AGmILW4YNgZrxdCKq3vLb5EYSgc9iYLZ+51FHn8N0eKw3DWSrlWCGWx3bkAhIeD6UbqGDMK7C7nNxxAYIABeFJgZ4DYIAYQy405E9iaQecyUjVA3MPScKbkFpghxgs6OIDkAo7YQHt3JlNh9ffgQ3jRB1Au0cxdFtveJEgZ2EVkgAGC8UQjKw20mVcKd+zdbXsGnZuAE4glY3pltaeOoJP/AcTDgV49QDh5cPr4o1EgAlOoJdpAgaivrZg/Fgkpx3u9gnSam1z9t03dLhkUOWlnY9uJZXN3cdlbaf4jMjMAjsuwt70rULgjSHWLPXcEc4XBEHRkaNcFOpnlyNX/ztTfB91RjQJPmt9gNYOuzHoTCtegpnQIxbq80QJ+WdadD2Rj/K1mOWrc10v9fRADiBmykrSwLBqw2qLETajnUhig2xsGsFgwMWxg5fy1/0amnVl0yvbXrTWAuISxreZzTseSuwUlhQG8Kgz5ZcRbrpBtEAFayQpACiWTP6lIYwBV03eSBLLh0F5rAeEI9heGujw0AX4Y95oLIP2y+289yVXbZD6TxgCoECkp06QNgKucbFTkFkRhiN6bHuIF/LIDiFNUrVyfdg40kjp/nKaTJLuISt1qHidukp1vfe7xtHNeawFzi5gX8MuAJyeA5y/73lZj/K1oKmUAOIMyLYCx5DJfAJsWeqVGC7FWoBARjduw2r5PPsafRa12D7UMrK21gHyjIq+mZhtrBQCv1gpYTdV2gp4Shd6YGqL2iqzbMecNmF0n2/fxfKWUloAlA1hpgUzblXllS41owKu1AlZTte0ABH9+cTl977Oj6Vc3lvHnuZVy7QJOa6XE84fkW0n/lB0HniQLZEytWWmBC49tkqZQrfavzRd2W8Ra4s0US3RRLgg7NAOQ+BevD9Ojn66kN6e917H0zvgizhTeZSxlW8gDuUg/kFFf/eDgmei6mRPqybRyCMTH9u3mFjFsZR4oq6Duv7xKrqK8UvQGACXFxVRamj5CfveJ/6BH39hEv2l6hv549nf0budxKi0qp+pQDdlB8cQItf/yKVvXHokU03M3j6ATV8q3qhl7SaOaFo3cBlR/2GL/Jlnen/G075RnDmygDLDBqtoq2dk2/qGy2YHwBdyOCuxUBiH9qc/BBJtf/ypt+J/P8ee/HfS69DMs2qlSAal/7uYKcWSS8vOj3V90DQ0lU/2Z9m1WFe1+yoKsHsvWg+fa1swcr/AsUr35tZ6jb9KIm+9Kew8qU12v/la6xCwXwAnU0CQaLBJmoEqyr3DjhT/Sqc4Taee7uUlovPAq/fepXwgmuLJiMoWD6elfmI6mxLt0pPMwl/Aiocp7ilWqak9KchP//ZlbRtCZmuzELe/WacaJXnILsPtj13xHuuLn9IYV0vvMuPm+eseBnZTtb5MNqHF9CwuhSqhEUs9DA2DrWOysPeh6Lk3jv/lDOv31Fa6VjN1oEYNWwLFo/IfpAxM+QtMrZwvtgHNHWt9I6sMbBztxNxyIcUZQaN9M+zuXtJe7Fwkk7+Xjll6/fD4hi6pxbQvZgC0GQKn46LIFqwLEXjK/hpIw4miz+sQXrln/MJ190J3NFWEGDD8ALWL5dAgZjFDF/YNspuEP85x/TrzY/ki3bMA9lBEfBTor1a+RumrqzgO2Jl7YFiOEhUyhrbLXmjc/IOVEMIVbkUFqZdCNfEBrB8tK/FzhVhQw5t6Nlp2+Vpt2c8dvq1XSRwZH31Tt1hpkzaNQ85B0mbpH44gb9QLF5dJwZ4yRn4F7Vi7ZsDt5r1dbqv7Jz7y+jhzAEQPAFCikL5H1DKC7FppABniv+TKB0SIGdLugAXy4PdEA4FPJPH7gwrZNcuIrLEkbh3Csq1BR0hmThhfIEFqpJvxD+ZoD0SJGNOAIpqLKZrxvQPepAoDat0qr495arclgpG6SVfuyISdjhdSilT8Ap9AqKwVzAI8217y7my1iQe9T9o5gePsytQ/gnlr1YCLkm7x9vy2vP+1zKUdM3v76Op4ckMaZ8E6tmABOzcSHfpbTrAGjNwAw+wHhIv+0doV6nakXxPm4J1aJKNxLK48fNJi8Y38D5Yj83NVuniVMWWSQikxMAOIjT+A0/25sLQOYI4FwwFkRJsHzO7oNP2Bkhy4OJyjpsc8A6OqZ+NBPLQUiE/GFQ94tz9TaRV6KcOvb5+LrZtW8wEmzlB9p81SMfQbDcxalvRdZrfJFHxGD6mUbHcmgJPpIv2Y+MV4b0DWNqquqBl5DJu9VHtvbRXsnE20ypSXymD2RIOrgkcKX9uh0w2ttVHs2Ic4jO9hTkjnOr7mUoNlHszuqcPaq/2GDqKvIAJtvXZ9gUTh9k37eeI7yQN6WEKnidTNrdlkxQc+xgyJjGK77gPQfhdqr4HYvJlaxZE8ds+oJpF8xFc2rYoBUIJD8F7gqFOleu0AU0MaZAIwQ6wGxk0c7LyZeusyotnw2rZp9H00OjBUMOrJTp2lNvbTwr3FR6AlqyYyfFkxnhmlNfXT1u9bta+jkGbfhB5YaEEJz7qE1Ip1ucReSxM/B6TPDtZTVyWV1Ee6JviTbfwCAnbNKaRrIZDYMaHMWU+/SZHZxwvhxA1PEYolOWrf3LsqGcFEZfeiKT9CHrvo4HW05RscvHafO3k4qLy6nMn5MGT2ZasrG8d+TJgXEOPXlOyxT2qgZHKktpuaqADX3F4G+sLNNajbg6GG1tVWIByDEs47zAfeID7iXsyR7TFD1ua9ktP34x1s5I5i3OjWArebja5MOL4pCNWPf2yUMlT+r7F4q4cNBZ/4CGi3QA5EPYOvH3NeQUQBgMpFLsa6fuEt8wFUGALIxAWAnMSQKTU9tlvoH8X/6dzE8IlRSQldPigycf/LQwyLHn4p8CJ+KU2tud7wxFADCo1sqW6kZ9j7jUjsM8VC0j7tJfMB1BgBOLq2rpNLAE9xML7W6xo5JACAV0AipjNCz8htimigqgtOnTR04f5hX9DYf+Kp4Pm3UbF7tm5M34Q041QJ2CQ9Gv7CtIeO+jCLc5t4+MrHkMjxhAAPHly1oUIhtzHSN3TRxqmnou+UzlOgfIjV5UmTQECkwQXVpjePMoB2g3pFpWbyxaFZWHTUDar6dS7x1iJcEijtO8/tO4CkDAMc/PW+doiobZRtUGxCNjnd9UUQD2SBWvZ6K0qXSSorFYjSO+wCjJQ0iXgDEl5W3Ie1o1cKyeTtZTvydC481ZDYpPLevs8D9U3bse5I8hOcMANjxC4Bk5fAe21lCURPg+YBQyLt192aAAYyhGckQ9jbbqW1hzniUk324hvvOnhUKwgAGji+fv8U8hkYGp4xQSJhnJdiBMF+c8PK27cGAyld7tAYv7L0MBWUA4OiyBfUB0p/Ipg0AMELF4tuH7Qpe+xIPsKjo5NlRgBFsKSg4AwCIEvRQcF02B9EAMmcokaLZ1O8reY2BGshs2p2jhGqeGk9sKZTUp2JIGMAAfANige/z0vJSu+8xvGynhSQvYQzT6uARSmzfXieNsHsU4uFdAWy9FYaUAQwcWzbv87wsudGOWTBg9PFjOCLm4xXaX4BdxxQuSLoxTs8B9mhc6gut7mXwBQMYyIURDCCUhKkAU2BgshsLPg2A2Ji329f/6FDKU+EbwhvwFQMYgKMY5P4BL9jWUx4AA0AzgDnwiN9RhraaC4St1bC7FrZXwQBJ9DmC+C6sbfAd4Q34kgEMJPMHgQbuJt2Yi1YYUvBEDmPqVk1Tdk57dl8j+RS+ZoBUHPvU/KU89b+U39g7iSn+3MwHnblM2YlJnH6UdhmGDQOkIplLYJ/n8dMc80YXhQeLMqbs0hVlJ6atDkUolw+GJQOkAmZC0wN1vGJWryo0hymszjMNwSWcdLHR5l7+OY0BKt4zacefojSMMewZQIaTKxbWJXRWqSp6HSdYhJuOWhSj0EXGiVhp7U8kVz1hN1X+ENUZtZPKJVxTogG1qHG4E1uG/wOt4enyO04KaAAAAABJRU5ErkJggg==">
            <p class='header'>Would you like to strip identifying metadata from this file?</p>
        </div>
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
