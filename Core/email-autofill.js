(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
(function (global,setImmediate){
/**
@license @nocompile
Copyright (c) 2018 The Polymer Project Authors. All rights reserved.
This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
Code distributed by Google as part of the polymer project is also
subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
*/
(function(){/*

 Copyright (c) 2016 The Polymer Project Authors. All rights reserved.
 This code may only be used under the BSD style license found at
 http://polymer.github.io/LICENSE.txt The complete set of authors may be found
 at http://polymer.github.io/AUTHORS.txt The complete set of contributors may
 be found at http://polymer.github.io/CONTRIBUTORS.txt Code distributed by
 Google as part of the polymer project is also subject to an additional IP
 rights grant found at http://polymer.github.io/PATENTS.txt
*/
'use strict';var w;function aa(a){var b=0;return function(){return b<a.length?{done:!1,value:a[b++]}:{done:!0}}}var ba="function"==typeof Object.defineProperties?Object.defineProperty:function(a,b,c){a!=Array.prototype&&a!=Object.prototype&&(a[b]=c.value)},ca="undefined"!=typeof window&&window===this?this:"undefined"!=typeof global&&null!=global?global:this;function da(){da=function(){};ca.Symbol||(ca.Symbol=fa)}
function ha(a,b){this.a=a;ba(this,"description",{configurable:!0,writable:!0,value:b})}ha.prototype.toString=function(){return this.a};var fa=function(){function a(c){if(this instanceof a)throw new TypeError("Symbol is not a constructor");return new ha("jscomp_symbol_"+(c||"")+"_"+b++,c)}var b=0;return a}();
function ia(){da();var a=ca.Symbol.iterator;a||(a=ca.Symbol.iterator=ca.Symbol("Symbol.iterator"));"function"!=typeof Array.prototype[a]&&ba(Array.prototype,a,{configurable:!0,writable:!0,value:function(){return la(aa(this))}});ia=function(){}}function la(a){ia();a={next:a};a[ca.Symbol.iterator]=function(){return this};return a}function ma(a){var b="undefined"!=typeof Symbol&&Symbol.iterator&&a[Symbol.iterator];return b?b.call(a):{next:aa(a)}}
function na(a){for(var b,c=[];!(b=a.next()).done;)c.push(b.value);return c}var oa;if("function"==typeof Object.setPrototypeOf)oa=Object.setPrototypeOf;else{var pa;a:{var qa={Pa:!0},ra={};try{ra.__proto__=qa;pa=ra.Pa;break a}catch(a){}pa=!1}oa=pa?function(a,b){a.__proto__=b;if(a.__proto__!==b)throw new TypeError(a+" is not extensible");return a}:null}var sa=oa;function wa(){this.l=!1;this.b=null;this.Ea=void 0;this.a=1;this.Y=0;this.c=null}
function ya(a){if(a.l)throw new TypeError("Generator is already running");a.l=!0}wa.prototype.J=function(a){this.Ea=a};function za(a,b){a.c={Sa:b,Wa:!0};a.a=a.Y}wa.prototype.return=function(a){this.c={return:a};this.a=this.Y};function Aa(a,b){a.a=3;return{value:b}}function Ba(a){this.a=new wa;this.b=a}function Ca(a,b){ya(a.a);var c=a.a.b;if(c)return Da(a,"return"in c?c["return"]:function(d){return{value:d,done:!0}},b,a.a.return);a.a.return(b);return Ea(a)}
function Da(a,b,c,d){try{var e=b.call(a.a.b,c);if(!(e instanceof Object))throw new TypeError("Iterator result "+e+" is not an object");if(!e.done)return a.a.l=!1,e;var f=e.value}catch(g){return a.a.b=null,za(a.a,g),Ea(a)}a.a.b=null;d.call(a.a,f);return Ea(a)}function Ea(a){for(;a.a.a;)try{var b=a.b(a.a);if(b)return a.a.l=!1,{value:b.value,done:!1}}catch(c){a.a.Ea=void 0,za(a.a,c)}a.a.l=!1;if(a.a.c){b=a.a.c;a.a.c=null;if(b.Wa)throw b.Sa;return{value:b.return,done:!0}}return{value:void 0,done:!0}}
function Fa(a){this.next=function(b){ya(a.a);a.a.b?b=Da(a,a.a.b.next,b,a.a.J):(a.a.J(b),b=Ea(a));return b};this.throw=function(b){ya(a.a);a.a.b?b=Da(a,a.a.b["throw"],b,a.a.J):(za(a.a,b),b=Ea(a));return b};this.return=function(b){return Ca(a,b)};ia();this[Symbol.iterator]=function(){return this}}function Ga(a,b){b=new Fa(new Ba(b));sa&&sa(b,a.prototype);return b}Array.from||(Array.from=function(a){return[].slice.call(a)});
Object.assign||(Object.assign=function(a){for(var b=[].slice.call(arguments,1),c=0,d;c<b.length;c++)if(d=b[c])for(var e=a,f=Object.keys(d),g=0;g<f.length;g++){var h=f[g];e[h]=d[h]}return a});var Ha=document.createEvent("Event");Ha.initEvent("foo",!0,!0);Ha.preventDefault();if(!Ha.defaultPrevented){var Ia=Event.prototype.preventDefault;Event.prototype.preventDefault=function(){this.cancelable&&(Ia.call(this),Object.defineProperty(this,"defaultPrevented",{get:function(){return!0},configurable:!0}))}}var Ja=/Trident/.test(navigator.userAgent);
if(!window.Event||Ja&&"function"!==typeof window.Event){var Ka=window.Event;window.Event=function(a,b){b=b||{};var c=document.createEvent("Event");c.initEvent(a,!!b.bubbles,!!b.cancelable);return c};if(Ka){for(var La in Ka)window.Event[La]=Ka[La];window.Event.prototype=Ka.prototype}}
if(!window.CustomEvent||Ja&&"function"!==typeof window.CustomEvent)window.CustomEvent=function(a,b){b=b||{};var c=document.createEvent("CustomEvent");c.initCustomEvent(a,!!b.bubbles,!!b.cancelable,b.detail);return c},window.CustomEvent.prototype=window.Event.prototype;
if(!window.MouseEvent||Ja&&"function"!==typeof window.MouseEvent){var Ma=window.MouseEvent;window.MouseEvent=function(a,b){b=b||{};var c=document.createEvent("MouseEvent");c.initMouseEvent(a,!!b.bubbles,!!b.cancelable,b.view||window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.button,b.relatedTarget);return c};if(Ma)for(var Na in Ma)window.MouseEvent[Na]=Ma[Na];window.MouseEvent.prototype=Ma.prototype};/*

 Copyright (c) 2016 The Polymer Project Authors. All rights reserved.
 This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
 The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
 The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
 Code distributed by Google as part of the polymer project is also
 subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
*/
(function(){function a(){}function b(p,r){if(!p.childNodes.length)return[];switch(p.nodeType){case Node.DOCUMENT_NODE:return F.call(p,r);case Node.DOCUMENT_FRAGMENT_NODE:return E.call(p,r);default:return t.call(p,r)}}var c="undefined"===typeof HTMLTemplateElement,d=!(document.createDocumentFragment().cloneNode()instanceof DocumentFragment),e=!1;/Trident/.test(navigator.userAgent)&&function(){function p(z,R){if(z instanceof DocumentFragment)for(var fb;fb=z.firstChild;)B.call(this,fb,R);else B.call(this,
z,R);return z}e=!0;var r=Node.prototype.cloneNode;Node.prototype.cloneNode=function(z){z=r.call(this,z);this instanceof DocumentFragment&&(z.__proto__=DocumentFragment.prototype);return z};DocumentFragment.prototype.querySelectorAll=HTMLElement.prototype.querySelectorAll;DocumentFragment.prototype.querySelector=HTMLElement.prototype.querySelector;Object.defineProperties(DocumentFragment.prototype,{nodeType:{get:function(){return Node.DOCUMENT_FRAGMENT_NODE},configurable:!0},localName:{get:function(){},
configurable:!0},nodeName:{get:function(){return"#document-fragment"},configurable:!0}});var B=Node.prototype.insertBefore;Node.prototype.insertBefore=p;var K=Node.prototype.appendChild;Node.prototype.appendChild=function(z){z instanceof DocumentFragment?p.call(this,z,null):K.call(this,z);return z};var Z=Node.prototype.removeChild,ja=Node.prototype.replaceChild;Node.prototype.replaceChild=function(z,R){z instanceof DocumentFragment?(p.call(this,z,R),Z.call(this,R)):ja.call(this,z,R);return R};Document.prototype.createDocumentFragment=
function(){var z=this.createElement("df");z.__proto__=DocumentFragment.prototype;return z};var ta=Document.prototype.importNode;Document.prototype.importNode=function(z,R){R=ta.call(this,z,R||!1);z instanceof DocumentFragment&&(R.__proto__=DocumentFragment.prototype);return R}}();var f=Node.prototype.cloneNode,g=Document.prototype.createElement,h=Document.prototype.importNode,k=Node.prototype.removeChild,l=Node.prototype.appendChild,m=Node.prototype.replaceChild,q=DOMParser.prototype.parseFromString,
H=Object.getOwnPropertyDescriptor(window.HTMLElement.prototype,"innerHTML")||{get:function(){return this.innerHTML},set:function(p){this.innerHTML=p}},C=Object.getOwnPropertyDescriptor(window.Node.prototype,"childNodes")||{get:function(){return this.childNodes}},t=Element.prototype.querySelectorAll,F=Document.prototype.querySelectorAll,E=DocumentFragment.prototype.querySelectorAll,M=function(){if(!c){var p=document.createElement("template"),r=document.createElement("template");r.content.appendChild(document.createElement("div"));
p.content.appendChild(r);p=p.cloneNode(!0);return 0===p.content.childNodes.length||0===p.content.firstChild.content.childNodes.length||d}}();if(c){var y=document.implementation.createHTMLDocument("template"),W=!0,v=document.createElement("style");v.textContent="template{display:none;}";var ua=document.head;ua.insertBefore(v,ua.firstElementChild);a.prototype=Object.create(HTMLElement.prototype);var ea=!document.createElement("div").hasOwnProperty("innerHTML");a.U=function(p){if(!p.content&&p.namespaceURI===
document.documentElement.namespaceURI){p.content=y.createDocumentFragment();for(var r;r=p.firstChild;)l.call(p.content,r);if(ea)p.__proto__=a.prototype;else if(p.cloneNode=function(B){return a.b(this,B)},W)try{n(p),I(p)}catch(B){W=!1}a.a(p.content)}};var va={option:["select"],thead:["table"],col:["colgroup","table"],tr:["tbody","table"],th:["tr","tbody","table"],td:["tr","tbody","table"]},n=function(p){Object.defineProperty(p,"innerHTML",{get:function(){return xa(this)},set:function(r){var B=va[(/<([a-z][^/\0>\x20\t\r\n\f]+)/i.exec(r)||
["",""])[1].toLowerCase()];if(B)for(var K=0;K<B.length;K++)r="<"+B[K]+">"+r+"</"+B[K]+">";y.body.innerHTML=r;for(a.a(y);this.content.firstChild;)k.call(this.content,this.content.firstChild);r=y.body;if(B)for(K=0;K<B.length;K++)r=r.lastChild;for(;r.firstChild;)l.call(this.content,r.firstChild)},configurable:!0})},I=function(p){Object.defineProperty(p,"outerHTML",{get:function(){return"<template>"+this.innerHTML+"</template>"},set:function(r){if(this.parentNode){y.body.innerHTML=r;for(r=this.ownerDocument.createDocumentFragment();y.body.firstChild;)l.call(r,
y.body.firstChild);m.call(this.parentNode,r,this)}else throw Error("Failed to set the 'outerHTML' property on 'Element': This element has no parent node.");},configurable:!0})};n(a.prototype);I(a.prototype);a.a=function(p){p=b(p,"template");for(var r=0,B=p.length,K;r<B&&(K=p[r]);r++)a.U(K)};document.addEventListener("DOMContentLoaded",function(){a.a(document)});Document.prototype.createElement=function(){var p=g.apply(this,arguments);"template"===p.localName&&a.U(p);return p};DOMParser.prototype.parseFromString=
function(){var p=q.apply(this,arguments);a.a(p);return p};Object.defineProperty(HTMLElement.prototype,"innerHTML",{get:function(){return xa(this)},set:function(p){H.set.call(this,p);a.a(this)},configurable:!0,enumerable:!0});var ka=/[&\u00A0"]/g,bc=/[&\u00A0<>]/g,gb=function(p){switch(p){case "&":return"&amp;";case "<":return"&lt;";case ">":return"&gt;";case '"':return"&quot;";case "\u00a0":return"&nbsp;"}};v=function(p){for(var r={},B=0;B<p.length;B++)r[p[B]]=!0;return r};var Sa=v("area base br col command embed hr img input keygen link meta param source track wbr".split(" ")),
hb=v("style script xmp iframe noembed noframes plaintext noscript".split(" ")),xa=function(p,r){"template"===p.localName&&(p=p.content);for(var B="",K=r?r(p):C.get.call(p),Z=0,ja=K.length,ta;Z<ja&&(ta=K[Z]);Z++){a:{var z=ta;var R=p;var fb=r;switch(z.nodeType){case Node.ELEMENT_NODE:for(var cc=z.localName,ib="<"+cc,rg=z.attributes,Bd=0;R=rg[Bd];Bd++)ib+=" "+R.name+'="'+R.value.replace(ka,gb)+'"';ib+=">";z=Sa[cc]?ib:ib+xa(z,fb)+"</"+cc+">";break a;case Node.TEXT_NODE:z=z.data;z=R&&hb[R.localName]?z:
z.replace(bc,gb);break a;case Node.COMMENT_NODE:z="\x3c!--"+z.data+"--\x3e";break a;default:throw window.console.error(z),Error("not implemented");}}B+=z}return B}}if(c||M){a.b=function(p,r){var B=f.call(p,!1);this.U&&this.U(B);r&&(l.call(B.content,f.call(p.content,!0)),J(B.content,p.content));return B};var J=function(p,r){if(r.querySelectorAll&&(r=b(r,"template"),0!==r.length)){p=b(p,"template");for(var B=0,K=p.length,Z,ja;B<K;B++)ja=r[B],Z=p[B],a&&a.U&&a.U(ja),m.call(Z.parentNode,u.call(ja,!0),
Z)}},u=Node.prototype.cloneNode=function(p){if(!e&&d&&this instanceof DocumentFragment)if(p)var r=G.call(this.ownerDocument,this,!0);else return this.ownerDocument.createDocumentFragment();else this.nodeType===Node.ELEMENT_NODE&&"template"===this.localName&&this.namespaceURI==document.documentElement.namespaceURI?r=a.b(this,p):r=f.call(this,p);p&&J(r,this);return r},G=Document.prototype.importNode=function(p,r){r=r||!1;if("template"===p.localName)return a.b(p,r);var B=h.call(this,p,r);if(r){J(B,p);
p=b(B,'script:not([type]),script[type="application/javascript"],script[type="text/javascript"]');for(var K,Z=0;Z<p.length;Z++){K=p[Z];r=g.call(document,"script");r.textContent=K.textContent;for(var ja=K.attributes,ta=0,z;ta<ja.length;ta++)z=ja[ta],r.setAttribute(z.name,z.value);m.call(K.parentNode,r,K)}}return B}}c&&(window.HTMLTemplateElement=a)})();var Oa=setTimeout;function Pa(){}function Qa(a,b){return function(){a.apply(b,arguments)}}function x(a){if(!(this instanceof x))throw new TypeError("Promises must be constructed via new");if("function"!==typeof a)throw new TypeError("not a function");this.I=0;this.za=!1;this.C=void 0;this.W=[];Ra(a,this)}
function Ta(a,b){for(;3===a.I;)a=a.C;0===a.I?a.W.push(b):(a.za=!0,Ua(function(){var c=1===a.I?b.Ya:b.Za;if(null===c)(1===a.I?Va:Wa)(b.va,a.C);else{try{var d=c(a.C)}catch(e){Wa(b.va,e);return}Va(b.va,d)}}))}function Va(a,b){try{if(b===a)throw new TypeError("A promise cannot be resolved with itself.");if(b&&("object"===typeof b||"function"===typeof b)){var c=b.then;if(b instanceof x){a.I=3;a.C=b;Xa(a);return}if("function"===typeof c){Ra(Qa(c,b),a);return}}a.I=1;a.C=b;Xa(a)}catch(d){Wa(a,d)}}
function Wa(a,b){a.I=2;a.C=b;Xa(a)}function Xa(a){2===a.I&&0===a.W.length&&Ua(function(){a.za||"undefined"!==typeof console&&console&&console.warn("Possible Unhandled Promise Rejection:",a.C)});for(var b=0,c=a.W.length;b<c;b++)Ta(a,a.W[b]);a.W=null}function Ya(a,b,c){this.Ya="function"===typeof a?a:null;this.Za="function"===typeof b?b:null;this.va=c}function Ra(a,b){var c=!1;try{a(function(d){c||(c=!0,Va(b,d))},function(d){c||(c=!0,Wa(b,d))})}catch(d){c||(c=!0,Wa(b,d))}}
x.prototype["catch"]=function(a){return this.then(null,a)};x.prototype.then=function(a,b){var c=new this.constructor(Pa);Ta(this,new Ya(a,b,c));return c};x.prototype["finally"]=function(a){var b=this.constructor;return this.then(function(c){return b.resolve(a()).then(function(){return c})},function(c){return b.resolve(a()).then(function(){return b.reject(c)})})};
function Za(a){return new x(function(b,c){function d(h,k){try{if(k&&("object"===typeof k||"function"===typeof k)){var l=k.then;if("function"===typeof l){l.call(k,function(m){d(h,m)},c);return}}e[h]=k;0===--f&&b(e)}catch(m){c(m)}}if(!a||"undefined"===typeof a.length)return c(new TypeError("Promise.all accepts an array"));var e=Array.prototype.slice.call(a);if(0===e.length)return b([]);for(var f=e.length,g=0;g<e.length;g++)d(g,e[g])})}
function $a(a){return a&&"object"===typeof a&&a.constructor===x?a:new x(function(b){b(a)})}function ab(a){return new x(function(b,c){c(a)})}function bb(a){return new x(function(b,c){if(!a||"undefined"===typeof a.length)return c(new TypeError("Promise.race accepts an array"));for(var d=0,e=a.length;d<e;d++)$a(a[d]).then(b,c)})}var Ua="function"===typeof setImmediate&&function(a){setImmediate(a)}||function(a){Oa(a,0)};/*

Copyright (c) 2017 The Polymer Project Authors. All rights reserved.
This code may only be used under the BSD style license found at
http://polymer.github.io/LICENSE.txt The complete set of authors may be found at
http://polymer.github.io/AUTHORS.txt The complete set of contributors may be
found at http://polymer.github.io/CONTRIBUTORS.txt Code distributed by Google as
part of the polymer project is also subject to an additional IP rights grant
found at http://polymer.github.io/PATENTS.txt
*/
if(!window.Promise){window.Promise=x;x.prototype.then=x.prototype.then;x.all=Za;x.race=bb;x.resolve=$a;x.reject=ab;var cb=document.createTextNode(""),db=[];(new MutationObserver(function(){for(var a=db.length,b=0;b<a;b++)db[b]();db.splice(0,a)})).observe(cb,{characterData:!0});Ua=function(a){db.push(a);cb.textContent=0<cb.textContent.length?"":"a"}};/*
 Copyright (C) 2015 by WebReflection

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
(function(a,b){if(!(b in a)){var c=typeof global===typeof c?window:global,d=0,e=""+Math.random(),f="__\u0001symbol@@"+e,g=a.getOwnPropertyNames,h=a.getOwnPropertyDescriptor,k=a.create,l=a.keys,m=a.freeze||a,q=a.defineProperty,H=a.defineProperties,C=h(a,"getOwnPropertyNames"),t=a.prototype,F=t.hasOwnProperty,E=t.propertyIsEnumerable,M=t.toString,y=function(J,u,G){F.call(J,f)||q(J,f,{enumerable:!1,configurable:!1,writable:!1,value:{}});J[f]["@@"+u]=G},W=function(J,u){var G=k(J);g(u).forEach(function(p){va.call(u,
p)&&Sa(G,p,u[p])});return G},v=function(){},ua=function(J){return J!=f&&!F.call(ka,J)},ea=function(J){return J!=f&&F.call(ka,J)},va=function(J){var u=""+J;return ea(u)?F.call(this,u)&&this[f]["@@"+u]:E.call(this,J)},n=function(J){q(t,J,{enumerable:!1,configurable:!0,get:v,set:function(u){xa(this,J,{enumerable:!1,configurable:!0,writable:!0,value:u});y(this,J,!0)}});return m(ka[J]=q(a(J),"constructor",bc))},I=function G(u){if(this instanceof G)throw new TypeError("Symbol is not a constructor");return n("__\u0001symbol:".concat(u||
"",e,++d))},ka=k(null),bc={value:I},gb=function(u){return ka[u]},Sa=function(u,G,p){var r=""+G;if(ea(r)){G=xa;if(p.enumerable){var B=k(p);B.enumerable=!1}else B=p;G(u,r,B);y(u,r,!!p.enumerable)}else q(u,G,p);return u},hb=function(u){return g(u).filter(ea).map(gb)};C.value=Sa;q(a,"defineProperty",C);C.value=hb;q(a,b,C);C.value=function(u){return g(u).filter(ua)};q(a,"getOwnPropertyNames",C);C.value=function(u,G){var p=hb(G);p.length?l(G).concat(p).forEach(function(r){va.call(G,r)&&Sa(u,r,G[r])}):H(u,
G);return u};q(a,"defineProperties",C);C.value=va;q(t,"propertyIsEnumerable",C);C.value=I;q(c,"Symbol",C);C.value=function(u){u="__\u0001symbol:".concat("__\u0001symbol:",u,e);return u in t?ka[u]:n(u)};q(I,"for",C);C.value=function(u){if(ua(u))throw new TypeError(u+" is not a symbol");if(F.call(ka,u)&&(u=u.slice(10),"__\u0001symbol:"===u.slice(0,10)&&(u=u.slice(10),u!==e)))return u=u.slice(0,u.length-e.length),0<u.length?u:void 0};q(I,"keyFor",C);C.value=function(u,G){var p=h(u,G);p&&ea(G)&&(p.enumerable=
va.call(u,G));return p};q(a,"getOwnPropertyDescriptor",C);C.value=function(u,G){return 1===arguments.length||"undefined"===typeof G?k(u):W(u,G)};q(a,"create",C);C.value=function(){var u=M.call(this);return"[object String]"===u&&ea(this)?"[object Symbol]":u};q(t,"toString",C);try{if(!0===k(q({},"__\u0001symbol:",{get:function(){return q(this,"__\u0001symbol:",{value:!0})["__\u0001symbol:"]}}))["__\u0001symbol:"])var xa=q;else throw"IE11";}catch(u){xa=function(G,p,r){var B=h(t,p);delete t[p];q(G,p,
r);q(t,p,B)}}}})(Object,"getOwnPropertySymbols");
(function(a,b){var c=a.defineProperty,d=a.prototype,e=d.toString,f;"iterator match replace search split hasInstance isConcatSpreadable unscopables species toPrimitive toStringTag".split(" ").forEach(function(g){if(!(g in b))switch(c(b,g,{value:b(g)}),g){case "toStringTag":f=a.getOwnPropertyDescriptor(d,"toString"),f.value=function(){var h=e.call(this),k=null!=this?this[b.toStringTag]:this;return null==k?h:"[object "+k+"]"},c(d,"toString",f)}})})(Object,Symbol);
(function(a,b,c){function d(){return this}b[a]||(b[a]=function(){var e=0,f=this,g={next:function(){var h=f.length<=e;return h?{done:h}:{done:h,value:f[e++]}}};g[a]=d;return g});c[a]||(c[a]=function(){var e=String.fromCodePoint,f=this,g=0,h=f.length,k={next:function(){var l=h<=g,m=l?"":e(f.codePointAt(g));g+=m.length;return l?{done:l}:{done:l,value:m}}};k[a]=d;return k})})(Symbol.iterator,Array.prototype,String.prototype);/*

Copyright (c) 2018 The Polymer Project Authors. All rights reserved.
This code may only be used under the BSD style license found at
http://polymer.github.io/LICENSE.txt The complete set of authors may be found at
http://polymer.github.io/AUTHORS.txt The complete set of contributors may be
found at http://polymer.github.io/CONTRIBUTORS.txt Code distributed by Google as
part of the polymer project is also subject to an additional IP rights grant
found at http://polymer.github.io/PATENTS.txt
*/
var eb=Object.prototype.toString;Object.prototype.toString=function(){return void 0===this?"[object Undefined]":null===this?"[object Null]":eb.call(this)};Object.keys=function(a){return Object.getOwnPropertyNames(a).filter(function(b){return(b=Object.getOwnPropertyDescriptor(a,b))&&b.enumerable})};da();ia();
String.prototype[Symbol.iterator]&&String.prototype.codePointAt||(da(),ia(),String.prototype[Symbol.iterator]=function b(){var c,d=this;return Ga(b,function(e){1==e.a&&(c=0);if(3!=e.a)return c<d.length?e=Aa(e,d[c]):(e.a=0,e=void 0),e;c++;e.a=2})});da();ia();
Set.prototype[Symbol.iterator]||(da(),ia(),Set.prototype[Symbol.iterator]=function b(){var c,d=this,e;return Ga(b,function(f){1==f.a&&(c=[],d.forEach(function(g){c.push(g)}),e=0);if(3!=f.a)return e<c.length?f=Aa(f,c[e]):(f.a=0,f=void 0),f;e++;f.a=2})});da();ia();
Map.prototype[Symbol.iterator]||(da(),ia(),Map.prototype[Symbol.iterator]=function b(){var c,d=this,e;return Ga(b,function(f){1==f.a&&(c=[],d.forEach(function(g,h){c.push([h,g])}),e=0);if(3!=f.a)return e<c.length?f=Aa(f,c[e]):(f.a=0,f=void 0),f;e++;f.a=2})});/*

 Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
 This code may only be used under the BSD style license found at
 http://polymer.github.io/LICENSE.txt The complete set of authors may be found
 at http://polymer.github.io/AUTHORS.txt The complete set of contributors may
 be found at http://polymer.github.io/CONTRIBUTORS.txt Code distributed by
 Google as part of the polymer project is also subject to an additional IP
 rights grant found at http://polymer.github.io/PATENTS.txt
*/
var jb=window;jb.WebComponents=jb.WebComponents||{flags:{}};var kb=document.querySelector('script[src*="webcomponents-bundle"]'),lb=/wc-(.+)/,mb={};if(!mb.noOpts){location.search.slice(1).split("&").forEach(function(a){a=a.split("=");var b;a[0]&&(b=a[0].match(lb))&&(mb[b[1]]=a[1]||!0)});if(kb)for(var nb=0,ob=void 0;ob=kb.attributes[nb];nb++)"src"!==ob.name&&(mb[ob.name]=ob.value||!0);var pb={};mb.log&&mb.log.split&&mb.log.split(",").forEach(function(a){pb[a]=!0});mb.log=pb}
jb.WebComponents.flags=mb;var qb=mb.shadydom;if(qb){jb.ShadyDOM=jb.ShadyDOM||{};jb.ShadyDOM.force=qb;var rb=mb.noPatch;jb.ShadyDOM.noPatch="true"===rb?!0:rb}var sb=mb.register||mb.ce;sb&&window.customElements&&(jb.customElements.forcePolyfill=sb);/*

Copyright (c) 2016 The Polymer Project Authors. All rights reserved.
This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
Code distributed by Google as part of the polymer project is also
subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
*/
function tb(){}tb.prototype.toJSON=function(){return{}};function A(a){a.__shady||(a.__shady=new tb);return a.__shady}function D(a){return a&&a.__shady};var L=window.ShadyDOM||{};L.Ua=!(!Element.prototype.attachShadow||!Node.prototype.getRootNode);var ub=Object.getOwnPropertyDescriptor(Node.prototype,"firstChild");L.B=!!(ub&&ub.configurable&&ub.get);L.sa=L.force||!L.Ua;L.D=L.noPatch||!1;L.aa=L.preferPerformance;L.ua="on-demand"===L.D;L.Ia=navigator.userAgent.match("Trident");function vb(a){return(a=D(a))&&void 0!==a.firstChild}function N(a){return a instanceof ShadowRoot}function wb(a){return(a=(a=D(a))&&a.root)&&xb(a)}
var yb=Element.prototype,zb=yb.matches||yb.matchesSelector||yb.mozMatchesSelector||yb.msMatchesSelector||yb.oMatchesSelector||yb.webkitMatchesSelector,Ab=document.createTextNode(""),Bb=0,Cb=[];(new MutationObserver(function(){for(;Cb.length;)try{Cb.shift()()}catch(a){throw Ab.textContent=Bb++,a;}})).observe(Ab,{characterData:!0});function Db(a){Cb.push(a);Ab.textContent=Bb++}
var Eb=document.contains?function(a,b){return a.__shady_native_contains(b)}:function(a,b){return a===b||a.documentElement&&a.documentElement.__shady_native_contains(b)};function Fb(a,b){for(;b;){if(b==a)return!0;b=b.__shady_parentNode}return!1}
function Gb(a){for(var b=a.length-1;0<=b;b--){var c=a[b],d=c.getAttribute("id")||c.getAttribute("name");d&&"length"!==d&&isNaN(d)&&(a[d]=c)}a.item=function(e){return a[e]};a.namedItem=function(e){if("length"!==e&&isNaN(e)&&a[e])return a[e];for(var f=ma(a),g=f.next();!g.done;g=f.next())if(g=g.value,(g.getAttribute("id")||g.getAttribute("name"))==e)return g;return null};return a}function Hb(a){var b=[];for(a=a.__shady_native_firstChild;a;a=a.__shady_native_nextSibling)b.push(a);return b}
function Ib(a){var b=[];for(a=a.__shady_firstChild;a;a=a.__shady_nextSibling)b.push(a);return b}function Jb(a,b,c){c.configurable=!0;if(c.value)a[b]=c.value;else try{Object.defineProperty(a,b,c)}catch(d){}}function O(a,b,c,d){c=void 0===c?"":c;for(var e in b)d&&0<=d.indexOf(e)||Jb(a,c+e,b[e])}function Kb(a,b){for(var c in b)c in a&&Jb(a,c,b[c])}function P(a){var b={};Object.getOwnPropertyNames(a).forEach(function(c){b[c]=Object.getOwnPropertyDescriptor(a,c)});return b}
function Lb(a,b){for(var c=Object.getOwnPropertyNames(b),d=0,e;d<c.length;d++)e=c[d],a[e]=b[e]};var Mb=[],Nb;function Ob(a){Nb||(Nb=!0,Db(Pb));Mb.push(a)}function Pb(){Nb=!1;for(var a=!!Mb.length;Mb.length;)Mb.shift()();return a}Pb.list=Mb;function Qb(){this.a=!1;this.addedNodes=[];this.removedNodes=[];this.ja=new Set}function Rb(a){a.a||(a.a=!0,Db(function(){a.flush()}))}Qb.prototype.flush=function(){if(this.a){this.a=!1;var a=this.takeRecords();a.length&&this.ja.forEach(function(b){b(a)})}};Qb.prototype.takeRecords=function(){if(this.addedNodes.length||this.removedNodes.length){var a=[{addedNodes:this.addedNodes,removedNodes:this.removedNodes}];this.addedNodes=[];this.removedNodes=[];return a}return[]};
function Sb(a,b){var c=A(a);c.Z||(c.Z=new Qb);c.Z.ja.add(b);var d=c.Z;return{Ma:b,S:d,Na:a,takeRecords:function(){return d.takeRecords()}}}function Tb(a){var b=a&&a.S;b&&(b.ja.delete(a.Ma),b.ja.size||(A(a.Na).Z=null))}
function Ub(a,b){var c=b.getRootNode();return a.map(function(d){var e=c===d.target.getRootNode();if(e&&d.addedNodes){if(e=[].slice.call(d.addedNodes).filter(function(f){return c===f.getRootNode()}),e.length)return d=Object.create(d),Object.defineProperty(d,"addedNodes",{value:e,configurable:!0}),d}else if(e)return d}).filter(function(d){return d})};var Vb=/[&\u00A0"]/g,Wb=/[&\u00A0<>]/g;function Xb(a){switch(a){case "&":return"&amp;";case "<":return"&lt;";case ">":return"&gt;";case '"':return"&quot;";case "\u00a0":return"&nbsp;"}}function Yb(a){for(var b={},c=0;c<a.length;c++)b[a[c]]=!0;return b}var Zb=Yb("area base br col command embed hr img input keygen link meta param source track wbr".split(" ")),$b=Yb("style script xmp iframe noembed noframes plaintext noscript".split(" "));
function ac(a,b){"template"===a.localName&&(a=a.content);for(var c="",d=b?b(a):a.childNodes,e=0,f=d.length,g=void 0;e<f&&(g=d[e]);e++){a:{var h=g;var k=a,l=b;switch(h.nodeType){case Node.ELEMENT_NODE:k=h.localName;for(var m="<"+k,q=h.attributes,H=0,C;C=q[H];H++)m+=" "+C.name+'="'+C.value.replace(Vb,Xb)+'"';m+=">";h=Zb[k]?m:m+ac(h,l)+"</"+k+">";break a;case Node.TEXT_NODE:h=h.data;h=k&&$b[k.localName]?h:h.replace(Wb,Xb);break a;case Node.COMMENT_NODE:h="\x3c!--"+h.data+"--\x3e";break a;default:throw window.console.error(h),
Error("not implemented");}}c+=h}return c};var dc=L.B,ec={querySelector:function(a){return this.__shady_native_querySelector(a)},querySelectorAll:function(a){return this.__shady_native_querySelectorAll(a)}},fc={};function gc(a){fc[a]=function(b){return b["__shady_native_"+a]}}function hc(a,b){O(a,b,"__shady_native_");for(var c in b)gc(c)}function Q(a,b){b=void 0===b?[]:b;for(var c=0;c<b.length;c++){var d=b[c],e=Object.getOwnPropertyDescriptor(a,d);e&&(Object.defineProperty(a,"__shady_native_"+d,e),e.value?ec[d]||(ec[d]=e.value):gc(d))}}
var ic=document.createTreeWalker(document,NodeFilter.SHOW_ALL,null,!1),jc=document.createTreeWalker(document,NodeFilter.SHOW_ELEMENT,null,!1),kc=document.implementation.createHTMLDocument("inert");function lc(a){for(var b;b=a.__shady_native_firstChild;)a.__shady_native_removeChild(b)}var mc=["firstElementChild","lastElementChild","children","childElementCount"],nc=["querySelector","querySelectorAll"];
function oc(){var a=["dispatchEvent","addEventListener","removeEventListener"];window.EventTarget?Q(window.EventTarget.prototype,a):(Q(Node.prototype,a),Q(Window.prototype,a));dc?Q(Node.prototype,"parentNode firstChild lastChild previousSibling nextSibling childNodes parentElement textContent".split(" ")):hc(Node.prototype,{parentNode:{get:function(){ic.currentNode=this;return ic.parentNode()}},firstChild:{get:function(){ic.currentNode=this;return ic.firstChild()}},lastChild:{get:function(){ic.currentNode=
this;return ic.lastChild()}},previousSibling:{get:function(){ic.currentNode=this;return ic.previousSibling()}},nextSibling:{get:function(){ic.currentNode=this;return ic.nextSibling()}},childNodes:{get:function(){var b=[];ic.currentNode=this;for(var c=ic.firstChild();c;)b.push(c),c=ic.nextSibling();return b}},parentElement:{get:function(){jc.currentNode=this;return jc.parentNode()}},textContent:{get:function(){switch(this.nodeType){case Node.ELEMENT_NODE:case Node.DOCUMENT_FRAGMENT_NODE:for(var b=
document.createTreeWalker(this,NodeFilter.SHOW_TEXT,null,!1),c="",d;d=b.nextNode();)c+=d.nodeValue;return c;default:return this.nodeValue}},set:function(b){if("undefined"===typeof b||null===b)b="";switch(this.nodeType){case Node.ELEMENT_NODE:case Node.DOCUMENT_FRAGMENT_NODE:lc(this);(0<b.length||this.nodeType===Node.ELEMENT_NODE)&&this.__shady_native_insertBefore(document.createTextNode(b),void 0);break;default:this.nodeValue=b}}}});Q(Node.prototype,"appendChild insertBefore removeChild replaceChild cloneNode contains".split(" "));
Q(HTMLElement.prototype,["parentElement","contains"]);a={firstElementChild:{get:function(){jc.currentNode=this;return jc.firstChild()}},lastElementChild:{get:function(){jc.currentNode=this;return jc.lastChild()}},children:{get:function(){var b=[];jc.currentNode=this;for(var c=jc.firstChild();c;)b.push(c),c=jc.nextSibling();return Gb(b)}},childElementCount:{get:function(){return this.children?this.children.length:0}}};dc?(Q(Element.prototype,mc),Q(Element.prototype,["previousElementSibling","nextElementSibling",
"innerHTML","className"]),Q(HTMLElement.prototype,["children","innerHTML","className"])):(hc(Element.prototype,a),hc(Element.prototype,{previousElementSibling:{get:function(){jc.currentNode=this;return jc.previousSibling()}},nextElementSibling:{get:function(){jc.currentNode=this;return jc.nextSibling()}},innerHTML:{get:function(){return ac(this,Hb)},set:function(b){var c="template"===this.localName?this.content:this;lc(c);var d=this.localName||"div";d=this.namespaceURI&&this.namespaceURI!==kc.namespaceURI?
kc.createElementNS(this.namespaceURI,d):kc.createElement(d);d.innerHTML=b;for(b="template"===this.localName?d.content:d;d=b.__shady_native_firstChild;)c.__shady_native_insertBefore(d,void 0)}},className:{get:function(){return this.getAttribute("class")||""},set:function(b){this.setAttribute("class",b)}}}));Q(Element.prototype,"setAttribute getAttribute hasAttribute removeAttribute focus blur".split(" "));Q(Element.prototype,nc);Q(HTMLElement.prototype,["focus","blur"]);window.HTMLTemplateElement&&
Q(window.HTMLTemplateElement.prototype,["innerHTML"]);dc?Q(DocumentFragment.prototype,mc):hc(DocumentFragment.prototype,a);Q(DocumentFragment.prototype,nc);dc?(Q(Document.prototype,mc),Q(Document.prototype,["activeElement"])):hc(Document.prototype,a);Q(Document.prototype,["importNode","getElementById"]);Q(Document.prototype,nc)};var pc=P({get childNodes(){return this.__shady_childNodes},get firstChild(){return this.__shady_firstChild},get lastChild(){return this.__shady_lastChild},get childElementCount(){return this.__shady_childElementCount},get children(){return this.__shady_children},get firstElementChild(){return this.__shady_firstElementChild},get lastElementChild(){return this.__shady_lastElementChild},get shadowRoot(){return this.__shady_shadowRoot}}),qc=P({get textContent(){return this.__shady_textContent},set textContent(a){this.__shady_textContent=
a},get innerHTML(){return this.__shady_innerHTML},set innerHTML(a){return this.__shady_innerHTML=a}}),rc=P({get parentElement(){return this.__shady_parentElement},get parentNode(){return this.__shady_parentNode},get nextSibling(){return this.__shady_nextSibling},get previousSibling(){return this.__shady_previousSibling},get nextElementSibling(){return this.__shady_nextElementSibling},get previousElementSibling(){return this.__shady_previousElementSibling},get className(){return this.__shady_className},
set className(a){return this.__shady_className=a}});function sc(a){for(var b in a){var c=a[b];c&&(c.enumerable=!1)}}sc(pc);sc(qc);sc(rc);var tc=L.B||!0===L.D,uc=tc?function(){}:function(a){var b=A(a);b.Ka||(b.Ka=!0,Kb(a,rc))},vc=tc?function(){}:function(a){var b=A(a);b.Ja||(b.Ja=!0,Kb(a,pc),window.customElements&&window.customElements.polyfillWrapFlushCallback&&!L.D||Kb(a,qc))};var wc="__eventWrappers"+Date.now(),xc=function(){var a=Object.getOwnPropertyDescriptor(Event.prototype,"composed");return a?function(b){return a.get.call(b)}:null}(),yc=function(){function a(){}var b=!1,c={get capture(){b=!0;return!1}};window.addEventListener("test",a,c);window.removeEventListener("test",a,c);return b}();function zc(a){if(a&&"object"===typeof a){var b=!!a.capture;var c=!!a.once;var d=!!a.passive;var e=a.O}else b=!!a,d=c=!1;return{Ga:e,capture:b,once:c,passive:d,Fa:yc?a:b}}
var Ac={blur:!0,focus:!0,focusin:!0,focusout:!0,click:!0,dblclick:!0,mousedown:!0,mouseenter:!0,mouseleave:!0,mousemove:!0,mouseout:!0,mouseover:!0,mouseup:!0,wheel:!0,beforeinput:!0,input:!0,keydown:!0,keyup:!0,compositionstart:!0,compositionupdate:!0,compositionend:!0,touchstart:!0,touchend:!0,touchmove:!0,touchcancel:!0,pointerover:!0,pointerenter:!0,pointerdown:!0,pointermove:!0,pointerup:!0,pointercancel:!0,pointerout:!0,pointerleave:!0,gotpointercapture:!0,lostpointercapture:!0,dragstart:!0,
drag:!0,dragenter:!0,dragleave:!0,dragover:!0,drop:!0,dragend:!0,DOMActivate:!0,DOMFocusIn:!0,DOMFocusOut:!0,keypress:!0},Bc={DOMAttrModified:!0,DOMAttributeNameChanged:!0,DOMCharacterDataModified:!0,DOMElementNameChanged:!0,DOMNodeInserted:!0,DOMNodeInsertedIntoDocument:!0,DOMNodeRemoved:!0,DOMNodeRemovedFromDocument:!0,DOMSubtreeModified:!0};function Cc(a){return a instanceof Node?a.__shady_getRootNode():a}
function Dc(a,b){var c=[],d=a;for(a=Cc(a);d;)c.push(d),d.__shady_assignedSlot?d=d.__shady_assignedSlot:d.nodeType===Node.DOCUMENT_FRAGMENT_NODE&&d.host&&(b||d!==a)?d=d.host:d=d.__shady_parentNode;c[c.length-1]===document&&c.push(window);return c}function Ec(a){a.__composedPath||(a.__composedPath=Dc(a.target,!0));return a.__composedPath}function Fc(a,b){if(!N)return a;a=Dc(a,!0);for(var c=0,d,e=void 0,f,g=void 0;c<b.length;c++)if(d=b[c],f=Cc(d),f!==e&&(g=a.indexOf(f),e=f),!N(f)||-1<g)return d}
function Gc(a){function b(c,d){c=new a(c,d);c.__composed=d&&!!d.composed;return c}b.__proto__=a;b.prototype=a.prototype;return b}var Hc={focus:!0,blur:!0};function Ic(a){return a.__target!==a.target||a.__relatedTarget!==a.relatedTarget}function Jc(a,b,c){if(c=b.__handlers&&b.__handlers[a.type]&&b.__handlers[a.type][c])for(var d=0,e;(e=c[d])&&(!Ic(a)||a.target!==a.relatedTarget)&&(e.call(b,a),!a.__immediatePropagationStopped);d++);}
function Kc(a){var b=a.composedPath(),c=b.map(function(k){return Fc(k,b)}),d=a.bubbles;Object.defineProperty(a,"currentTarget",{configurable:!0,enumerable:!0,get:function(){return g}});var e=Event.CAPTURING_PHASE;Object.defineProperty(a,"eventPhase",{configurable:!0,enumerable:!0,get:function(){return e}});for(var f=b.length-1;0<=f;f--){var g=b[f];e=g===c[f]?Event.AT_TARGET:Event.CAPTURING_PHASE;Jc(a,g,"capture");if(a.ma)return}for(f=0;f<b.length;f++){g=b[f];var h=g===c[f];if(h||d)if(e=h?Event.AT_TARGET:
Event.BUBBLING_PHASE,Jc(a,g,"bubble"),a.ma)return}e=0;g=null}function Lc(a,b,c,d,e,f){for(var g=0;g<a.length;g++){var h=a[g],k=h.type,l=h.capture,m=h.once,q=h.passive;if(b===h.node&&c===k&&d===l&&e===m&&f===q)return g}return-1}function Mc(a){Pb();return!L.aa&&this instanceof Node&&!Eb(document,this)?(a.__target||Nc(a,this),Kc(a)):this.__shady_native_dispatchEvent(a)}
function Oc(a,b,c){var d=zc(c),e=d.capture,f=d.once,g=d.passive,h=d.Ga;d=d.Fa;if(b){var k=typeof b;if("function"===k||"object"===k)if("object"!==k||b.handleEvent&&"function"===typeof b.handleEvent){if(Bc[a])return this.__shady_native_addEventListener(a,b,d);var l=h||this;if(h=b[wc]){if(-1<Lc(h,l,a,e,f,g))return}else b[wc]=[];h=function(m){f&&this.__shady_removeEventListener(a,b,c);m.__target||Nc(m);if(l!==this){var q=Object.getOwnPropertyDescriptor(m,"currentTarget");Object.defineProperty(m,"currentTarget",
{get:function(){return l},configurable:!0});var H=Object.getOwnPropertyDescriptor(m,"eventPhase");Object.defineProperty(m,"eventPhase",{configurable:!0,enumerable:!0,get:function(){return e?Event.CAPTURING_PHASE:Event.BUBBLING_PHASE}})}m.__previousCurrentTarget=m.currentTarget;if(!N(l)&&"slot"!==l.localName||-1!=m.composedPath().indexOf(l))if(m.composed||-1<m.composedPath().indexOf(l))if(Ic(m)&&m.target===m.relatedTarget)m.eventPhase===Event.BUBBLING_PHASE&&m.stopImmediatePropagation();else if(m.eventPhase===
Event.CAPTURING_PHASE||m.bubbles||m.target===l||l instanceof Window){var C="function"===k?b.call(l,m):b.handleEvent&&b.handleEvent(m);l!==this&&(q?(Object.defineProperty(m,"currentTarget",q),q=null):delete m.currentTarget,H?(Object.defineProperty(m,"eventPhase",H),H=null):delete m.eventPhase);return C}};b[wc].push({node:l,type:a,capture:e,once:f,passive:g,lb:h});this.__handlers=this.__handlers||{};this.__handlers[a]=this.__handlers[a]||{capture:[],bubble:[]};this.__handlers[a][e?"capture":"bubble"].push(h);
Hc[a]||this.__shady_native_addEventListener(a,h,d)}}}
function Pc(a,b,c){if(b){var d=zc(c);c=d.capture;var e=d.once,f=d.passive,g=d.Ga;d=d.Fa;if(Bc[a])return this.__shady_native_removeEventListener(a,b,d);var h=g||this;g=void 0;var k=null;try{k=b[wc]}catch(l){}k&&(e=Lc(k,h,a,c,e,f),-1<e&&(g=k.splice(e,1)[0].lb,k.length||(b[wc]=void 0)));this.__shady_native_removeEventListener(a,g||b,d);g&&this.__handlers&&this.__handlers[a]&&(a=this.__handlers[a][c?"capture":"bubble"],b=a.indexOf(g),-1<b&&a.splice(b,1))}}
function Qc(){for(var a in Hc)window.__shady_native_addEventListener(a,function(b){b.__target||(Nc(b),Kc(b))},!0)}
var Rc=P({get composed(){void 0===this.__composed&&(xc?this.__composed="focusin"===this.type||"focusout"===this.type||xc(this):!1!==this.isTrusted&&(this.__composed=Ac[this.type]));return this.__composed||!1},composedPath:function(){this.__composedPath||(this.__composedPath=Dc(this.__target,this.composed));return this.__composedPath},get target(){return Fc(this.currentTarget||this.__previousCurrentTarget,this.composedPath())},get relatedTarget(){if(!this.__relatedTarget)return null;this.__relatedTargetComposedPath||
(this.__relatedTargetComposedPath=Dc(this.__relatedTarget,!0));return Fc(this.currentTarget||this.__previousCurrentTarget,this.__relatedTargetComposedPath)},stopPropagation:function(){Event.prototype.stopPropagation.call(this);this.ma=!0},stopImmediatePropagation:function(){Event.prototype.stopImmediatePropagation.call(this);this.ma=this.__immediatePropagationStopped=!0}});
function Nc(a,b){b=void 0===b?a.target:b;a.__target=b;a.__relatedTarget=a.relatedTarget;if(L.B){b=Object.getPrototypeOf(a);if(!b.hasOwnProperty("__shady_patchedProto")){var c=Object.create(b);c.__shady_sourceProto=b;O(c,Rc);b.__shady_patchedProto=c}a.__proto__=b.__shady_patchedProto}else O(a,Rc)}var Sc=Gc(Event),Tc=Gc(CustomEvent),Uc=Gc(MouseEvent);
function Vc(){if(!xc&&Object.getOwnPropertyDescriptor(Event.prototype,"isTrusted")){var a=function(){var b=new MouseEvent("click",{bubbles:!0,cancelable:!0,composed:!0});this.__shady_dispatchEvent(b)};Element.prototype.click?Element.prototype.click=a:HTMLElement.prototype.click&&(HTMLElement.prototype.click=a)}}
var Wc=Object.getOwnPropertyNames(Element.prototype).filter(function(a){return"on"===a.substring(0,2)}),Xc=Object.getOwnPropertyNames(HTMLElement.prototype).filter(function(a){return"on"===a.substring(0,2)});function Yc(a){return{set:function(b){var c=A(this),d=a.substring(2);c.N||(c.N={});c.N[a]&&this.removeEventListener(d,c.N[a]);this.__shady_addEventListener(d,b);c.N[a]=b},get:function(){var b=D(this);return b&&b.N&&b.N[a]},configurable:!0}};function Zc(a,b){return{index:a,ba:[],ia:b}}
function $c(a,b,c,d){var e=0,f=0,g=0,h=0,k=Math.min(b-e,d-f);if(0==e&&0==f)a:{for(g=0;g<k;g++)if(a[g]!==c[g])break a;g=k}if(b==a.length&&d==c.length){h=a.length;for(var l=c.length,m=0;m<k-g&&ad(a[--h],c[--l]);)m++;h=m}e+=g;f+=g;b-=h;d-=h;if(0==b-e&&0==d-f)return[];if(e==b){for(b=Zc(e,0);f<d;)b.ba.push(c[f++]);return[b]}if(f==d)return[Zc(e,b-e)];k=e;g=f;d=d-g+1;h=b-k+1;b=Array(d);for(l=0;l<d;l++)b[l]=Array(h),b[l][0]=l;for(l=0;l<h;l++)b[0][l]=l;for(l=1;l<d;l++)for(m=1;m<h;m++)if(a[k+m-1]===c[g+l-1])b[l][m]=
b[l-1][m-1];else{var q=b[l-1][m]+1,H=b[l][m-1]+1;b[l][m]=q<H?q:H}k=b.length-1;g=b[0].length-1;d=b[k][g];for(a=[];0<k||0<g;)0==k?(a.push(2),g--):0==g?(a.push(3),k--):(h=b[k-1][g-1],l=b[k-1][g],m=b[k][g-1],q=l<m?l<h?l:h:m<h?m:h,q==h?(h==d?a.push(0):(a.push(1),d=h),k--,g--):q==l?(a.push(3),k--,d=l):(a.push(2),g--,d=m));a.reverse();b=void 0;k=[];for(g=0;g<a.length;g++)switch(a[g]){case 0:b&&(k.push(b),b=void 0);e++;f++;break;case 1:b||(b=Zc(e,0));b.ia++;e++;b.ba.push(c[f]);f++;break;case 2:b||(b=Zc(e,
0));b.ia++;e++;break;case 3:b||(b=Zc(e,0)),b.ba.push(c[f]),f++}b&&k.push(b);return k}function ad(a,b){return a===b};var bd=P({dispatchEvent:Mc,addEventListener:Oc,removeEventListener:Pc});var cd=null;function dd(){cd||(cd=window.ShadyCSS&&window.ShadyCSS.ScopingShim);return cd||null}function ed(a,b,c){var d=dd();return d&&"class"===b?(d.setElementClass(a,c),!0):!1}function fd(a,b){var c=dd();c&&c.unscopeNode(a,b)}function gd(a,b){var c=dd();if(!c)return!0;if(a.nodeType===Node.DOCUMENT_FRAGMENT_NODE){c=!0;for(a=a.__shady_firstChild;a;a=a.__shady_nextSibling)c=c&&gd(a,b);return c}return a.nodeType!==Node.ELEMENT_NODE?!0:c.currentScopeForNode(a)===b}
function hd(a){if(a.nodeType!==Node.ELEMENT_NODE)return"";var b=dd();return b?b.currentScopeForNode(a):""}function id(a,b){if(a)for(a.nodeType===Node.ELEMENT_NODE&&b(a),a=a.__shady_firstChild;a;a=a.__shady_nextSibling)a.nodeType===Node.ELEMENT_NODE&&id(a,b)};var jd=window.document,kd=L.aa,ld=Object.getOwnPropertyDescriptor(Node.prototype,"isConnected"),md=ld&&ld.get;function nd(a){for(var b;b=a.__shady_firstChild;)a.__shady_removeChild(b)}function od(a){var b=D(a);if(b&&void 0!==b.la)for(b=a.__shady_firstChild;b;b=b.__shady_nextSibling)od(b);if(a=D(a))a.la=void 0}function pd(a){var b=a;if(a&&"slot"===a.localName){var c=D(a);(c=c&&c.V)&&(b=c.length?c[0]:pd(a.__shady_nextSibling))}return b}
function qd(a,b,c){if(a=(a=D(a))&&a.Z){if(b)if(b.nodeType===Node.DOCUMENT_FRAGMENT_NODE)for(var d=0,e=b.childNodes.length;d<e;d++)a.addedNodes.push(b.childNodes[d]);else a.addedNodes.push(b);c&&a.removedNodes.push(c);Rb(a)}}
var xd=P({get parentNode(){var a=D(this);a=a&&a.parentNode;return void 0!==a?a:this.__shady_native_parentNode},get firstChild(){var a=D(this);a=a&&a.firstChild;return void 0!==a?a:this.__shady_native_firstChild},get lastChild(){var a=D(this);a=a&&a.lastChild;return void 0!==a?a:this.__shady_native_lastChild},get nextSibling(){var a=D(this);a=a&&a.nextSibling;return void 0!==a?a:this.__shady_native_nextSibling},get previousSibling(){var a=D(this);a=a&&a.previousSibling;return void 0!==a?a:this.__shady_native_previousSibling},
get childNodes(){if(vb(this)){var a=D(this);if(!a.childNodes){a.childNodes=[];for(var b=this.__shady_firstChild;b;b=b.__shady_nextSibling)a.childNodes.push(b)}var c=a.childNodes}else c=this.__shady_native_childNodes;c.item=function(d){return c[d]};return c},get parentElement(){var a=D(this);(a=a&&a.parentNode)&&a.nodeType!==Node.ELEMENT_NODE&&(a=null);return void 0!==a?a:this.__shady_native_parentElement},get isConnected(){if(md&&md.call(this))return!0;if(this.nodeType==Node.DOCUMENT_FRAGMENT_NODE)return!1;
var a=this.ownerDocument;if(null===a||Eb(a,this))return!0;for(a=this;a&&!(a instanceof Document);)a=a.__shady_parentNode||(N(a)?a.host:void 0);return!!(a&&a instanceof Document)},get textContent(){if(vb(this)){for(var a=[],b=this.__shady_firstChild;b;b=b.__shady_nextSibling)b.nodeType!==Node.COMMENT_NODE&&a.push(b.__shady_textContent);return a.join("")}return this.__shady_native_textContent},set textContent(a){if("undefined"===typeof a||null===a)a="";switch(this.nodeType){case Node.ELEMENT_NODE:case Node.DOCUMENT_FRAGMENT_NODE:if(!vb(this)&&
L.B){var b=this.__shady_firstChild;(b!=this.__shady_lastChild||b&&b.nodeType!=Node.TEXT_NODE)&&nd(this);this.__shady_native_textContent=a}else nd(this),(0<a.length||this.nodeType===Node.ELEMENT_NODE)&&this.__shady_insertBefore(document.createTextNode(a));break;default:this.nodeValue=a}},insertBefore:function(a,b){if(this.ownerDocument!==jd&&a.ownerDocument!==jd)return this.__shady_native_insertBefore(a,b),a;if(a===this)throw Error("Failed to execute 'appendChild' on 'Node': The new child element contains the parent.");
if(b){var c=D(b);c=c&&c.parentNode;if(void 0!==c&&c!==this||void 0===c&&b.__shady_native_parentNode!==this)throw Error("Failed to execute 'insertBefore' on 'Node': The node before which the new node is to be inserted is not a child of this node.");}if(b===a)return a;qd(this,a);var d=[],e=(c=rd(this))?c.host.localName:hd(this),f=a.__shady_parentNode;if(f){var g=hd(a);var h=!!c||!rd(a)||kd&&void 0!==this.__noInsertionPoint;f.__shady_removeChild(a,h)}f=!0;var k=(!kd||void 0===a.__noInsertionPoint&&void 0===
this.__noInsertionPoint)&&!gd(a,e),l=c&&!a.__noInsertionPoint&&(!kd||a.nodeType===Node.DOCUMENT_FRAGMENT_NODE);if(l||k)k&&(g=g||hd(a)),id(a,function(m){l&&"slot"===m.localName&&d.push(m);if(k){var q=g;dd()&&(q&&fd(m,q),(q=dd())&&q.scopeNode(m,e))}});d.length&&(sd(c),c.c.push.apply(c.c,d instanceof Array?d:na(ma(d))),td(c));vb(this)&&(ud(a,this,b),h=D(this),h.root?(f=!1,wb(this)&&td(h.root)):c&&"slot"===this.localName&&(f=!1,td(c)));f?(c=N(this)?this.host:this,b?(b=pd(b),c.__shady_native_insertBefore(a,
b)):c.__shady_native_appendChild(a)):a.ownerDocument!==this.ownerDocument&&this.ownerDocument.adoptNode(a);return a},appendChild:function(a){if(this!=a||!N(a))return this.__shady_insertBefore(a)},removeChild:function(a,b){b=void 0===b?!1:b;if(this.ownerDocument!==jd)return this.__shady_native_removeChild(a);if(a.__shady_parentNode!==this)throw Error("The node to be removed is not a child of this node: "+a);qd(this,null,a);var c=rd(a),d=c&&vd(c,a),e=D(this);if(vb(this)&&(wd(a,this),wb(this))){td(e.root);
var f=!0}if(dd()&&!b&&c&&a.nodeType!==Node.TEXT_NODE){var g=hd(a);id(a,function(h){fd(h,g)})}od(a);c&&((b="slot"===this.localName)&&(f=!0),(d||b)&&td(c));f||(f=N(this)?this.host:this,(!e.root&&"slot"!==a.localName||f===a.__shady_native_parentNode)&&f.__shady_native_removeChild(a));return a},replaceChild:function(a,b){this.__shady_insertBefore(a,b);this.__shady_removeChild(b);return a},cloneNode:function(a){if("template"==this.localName)return this.__shady_native_cloneNode(a);var b=this.__shady_native_cloneNode(!1);
if(a&&b.nodeType!==Node.ATTRIBUTE_NODE){a=this.__shady_firstChild;for(var c;a;a=a.__shady_nextSibling)c=a.__shady_cloneNode(!0),b.__shady_appendChild(c)}return b},getRootNode:function(a){if(this&&this.nodeType){var b=A(this),c=b.la;void 0===c&&(N(this)?(c=this,b.la=c):(c=(c=this.__shady_parentNode)?c.__shady_getRootNode(a):this,document.documentElement.__shady_native_contains(this)&&(b.la=c)));return c}},contains:function(a){return Fb(this,a)}});var zd=P({get assignedSlot(){var a=this.__shady_parentNode;(a=a&&a.__shady_shadowRoot)&&yd(a);return(a=D(this))&&a.assignedSlot||null}});function Ad(a,b,c){var d=[];Cd(a,b,c,d);return d}function Cd(a,b,c,d){for(a=a.__shady_firstChild;a;a=a.__shady_nextSibling){var e;if(e=a.nodeType===Node.ELEMENT_NODE){e=a;var f=b,g=c,h=d,k=f(e);k&&h.push(e);g&&g(k)?e=k:(Cd(e,f,g,h),e=void 0)}if(e)break}}
var Dd=P({get firstElementChild(){var a=D(this);if(a&&void 0!==a.firstChild){for(a=this.__shady_firstChild;a&&a.nodeType!==Node.ELEMENT_NODE;)a=a.__shady_nextSibling;return a}return this.__shady_native_firstElementChild},get lastElementChild(){var a=D(this);if(a&&void 0!==a.lastChild){for(a=this.__shady_lastChild;a&&a.nodeType!==Node.ELEMENT_NODE;)a=a.__shady_previousSibling;return a}return this.__shady_native_lastElementChild},get children(){return vb(this)?Gb(Array.prototype.filter.call(Ib(this),
function(a){return a.nodeType===Node.ELEMENT_NODE})):this.__shady_native_children},get childElementCount(){var a=this.__shady_children;return a?a.length:0}}),Ed=P({querySelector:function(a){return Ad(this,function(b){return zb.call(b,a)},function(b){return!!b})[0]||null},querySelectorAll:function(a,b){if(b){b=Array.prototype.slice.call(this.__shady_native_querySelectorAll(a));var c=this.__shady_getRootNode();return Gb(b.filter(function(d){return d.__shady_getRootNode()==c}))}return Gb(Ad(this,function(d){return zb.call(d,
a)}))}}),Fd=L.aa&&!L.D?Lb({},Dd):Dd;Lb(Dd,Ed);var Gd=window.document;function Hd(a,b){if("slot"===b)a=a.__shady_parentNode,wb(a)&&td(D(a).root);else if("slot"===a.localName&&"name"===b&&(b=rd(a))){if(b.a){Id(b);var c=a.La,d=Jd(a);if(d!==c){c=b.b[c];var e=c.indexOf(a);0<=e&&c.splice(e,1);c=b.b[d]||(b.b[d]=[]);c.push(a);1<c.length&&(b.b[d]=Kd(c))}}td(b)}}
var Ld=P({get previousElementSibling(){var a=D(this);if(a&&void 0!==a.previousSibling){for(a=this.__shady_previousSibling;a&&a.nodeType!==Node.ELEMENT_NODE;)a=a.__shady_previousSibling;return a}return this.__shady_native_previousElementSibling},get nextElementSibling(){var a=D(this);if(a&&void 0!==a.nextSibling){for(a=this.__shady_nextSibling;a&&a.nodeType!==Node.ELEMENT_NODE;)a=a.__shady_nextSibling;return a}return this.__shady_native_nextElementSibling},get slot(){return this.getAttribute("slot")},
set slot(a){this.__shady_setAttribute("slot",a)},get className(){return this.getAttribute("class")||""},set className(a){this.__shady_setAttribute("class",a)},setAttribute:function(a,b){this.ownerDocument!==Gd?this.__shady_native_setAttribute(a,b):ed(this,a,b)||(this.__shady_native_setAttribute(a,b),Hd(this,a))},removeAttribute:function(a){this.ownerDocument!==Gd?this.__shady_native_removeAttribute(a):ed(this,a,"")?""===this.getAttribute(a)&&this.__shady_native_removeAttribute(a):(this.__shady_native_removeAttribute(a),
Hd(this,a))}});L.aa||Wc.forEach(function(a){Ld[a]=Yc(a)});
var Qd=P({attachShadow:function(a){if(!this)throw Error("Must provide a host.");if(!a)throw Error("Not enough arguments.");if(a.shadyUpgradeFragment&&!L.Ia){var b=a.shadyUpgradeFragment;b.__proto__=ShadowRoot.prototype;Md(b,this,a);Nd(b,b);a=b.__noInsertionPoint?null:b.querySelectorAll("slot");b.__noInsertionPoint=void 0;if(a&&a.length){var c=b;sd(c);c.c.push.apply(c.c,a instanceof Array?a:na(ma(a)));td(b)}b.host.__shady_native_appendChild(b)}else b=new Od(Pd,this,a);return this.__CE_shadowRoot=b},
get shadowRoot(){var a=D(this);return a&&a.bb||null}});Lb(Ld,Qd);var Rd=document.implementation.createHTMLDocument("inert"),Sd=P({get innerHTML(){return vb(this)?ac("template"===this.localName?this.content:this,Ib):this.__shady_native_innerHTML},set innerHTML(a){if("template"===this.localName)this.__shady_native_innerHTML=a;else{nd(this);var b=this.localName||"div";b=this.namespaceURI&&this.namespaceURI!==Rd.namespaceURI?Rd.createElementNS(this.namespaceURI,b):Rd.createElement(b);for(L.B?b.__shady_native_innerHTML=a:b.innerHTML=a;a=b.__shady_firstChild;)this.__shady_insertBefore(a)}}});var Td=P({blur:function(){var a=D(this);(a=(a=a&&a.root)&&a.activeElement)?a.__shady_blur():this.__shady_native_blur()}});L.aa||Xc.forEach(function(a){Td[a]=Yc(a)});var Ud=P({assignedNodes:function(a){if("slot"===this.localName){var b=this.__shady_getRootNode();b&&N(b)&&yd(b);return(b=D(this))?(a&&a.flatten?b.V:b.assignedNodes)||[]:[]}},addEventListener:function(a,b,c){if("slot"!==this.localName||"slotchange"===a)Oc.call(this,a,b,c);else{"object"!==typeof c&&(c={capture:!!c});var d=this.__shady_parentNode;if(!d)throw Error("ShadyDOM cannot attach event to slot unless it has a `parentNode`");c.O=this;d.__shady_addEventListener(a,b,c)}},removeEventListener:function(a,
b,c){if("slot"!==this.localName||"slotchange"===a)Pc.call(this,a,b,c);else{"object"!==typeof c&&(c={capture:!!c});var d=this.__shady_parentNode;if(!d)throw Error("ShadyDOM cannot attach event to slot unless it has a `parentNode`");c.O=this;d.__shady_removeEventListener(a,b,c)}}});var Vd=P({getElementById:function(a){return""===a?null:Ad(this,function(b){return b.id==a},function(b){return!!b})[0]||null}});var Wd=P({get activeElement(){var a=L.B?document.__shady_native_activeElement:document.activeElement;if(!a||!a.nodeType)return null;var b=!!N(this);if(!(this===document||b&&this.host!==a&&this.host.__shady_native_contains(a)))return null;for(b=rd(a);b&&b!==this;)a=b.host,b=rd(a);return this===document?b?null:a:b===this?a:null}});var Xd=window.document,Yd=P({importNode:function(a,b){if(a.ownerDocument!==Xd||"template"===a.localName)return this.__shady_native_importNode(a,b);var c=this.__shady_native_importNode(a,!1);if(b)for(a=a.__shady_firstChild;a;a=a.__shady_nextSibling)b=this.__shady_importNode(a,!0),c.__shady_appendChild(b);return c}});var Zd=P({dispatchEvent:Mc,addEventListener:Oc.bind(window),removeEventListener:Pc.bind(window)});var $d={};Object.getOwnPropertyDescriptor(HTMLElement.prototype,"parentElement")&&($d.parentElement=xd.parentElement);Object.getOwnPropertyDescriptor(HTMLElement.prototype,"contains")&&($d.contains=xd.contains);Object.getOwnPropertyDescriptor(HTMLElement.prototype,"children")&&($d.children=Dd.children);Object.getOwnPropertyDescriptor(HTMLElement.prototype,"innerHTML")&&($d.innerHTML=Sd.innerHTML);Object.getOwnPropertyDescriptor(HTMLElement.prototype,"className")&&($d.className=Ld.className);
var ae={EventTarget:[bd],Node:[xd,window.EventTarget?null:bd],Text:[zd],Comment:[zd],CDATASection:[zd],ProcessingInstruction:[zd],Element:[Ld,Dd,zd,!L.B||"innerHTML"in Element.prototype?Sd:null,window.HTMLSlotElement?null:Ud],HTMLElement:[Td,$d],HTMLSlotElement:[Ud],DocumentFragment:[Fd,Vd],Document:[Yd,Fd,Vd,Wd],Window:[Zd]},be=L.B?null:["innerHTML","textContent"];function ce(a,b,c,d){b.forEach(function(e){return a&&e&&O(a,e,c,d)})}
function de(a){var b=a?null:be,c;for(c in ae)ce(window[c]&&window[c].prototype,ae[c],a,b)}["Text","Comment","CDATASection","ProcessingInstruction"].forEach(function(a){var b=window[a],c=Object.create(b.prototype);c.__shady_protoIsPatched=!0;ce(c,ae.EventTarget);ce(c,ae.Node);ae[a]&&ce(c,ae[a]);b.prototype.__shady_patchedProto=c});function ee(a){a.__shady_protoIsPatched=!0;ce(a,ae.EventTarget);ce(a,ae.Node);ce(a,ae.Element);ce(a,ae.HTMLElement);ce(a,ae.HTMLSlotElement);return a};var fe=L.ua,ge=L.B;function he(a,b){if(fe&&!a.__shady_protoIsPatched&&!N(a)){var c=Object.getPrototypeOf(a),d=c.hasOwnProperty("__shady_patchedProto")&&c.__shady_patchedProto;d||(d=Object.create(c),ee(d),c.__shady_patchedProto=d);Object.setPrototypeOf(a,d)}ge||(1===b?uc(a):2===b&&vc(a))}
function ie(a,b,c,d){he(a,1);d=d||null;var e=A(a),f=d?A(d):null;e.previousSibling=d?f.previousSibling:b.__shady_lastChild;if(f=D(e.previousSibling))f.nextSibling=a;if(f=D(e.nextSibling=d))f.previousSibling=a;e.parentNode=b;d?d===c.firstChild&&(c.firstChild=a):(c.lastChild=a,c.firstChild||(c.firstChild=a));c.childNodes=null}
function ud(a,b,c){he(b,2);var d=A(b);void 0!==d.firstChild&&(d.childNodes=null);if(a.nodeType===Node.DOCUMENT_FRAGMENT_NODE)for(a=a.__shady_native_firstChild;a;a=a.__shady_native_nextSibling)ie(a,b,d,c);else ie(a,b,d,c)}
function wd(a,b){var c=A(a);b=A(b);a===b.firstChild&&(b.firstChild=c.nextSibling);a===b.lastChild&&(b.lastChild=c.previousSibling);a=c.previousSibling;var d=c.nextSibling;a&&(A(a).nextSibling=d);d&&(A(d).previousSibling=a);c.parentNode=c.previousSibling=c.nextSibling=void 0;void 0!==b.childNodes&&(b.childNodes=null)}
function Nd(a,b){var c=A(a);if(b||void 0===c.firstChild){c.childNodes=null;var d=c.firstChild=a.__shady_native_firstChild;c.lastChild=a.__shady_native_lastChild;he(a,2);c=d;for(d=void 0;c;c=c.__shady_native_nextSibling){var e=A(c);e.parentNode=b||a;e.nextSibling=c.__shady_native_nextSibling;e.previousSibling=d||null;d=c;he(c,1)}}};var je=P({addEventListener:function(a,b,c){"object"!==typeof c&&(c={capture:!!c});c.O=c.O||this;this.host.__shady_addEventListener(a,b,c)},removeEventListener:function(a,b,c){"object"!==typeof c&&(c={capture:!!c});c.O=c.O||this;this.host.__shady_removeEventListener(a,b,c)}});function ke(a,b){O(a,je,b);O(a,Wd,b);O(a,Sd,b);O(a,Dd,b);L.D&&!b?(O(a,xd,b),O(a,Vd,b)):L.B||(O(a,rc),O(a,pc),O(a,qc))};var Pd={},le=L.deferConnectionCallbacks&&"loading"===document.readyState,me;function ne(a){var b=[];do b.unshift(a);while(a=a.__shady_parentNode);return b}function Od(a,b,c){if(a!==Pd)throw new TypeError("Illegal constructor");this.a=null;Md(this,b,c)}
function Md(a,b,c){a.host=b;a.mode=c&&c.mode;Nd(a.host);b=A(a.host);b.root=a;b.bb="closed"!==a.mode?a:null;b=A(a);b.firstChild=b.lastChild=b.parentNode=b.nextSibling=b.previousSibling=null;if(L.preferPerformance)for(;b=a.host.__shady_native_firstChild;)a.host.__shady_native_removeChild(b);else td(a)}function td(a){a.T||(a.T=!0,Ob(function(){return yd(a)}))}
function yd(a){var b;if(b=a.T){for(var c;a;)a:{a.T&&(c=a),b=a;a=b.host.__shady_getRootNode();if(N(a)&&(b=D(b.host))&&0<b.da)break a;a=void 0}b=c}(c=b)&&c._renderSelf()}
Od.prototype._renderSelf=function(){var a=le;le=!0;this.T=!1;if(this.a){Id(this);for(var b=0,c;b<this.a.length;b++){c=this.a[b];var d=D(c),e=d.assignedNodes;d.assignedNodes=[];d.V=[];if(d.Ba=e)for(d=0;d<e.length;d++){var f=D(e[d]);f.oa=f.assignedSlot;f.assignedSlot===c&&(f.assignedSlot=null)}}for(b=this.host.__shady_firstChild;b;b=b.__shady_nextSibling)oe(this,b);for(b=0;b<this.a.length;b++){c=this.a[b];e=D(c);if(!e.assignedNodes.length)for(d=c.__shady_firstChild;d;d=d.__shady_nextSibling)oe(this,
d,c);(d=(d=D(c.__shady_parentNode))&&d.root)&&(xb(d)||d.T)&&d._renderSelf();pe(this,e.V,e.assignedNodes);if(d=e.Ba){for(f=0;f<d.length;f++)D(d[f]).oa=null;e.Ba=null;d.length>e.assignedNodes.length&&(e.ra=!0)}e.ra&&(e.ra=!1,qe(this,c))}c=this.a;b=[];for(e=0;e<c.length;e++)d=c[e].__shady_parentNode,(f=D(d))&&f.root||!(0>b.indexOf(d))||b.push(d);for(c=0;c<b.length;c++){f=b[c];e=f===this?this.host:f;d=[];for(f=f.__shady_firstChild;f;f=f.__shady_nextSibling)if("slot"==f.localName)for(var g=D(f).V,h=0;h<
g.length;h++)d.push(g[h]);else d.push(f);f=Hb(e);g=$c(d,d.length,f,f.length);for(var k=h=0,l=void 0;h<g.length&&(l=g[h]);h++){for(var m=0,q=void 0;m<l.ba.length&&(q=l.ba[m]);m++)q.__shady_native_parentNode===e&&e.__shady_native_removeChild(q),f.splice(l.index+k,1);k-=l.ia}k=0;for(l=void 0;k<g.length&&(l=g[k]);k++)for(h=f[l.index],m=l.index;m<l.index+l.ia;m++)q=d[m],e.__shady_native_insertBefore(q,h),f.splice(m,0,q)}}if(!L.preferPerformance&&!this.Aa)for(b=this.host.__shady_firstChild;b;b=b.__shady_nextSibling)c=
D(b),b.__shady_native_parentNode!==this.host||"slot"!==b.localName&&c.assignedSlot||this.host.__shady_native_removeChild(b);this.Aa=!0;le=a;me&&me()};function oe(a,b,c){var d=A(b),e=d.oa;d.oa=null;c||(c=(a=a.b[b.__shady_slot||"__catchall"])&&a[0]);c?(A(c).assignedNodes.push(b),d.assignedSlot=c):d.assignedSlot=void 0;e!==d.assignedSlot&&d.assignedSlot&&(A(d.assignedSlot).ra=!0)}
function pe(a,b,c){for(var d=0,e=void 0;d<c.length&&(e=c[d]);d++)if("slot"==e.localName){var f=D(e).assignedNodes;f&&f.length&&pe(a,b,f)}else b.push(c[d])}function qe(a,b){b.__shady_native_dispatchEvent(new Event("slotchange"));b=D(b);b.assignedSlot&&qe(a,b.assignedSlot)}function sd(a){a.c=a.c||[];a.a=a.a||[];a.b=a.b||{}}
function Id(a){if(a.c&&a.c.length){for(var b=a.c,c,d=0;d<b.length;d++){var e=b[d];Nd(e);var f=e.__shady_parentNode;Nd(f);f=D(f);f.da=(f.da||0)+1;f=Jd(e);a.b[f]?(c=c||{},c[f]=!0,a.b[f].push(e)):a.b[f]=[e];a.a.push(e)}if(c)for(var g in c)a.b[g]=Kd(a.b[g]);a.c=[]}}function Jd(a){var b=a.name||a.getAttribute("name")||"__catchall";return a.La=b}
function Kd(a){return a.sort(function(b,c){b=ne(b);for(var d=ne(c),e=0;e<b.length;e++){c=b[e];var f=d[e];if(c!==f)return b=Ib(c.__shady_parentNode),b.indexOf(c)-b.indexOf(f)}})}
function vd(a,b){if(a.a){Id(a);var c=a.b,d;for(d in c)for(var e=c[d],f=0;f<e.length;f++){var g=e[f];if(Fb(b,g)){e.splice(f,1);var h=a.a.indexOf(g);0<=h&&(a.a.splice(h,1),(h=D(g.__shady_parentNode))&&h.da&&h.da--);f--;g=D(g);if(h=g.V)for(var k=0;k<h.length;k++){var l=h[k],m=l.__shady_native_parentNode;m&&m.__shady_native_removeChild(l)}g.V=[];g.assignedNodes=[];h=!0}}return h}}function xb(a){Id(a);return!(!a.a||!a.a.length)}
(function(a){a.__proto__=DocumentFragment.prototype;ke(a,"__shady_");ke(a);Object.defineProperties(a,{nodeType:{value:Node.DOCUMENT_FRAGMENT_NODE,configurable:!0},nodeName:{value:"#document-fragment",configurable:!0},nodeValue:{value:null,configurable:!0}});["localName","namespaceURI","prefix"].forEach(function(b){Object.defineProperty(a,b,{value:void 0,configurable:!0})});["ownerDocument","baseURI","isConnected"].forEach(function(b){Object.defineProperty(a,b,{get:function(){return this.host[b]},
configurable:!0})})})(Od.prototype);
if(window.customElements&&window.customElements.define&&L.sa&&!L.preferPerformance){var re=new Map;me=function(){var a=[];re.forEach(function(d,e){a.push([e,d])});re.clear();for(var b=0;b<a.length;b++){var c=a[b][0];a[b][1]?c.__shadydom_connectedCallback():c.__shadydom_disconnectedCallback()}};le&&document.addEventListener("readystatechange",function(){le=!1;me()},{once:!0});var se=function(a,b,c){var d=0,e="__isConnected"+d++;if(b||c)a.prototype.connectedCallback=a.prototype.__shadydom_connectedCallback=
function(){le?re.set(this,!0):this[e]||(this[e]=!0,b&&b.call(this))},a.prototype.disconnectedCallback=a.prototype.__shadydom_disconnectedCallback=function(){le?this.isConnected||re.set(this,!1):this[e]&&(this[e]=!1,c&&c.call(this))};return a},te=window.customElements.define,ue=function(a,b){var c=b.prototype.connectedCallback,d=b.prototype.disconnectedCallback;te.call(window.customElements,a,se(b,c,d));b.prototype.connectedCallback=c;b.prototype.disconnectedCallback=d};window.customElements.define=
ue;Object.defineProperty(window.CustomElementRegistry.prototype,"define",{value:ue,configurable:!0})}function rd(a){a=a.__shady_getRootNode();if(N(a))return a};function ve(a){this.node=a}w=ve.prototype;w.addEventListener=function(a,b,c){return this.node.__shady_addEventListener(a,b,c)};w.removeEventListener=function(a,b,c){return this.node.__shady_removeEventListener(a,b,c)};w.appendChild=function(a){return this.node.__shady_appendChild(a)};w.insertBefore=function(a,b){return this.node.__shady_insertBefore(a,b)};w.removeChild=function(a){return this.node.__shady_removeChild(a)};w.replaceChild=function(a,b){return this.node.__shady_replaceChild(a,b)};
w.cloneNode=function(a){return this.node.__shady_cloneNode(a)};w.getRootNode=function(a){return this.node.__shady_getRootNode(a)};w.contains=function(a){return this.node.__shady_contains(a)};w.dispatchEvent=function(a){return this.node.__shady_dispatchEvent(a)};w.setAttribute=function(a,b){this.node.__shady_setAttribute(a,b)};w.getAttribute=function(a){return this.node.__shady_native_getAttribute(a)};w.hasAttribute=function(a){return this.node.__shady_native_hasAttribute(a)};w.removeAttribute=function(a){this.node.__shady_removeAttribute(a)};
w.attachShadow=function(a){return this.node.__shady_attachShadow(a)};w.focus=function(){this.node.__shady_native_focus()};w.blur=function(){this.node.__shady_blur()};w.importNode=function(a,b){if(this.node.nodeType===Node.DOCUMENT_NODE)return this.node.__shady_importNode(a,b)};w.getElementById=function(a){if(this.node.nodeType===Node.DOCUMENT_NODE)return this.node.__shady_getElementById(a)};w.querySelector=function(a){return this.node.__shady_querySelector(a)};
w.querySelectorAll=function(a,b){return this.node.__shady_querySelectorAll(a,b)};w.assignedNodes=function(a){if("slot"===this.node.localName)return this.node.__shady_assignedNodes(a)};
ca.Object.defineProperties(ve.prototype,{activeElement:{configurable:!0,enumerable:!0,get:function(){if(N(this.node)||this.node.nodeType===Node.DOCUMENT_NODE)return this.node.__shady_activeElement}},_activeElement:{configurable:!0,enumerable:!0,get:function(){return this.activeElement}},host:{configurable:!0,enumerable:!0,get:function(){if(N(this.node))return this.node.host}},parentNode:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_parentNode}},firstChild:{configurable:!0,
enumerable:!0,get:function(){return this.node.__shady_firstChild}},lastChild:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_lastChild}},nextSibling:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_nextSibling}},previousSibling:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_previousSibling}},childNodes:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_childNodes}},parentElement:{configurable:!0,enumerable:!0,
get:function(){return this.node.__shady_parentElement}},firstElementChild:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_firstElementChild}},lastElementChild:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_lastElementChild}},nextElementSibling:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_nextElementSibling}},previousElementSibling:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_previousElementSibling}},
children:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_children}},childElementCount:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_childElementCount}},shadowRoot:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_shadowRoot}},assignedSlot:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_assignedSlot}},isConnected:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_isConnected}},innerHTML:{configurable:!0,
enumerable:!0,get:function(){return this.node.__shady_innerHTML},set:function(a){this.node.__shady_innerHTML=a}},textContent:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_textContent},set:function(a){this.node.__shady_textContent=a}},slot:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_slot},set:function(a){this.node.__shady_slot=a}},className:{configurable:!0,enumerable:!0,get:function(){return this.node.__shady_className},set:function(a){return this.node.__shady_className=
a}}});function we(a){Object.defineProperty(ve.prototype,a,{get:function(){return this.node["__shady_"+a]},set:function(b){this.node["__shady_"+a]=b},configurable:!0})}Wc.forEach(function(a){return we(a)});Xc.forEach(function(a){return we(a)});var xe=new WeakMap;function ye(a){if(N(a)||a instanceof ve)return a;var b=xe.get(a);b||(b=new ve(a),xe.set(a,b));return b};if(L.sa){var ze=L.B?function(a){return a}:function(a){vc(a);uc(a);return a},ShadyDOM={inUse:L.sa,patch:ze,isShadyRoot:N,enqueue:Ob,flush:Pb,flushInitial:function(a){!a.Aa&&a.T&&yd(a)},settings:L,filterMutations:Ub,observeChildren:Sb,unobserveChildren:Tb,deferConnectionCallbacks:L.deferConnectionCallbacks,preferPerformance:L.preferPerformance,handlesDynamicScoping:!0,wrap:L.D?ye:ze,wrapIfNeeded:!0===L.D?ye:function(a){return a},Wrapper:ve,composedPath:Ec,noPatch:L.D,patchOnDemand:L.ua,nativeMethods:ec,
nativeTree:fc,patchElementProto:ee};window.ShadyDOM=ShadyDOM;oc();de("__shady_");Object.defineProperty(document,"_activeElement",Wd.activeElement);O(Window.prototype,Zd,"__shady_");L.D?L.ua&&O(Element.prototype,Qd):(de(),Vc());Qc();window.Event=Sc;window.CustomEvent=Tc;window.MouseEvent=Uc;window.ShadowRoot=Od};/*

 Copyright (c) 2020 The Polymer Project Authors. All rights reserved.
 This code may only be used under the BSD style license found at
 http://polymer.github.io/LICENSE.txt The complete set of authors may be found
 at http://polymer.github.io/AUTHORS.txt The complete set of contributors may
 be found at http://polymer.github.io/CONTRIBUTORS.txt Code distributed by
 Google as part of the polymer project is also subject to an additional IP
 rights grant found at http://polymer.github.io/PATENTS.txt
*/
var Ae=window.Document.prototype.createElement,Be=window.Document.prototype.createElementNS,Ce=window.Document.prototype.importNode,De=window.Document.prototype.prepend,Ee=window.Document.prototype.append,Fe=window.DocumentFragment.prototype.prepend,Ge=window.DocumentFragment.prototype.append,He=window.Node.prototype.cloneNode,Ie=window.Node.prototype.appendChild,Je=window.Node.prototype.insertBefore,Ke=window.Node.prototype.removeChild,Le=window.Node.prototype.replaceChild,Me=Object.getOwnPropertyDescriptor(window.Node.prototype,
"textContent"),Ne=window.Element.prototype.attachShadow,Oe=Object.getOwnPropertyDescriptor(window.Element.prototype,"innerHTML"),Pe=window.Element.prototype.getAttribute,Qe=window.Element.prototype.setAttribute,Re=window.Element.prototype.removeAttribute,Se=window.Element.prototype.getAttributeNS,Te=window.Element.prototype.setAttributeNS,Ue=window.Element.prototype.removeAttributeNS,Ve=window.Element.prototype.insertAdjacentElement,We=window.Element.prototype.insertAdjacentHTML,Xe=window.Element.prototype.prepend,
Ye=window.Element.prototype.append,Ze=window.Element.prototype.before,$e=window.Element.prototype.after,af=window.Element.prototype.replaceWith,bf=window.Element.prototype.remove,cf=window.HTMLElement,df=Object.getOwnPropertyDescriptor(window.HTMLElement.prototype,"innerHTML"),ef=window.HTMLElement.prototype.insertAdjacentElement,ff=window.HTMLElement.prototype.insertAdjacentHTML;var gf=new Set;"annotation-xml color-profile font-face font-face-src font-face-uri font-face-format font-face-name missing-glyph".split(" ").forEach(function(a){return gf.add(a)});function hf(a){var b=gf.has(a);a=/^[a-z][.0-9_a-z]*-[-.0-9_a-z]*$/.test(a);return!b&&a}var jf=document.contains?document.contains.bind(document):document.documentElement.contains.bind(document.documentElement);
function S(a){var b=a.isConnected;if(void 0!==b)return b;if(jf(a))return!0;for(;a&&!(a.__CE_isImportDocument||a instanceof Document);)a=a.parentNode||(window.ShadowRoot&&a instanceof ShadowRoot?a.host:void 0);return!(!a||!(a.__CE_isImportDocument||a instanceof Document))}function kf(a){var b=a.children;if(b)return Array.prototype.slice.call(b);b=[];for(a=a.firstChild;a;a=a.nextSibling)a.nodeType===Node.ELEMENT_NODE&&b.push(a);return b}
function lf(a,b){for(;b&&b!==a&&!b.nextSibling;)b=b.parentNode;return b&&b!==a?b.nextSibling:null}
function mf(a,b,c){for(var d=a;d;){if(d.nodeType===Node.ELEMENT_NODE){var e=d;b(e);var f=e.localName;if("link"===f&&"import"===e.getAttribute("rel")){d=e.import;void 0===c&&(c=new Set);if(d instanceof Node&&!c.has(d))for(c.add(d),d=d.firstChild;d;d=d.nextSibling)mf(d,b,c);d=lf(a,e);continue}else if("template"===f){d=lf(a,e);continue}if(e=e.__CE_shadowRoot)for(e=e.firstChild;e;e=e.nextSibling)mf(e,b,c)}d=d.firstChild?d.firstChild:lf(a,d)}};function nf(){var a=!(null===of||void 0===of||!of.noDocumentConstructionObserver),b=!(null===of||void 0===of||!of.shadyDomFastWalk);this.X=[];this.a=[];this.R=!1;this.shadyDomFastWalk=b;this.jb=!a}function pf(a,b,c,d){var e=window.ShadyDom;if(a.shadyDomFastWalk&&e&&e.inUse){if(b.nodeType===Node.ELEMENT_NODE&&c(b),b.querySelectorAll)for(a=e.nativeMethods.querySelectorAll.call(b,"*"),b=0;b<a.length;b++)c(a[b])}else mf(b,c,d)}function qf(a,b){a.R=!0;a.X.push(b)}function rf(a,b){a.R=!0;a.a.push(b)}
function sf(a,b){a.R&&pf(a,b,function(c){return tf(a,c)})}function tf(a,b){if(a.R&&!b.__CE_patched){b.__CE_patched=!0;for(var c=0;c<a.X.length;c++)a.X[c](b);for(c=0;c<a.a.length;c++)a.a[c](b)}}function uf(a,b){var c=[];pf(a,b,function(e){return c.push(e)});for(b=0;b<c.length;b++){var d=c[b];1===d.__CE_state?a.connectedCallback(d):vf(a,d)}}function wf(a,b){var c=[];pf(a,b,function(e){return c.push(e)});for(b=0;b<c.length;b++){var d=c[b];1===d.__CE_state&&a.disconnectedCallback(d)}}
function xf(a,b,c){c=void 0===c?{}:c;var d=c.kb,e=c.upgrade||function(g){return vf(a,g)},f=[];pf(a,b,function(g){a.R&&tf(a,g);if("link"===g.localName&&"import"===g.getAttribute("rel")){var h=g.import;h instanceof Node&&(h.__CE_isImportDocument=!0,h.__CE_registry=document.__CE_registry);h&&"complete"===h.readyState?h.__CE_documentLoadHandled=!0:g.addEventListener("load",function(){var k=g.import;if(!k.__CE_documentLoadHandled){k.__CE_documentLoadHandled=!0;var l=new Set;d&&(d.forEach(function(m){return l.add(m)}),
l.delete(k));xf(a,k,{kb:l,upgrade:e})}})}else f.push(g)},d);for(b=0;b<f.length;b++)e(f[b])}
function vf(a,b){try{var c=b.ownerDocument,d=c.__CE_registry;var e=d&&(c.defaultView||c.__CE_isImportDocument)?yf(d,b.localName):void 0;if(e&&void 0===b.__CE_state){e.constructionStack.push(b);try{try{if(new e.constructorFunction!==b)throw Error("The custom element constructor did not produce the element being upgraded.");}finally{e.constructionStack.pop()}}catch(k){throw b.__CE_state=2,k;}b.__CE_state=1;b.__CE_definition=e;if(e.attributeChangedCallback&&b.hasAttributes()){var f=e.observedAttributes;
for(e=0;e<f.length;e++){var g=f[e],h=b.getAttribute(g);null!==h&&a.attributeChangedCallback(b,g,null,h,null)}}S(b)&&a.connectedCallback(b)}}catch(k){zf(k)}}nf.prototype.connectedCallback=function(a){var b=a.__CE_definition;if(b.connectedCallback)try{b.connectedCallback.call(a)}catch(c){zf(c)}};nf.prototype.disconnectedCallback=function(a){var b=a.__CE_definition;if(b.disconnectedCallback)try{b.disconnectedCallback.call(a)}catch(c){zf(c)}};
nf.prototype.attributeChangedCallback=function(a,b,c,d,e){var f=a.__CE_definition;if(f.attributeChangedCallback&&-1<f.observedAttributes.indexOf(b))try{f.attributeChangedCallback.call(a,b,c,d,e)}catch(g){zf(g)}};
function Af(a,b,c,d){var e=b.__CE_registry;if(e&&(null===d||"http://www.w3.org/1999/xhtml"===d)&&(e=yf(e,c)))try{var f=new e.constructorFunction;if(void 0===f.__CE_state||void 0===f.__CE_definition)throw Error("Failed to construct '"+c+"': The returned value was not constructed with the HTMLElement constructor.");if("http://www.w3.org/1999/xhtml"!==f.namespaceURI)throw Error("Failed to construct '"+c+"': The constructed element's namespace must be the HTML namespace.");if(f.hasAttributes())throw Error("Failed to construct '"+
c+"': The constructed element must not have any attributes.");if(null!==f.firstChild)throw Error("Failed to construct '"+c+"': The constructed element must not have any children.");if(null!==f.parentNode)throw Error("Failed to construct '"+c+"': The constructed element must not have a parent node.");if(f.ownerDocument!==b)throw Error("Failed to construct '"+c+"': The constructed element's owner document is incorrect.");if(f.localName!==c)throw Error("Failed to construct '"+c+"': The constructed element's local name is incorrect.");
return f}catch(g){return zf(g),b=null===d?Ae.call(b,c):Be.call(b,d,c),Object.setPrototypeOf(b,HTMLUnknownElement.prototype),b.__CE_state=2,b.__CE_definition=void 0,tf(a,b),b}b=null===d?Ae.call(b,c):Be.call(b,d,c);tf(a,b);return b}
function zf(a){var b=a.message,c=a.sourceURL||a.fileName||"",d=a.line||a.lineNumber||0,e=a.column||a.columnNumber||0,f=void 0;void 0===ErrorEvent.prototype.initErrorEvent?f=new ErrorEvent("error",{cancelable:!0,message:b,filename:c,lineno:d,colno:e,error:a}):(f=document.createEvent("ErrorEvent"),f.initErrorEvent("error",!1,!0,b,c,d),f.preventDefault=function(){Object.defineProperty(this,"defaultPrevented",{configurable:!0,get:function(){return!0}})});void 0===f.error&&Object.defineProperty(f,"error",
{configurable:!0,enumerable:!0,get:function(){return a}});window.dispatchEvent(f);f.defaultPrevented||console.error(a)};function Bf(){var a=this;this.C=void 0;this.Ca=new Promise(function(b){a.a=b})}Bf.prototype.resolve=function(a){if(this.C)throw Error("Already resolved.");this.C=a;this.a(a)};function Cf(a){var b=document;this.S=void 0;this.M=a;this.a=b;xf(this.M,this.a);"loading"===this.a.readyState&&(this.S=new MutationObserver(this.b.bind(this)),this.S.observe(this.a,{childList:!0,subtree:!0}))}function Df(a){a.S&&a.S.disconnect()}Cf.prototype.b=function(a){var b=this.a.readyState;"interactive"!==b&&"complete"!==b||Df(this);for(b=0;b<a.length;b++)for(var c=a[b].addedNodes,d=0;d<c.length;d++)xf(this.M,c[d])};function T(a){this.fa=new Map;this.ga=new Map;this.xa=new Map;this.na=!1;this.qa=new Map;this.ea=function(b){return b()};this.P=!1;this.ha=[];this.M=a;this.ya=a.jb?new Cf(a):void 0}w=T.prototype;w.$a=function(a,b){var c=this;if(!(b instanceof Function))throw new TypeError("Custom element constructor getters must be functions.");Ef(this,a);this.fa.set(a,b);this.ha.push(a);this.P||(this.P=!0,this.ea(function(){return Ff(c)}))};
w.define=function(a,b){var c=this;if(!(b instanceof Function))throw new TypeError("Custom element constructors must be functions.");Ef(this,a);Gf(this,a,b);this.ha.push(a);this.P||(this.P=!0,this.ea(function(){return Ff(c)}))};function Ef(a,b){if(!hf(b))throw new SyntaxError("The element name '"+b+"' is not valid.");if(yf(a,b))throw Error("A custom element with name '"+(b+"' has already been defined."));if(a.na)throw Error("A custom element is already being defined.");}
function Gf(a,b,c){a.na=!0;var d;try{var e=c.prototype;if(!(e instanceof Object))throw new TypeError("The custom element constructor's prototype is not an object.");var f=function(m){var q=e[m];if(void 0!==q&&!(q instanceof Function))throw Error("The '"+m+"' callback must be a function.");return q};var g=f("connectedCallback");var h=f("disconnectedCallback");var k=f("adoptedCallback");var l=(d=f("attributeChangedCallback"))&&c.observedAttributes||[]}catch(m){throw m;}finally{a.na=!1}c={localName:b,
constructorFunction:c,connectedCallback:g,disconnectedCallback:h,adoptedCallback:k,attributeChangedCallback:d,observedAttributes:l,constructionStack:[]};a.ga.set(b,c);a.xa.set(c.constructorFunction,c);return c}w.upgrade=function(a){xf(this.M,a)};
function Ff(a){if(!1!==a.P){a.P=!1;for(var b=[],c=a.ha,d=new Map,e=0;e<c.length;e++)d.set(c[e],[]);xf(a.M,document,{upgrade:function(k){if(void 0===k.__CE_state){var l=k.localName,m=d.get(l);m?m.push(k):a.ga.has(l)&&b.push(k)}}});for(e=0;e<b.length;e++)vf(a.M,b[e]);for(e=0;e<c.length;e++){for(var f=c[e],g=d.get(f),h=0;h<g.length;h++)vf(a.M,g[h]);(f=a.qa.get(f))&&f.resolve(void 0)}c.length=0}}w.get=function(a){if(a=yf(this,a))return a.constructorFunction};
w.whenDefined=function(a){if(!hf(a))return Promise.reject(new SyntaxError("'"+a+"' is not a valid custom element name."));var b=this.qa.get(a);if(b)return b.Ca;b=new Bf;this.qa.set(a,b);var c=this.ga.has(a)||this.fa.has(a);a=-1===this.ha.indexOf(a);c&&a&&b.resolve(void 0);return b.Ca};w.polyfillWrapFlushCallback=function(a){this.ya&&Df(this.ya);var b=this.ea;this.ea=function(c){return a(function(){return b(c)})}};
function yf(a,b){var c=a.ga.get(b);if(c)return c;if(c=a.fa.get(b)){a.fa.delete(b);try{return Gf(a,b,c())}catch(d){zf(d)}}}window.CustomElementRegistry=T;T.prototype.define=T.prototype.define;T.prototype.upgrade=T.prototype.upgrade;T.prototype.get=T.prototype.get;T.prototype.whenDefined=T.prototype.whenDefined;T.prototype.polyfillDefineLazy=T.prototype.$a;T.prototype.polyfillWrapFlushCallback=T.prototype.polyfillWrapFlushCallback;function Hf(a,b,c){function d(e){return function(f){for(var g=[],h=0;h<arguments.length;++h)g[h]=arguments[h];h=[];for(var k=[],l=0;l<g.length;l++){var m=g[l];m instanceof Element&&S(m)&&k.push(m);if(m instanceof DocumentFragment)for(m=m.firstChild;m;m=m.nextSibling)h.push(m);else h.push(m)}e.apply(this,g);for(g=0;g<k.length;g++)wf(a,k[g]);if(S(this))for(g=0;g<h.length;g++)k=h[g],k instanceof Element&&uf(a,k)}}void 0!==c.prepend&&(b.prepend=d(c.prepend));void 0!==c.append&&(b.append=d(c.append))}
;function If(a){Document.prototype.createElement=function(b){return Af(a,this,b,null)};Document.prototype.importNode=function(b,c){b=Ce.call(this,b,!!c);this.__CE_registry?xf(a,b):sf(a,b);return b};Document.prototype.createElementNS=function(b,c){return Af(a,this,c,b)};Hf(a,Document.prototype,{prepend:De,append:Ee})};function Jf(a){function b(d){return function(e){for(var f=[],g=0;g<arguments.length;++g)f[g]=arguments[g];g=[];for(var h=[],k=0;k<f.length;k++){var l=f[k];l instanceof Element&&S(l)&&h.push(l);if(l instanceof DocumentFragment)for(l=l.firstChild;l;l=l.nextSibling)g.push(l);else g.push(l)}d.apply(this,f);for(f=0;f<h.length;f++)wf(a,h[f]);if(S(this))for(f=0;f<g.length;f++)h=g[f],h instanceof Element&&uf(a,h)}}var c=Element.prototype;void 0!==Ze&&(c.before=b(Ze));void 0!==$e&&(c.after=b($e));void 0!==
af&&(c.replaceWith=function(d){for(var e=[],f=0;f<arguments.length;++f)e[f]=arguments[f];f=[];for(var g=[],h=0;h<e.length;h++){var k=e[h];k instanceof Element&&S(k)&&g.push(k);if(k instanceof DocumentFragment)for(k=k.firstChild;k;k=k.nextSibling)f.push(k);else f.push(k)}h=S(this);af.apply(this,e);for(e=0;e<g.length;e++)wf(a,g[e]);if(h)for(wf(a,this),e=0;e<f.length;e++)g=f[e],g instanceof Element&&uf(a,g)});void 0!==bf&&(c.remove=function(){var d=S(this);bf.call(this);d&&wf(a,this)})};function Kf(a){function b(e,f){Object.defineProperty(e,"innerHTML",{enumerable:f.enumerable,configurable:!0,get:f.get,set:function(g){var h=this,k=void 0;S(this)&&(k=[],pf(a,this,function(q){q!==h&&k.push(q)}));f.set.call(this,g);if(k)for(var l=0;l<k.length;l++){var m=k[l];1===m.__CE_state&&a.disconnectedCallback(m)}this.ownerDocument.__CE_registry?xf(a,this):sf(a,this);return g}})}function c(e,f){e.insertAdjacentElement=function(g,h){var k=S(h);g=f.call(this,g,h);k&&wf(a,h);S(g)&&uf(a,h);return g}}
function d(e,f){function g(h,k){for(var l=[];h!==k;h=h.nextSibling)l.push(h);for(k=0;k<l.length;k++)xf(a,l[k])}e.insertAdjacentHTML=function(h,k){h=h.toLowerCase();if("beforebegin"===h){var l=this.previousSibling;f.call(this,h,k);g(l||this.parentNode.firstChild,this)}else if("afterbegin"===h)l=this.firstChild,f.call(this,h,k),g(this.firstChild,l);else if("beforeend"===h)l=this.lastChild,f.call(this,h,k),g(l||this.firstChild,null);else if("afterend"===h)l=this.nextSibling,f.call(this,h,k),g(this.nextSibling,
l);else throw new SyntaxError("The value provided ("+String(h)+") is not one of 'beforebegin', 'afterbegin', 'beforeend', or 'afterend'.");}}Ne&&(Element.prototype.attachShadow=function(e){e=Ne.call(this,e);if(a.R&&!e.__CE_patched){e.__CE_patched=!0;for(var f=0;f<a.X.length;f++)a.X[f](e)}return this.__CE_shadowRoot=e});Oe&&Oe.get?b(Element.prototype,Oe):df&&df.get?b(HTMLElement.prototype,df):rf(a,function(e){b(e,{enumerable:!0,configurable:!0,get:function(){return He.call(this,!0).innerHTML},set:function(f){var g=
"template"===this.localName,h=g?this.content:this,k=Be.call(document,this.namespaceURI,this.localName);for(k.innerHTML=f;0<h.childNodes.length;)Ke.call(h,h.childNodes[0]);for(f=g?k.content:k;0<f.childNodes.length;)Ie.call(h,f.childNodes[0])}})});Element.prototype.setAttribute=function(e,f){if(1!==this.__CE_state)return Qe.call(this,e,f);var g=Pe.call(this,e);Qe.call(this,e,f);f=Pe.call(this,e);a.attributeChangedCallback(this,e,g,f,null)};Element.prototype.setAttributeNS=function(e,f,g){if(1!==this.__CE_state)return Te.call(this,
e,f,g);var h=Se.call(this,e,f);Te.call(this,e,f,g);g=Se.call(this,e,f);a.attributeChangedCallback(this,f,h,g,e)};Element.prototype.removeAttribute=function(e){if(1!==this.__CE_state)return Re.call(this,e);var f=Pe.call(this,e);Re.call(this,e);null!==f&&a.attributeChangedCallback(this,e,f,null,null)};Element.prototype.removeAttributeNS=function(e,f){if(1!==this.__CE_state)return Ue.call(this,e,f);var g=Se.call(this,e,f);Ue.call(this,e,f);var h=Se.call(this,e,f);g!==h&&a.attributeChangedCallback(this,
f,g,h,e)};ef?c(HTMLElement.prototype,ef):Ve&&c(Element.prototype,Ve);ff?d(HTMLElement.prototype,ff):We&&d(Element.prototype,We);Hf(a,Element.prototype,{prepend:Xe,append:Ye});Jf(a)};var Lf={};function Mf(a){function b(){var c=this.constructor;var d=document.__CE_registry.xa.get(c);if(!d)throw Error("Failed to construct a custom element: The constructor was not registered with `customElements`.");var e=d.constructionStack;if(0===e.length)return e=Ae.call(document,d.localName),Object.setPrototypeOf(e,c.prototype),e.__CE_state=1,e.__CE_definition=d,tf(a,e),e;var f=e.length-1,g=e[f];if(g===Lf)throw Error("Failed to construct '"+d.localName+"': This element was already constructed.");e[f]=
Lf;Object.setPrototypeOf(g,c.prototype);tf(a,g);return g}b.prototype=cf.prototype;Object.defineProperty(HTMLElement.prototype,"constructor",{writable:!0,configurable:!0,enumerable:!1,value:b});window.HTMLElement=b};function Nf(a){function b(c,d){Object.defineProperty(c,"textContent",{enumerable:d.enumerable,configurable:!0,get:d.get,set:function(e){if(this.nodeType===Node.TEXT_NODE)d.set.call(this,e);else{var f=void 0;if(this.firstChild){var g=this.childNodes,h=g.length;if(0<h&&S(this)){f=Array(h);for(var k=0;k<h;k++)f[k]=g[k]}}d.set.call(this,e);if(f)for(e=0;e<f.length;e++)wf(a,f[e])}}})}Node.prototype.insertBefore=function(c,d){if(c instanceof DocumentFragment){var e=kf(c);c=Je.call(this,c,d);if(S(this))for(d=
0;d<e.length;d++)uf(a,e[d]);return c}e=c instanceof Element&&S(c);d=Je.call(this,c,d);e&&wf(a,c);S(this)&&uf(a,c);return d};Node.prototype.appendChild=function(c){if(c instanceof DocumentFragment){var d=kf(c);c=Ie.call(this,c);if(S(this))for(var e=0;e<d.length;e++)uf(a,d[e]);return c}d=c instanceof Element&&S(c);e=Ie.call(this,c);d&&wf(a,c);S(this)&&uf(a,c);return e};Node.prototype.cloneNode=function(c){c=He.call(this,!!c);this.ownerDocument.__CE_registry?xf(a,c):sf(a,c);return c};Node.prototype.removeChild=
function(c){var d=c instanceof Element&&S(c),e=Ke.call(this,c);d&&wf(a,c);return e};Node.prototype.replaceChild=function(c,d){if(c instanceof DocumentFragment){var e=kf(c);c=Le.call(this,c,d);if(S(this))for(wf(a,d),d=0;d<e.length;d++)uf(a,e[d]);return c}e=c instanceof Element&&S(c);var f=Le.call(this,c,d),g=S(this);g&&wf(a,d);e&&wf(a,c);g&&uf(a,c);return f};Me&&Me.get?b(Node.prototype,Me):qf(a,function(c){b(c,{enumerable:!0,configurable:!0,get:function(){for(var d=[],e=this.firstChild;e;e=e.nextSibling)e.nodeType!==
Node.COMMENT_NODE&&d.push(e.textContent);return d.join("")},set:function(d){for(;this.firstChild;)Ke.call(this,this.firstChild);null!=d&&""!==d&&Ie.call(this,document.createTextNode(d))}})})};var of=window.customElements;function Of(){var a=new nf;Mf(a);If(a);Hf(a,DocumentFragment.prototype,{prepend:Fe,append:Ge});Nf(a);Kf(a);a=new T(a);document.__CE_registry=a;Object.defineProperty(window,"customElements",{configurable:!0,enumerable:!0,value:a})}of&&!of.forcePolyfill&&"function"==typeof of.define&&"function"==typeof of.get||Of();window.__CE_installPolyfill=Of;/*

Copyright (c) 2017 The Polymer Project Authors. All rights reserved.
This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
Code distributed by Google as part of the polymer project is also
subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
*/
function Pf(){this.end=this.start=0;this.rules=this.parent=this.previous=null;this.cssText=this.parsedCssText="";this.atRule=!1;this.type=0;this.parsedSelector=this.selector=this.keyframesName=""}
function Qf(a){var b=a=a.replace(Rf,"").replace(Sf,""),c=new Pf;c.start=0;c.end=b.length;for(var d=c,e=0,f=b.length;e<f;e++)if("{"===b[e]){d.rules||(d.rules=[]);var g=d,h=g.rules[g.rules.length-1]||null;d=new Pf;d.start=e+1;d.parent=g;d.previous=h;g.rules.push(d)}else"}"===b[e]&&(d.end=e+1,d=d.parent||c);return Tf(c,a)}
function Tf(a,b){var c=b.substring(a.start,a.end-1);a.parsedCssText=a.cssText=c.trim();a.parent&&(c=b.substring(a.previous?a.previous.end:a.parent.start,a.start-1),c=Uf(c),c=c.replace(Vf," "),c=c.substring(c.lastIndexOf(";")+1),c=a.parsedSelector=a.selector=c.trim(),a.atRule=0===c.indexOf("@"),a.atRule?0===c.indexOf("@media")?a.type=Wf:c.match(Xf)&&(a.type=Yf,a.keyframesName=a.selector.split(Vf).pop()):a.type=0===c.indexOf("--")?Zf:$f);if(c=a.rules)for(var d=0,e=c.length,f=void 0;d<e&&(f=c[d]);d++)Tf(f,
b);return a}function Uf(a){return a.replace(/\\([0-9a-f]{1,6})\s/gi,function(b,c){b=c;for(c=6-b.length;c--;)b="0"+b;return"\\"+b})}
function ag(a,b,c){c=void 0===c?"":c;var d="";if(a.cssText||a.rules){var e=a.rules,f;if(f=e)f=e[0],f=!(f&&f.selector&&0===f.selector.indexOf("--"));if(f){f=0;for(var g=e.length,h=void 0;f<g&&(h=e[f]);f++)d=ag(h,b,d)}else b?b=a.cssText:(b=a.cssText,b=b.replace(bg,"").replace(cg,""),b=b.replace(dg,"").replace(eg,"")),(d=b.trim())&&(d="  "+d+"\n")}d&&(a.selector&&(c+=a.selector+" {\n"),c+=d,a.selector&&(c+="}\n\n"));return c}
var $f=1,Yf=7,Wf=4,Zf=1E3,Rf=/\/\*[^*]*\*+([^/*][^*]*\*+)*\//gim,Sf=/@import[^;]*;/gim,bg=/(?:^[^;\-\s}]+)?--[^;{}]*?:[^{};]*?(?:[;\n]|$)/gim,cg=/(?:^[^;\-\s}]+)?--[^;{}]*?:[^{};]*?{[^}]*?}(?:[;\n]|$)?/gim,dg=/@apply\s*\(?[^);]*\)?\s*(?:[;\n]|$)?/gim,eg=/[^;:]*?:[^;]*?var\([^;]*\)(?:[;\n]|$)?/gim,Xf=/^@[^\s]*keyframes/,Vf=/\s+/g;var U=!(window.ShadyDOM&&window.ShadyDOM.inUse),fg;function gg(a){fg=a&&a.shimcssproperties?!1:U||!(navigator.userAgent.match(/AppleWebKit\/601|Edge\/15/)||!window.CSS||!CSS.supports||!CSS.supports("box-shadow","0 0 0 var(--foo)"))}var hg;window.ShadyCSS&&void 0!==window.ShadyCSS.cssBuild&&(hg=window.ShadyCSS.cssBuild);var ig=!(!window.ShadyCSS||!window.ShadyCSS.disableRuntime);
window.ShadyCSS&&void 0!==window.ShadyCSS.nativeCss?fg=window.ShadyCSS.nativeCss:window.ShadyCSS?(gg(window.ShadyCSS),window.ShadyCSS=void 0):gg(window.WebComponents&&window.WebComponents.flags);var V=fg;var jg=/(?:^|[;\s{]\s*)(--[\w-]*?)\s*:\s*(?:((?:'(?:\\'|.)*?'|"(?:\\"|.)*?"|\([^)]*?\)|[^};{])+)|\{([^}]*)\}(?:(?=[;\s}])|$))/gi,kg=/(?:^|\W+)@apply\s*\(?([^);\n]*)\)?/gi,lg=/(--[\w-]+)\s*([:,;)]|$)/gi,mg=/(animation\s*:)|(animation-name\s*:)/,ng=/@media\s(.*)/,og=/\{[^}]*\}/g;var pg=new Set;function qg(a,b){if(!a)return"";"string"===typeof a&&(a=Qf(a));b&&sg(a,b);return ag(a,V)}function tg(a){!a.__cssRules&&a.textContent&&(a.__cssRules=Qf(a.textContent));return a.__cssRules||null}function ug(a){return!!a.parent&&a.parent.type===Yf}function sg(a,b,c,d){if(a){var e=!1,f=a.type;if(d&&f===Wf){var g=a.selector.match(ng);g&&(window.matchMedia(g[1]).matches||(e=!0))}f===$f?b(a):c&&f===Yf?c(a):f===Zf&&(e=!0);if((a=a.rules)&&!e)for(e=0,f=a.length,g=void 0;e<f&&(g=a[e]);e++)sg(g,b,c,d)}}
function vg(a,b,c,d){var e=document.createElement("style");b&&e.setAttribute("scope",b);e.textContent=a;wg(e,c,d);return e}var xg=null;function yg(a){a=document.createComment(" Shady DOM styles for "+a+" ");var b=document.head;b.insertBefore(a,(xg?xg.nextSibling:null)||b.firstChild);return xg=a}function wg(a,b,c){b=b||document.head;b.insertBefore(a,c&&c.nextSibling||b.firstChild);xg?a.compareDocumentPosition(xg)===Node.DOCUMENT_POSITION_PRECEDING&&(xg=a):xg=a}
function zg(a,b){for(var c=0,d=a.length;b<d;b++)if("("===a[b])c++;else if(")"===a[b]&&0===--c)return b;return-1}function Ag(a,b){var c=a.indexOf("var(");if(-1===c)return b(a,"","","");var d=zg(a,c+3),e=a.substring(c+4,d);c=a.substring(0,c);a=Ag(a.substring(d+1),b);d=e.indexOf(",");return-1===d?b(c,e.trim(),"",a):b(c,e.substring(0,d).trim(),e.substring(d+1).trim(),a)}function Bg(a,b){U?a.setAttribute("class",b):window.ShadyDOM.nativeMethods.setAttribute.call(a,"class",b)}
var Cg=window.ShadyDOM&&window.ShadyDOM.wrap||function(a){return a};function Dg(a){var b=a.localName,c="";b?-1<b.indexOf("-")||(c=b,b=a.getAttribute&&a.getAttribute("is")||""):(b=a.is,c=a.extends);return{is:b,ca:c}}function Eg(a){for(var b=[],c="",d=0;0<=d&&d<a.length;d++)if("("===a[d]){var e=zg(a,d);c+=a.slice(d,e+1);d=e}else","===a[d]?(b.push(c),c=""):c+=a[d];c&&b.push(c);return b}
function Fg(a){if(void 0!==hg)return hg;if(void 0===a.__cssBuild){var b=a.getAttribute("css-build");if(b)a.__cssBuild=b;else{a:{b="template"===a.localName?a.content.firstChild:a.firstChild;if(b instanceof Comment&&(b=b.textContent.trim().split(":"),"css-build"===b[0])){b=b[1];break a}b=""}if(""!==b){var c="template"===a.localName?a.content.firstChild:a.firstChild;c.parentNode.removeChild(c)}a.__cssBuild=b}}return a.__cssBuild||""}
function Gg(a){a=void 0===a?"":a;return""!==a&&V?U?"shadow"===a:"shady"===a:!1};function Hg(){}function Ig(a,b){Jg(Kg,a,function(c){Lg(c,b||"")})}function Jg(a,b,c){b.nodeType===Node.ELEMENT_NODE&&c(b);var d;"template"===b.localName?d=(b.content||b._content||b).childNodes:d=b.children||b.childNodes;if(d)for(b=0;b<d.length;b++)Jg(a,d[b],c)}
function Lg(a,b,c){if(b)if(a.classList)c?(a.classList.remove("style-scope"),a.classList.remove(b)):(a.classList.add("style-scope"),a.classList.add(b));else if(a.getAttribute){var d=a.getAttribute("class");c?d&&(b=d.replace("style-scope","").replace(b,""),Bg(a,b)):Bg(a,(d?d+" ":"")+"style-scope "+b)}}function Mg(a,b,c){Jg(Kg,a,function(d){Lg(d,b,!0);Lg(d,c)})}function Ng(a,b){Jg(Kg,a,function(c){Lg(c,b||"",!0)})}
function Og(a,b,c,d,e){var f=Kg;e=void 0===e?"":e;""===e&&(U||"shady"===(void 0===d?"":d)?e=qg(b,c):(a=Dg(a),e=Pg(f,b,a.is,a.ca,c)+"\n\n"));return e.trim()}function Pg(a,b,c,d,e){var f=Qg(c,d);c=c?"."+c:"";return qg(b,function(g){g.c||(g.selector=g.w=Rg(a,g,a.b,c,f),g.c=!0);e&&e(g,c,f)})}function Qg(a,b){return b?"[is="+a+"]":a}
function Rg(a,b,c,d,e){var f=Eg(b.selector);if(!ug(b)){b=0;for(var g=f.length,h=void 0;b<g&&(h=f[b]);b++)f[b]=c.call(a,h,d,e)}return f.filter(function(k){return!!k}).join(",")}function Sg(a){return a.replace(Tg,function(b,c,d){-1<d.indexOf("+")?d=d.replace(/\+/g,"___"):-1<d.indexOf("___")&&(d=d.replace(/___/g,"+"));return":"+c+"("+d+")"})}
function Ug(a){for(var b=[],c;c=a.match(Vg);){var d=c.index,e=zg(a,d);if(-1===e)throw Error(c.input+" selector missing ')'");c=a.slice(d,e+1);a=a.replace(c,"\ue000");b.push(c)}return{wa:a,matches:b}}function Wg(a,b){var c=a.split("\ue000");return b.reduce(function(d,e,f){return d+e+c[f+1]},c[0])}
Hg.prototype.b=function(a,b,c){var d=!1;a=a.trim();var e=Tg.test(a);e&&(a=a.replace(Tg,function(h,k,l){return":"+k+"("+l.replace(/\s/g,"")+")"}),a=Sg(a));var f=Vg.test(a);if(f){var g=Ug(a);a=g.wa;g=g.matches}a=a.replace(Xg,":host $1");a=a.replace(Yg,function(h,k,l){d||(h=Zg(l,k,b,c),d=d||h.stop,k=h.Qa,l=h.value);return k+l});f&&(a=Wg(a,g));e&&(a=Sg(a));return a=a.replace($g,function(h,k,l,m){return'[dir="'+l+'"] '+k+m+", "+k+'[dir="'+l+'"]'+m})};
function Zg(a,b,c,d){var e=a.indexOf("::slotted");0<=a.indexOf(":host")?a=ah(a,d):0!==e&&(a=c?bh(a,c):a);c=!1;0<=e&&(b="",c=!0);if(c){var f=!0;c&&(a=a.replace(ch,function(g,h){return" > "+h}))}return{value:a,Qa:b,stop:f}}function bh(a,b){a=a.split(/(\[.+?\])/);for(var c=[],d=0;d<a.length;d++)if(1===d%2)c.push(a[d]);else{var e=a[d];if(""!==e||d!==a.length-1)e=e.split(":"),e[0]+=b,c.push(e.join(":"))}return c.join("")}
function ah(a,b){var c=a.match(dh);return(c=c&&c[2].trim()||"")?c[0].match(eh)?a.replace(dh,function(d,e,f){return b+f}):c.split(eh)[0]===b?c:"should_not_match":a.replace(":host",b)}function fh(a){":root"===a.selector&&(a.selector="html")}Hg.prototype.c=function(a){return a.match(":host")?"":a.match("::slotted")?this.b(a,":not(.style-scope)"):bh(a.trim(),":not(.style-scope)")};ca.Object.defineProperties(Hg.prototype,{a:{configurable:!0,enumerable:!0,get:function(){return"style-scope"}}});
var Tg=/:(nth[-\w]+)\(([^)]+)\)/,Yg=/(^|[\s>+~]+)((?:\[.+?\]|[^\s>+~=[])+)/g,eh=/[[.:#*]/,Xg=/^(::slotted)/,dh=/(:host)(?:\(((?:\([^)(]*\)|[^)(]*)+?)\))/,ch=/(?:::slotted)(?:\(((?:\([^)(]*\)|[^)(]*)+?)\))/,$g=/(.*):dir\((?:(ltr|rtl))\)(.*)/,Vg=/:(?:matches|any|-(?:webkit|moz)-any)/,Kg=new Hg;function gh(a,b,c,d,e){this.H=a||null;this.b=b||null;this.ta=c||[];this.F=null;this.cssBuild=e||"";this.ca=d||"";this.a=this.G=this.L=null}function hh(a){return a?a.__styleInfo:null}function ih(a,b){return a.__styleInfo=b}gh.prototype.c=function(){return this.H};gh.prototype._getStyleRules=gh.prototype.c;function jh(a){var b=this.matches||this.matchesSelector||this.mozMatchesSelector||this.msMatchesSelector||this.oMatchesSelector||this.webkitMatchesSelector;return b&&b.call(this,a)}var kh=/:host\s*>\s*/,lh=navigator.userAgent.match("Trident");function mh(){}function nh(a){var b={},c=[],d=0;sg(a,function(f){oh(f);f.index=d++;f=f.v.cssText;for(var g;g=lg.exec(f);){var h=g[1];":"!==g[2]&&(b[h]=!0)}},function(f){c.push(f)});a.b=c;a=[];for(var e in b)a.push(e);return a}
function oh(a){if(!a.v){var b={},c={};ph(a,c)&&(b.K=c,a.rules=null);b.cssText=a.parsedCssText.replace(og,"").replace(jg,"");a.v=b}}function ph(a,b){var c=a.v;if(c){if(c.K)return Object.assign(b,c.K),!0}else{c=a.parsedCssText;for(var d;a=jg.exec(c);){d=(a[2]||a[3]).trim();if("inherit"!==d||"unset"!==d)b[a[1].trim()]=d;d=!0}return d}}
function qh(a,b,c){b&&(b=0<=b.indexOf(";")?rh(a,b,c):Ag(b,function(d,e,f,g){if(!e)return d+g;(e=qh(a,c[e],c))&&"initial"!==e?"apply-shim-inherit"===e&&(e="inherit"):e=qh(a,c[f]||f,c)||f;return d+(e||"")+g}));return b&&b.trim()||""}
function rh(a,b,c){b=b.split(";");for(var d=0,e,f;d<b.length;d++)if(e=b[d]){kg.lastIndex=0;if(f=kg.exec(e))e=qh(a,c[f[1]],c);else if(f=e.indexOf(":"),-1!==f){var g=e.substring(f);g=g.trim();g=qh(a,g,c)||g;e=e.substring(0,f)+g}b[d]=e&&e.lastIndexOf(";")===e.length-1?e.slice(0,-1):e||""}return b.join(";")}
function sh(a,b){var c={},d=[];sg(a,function(e){e.v||oh(e);var f=e.w||e.parsedSelector;b&&e.v.K&&f&&jh.call(b,f)&&(ph(e,c),e=e.index,f=parseInt(e/32,10),d[f]=(d[f]||0)|1<<e%32)},null,!0);return{K:c,key:d}}
function th(a,b,c,d){b.v||oh(b);if(b.v.K){var e=Dg(a);a=e.is;e=e.ca;e=a?Qg(a,e):"html";var f=b.parsedSelector;var g=!!f.match(kh)||"html"===e&&-1<f.indexOf("html");var h=0===f.indexOf(":host")&&!g;"shady"===c&&(g=f===e+" > *."+e||-1!==f.indexOf("html"),h=!g&&0===f.indexOf(e));if(g||h)c=e,h&&(b.w||(b.w=Rg(Kg,b,Kg.b,a?"."+a:"",e)),c=b.w||e),g&&"html"===e&&(c=b.w||b.J),d({wa:c,Xa:h,mb:g})}}
function uh(a,b,c){var d={},e={};sg(b,function(f){th(a,f,c,function(g){jh.call(a._element||a,g.wa)&&(g.Xa?ph(f,d):ph(f,e))})},null,!0);return{cb:e,Va:d}}
function vh(a,b,c,d){var e=Dg(b),f=Qg(e.is,e.ca),g=new RegExp("(?:^|[^.#[:])"+(b.extends?"\\"+f.slice(0,-1)+"\\]":f)+"($|[.:[\\s>+~])"),h=hh(b);e=h.H;h=h.cssBuild;var k=wh(e,d);return Og(b,e,function(l){var m="";l.v||oh(l);l.v.cssText&&(m=rh(a,l.v.cssText,c));l.cssText=m;if(!U&&!ug(l)&&l.cssText){var q=m=l.cssText;null==l.Da&&(l.Da=mg.test(m));if(l.Da)if(null==l.ka){l.ka=[];for(var H in k)q=k[H],q=q(m),m!==q&&(m=q,l.ka.push(H))}else{for(H=0;H<l.ka.length;++H)q=k[l.ka[H]],m=q(m);q=m}l.cssText=q;l.w=
l.w||l.selector;m="."+d;H=Eg(l.w);q=0;for(var C=H.length,t=void 0;q<C&&(t=H[q]);q++)H[q]=t.match(g)?t.replace(f,m):m+" "+t;l.selector=H.join(",")}},h)}function wh(a,b){a=a.b;var c={};if(!U&&a)for(var d=0,e=a[d];d<a.length;e=a[++d]){var f=e,g=b;f.l=new RegExp("\\b"+f.keyframesName+"(?!\\B|-)","g");f.a=f.keyframesName+"-"+g;f.w=f.w||f.selector;f.selector=f.w.replace(f.keyframesName,f.a);c[e.keyframesName]=xh(e)}return c}function xh(a){return function(b){return b.replace(a.l,a.a)}}
function yh(a,b){var c=zh,d=tg(a);a.textContent=qg(d,function(e){var f=e.cssText=e.parsedCssText;e.v&&e.v.cssText&&(f=f.replace(bg,"").replace(cg,""),e.cssText=rh(c,f,b))})}ca.Object.defineProperties(mh.prototype,{a:{configurable:!0,enumerable:!0,get:function(){return"x-scope"}}});var zh=new mh;var Ah={},Bh=window.customElements;if(Bh&&!U&&!ig){var Ch=Bh.define;Bh.define=function(a,b,c){Ah[a]||(Ah[a]=yg(a));Ch.call(Bh,a,b,c)}};function Dh(){this.cache={}}Dh.prototype.store=function(a,b,c,d){var e=this.cache[a]||[];e.push({K:b,styleElement:c,G:d});100<e.length&&e.shift();this.cache[a]=e};function Eh(){}var Fh=new RegExp(Kg.a+"\\s*([^\\s]*)");function Gh(a){return(a=(a.classList&&a.classList.value?a.classList.value:a.getAttribute("class")||"").match(Fh))?a[1]:""}function Hh(a){var b=Cg(a).getRootNode();return b===a||b===a.ownerDocument?"":(a=b.host)?Dg(a).is:""}
function Ih(a){for(var b=0;b<a.length;b++){var c=a[b];if(c.target!==document.documentElement&&c.target!==document.head)for(var d=0;d<c.addedNodes.length;d++){var e=c.addedNodes[d];if(e.nodeType===Node.ELEMENT_NODE){var f=e.getRootNode(),g=Gh(e);if(g&&f===e.ownerDocument&&("style"!==e.localName&&"template"!==e.localName||""===Fg(e)))Ng(e,g);else if(f instanceof ShadowRoot)for(f=Hh(e),f!==g&&Mg(e,g,f),e=window.ShadyDOM.nativeMethods.querySelectorAll.call(e,":not(."+Kg.a+")"),g=0;g<e.length;g++){f=e[g];
var h=Hh(f);h&&Lg(f,h)}}}}}
if(!(U||window.ShadyDOM&&window.ShadyDOM.handlesDynamicScoping)){var Jh=new MutationObserver(Ih),Kh=function(a){Jh.observe(a,{childList:!0,subtree:!0})};if(window.customElements&&!window.customElements.polyfillWrapFlushCallback)Kh(document);else{var Lh=function(){Kh(document.body)};window.HTMLImports?window.HTMLImports.whenReady(Lh):requestAnimationFrame(function(){if("loading"===document.readyState){var a=function(){Lh();document.removeEventListener("readystatechange",a)};document.addEventListener("readystatechange",
a)}else Lh()})}Eh=function(){Ih(Jh.takeRecords())}};var Mh={};var Nh=Promise.resolve();function Oh(a){if(a=Mh[a])a._applyShimCurrentVersion=a._applyShimCurrentVersion||0,a._applyShimValidatingVersion=a._applyShimValidatingVersion||0,a._applyShimNextVersion=(a._applyShimNextVersion||0)+1}function Ph(a){return a._applyShimCurrentVersion===a._applyShimNextVersion}function Qh(a){a._applyShimValidatingVersion=a._applyShimNextVersion;a._validating||(a._validating=!0,Nh.then(function(){a._applyShimCurrentVersion=a._applyShimNextVersion;a._validating=!1}))};var Rh={},Sh=new Dh;function X(){this.Y={};this.c=document.documentElement;var a=new Pf;a.rules=[];this.l=ih(this.c,new gh(a));this.J=!1;this.a=this.b=null}w=X.prototype;w.flush=function(){Eh()};w.Ta=function(a){return tg(a)};w.hb=function(a){return qg(a)};w.prepareTemplate=function(a,b,c){this.prepareTemplateDom(a,b);this.prepareTemplateStyles(a,b,c)};
w.prepareTemplateStyles=function(a,b,c){if(!a._prepared&&!ig){U||Ah[b]||(Ah[b]=yg(b));a._prepared=!0;a.name=b;a.extends=c;Mh[b]=a;var d=Fg(a),e=Gg(d);c={is:b,extends:c};for(var f=[],g=a.content.querySelectorAll("style"),h=0;h<g.length;h++){var k=g[h];if(k.hasAttribute("shady-unscoped")){if(!U){var l=k.textContent;if(!pg.has(l)){pg.add(l);var m=document.createElement("style");m.setAttribute("shady-unscoped","");m.textContent=l;document.head.appendChild(m)}k.parentNode.removeChild(k)}}else f.push(k.textContent),
k.parentNode.removeChild(k)}f=f.join("").trim()+(Rh[b]||"");Th(this);if(!e){if(g=!d)g=kg.test(f)||jg.test(f),kg.lastIndex=0,jg.lastIndex=0;h=Qf(f);g&&V&&this.b&&this.b.transformRules(h,b);a._styleAst=h}g=[];V||(g=nh(a._styleAst));if(!g.length||V)h=U?a.content:null,b=Ah[b]||null,d=Og(c,a._styleAst,null,d,e?f:""),d=d.length?vg(d,c.is,h,b):null,a._style=d;a.a=g}};w.ab=function(a,b){Rh[b]=a.join(" ")};
w.prepareTemplateDom=function(a,b){if(!ig){var c=Fg(a);U||"shady"===c||a._domPrepared||(a._domPrepared=!0,Ig(a.content,b))}};function Uh(a){var b=Dg(a),c=b.is;b=b.ca;var d=Ah[c]||null,e=Mh[c];if(e){c=e._styleAst;var f=e.a;e=Fg(e);b=new gh(c,d,f,b,e);ih(a,b);return b}}
function Vh(a){!a.a&&window.ShadyCSS&&window.ShadyCSS.CustomStyleInterface&&(a.a=window.ShadyCSS.CustomStyleInterface,a.a.transformCallback=function(b){a.Ha(b)},a.a.validateCallback=function(){requestAnimationFrame(function(){(a.a.enqueued||a.J)&&a.flushCustomStyles()})})}function Th(a){if(!a.b&&window.ShadyCSS&&window.ShadyCSS.ApplyShim){a.b=window.ShadyCSS.ApplyShim;a.b.invalidCallback=Oh;var b=!0}else b=!1;Vh(a);return b}
w.flushCustomStyles=function(){if(!ig){var a=Th(this);if(this.a){var b=this.a.processStyles();if((a||this.a.enqueued)&&!Gg(this.l.cssBuild)){if(V){if(!this.l.cssBuild)for(a=0;a<b.length;a++){var c=this.a.getStyleForCustomStyle(b[a]);if(c&&V&&this.b){var d=tg(c);Th(this);this.b.transformRules(d);c.textContent=qg(d)}}}else{Wh(this,b);Xh(this,this.c,this.l);for(a=0;a<b.length;a++)(c=this.a.getStyleForCustomStyle(b[a]))&&yh(c,this.l.L);this.J&&this.styleDocument()}this.a.enqueued=!1}}}};
function Wh(a,b){b=b.map(function(c){return a.a.getStyleForCustomStyle(c)}).filter(function(c){return!!c});b.sort(function(c,d){c=d.compareDocumentPosition(c);return c&Node.DOCUMENT_POSITION_FOLLOWING?1:c&Node.DOCUMENT_POSITION_PRECEDING?-1:0});a.l.H.rules=b.map(function(c){return tg(c)})}
w.styleElement=function(a,b){if(ig){if(b){hh(a)||ih(a,new gh(null));var c=hh(a);c.F=c.F||{};Object.assign(c.F,b);Yh(this,a,c)}}else if(c=hh(a)||Uh(a))if(a!==this.c&&(this.J=!0),b&&(c.F=c.F||{},Object.assign(c.F,b)),V)Yh(this,a,c);else if(this.flush(),Xh(this,a,c),c.ta&&c.ta.length){b=Dg(a).is;var d;a:{if(d=Sh.cache[b])for(var e=d.length-1;0<=e;e--){var f=d[e];b:{var g=c.ta;for(var h=0;h<g.length;h++){var k=g[h];if(f.K[k]!==c.L[k]){g=!1;break b}}g=!0}if(g){d=f;break a}}d=void 0}g=d?d.styleElement:
null;e=c.G;(f=d&&d.G)||(f=this.Y[b]=(this.Y[b]||0)+1,f=b+"-"+f);c.G=f;f=c.G;h=zh;h=g?g.textContent||"":vh(h,a,c.L,f);k=hh(a);var l=k.a;l&&!U&&l!==g&&(l._useCount--,0>=l._useCount&&l.parentNode&&l.parentNode.removeChild(l));U?k.a?(k.a.textContent=h,g=k.a):h&&(g=vg(h,f,a.shadowRoot,k.b)):g?g.parentNode||(lh&&-1<h.indexOf("@media")&&(g.textContent=h),wg(g,null,k.b)):h&&(g=vg(h,f,null,k.b));g&&(g._useCount=g._useCount||0,k.a!=g&&g._useCount++,k.a=g);f=g;U||(g=c.G,k=h=a.getAttribute("class")||"",e&&(k=
h.replace(new RegExp("\\s*x-scope\\s*"+e+"\\s*","g")," ")),k+=(k?" ":"")+"x-scope "+g,h!==k&&Bg(a,k));d||Sh.store(b,c.L,f,c.G)}};
function Yh(a,b,c){var d=Dg(b).is;if(c.F){var e=c.F,f;for(f in e)null===f?b.style.removeProperty(f):b.style.setProperty(f,e[f])}e=Mh[d];if(!(!e&&b!==a.c||e&&""!==Fg(e))&&e&&e._style&&!Ph(e)){if(Ph(e)||e._applyShimValidatingVersion!==e._applyShimNextVersion)Th(a),a.b&&a.b.transformRules(e._styleAst,d),e._style.textContent=Og(b,c.H),Qh(e);U&&(a=b.shadowRoot)&&(a=a.querySelector("style"))&&(a.textContent=Og(b,c.H));c.H=e._styleAst}}
function Zh(a,b){return(b=Cg(b).getRootNode().host)?hh(b)||Uh(b)?b:Zh(a,b):a.c}function Xh(a,b,c){var d=Zh(a,b),e=hh(d),f=e.L;d===a.c||f||(Xh(a,d,e),f=e.L);a=Object.create(f||null);d=uh(b,c.H,c.cssBuild);b=sh(e.H,b).K;Object.assign(a,d.Va,b,d.cb);b=c.F;for(var g in b)if((e=b[g])||0===e)a[g]=e;g=zh;b=Object.getOwnPropertyNames(a);for(e=0;e<b.length;e++)d=b[e],a[d]=qh(g,a[d],a);c.L=a}w.styleDocument=function(a){this.styleSubtree(this.c,a)};
w.styleSubtree=function(a,b){var c=Cg(a),d=c.shadowRoot,e=a===this.c;(d||e)&&this.styleElement(a,b);if(a=e?c:d)for(a=Array.from(a.querySelectorAll("*")).filter(function(f){return Cg(f).shadowRoot}),b=0;b<a.length;b++)this.styleSubtree(a[b])};
w.Ha=function(a){var b=this,c=Fg(a);c!==this.l.cssBuild&&(this.l.cssBuild=c);if(!Gg(c)){var d=tg(a);sg(d,function(e){if(U)fh(e);else{var f=Kg;e.selector=e.parsedSelector;fh(e);e.selector=e.w=Rg(f,e,f.c,void 0,void 0)}V&&""===c&&(Th(b),b.b&&b.b.transformRule(e))});V?a.textContent=qg(d):this.l.H.rules.push(d)}};w.getComputedStyleValue=function(a,b){var c;V||(c=(hh(a)||hh(Zh(this,a))).L[b]);return(c=c||window.getComputedStyle(a).getPropertyValue(b))?c.trim():""};
w.gb=function(a,b){var c=Cg(a).getRootNode(),d;b?d=("string"===typeof b?b:String(b)).split(/\s/):d=[];b=c.host&&c.host.localName;if(!b&&(c=a.getAttribute("class"))){c=c.split(/\s/);for(var e=0;e<c.length;e++)if(c[e]===Kg.a){b=c[e+1];break}}b&&d.push(Kg.a,b);V||(b=hh(a))&&b.G&&d.push(zh.a,b.G);Bg(a,d.join(" "))};w.Oa=function(a){return hh(a)};w.fb=function(a,b){Lg(a,b)};w.ib=function(a,b){Lg(a,b,!0)};w.eb=function(a){return Hh(a)};w.Ra=function(a){return Gh(a)};X.prototype.flush=X.prototype.flush;
X.prototype.prepareTemplate=X.prototype.prepareTemplate;X.prototype.styleElement=X.prototype.styleElement;X.prototype.styleDocument=X.prototype.styleDocument;X.prototype.styleSubtree=X.prototype.styleSubtree;X.prototype.getComputedStyleValue=X.prototype.getComputedStyleValue;X.prototype.setElementClass=X.prototype.gb;X.prototype._styleInfoForNode=X.prototype.Oa;X.prototype.transformCustomStyleForDocument=X.prototype.Ha;X.prototype.getStyleAst=X.prototype.Ta;X.prototype.styleAstToString=X.prototype.hb;
X.prototype.flushCustomStyles=X.prototype.flushCustomStyles;X.prototype.scopeNode=X.prototype.fb;X.prototype.unscopeNode=X.prototype.ib;X.prototype.scopeForNode=X.prototype.eb;X.prototype.currentScopeForNode=X.prototype.Ra;X.prototype.prepareAdoptedCssText=X.prototype.ab;Object.defineProperties(X.prototype,{nativeShadow:{get:function(){return U}},nativeCss:{get:function(){return V}}});var Y=new X,$h,ai;window.ShadyCSS&&($h=window.ShadyCSS.ApplyShim,ai=window.ShadyCSS.CustomStyleInterface);
window.ShadyCSS={ScopingShim:Y,prepareTemplate:function(a,b,c){Y.flushCustomStyles();Y.prepareTemplate(a,b,c)},prepareTemplateDom:function(a,b){Y.prepareTemplateDom(a,b)},prepareTemplateStyles:function(a,b,c){Y.flushCustomStyles();Y.prepareTemplateStyles(a,b,c)},styleSubtree:function(a,b){Y.flushCustomStyles();Y.styleSubtree(a,b)},styleElement:function(a){Y.flushCustomStyles();Y.styleElement(a)},styleDocument:function(a){Y.flushCustomStyles();Y.styleDocument(a)},flushCustomStyles:function(){Y.flushCustomStyles()},
getComputedStyleValue:function(a,b){return Y.getComputedStyleValue(a,b)},nativeCss:V,nativeShadow:U,cssBuild:hg,disableRuntime:ig};$h&&(window.ShadyCSS.ApplyShim=$h);ai&&(window.ShadyCSS.CustomStyleInterface=ai);(function(a){function b(t){""==t&&(f.call(this),this.h=!0);return t.toLowerCase()}function c(t){var F=t.charCodeAt(0);return 32<F&&127>F&&-1==[34,35,60,62,63,96].indexOf(F)?t:encodeURIComponent(t)}function d(t){var F=t.charCodeAt(0);return 32<F&&127>F&&-1==[34,35,60,62,96].indexOf(F)?t:encodeURIComponent(t)}function e(t,F,E){function M(ka){va.push(ka)}var y=F||"scheme start",W=0,v="",ua=!1,ea=!1,va=[];a:for(;(void 0!=t[W-1]||0==W)&&!this.h;){var n=t[W];switch(y){case "scheme start":if(n&&q.test(n))v+=
n.toLowerCase(),y="scheme";else if(F){M("Invalid scheme.");break a}else{v="";y="no scheme";continue}break;case "scheme":if(n&&H.test(n))v+=n.toLowerCase();else if(":"==n){this.g=v;v="";if(F)break a;void 0!==l[this.g]&&(this.A=!0);y="file"==this.g?"relative":this.A&&E&&E.g==this.g?"relative or authority":this.A?"authority first slash":"scheme data"}else if(F){void 0!=n&&M("Code point not allowed in scheme: "+n);break a}else{v="";W=0;y="no scheme";continue}break;case "scheme data":"?"==n?(this.o="?",
y="query"):"#"==n?(this.u="#",y="fragment"):void 0!=n&&"\t"!=n&&"\n"!=n&&"\r"!=n&&(this.pa+=c(n));break;case "no scheme":if(E&&void 0!==l[E.g]){y="relative";continue}else M("Missing scheme."),f.call(this),this.h=!0;break;case "relative or authority":if("/"==n&&"/"==t[W+1])y="authority ignore slashes";else{M("Expected /, got: "+n);y="relative";continue}break;case "relative":this.A=!0;"file"!=this.g&&(this.g=E.g);if(void 0==n){this.i=E.i;this.m=E.m;this.j=E.j.slice();this.o=E.o;this.s=E.s;this.f=E.f;
break a}else if("/"==n||"\\"==n)"\\"==n&&M("\\ is an invalid code point."),y="relative slash";else if("?"==n)this.i=E.i,this.m=E.m,this.j=E.j.slice(),this.o="?",this.s=E.s,this.f=E.f,y="query";else if("#"==n)this.i=E.i,this.m=E.m,this.j=E.j.slice(),this.o=E.o,this.u="#",this.s=E.s,this.f=E.f,y="fragment";else{y=t[W+1];var I=t[W+2];if("file"!=this.g||!q.test(n)||":"!=y&&"|"!=y||void 0!=I&&"/"!=I&&"\\"!=I&&"?"!=I&&"#"!=I)this.i=E.i,this.m=E.m,this.s=E.s,this.f=E.f,this.j=E.j.slice(),this.j.pop();y=
"relative path";continue}break;case "relative slash":if("/"==n||"\\"==n)"\\"==n&&M("\\ is an invalid code point."),y="file"==this.g?"file host":"authority ignore slashes";else{"file"!=this.g&&(this.i=E.i,this.m=E.m,this.s=E.s,this.f=E.f);y="relative path";continue}break;case "authority first slash":if("/"==n)y="authority second slash";else{M("Expected '/', got: "+n);y="authority ignore slashes";continue}break;case "authority second slash":y="authority ignore slashes";if("/"!=n){M("Expected '/', got: "+
n);continue}break;case "authority ignore slashes":if("/"!=n&&"\\"!=n){y="authority";continue}else M("Expected authority, got: "+n);break;case "authority":if("@"==n){ua&&(M("@ already seen."),v+="%40");ua=!0;for(n=0;n<v.length;n++)I=v[n],"\t"==I||"\n"==I||"\r"==I?M("Invalid whitespace in authority."):":"==I&&null===this.f?this.f="":(I=c(I),null!==this.f?this.f+=I:this.s+=I);v=""}else if(void 0==n||"/"==n||"\\"==n||"?"==n||"#"==n){W-=v.length;v="";y="host";continue}else v+=n;break;case "file host":if(void 0==
n||"/"==n||"\\"==n||"?"==n||"#"==n){2!=v.length||!q.test(v[0])||":"!=v[1]&&"|"!=v[1]?(0!=v.length&&(this.i=b.call(this,v),v=""),y="relative path start"):y="relative path";continue}else"\t"==n||"\n"==n||"\r"==n?M("Invalid whitespace in file host."):v+=n;break;case "host":case "hostname":if(":"!=n||ea)if(void 0==n||"/"==n||"\\"==n||"?"==n||"#"==n){this.i=b.call(this,v);v="";y="relative path start";if(F)break a;continue}else"\t"!=n&&"\n"!=n&&"\r"!=n?("["==n?ea=!0:"]"==n&&(ea=!1),v+=n):M("Invalid code point in host/hostname: "+
n);else if(this.i=b.call(this,v),v="",y="port","hostname"==F)break a;break;case "port":if(/[0-9]/.test(n))v+=n;else if(void 0==n||"/"==n||"\\"==n||"?"==n||"#"==n||F){""!=v&&(v=parseInt(v,10),v!=l[this.g]&&(this.m=v+""),v="");if(F)break a;y="relative path start";continue}else"\t"==n||"\n"==n||"\r"==n?M("Invalid code point in port: "+n):(f.call(this),this.h=!0);break;case "relative path start":"\\"==n&&M("'\\' not allowed in path.");y="relative path";if("/"!=n&&"\\"!=n)continue;break;case "relative path":if(void 0!=
n&&"/"!=n&&"\\"!=n&&(F||"?"!=n&&"#"!=n))"\t"!=n&&"\n"!=n&&"\r"!=n&&(v+=c(n));else{"\\"==n&&M("\\ not allowed in relative path.");if(I=m[v.toLowerCase()])v=I;".."==v?(this.j.pop(),"/"!=n&&"\\"!=n&&this.j.push("")):"."==v&&"/"!=n&&"\\"!=n?this.j.push(""):"."!=v&&("file"==this.g&&0==this.j.length&&2==v.length&&q.test(v[0])&&"|"==v[1]&&(v=v[0]+":"),this.j.push(v));v="";"?"==n?(this.o="?",y="query"):"#"==n&&(this.u="#",y="fragment")}break;case "query":F||"#"!=n?void 0!=n&&"\t"!=n&&"\n"!=n&&"\r"!=n&&(this.o+=
d(n)):(this.u="#",y="fragment");break;case "fragment":void 0!=n&&"\t"!=n&&"\n"!=n&&"\r"!=n&&(this.u+=n)}W++}}function f(){this.s=this.pa=this.g="";this.f=null;this.m=this.i="";this.j=[];this.u=this.o="";this.A=this.h=!1}function g(t,F){void 0===F||F instanceof g||(F=new g(String(F)));this.a=t;f.call(this);e.call(this,this.a.replace(/^[ \t\r\n\f]+|[ \t\r\n\f]+$/g,""),null,F)}var h=!1;try{var k=new URL("b","http://a");k.pathname="c%20d";h="http://a/c%20d"===k.href}catch(t){}if(!h){var l=Object.create(null);
l.ftp=21;l.file=0;l.gopher=70;l.http=80;l.https=443;l.ws=80;l.wss=443;var m=Object.create(null);m["%2e"]=".";m[".%2e"]="..";m["%2e."]="..";m["%2e%2e"]="..";var q=/[a-zA-Z]/,H=/[a-zA-Z0-9\+\-\.]/;g.prototype={toString:function(){return this.href},get href(){if(this.h)return this.a;var t="";if(""!=this.s||null!=this.f)t=this.s+(null!=this.f?":"+this.f:"")+"@";return this.protocol+(this.A?"//"+t+this.host:"")+this.pathname+this.o+this.u},set href(t){f.call(this);e.call(this,t)},get protocol(){return this.g+
":"},set protocol(t){this.h||e.call(this,t+":","scheme start")},get host(){return this.h?"":this.m?this.i+":"+this.m:this.i},set host(t){!this.h&&this.A&&e.call(this,t,"host")},get hostname(){return this.i},set hostname(t){!this.h&&this.A&&e.call(this,t,"hostname")},get port(){return this.m},set port(t){!this.h&&this.A&&e.call(this,t,"port")},get pathname(){return this.h?"":this.A?"/"+this.j.join("/"):this.pa},set pathname(t){!this.h&&this.A&&(this.j=[],e.call(this,t,"relative path start"))},get search(){return this.h||
!this.o||"?"==this.o?"":this.o},set search(t){!this.h&&this.A&&(this.o="?","?"==t[0]&&(t=t.slice(1)),e.call(this,t,"query"))},get hash(){return this.h||!this.u||"#"==this.u?"":this.u},set hash(t){this.h||(t?(this.u="#","#"==t[0]&&(t=t.slice(1)),e.call(this,t,"fragment")):this.u="")},get origin(){var t;if(this.h||!this.g)return"";switch(this.g){case "data":case "file":case "javascript":case "mailto":return"null"}return(t=this.host)?this.g+"://"+t:""}};var C=a.URL;C&&(g.createObjectURL=function(t){return C.createObjectURL.apply(C,
arguments)},g.revokeObjectURL=function(t){C.revokeObjectURL(t)});a.URL=g}})(window);Object.getOwnPropertyDescriptor(Node.prototype,"baseURI")||Object.defineProperty(Node.prototype,"baseURI",{get:function(){var a=(this.ownerDocument||this).querySelector("base[href]");return a&&a.href||window.location.href},configurable:!0,enumerable:!0});var bi=document.createElement("style");bi.textContent="body {transition: opacity ease-in 0.2s; } \nbody[unresolved] {opacity: 0; display: block; overflow: hidden; position: relative; } \n";var ci=document.querySelector("head");ci.insertBefore(bi,ci.firstChild);/*

Copyright (c) 2018 The Polymer Project Authors. All rights reserved.
This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
Code distributed by Google as part of the polymer project is also
subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
*/
var di=window.customElements,ei=!1,fi=null;di.polyfillWrapFlushCallback&&di.polyfillWrapFlushCallback(function(a){fi=a;ei&&a()});function gi(){window.HTMLTemplateElement.bootstrap&&window.HTMLTemplateElement.bootstrap(window.document);fi&&fi();ei=!0;window.WebComponents.ready=!0;document.dispatchEvent(new CustomEvent("WebComponentsReady",{bubbles:!0}))}
"complete"!==document.readyState?(window.addEventListener("load",gi),window.addEventListener("DOMContentLoaded",function(){window.removeEventListener("load",gi);gi()})):gi();}).call(this);



}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {},require("timers").setImmediate)
},{"timers":4}],2:[function(require,module,exports){
/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the W3C SOFTWARE AND DOCUMENT NOTICE AND LICENSE.
 *
 *  https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
 *
 */
(function() {
'use strict';

// Exit early if we're not running in a browser.
if (typeof window !== 'object') {
  return;
}

// Exit early if all IntersectionObserver and IntersectionObserverEntry
// features are natively supported.
if ('IntersectionObserver' in window &&
    'IntersectionObserverEntry' in window &&
    'intersectionRatio' in window.IntersectionObserverEntry.prototype) {

  // Minimal polyfill for Edge 15's lack of `isIntersecting`
  // See: https://github.com/w3c/IntersectionObserver/issues/211
  if (!('isIntersecting' in window.IntersectionObserverEntry.prototype)) {
    Object.defineProperty(window.IntersectionObserverEntry.prototype,
      'isIntersecting', {
      get: function () {
        return this.intersectionRatio > 0;
      }
    });
  }
  return;
}

/**
 * Returns the embedding frame element, if any.
 * @param {!Document} doc
 * @return {!Element}
 */
function getFrameElement(doc) {
  try {
    return doc.defaultView && doc.defaultView.frameElement || null;
  } catch (e) {
    // Ignore the error.
    return null;
  }
}

/**
 * A local reference to the root document.
 */
var document = (function(startDoc) {
  var doc = startDoc;
  var frame = getFrameElement(doc);
  while (frame) {
    doc = frame.ownerDocument;
    frame = getFrameElement(doc);
  }
  return doc;
})(window.document);

/**
 * An IntersectionObserver registry. This registry exists to hold a strong
 * reference to IntersectionObserver instances currently observing a target
 * element. Without this registry, instances without another reference may be
 * garbage collected.
 */
var registry = [];

/**
 * The signal updater for cross-origin intersection. When not null, it means
 * that the polyfill is configured to work in a cross-origin mode.
 * @type {function(DOMRect|ClientRect, DOMRect|ClientRect)}
 */
var crossOriginUpdater = null;

/**
 * The current cross-origin intersection. Only used in the cross-origin mode.
 * @type {DOMRect|ClientRect}
 */
var crossOriginRect = null;


/**
 * Creates the global IntersectionObserverEntry constructor.
 * https://w3c.github.io/IntersectionObserver/#intersection-observer-entry
 * @param {Object} entry A dictionary of instance properties.
 * @constructor
 */
function IntersectionObserverEntry(entry) {
  this.time = entry.time;
  this.target = entry.target;
  this.rootBounds = ensureDOMRect(entry.rootBounds);
  this.boundingClientRect = ensureDOMRect(entry.boundingClientRect);
  this.intersectionRect = ensureDOMRect(entry.intersectionRect || getEmptyRect());
  this.isIntersecting = !!entry.intersectionRect;

  // Calculates the intersection ratio.
  var targetRect = this.boundingClientRect;
  var targetArea = targetRect.width * targetRect.height;
  var intersectionRect = this.intersectionRect;
  var intersectionArea = intersectionRect.width * intersectionRect.height;

  // Sets intersection ratio.
  if (targetArea) {
    // Round the intersection ratio to avoid floating point math issues:
    // https://github.com/w3c/IntersectionObserver/issues/324
    this.intersectionRatio = Number((intersectionArea / targetArea).toFixed(4));
  } else {
    // If area is zero and is intersecting, sets to 1, otherwise to 0
    this.intersectionRatio = this.isIntersecting ? 1 : 0;
  }
}


/**
 * Creates the global IntersectionObserver constructor.
 * https://w3c.github.io/IntersectionObserver/#intersection-observer-interface
 * @param {Function} callback The function to be invoked after intersection
 *     changes have queued. The function is not invoked if the queue has
 *     been emptied by calling the `takeRecords` method.
 * @param {Object=} opt_options Optional configuration options.
 * @constructor
 */
function IntersectionObserver(callback, opt_options) {

  var options = opt_options || {};

  if (typeof callback != 'function') {
    throw new Error('callback must be a function');
  }

  if (options.root && options.root.nodeType != 1) {
    throw new Error('root must be an Element');
  }

  // Binds and throttles `this._checkForIntersections`.
  this._checkForIntersections = throttle(
      this._checkForIntersections.bind(this), this.THROTTLE_TIMEOUT);

  // Private properties.
  this._callback = callback;
  this._observationTargets = [];
  this._queuedEntries = [];
  this._rootMarginValues = this._parseRootMargin(options.rootMargin);

  // Public properties.
  this.thresholds = this._initThresholds(options.threshold);
  this.root = options.root || null;
  this.rootMargin = this._rootMarginValues.map(function(margin) {
    return margin.value + margin.unit;
  }).join(' ');

  /** @private @const {!Array<!Document>} */
  this._monitoringDocuments = [];
  /** @private @const {!Array<function()>} */
  this._monitoringUnsubscribes = [];
}


/**
 * The minimum interval within which the document will be checked for
 * intersection changes.
 */
IntersectionObserver.prototype.THROTTLE_TIMEOUT = 100;


/**
 * The frequency in which the polyfill polls for intersection changes.
 * this can be updated on a per instance basis and must be set prior to
 * calling `observe` on the first target.
 */
IntersectionObserver.prototype.POLL_INTERVAL = null;

/**
 * Use a mutation observer on the root element
 * to detect intersection changes.
 */
IntersectionObserver.prototype.USE_MUTATION_OBSERVER = true;


/**
 * Sets up the polyfill in the cross-origin mode. The result is the
 * updater function that accepts two arguments: `boundingClientRect` and
 * `intersectionRect` - just as these fields would be available to the
 * parent via `IntersectionObserverEntry`. This function should be called
 * each time the iframe receives intersection information from the parent
 * window, e.g. via messaging.
 * @return {function(DOMRect|ClientRect, DOMRect|ClientRect)}
 */
IntersectionObserver._setupCrossOriginUpdater = function() {
  if (!crossOriginUpdater) {
    /**
     * @param {DOMRect|ClientRect} boundingClientRect
     * @param {DOMRect|ClientRect} intersectionRect
     */
    crossOriginUpdater = function(boundingClientRect, intersectionRect) {
      if (!boundingClientRect || !intersectionRect) {
        crossOriginRect = getEmptyRect();
      } else {
        crossOriginRect = convertFromParentRect(boundingClientRect, intersectionRect);
      }
      registry.forEach(function(observer) {
        observer._checkForIntersections();
      });
    };
  }
  return crossOriginUpdater;
};


/**
 * Resets the cross-origin mode.
 */
IntersectionObserver._resetCrossOriginUpdater = function() {
  crossOriginUpdater = null;
  crossOriginRect = null;
};


/**
 * Starts observing a target element for intersection changes based on
 * the thresholds values.
 * @param {Element} target The DOM element to observe.
 */
IntersectionObserver.prototype.observe = function(target) {
  var isTargetAlreadyObserved = this._observationTargets.some(function(item) {
    return item.element == target;
  });

  if (isTargetAlreadyObserved) {
    return;
  }

  if (!(target && target.nodeType == 1)) {
    throw new Error('target must be an Element');
  }

  this._registerInstance();
  this._observationTargets.push({element: target, entry: null});
  this._monitorIntersections(target.ownerDocument);
  this._checkForIntersections();
};


/**
 * Stops observing a target element for intersection changes.
 * @param {Element} target The DOM element to observe.
 */
IntersectionObserver.prototype.unobserve = function(target) {
  this._observationTargets =
      this._observationTargets.filter(function(item) {
        return item.element != target;
      });
  this._unmonitorIntersections(target.ownerDocument);
  if (this._observationTargets.length == 0) {
    this._unregisterInstance();
  }
};


/**
 * Stops observing all target elements for intersection changes.
 */
IntersectionObserver.prototype.disconnect = function() {
  this._observationTargets = [];
  this._unmonitorAllIntersections();
  this._unregisterInstance();
};


/**
 * Returns any queue entries that have not yet been reported to the
 * callback and clears the queue. This can be used in conjunction with the
 * callback to obtain the absolute most up-to-date intersection information.
 * @return {Array} The currently queued entries.
 */
IntersectionObserver.prototype.takeRecords = function() {
  var records = this._queuedEntries.slice();
  this._queuedEntries = [];
  return records;
};


/**
 * Accepts the threshold value from the user configuration object and
 * returns a sorted array of unique threshold values. If a value is not
 * between 0 and 1 and error is thrown.
 * @private
 * @param {Array|number=} opt_threshold An optional threshold value or
 *     a list of threshold values, defaulting to [0].
 * @return {Array} A sorted list of unique and valid threshold values.
 */
IntersectionObserver.prototype._initThresholds = function(opt_threshold) {
  var threshold = opt_threshold || [0];
  if (!Array.isArray(threshold)) threshold = [threshold];

  return threshold.sort().filter(function(t, i, a) {
    if (typeof t != 'number' || isNaN(t) || t < 0 || t > 1) {
      throw new Error('threshold must be a number between 0 and 1 inclusively');
    }
    return t !== a[i - 1];
  });
};


/**
 * Accepts the rootMargin value from the user configuration object
 * and returns an array of the four margin values as an object containing
 * the value and unit properties. If any of the values are not properly
 * formatted or use a unit other than px or %, and error is thrown.
 * @private
 * @param {string=} opt_rootMargin An optional rootMargin value,
 *     defaulting to '0px'.
 * @return {Array<Object>} An array of margin objects with the keys
 *     value and unit.
 */
IntersectionObserver.prototype._parseRootMargin = function(opt_rootMargin) {
  var marginString = opt_rootMargin || '0px';
  var margins = marginString.split(/\s+/).map(function(margin) {
    var parts = /^(-?\d*\.?\d+)(px|%)$/.exec(margin);
    if (!parts) {
      throw new Error('rootMargin must be specified in pixels or percent');
    }
    return {value: parseFloat(parts[1]), unit: parts[2]};
  });

  // Handles shorthand.
  margins[1] = margins[1] || margins[0];
  margins[2] = margins[2] || margins[0];
  margins[3] = margins[3] || margins[1];

  return margins;
};


/**
 * Starts polling for intersection changes if the polling is not already
 * happening, and if the page's visibility state is visible.
 * @param {!Document} doc
 * @private
 */
IntersectionObserver.prototype._monitorIntersections = function(doc) {
  var win = doc.defaultView;
  if (!win) {
    // Already destroyed.
    return;
  }
  if (this._monitoringDocuments.indexOf(doc) != -1) {
    // Already monitoring.
    return;
  }

  // Private state for monitoring.
  var callback = this._checkForIntersections;
  var monitoringInterval = null;
  var domObserver = null;

  // If a poll interval is set, use polling instead of listening to
  // resize and scroll events or DOM mutations.
  if (this.POLL_INTERVAL) {
    monitoringInterval = win.setInterval(callback, this.POLL_INTERVAL);
  } else {
    addEvent(win, 'resize', callback, true);
    addEvent(doc, 'scroll', callback, true);
    if (this.USE_MUTATION_OBSERVER && 'MutationObserver' in win) {
      domObserver = new win.MutationObserver(callback);
      domObserver.observe(doc, {
        attributes: true,
        childList: true,
        characterData: true,
        subtree: true
      });
    }
  }

  this._monitoringDocuments.push(doc);
  this._monitoringUnsubscribes.push(function() {
    // Get the window object again. When a friendly iframe is destroyed, it
    // will be null.
    var win = doc.defaultView;

    if (win) {
      if (monitoringInterval) {
        win.clearInterval(monitoringInterval);
      }
      removeEvent(win, 'resize', callback, true);
    }

    removeEvent(doc, 'scroll', callback, true);
    if (domObserver) {
      domObserver.disconnect();
    }
  });

  // Also monitor the parent.
  if (doc != (this.root && this.root.ownerDocument || document)) {
    var frame = getFrameElement(doc);
    if (frame) {
      this._monitorIntersections(frame.ownerDocument);
    }
  }
};


/**
 * Stops polling for intersection changes.
 * @param {!Document} doc
 * @private
 */
IntersectionObserver.prototype._unmonitorIntersections = function(doc) {
  var index = this._monitoringDocuments.indexOf(doc);
  if (index == -1) {
    return;
  }

  var rootDoc = (this.root && this.root.ownerDocument || document);

  // Check if any dependent targets are still remaining.
  var hasDependentTargets =
      this._observationTargets.some(function(item) {
        var itemDoc = item.element.ownerDocument;
        // Target is in this context.
        if (itemDoc == doc) {
          return true;
        }
        // Target is nested in this context.
        while (itemDoc && itemDoc != rootDoc) {
          var frame = getFrameElement(itemDoc);
          itemDoc = frame && frame.ownerDocument;
          if (itemDoc == doc) {
            return true;
          }
        }
        return false;
      });
  if (hasDependentTargets) {
    return;
  }

  // Unsubscribe.
  var unsubscribe = this._monitoringUnsubscribes[index];
  this._monitoringDocuments.splice(index, 1);
  this._monitoringUnsubscribes.splice(index, 1);
  unsubscribe();

  // Also unmonitor the parent.
  if (doc != rootDoc) {
    var frame = getFrameElement(doc);
    if (frame) {
      this._unmonitorIntersections(frame.ownerDocument);
    }
  }
};


/**
 * Stops polling for intersection changes.
 * @param {!Document} doc
 * @private
 */
IntersectionObserver.prototype._unmonitorAllIntersections = function() {
  var unsubscribes = this._monitoringUnsubscribes.slice(0);
  this._monitoringDocuments.length = 0;
  this._monitoringUnsubscribes.length = 0;
  for (var i = 0; i < unsubscribes.length; i++) {
    unsubscribes[i]();
  }
};


/**
 * Scans each observation target for intersection changes and adds them
 * to the internal entries queue. If new entries are found, it
 * schedules the callback to be invoked.
 * @private
 */
IntersectionObserver.prototype._checkForIntersections = function() {
  if (!this.root && crossOriginUpdater && !crossOriginRect) {
    // Cross origin monitoring, but no initial data available yet.
    return;
  }

  var rootIsInDom = this._rootIsInDom();
  var rootRect = rootIsInDom ? this._getRootRect() : getEmptyRect();

  this._observationTargets.forEach(function(item) {
    var target = item.element;
    var targetRect = getBoundingClientRect(target);
    var rootContainsTarget = this._rootContainsTarget(target);
    var oldEntry = item.entry;
    var intersectionRect = rootIsInDom && rootContainsTarget &&
        this._computeTargetAndRootIntersection(target, targetRect, rootRect);

    var newEntry = item.entry = new IntersectionObserverEntry({
      time: now(),
      target: target,
      boundingClientRect: targetRect,
      rootBounds: crossOriginUpdater && !this.root ? null : rootRect,
      intersectionRect: intersectionRect
    });

    if (!oldEntry) {
      this._queuedEntries.push(newEntry);
    } else if (rootIsInDom && rootContainsTarget) {
      // If the new entry intersection ratio has crossed any of the
      // thresholds, add a new entry.
      if (this._hasCrossedThreshold(oldEntry, newEntry)) {
        this._queuedEntries.push(newEntry);
      }
    } else {
      // If the root is not in the DOM or target is not contained within
      // root but the previous entry for this target had an intersection,
      // add a new record indicating removal.
      if (oldEntry && oldEntry.isIntersecting) {
        this._queuedEntries.push(newEntry);
      }
    }
  }, this);

  if (this._queuedEntries.length) {
    this._callback(this.takeRecords(), this);
  }
};


/**
 * Accepts a target and root rect computes the intersection between then
 * following the algorithm in the spec.
 * TODO(philipwalton): at this time clip-path is not considered.
 * https://w3c.github.io/IntersectionObserver/#calculate-intersection-rect-algo
 * @param {Element} target The target DOM element
 * @param {Object} targetRect The bounding rect of the target.
 * @param {Object} rootRect The bounding rect of the root after being
 *     expanded by the rootMargin value.
 * @return {?Object} The final intersection rect object or undefined if no
 *     intersection is found.
 * @private
 */
IntersectionObserver.prototype._computeTargetAndRootIntersection =
    function(target, targetRect, rootRect) {
  // If the element isn't displayed, an intersection can't happen.
  if (window.getComputedStyle(target).display == 'none') return;

  var intersectionRect = targetRect;
  var parent = getParentNode(target);
  var atRoot = false;

  while (!atRoot && parent) {
    var parentRect = null;
    var parentComputedStyle = parent.nodeType == 1 ?
        window.getComputedStyle(parent) : {};

    // If the parent isn't displayed, an intersection can't happen.
    if (parentComputedStyle.display == 'none') return null;

    if (parent == this.root || parent.nodeType == /* DOCUMENT */ 9) {
      atRoot = true;
      if (parent == this.root || parent == document) {
        if (crossOriginUpdater && !this.root) {
          if (!crossOriginRect ||
              crossOriginRect.width == 0 && crossOriginRect.height == 0) {
            // A 0-size cross-origin intersection means no-intersection.
            parent = null;
            parentRect = null;
            intersectionRect = null;
          } else {
            parentRect = crossOriginRect;
          }
        } else {
          parentRect = rootRect;
        }
      } else {
        // Check if there's a frame that can be navigated to.
        var frame = getParentNode(parent);
        var frameRect = frame && getBoundingClientRect(frame);
        var frameIntersect =
            frame &&
            this._computeTargetAndRootIntersection(frame, frameRect, rootRect);
        if (frameRect && frameIntersect) {
          parent = frame;
          parentRect = convertFromParentRect(frameRect, frameIntersect);
        } else {
          parent = null;
          intersectionRect = null;
        }
      }
    } else {
      // If the element has a non-visible overflow, and it's not the <body>
      // or <html> element, update the intersection rect.
      // Note: <body> and <html> cannot be clipped to a rect that's not also
      // the document rect, so no need to compute a new intersection.
      var doc = parent.ownerDocument;
      if (parent != doc.body &&
          parent != doc.documentElement &&
          parentComputedStyle.overflow != 'visible') {
        parentRect = getBoundingClientRect(parent);
      }
    }

    // If either of the above conditionals set a new parentRect,
    // calculate new intersection data.
    if (parentRect) {
      intersectionRect = computeRectIntersection(parentRect, intersectionRect);
    }
    if (!intersectionRect) break;
    parent = parent && getParentNode(parent);
  }
  return intersectionRect;
};


/**
 * Returns the root rect after being expanded by the rootMargin value.
 * @return {ClientRect} The expanded root rect.
 * @private
 */
IntersectionObserver.prototype._getRootRect = function() {
  var rootRect;
  if (this.root) {
    rootRect = getBoundingClientRect(this.root);
  } else {
    // Use <html>/<body> instead of window since scroll bars affect size.
    var html = document.documentElement;
    var body = document.body;
    rootRect = {
      top: 0,
      left: 0,
      right: html.clientWidth || body.clientWidth,
      width: html.clientWidth || body.clientWidth,
      bottom: html.clientHeight || body.clientHeight,
      height: html.clientHeight || body.clientHeight
    };
  }
  return this._expandRectByRootMargin(rootRect);
};


/**
 * Accepts a rect and expands it by the rootMargin value.
 * @param {DOMRect|ClientRect} rect The rect object to expand.
 * @return {ClientRect} The expanded rect.
 * @private
 */
IntersectionObserver.prototype._expandRectByRootMargin = function(rect) {
  var margins = this._rootMarginValues.map(function(margin, i) {
    return margin.unit == 'px' ? margin.value :
        margin.value * (i % 2 ? rect.width : rect.height) / 100;
  });
  var newRect = {
    top: rect.top - margins[0],
    right: rect.right + margins[1],
    bottom: rect.bottom + margins[2],
    left: rect.left - margins[3]
  };
  newRect.width = newRect.right - newRect.left;
  newRect.height = newRect.bottom - newRect.top;

  return newRect;
};


/**
 * Accepts an old and new entry and returns true if at least one of the
 * threshold values has been crossed.
 * @param {?IntersectionObserverEntry} oldEntry The previous entry for a
 *    particular target element or null if no previous entry exists.
 * @param {IntersectionObserverEntry} newEntry The current entry for a
 *    particular target element.
 * @return {boolean} Returns true if a any threshold has been crossed.
 * @private
 */
IntersectionObserver.prototype._hasCrossedThreshold =
    function(oldEntry, newEntry) {

  // To make comparing easier, an entry that has a ratio of 0
  // but does not actually intersect is given a value of -1
  var oldRatio = oldEntry && oldEntry.isIntersecting ?
      oldEntry.intersectionRatio || 0 : -1;
  var newRatio = newEntry.isIntersecting ?
      newEntry.intersectionRatio || 0 : -1;

  // Ignore unchanged ratios
  if (oldRatio === newRatio) return;

  for (var i = 0; i < this.thresholds.length; i++) {
    var threshold = this.thresholds[i];

    // Return true if an entry matches a threshold or if the new ratio
    // and the old ratio are on the opposite sides of a threshold.
    if (threshold == oldRatio || threshold == newRatio ||
        threshold < oldRatio !== threshold < newRatio) {
      return true;
    }
  }
};


/**
 * Returns whether or not the root element is an element and is in the DOM.
 * @return {boolean} True if the root element is an element and is in the DOM.
 * @private
 */
IntersectionObserver.prototype._rootIsInDom = function() {
  return !this.root || containsDeep(document, this.root);
};


/**
 * Returns whether or not the target element is a child of root.
 * @param {Element} target The target element to check.
 * @return {boolean} True if the target element is a child of root.
 * @private
 */
IntersectionObserver.prototype._rootContainsTarget = function(target) {
  return containsDeep(this.root || document, target) &&
    (!this.root || this.root.ownerDocument == target.ownerDocument);
};


/**
 * Adds the instance to the global IntersectionObserver registry if it isn't
 * already present.
 * @private
 */
IntersectionObserver.prototype._registerInstance = function() {
  if (registry.indexOf(this) < 0) {
    registry.push(this);
  }
};


/**
 * Removes the instance from the global IntersectionObserver registry.
 * @private
 */
IntersectionObserver.prototype._unregisterInstance = function() {
  var index = registry.indexOf(this);
  if (index != -1) registry.splice(index, 1);
};


/**
 * Returns the result of the performance.now() method or null in browsers
 * that don't support the API.
 * @return {number} The elapsed time since the page was requested.
 */
function now() {
  return window.performance && performance.now && performance.now();
}


/**
 * Throttles a function and delays its execution, so it's only called at most
 * once within a given time period.
 * @param {Function} fn The function to throttle.
 * @param {number} timeout The amount of time that must pass before the
 *     function can be called again.
 * @return {Function} The throttled function.
 */
function throttle(fn, timeout) {
  var timer = null;
  return function () {
    if (!timer) {
      timer = setTimeout(function() {
        fn();
        timer = null;
      }, timeout);
    }
  };
}


/**
 * Adds an event handler to a DOM node ensuring cross-browser compatibility.
 * @param {Node} node The DOM node to add the event handler to.
 * @param {string} event The event name.
 * @param {Function} fn The event handler to add.
 * @param {boolean} opt_useCapture Optionally adds the even to the capture
 *     phase. Note: this only works in modern browsers.
 */
function addEvent(node, event, fn, opt_useCapture) {
  if (typeof node.addEventListener == 'function') {
    node.addEventListener(event, fn, opt_useCapture || false);
  }
  else if (typeof node.attachEvent == 'function') {
    node.attachEvent('on' + event, fn);
  }
}


/**
 * Removes a previously added event handler from a DOM node.
 * @param {Node} node The DOM node to remove the event handler from.
 * @param {string} event The event name.
 * @param {Function} fn The event handler to remove.
 * @param {boolean} opt_useCapture If the event handler was added with this
 *     flag set to true, it should be set to true here in order to remove it.
 */
function removeEvent(node, event, fn, opt_useCapture) {
  if (typeof node.removeEventListener == 'function') {
    node.removeEventListener(event, fn, opt_useCapture || false);
  }
  else if (typeof node.detatchEvent == 'function') {
    node.detatchEvent('on' + event, fn);
  }
}


/**
 * Returns the intersection between two rect objects.
 * @param {Object} rect1 The first rect.
 * @param {Object} rect2 The second rect.
 * @return {?Object|?ClientRect} The intersection rect or undefined if no
 *     intersection is found.
 */
function computeRectIntersection(rect1, rect2) {
  var top = Math.max(rect1.top, rect2.top);
  var bottom = Math.min(rect1.bottom, rect2.bottom);
  var left = Math.max(rect1.left, rect2.left);
  var right = Math.min(rect1.right, rect2.right);
  var width = right - left;
  var height = bottom - top;

  return (width >= 0 && height >= 0) && {
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    width: width,
    height: height
  } || null;
}


/**
 * Shims the native getBoundingClientRect for compatibility with older IE.
 * @param {Element} el The element whose bounding rect to get.
 * @return {DOMRect|ClientRect} The (possibly shimmed) rect of the element.
 */
function getBoundingClientRect(el) {
  var rect;

  try {
    rect = el.getBoundingClientRect();
  } catch (err) {
    // Ignore Windows 7 IE11 "Unspecified error"
    // https://github.com/w3c/IntersectionObserver/pull/205
  }

  if (!rect) return getEmptyRect();

  // Older IE
  if (!(rect.width && rect.height)) {
    rect = {
      top: rect.top,
      right: rect.right,
      bottom: rect.bottom,
      left: rect.left,
      width: rect.right - rect.left,
      height: rect.bottom - rect.top
    };
  }
  return rect;
}


/**
 * Returns an empty rect object. An empty rect is returned when an element
 * is not in the DOM.
 * @return {ClientRect} The empty rect.
 */
function getEmptyRect() {
  return {
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    width: 0,
    height: 0
  };
}


/**
 * Ensure that the result has all of the necessary fields of the DOMRect.
 * Specifically this ensures that `x` and `y` fields are set.
 *
 * @param {?DOMRect|?ClientRect} rect
 * @return {?DOMRect}
 */
function ensureDOMRect(rect) {
  // A `DOMRect` object has `x` and `y` fields.
  if (!rect || 'x' in rect) {
    return rect;
  }
  // A IE's `ClientRect` type does not have `x` and `y`. The same is the case
  // for internally calculated Rect objects. For the purposes of
  // `IntersectionObserver`, it's sufficient to simply mirror `left` and `top`
  // for these fields.
  return {
    top: rect.top,
    y: rect.top,
    bottom: rect.bottom,
    left: rect.left,
    x: rect.left,
    right: rect.right,
    width: rect.width,
    height: rect.height
  };
}


/**
 * Inverts the intersection and bounding rect from the parent (frame) BCR to
 * the local BCR space.
 * @param {DOMRect|ClientRect} parentBoundingRect The parent's bound client rect.
 * @param {DOMRect|ClientRect} parentIntersectionRect The parent's own intersection rect.
 * @return {ClientRect} The local root bounding rect for the parent's children.
 */
function convertFromParentRect(parentBoundingRect, parentIntersectionRect) {
  var top = parentIntersectionRect.top - parentBoundingRect.top;
  var left = parentIntersectionRect.left - parentBoundingRect.left;
  return {
    top: top,
    left: left,
    height: parentIntersectionRect.height,
    width: parentIntersectionRect.width,
    bottom: top + parentIntersectionRect.height,
    right: left + parentIntersectionRect.width
  };
}


/**
 * Checks to see if a parent element contains a child element (including inside
 * shadow DOM).
 * @param {Node} parent The parent element.
 * @param {Node} child The child element.
 * @return {boolean} True if the parent node contains the child node.
 */
function containsDeep(parent, child) {
  var node = child;
  while (node) {
    if (node == parent) return true;

    node = getParentNode(node);
  }
  return false;
}


/**
 * Gets the parent node of an element or its host element if the parent node
 * is a shadow root.
 * @param {Node} node The node whose parent to get.
 * @return {Node|null} The parent node or null if no parent exists.
 */
function getParentNode(node) {
  var parent = node.parentNode;

  if (node.nodeType == /* DOCUMENT */ 9 && node != document) {
    // If this node is a document node, look for the embedding frame.
    return getFrameElement(node);
  }

  if (parent && parent.nodeType == 11 && parent.host) {
    // If the parent is a shadow root, return the host element.
    return parent.host;
  }

  if (parent && parent.assignedSlot) {
    // If the parent is distributed in a <slot>, return the parent of a slot.
    return parent.assignedSlot.parentNode;
  }

  return parent;
}


// Exposes the constructors globally.
window.IntersectionObserver = IntersectionObserver;
window.IntersectionObserverEntry = IntersectionObserverEntry;

}());

},{}],3:[function(require,module,exports){
// shim for using process in browser
var process = module.exports = {};

// cached from whatever global is present so that test runners that stub it
// don't break things.  But we need to wrap it in a try catch in case it is
// wrapped in strict mode code which doesn't define any globals.  It's inside a
// function because try/catches deoptimize in certain engines.

var cachedSetTimeout;
var cachedClearTimeout;

function defaultSetTimout() {
    throw new Error('setTimeout has not been defined');
}
function defaultClearTimeout () {
    throw new Error('clearTimeout has not been defined');
}
(function () {
    try {
        if (typeof setTimeout === 'function') {
            cachedSetTimeout = setTimeout;
        } else {
            cachedSetTimeout = defaultSetTimout;
        }
    } catch (e) {
        cachedSetTimeout = defaultSetTimout;
    }
    try {
        if (typeof clearTimeout === 'function') {
            cachedClearTimeout = clearTimeout;
        } else {
            cachedClearTimeout = defaultClearTimeout;
        }
    } catch (e) {
        cachedClearTimeout = defaultClearTimeout;
    }
} ())
function runTimeout(fun) {
    if (cachedSetTimeout === setTimeout) {
        //normal enviroments in sane situations
        return setTimeout(fun, 0);
    }
    // if setTimeout wasn't available but was latter defined
    if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
        cachedSetTimeout = setTimeout;
        return setTimeout(fun, 0);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedSetTimeout(fun, 0);
    } catch(e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
            return cachedSetTimeout.call(null, fun, 0);
        } catch(e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
            return cachedSetTimeout.call(this, fun, 0);
        }
    }


}
function runClearTimeout(marker) {
    if (cachedClearTimeout === clearTimeout) {
        //normal enviroments in sane situations
        return clearTimeout(marker);
    }
    // if clearTimeout wasn't available but was latter defined
    if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
        cachedClearTimeout = clearTimeout;
        return clearTimeout(marker);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedClearTimeout(marker);
    } catch (e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
            return cachedClearTimeout.call(null, marker);
        } catch (e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
            return cachedClearTimeout.call(this, marker);
        }
    }



}
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    if (!draining || !currentQueue) {
        return;
    }
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = runTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    runClearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        runTimeout(drainQueue);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;
process.prependListener = noop;
process.prependOnceListener = noop;

process.listeners = function (name) { return [] }

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],4:[function(require,module,exports){
(function (setImmediate,clearImmediate){
var nextTick = require('process/browser.js').nextTick;
var apply = Function.prototype.apply;
var slice = Array.prototype.slice;
var immediateIds = {};
var nextImmediateId = 0;

// DOM APIs, for completeness

exports.setTimeout = function() {
  return new Timeout(apply.call(setTimeout, window, arguments), clearTimeout);
};
exports.setInterval = function() {
  return new Timeout(apply.call(setInterval, window, arguments), clearInterval);
};
exports.clearTimeout =
exports.clearInterval = function(timeout) { timeout.close(); };

function Timeout(id, clearFn) {
  this._id = id;
  this._clearFn = clearFn;
}
Timeout.prototype.unref = Timeout.prototype.ref = function() {};
Timeout.prototype.close = function() {
  this._clearFn.call(window, this._id);
};

// Does not start the time, just sets up the members needed.
exports.enroll = function(item, msecs) {
  clearTimeout(item._idleTimeoutId);
  item._idleTimeout = msecs;
};

exports.unenroll = function(item) {
  clearTimeout(item._idleTimeoutId);
  item._idleTimeout = -1;
};

exports._unrefActive = exports.active = function(item) {
  clearTimeout(item._idleTimeoutId);

  var msecs = item._idleTimeout;
  if (msecs >= 0) {
    item._idleTimeoutId = setTimeout(function onTimeout() {
      if (item._onTimeout)
        item._onTimeout();
    }, msecs);
  }
};

// That's not how node.js implements it but the exposed api is the same.
exports.setImmediate = typeof setImmediate === "function" ? setImmediate : function(fn) {
  var id = nextImmediateId++;
  var args = arguments.length < 2 ? false : slice.call(arguments, 1);

  immediateIds[id] = true;

  nextTick(function onNextTick() {
    if (immediateIds[id]) {
      // fn.call() is faster so we optimize for the common use-case
      // @see http://jsperf.com/call-apply-segu
      if (args) {
        fn.apply(null, args);
      } else {
        fn.call(null);
      }
      // Prevent ids from leaking
      exports.clearImmediate(id);
    }
  });

  return id;
};

exports.clearImmediate = typeof clearImmediate === "function" ? clearImmediate : function(id) {
  delete immediateIds[id];
};
}).call(this,require("timers").setImmediate,require("timers").clearImmediate)
},{"process/browser.js":3,"timers":4}],5:[function(require,module,exports){
const logo = 'data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNTdweCIgaGVpZ2h0PSI1N3B4IiB2aWV3Qm94PSIwIDAgNTcgNTciIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8dGl0bGU+ZGRnLWxvZ28tYm9yZGVybGVzczwvdGl0bGU+CiAgICA8ZGVmcz4KICAgICAgICA8cGF0aCBkPSJNMjguNSw1NyBDNDQuMjQwMSw1NyA1Nyw0NC4yNDAxIDU3LDI4LjUgQzU3LDEyLjc1OTkgNDQuMjQwMSwwIDI4LjUsMCBDMTIuNzU5OSwwIDAsMTIuNzU5OSAwLDI4LjUgQzAsNDQuMjQwMSAxMi43NTk5LDU3IDI4LjUsNTcgWiIgaWQ9InBhdGgtMSI+PC9wYXRoPgogICAgICAgIDxsaW5lYXJHcmFkaWVudCB4MT0iLTAuNDU0NDU4OTI0JSIgeTE9IjQ5LjQ2MTk2NjQlIiB4Mj0iOTkuNDUyMjExJSIgeTI9IjQ5LjQ2MTk2NjQlIiBpZD0ibGluZWFyR3JhZGllbnQtMyI+CiAgICAgICAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiM2MTc2QjkiIG9mZnNldD0iMC41NiUiPjwvc3RvcD4KICAgICAgICAgICAgPHN0b3Agc3RvcC1jb2xvcj0iIzM5NEE5RiIgb2Zmc2V0PSI2OS4xJSI+PC9zdG9wPgogICAgICAgIDwvbGluZWFyR3JhZGllbnQ+CiAgICAgICAgPGxpbmVhckdyYWRpZW50IHgxPSIwLjUxMjYwODMyNiUiIHkxPSI1Mi43OTIwMzM1JSIgeDI9IjEwMC41NzY5NzIlIiB5Mj0iNTIuNzkyMDMzNSUiIGlkPSJsaW5lYXJHcmFkaWVudC00Ij4KICAgICAgICAgICAgPHN0b3Agc3RvcC1jb2xvcj0iIzYxNzZCOSIgb2Zmc2V0PSIwLjU2JSI+PC9zdG9wPgogICAgICAgICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjMzk0QTlGIiBvZmZzZXQ9IjY5LjElIj48L3N0b3A+CiAgICAgICAgPC9saW5lYXJHcmFkaWVudD4KICAgIDwvZGVmcz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJkZGctbG9nby1ib3JkZXJsZXNzIj4KICAgICAgICAgICAgPHBhdGggZD0iTTI4LjUsNTcgQzQ0LjI0MDEsNTcgNTcsNDQuMjQwMSA1NywyOC41IEM1NywxMi43NTk5IDQ0LjI0MDEsMCAyOC41LDAgQzEyLjc1OTksMCAwLDEyLjc1OTkgMCwyOC41IEMwLDQ0LjI0MDEgMTIuNzU5OSw1NyAyOC41LDU3IFoiIGlkPSJQYXRoIiBmaWxsPSIjREM1OTNBIiBmaWxsLXJ1bGU9Im5vbnplcm8iPjwvcGF0aD4KICAgICAgICAgICAgPGcgaWQ9IkNsaXBwZWQiPgogICAgICAgICAgICAgICAgPG1hc2sgaWQ9Im1hc2stMiIgZmlsbD0id2hpdGUiPgogICAgICAgICAgICAgICAgICAgIDx1c2UgeGxpbms6aHJlZj0iI3BhdGgtMSI+PC91c2U+CiAgICAgICAgICAgICAgICA8L21hc2s+CiAgICAgICAgICAgICAgICA8ZyBpZD0iUGF0aCI+PC9nPgogICAgICAgICAgICAgICAgPGcgaWQ9Ikdyb3VwIiBtYXNrPSJ1cmwoI21hc2stMikiIGZpbGwtcnVsZT0ibm9uemVybyI+CiAgICAgICAgICAgICAgICAgICAgPGcgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuMDAwMDAwLCA2LjAwMDAwMCkiIGlkPSJQYXRoIj4KICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTI4LjIxMjMsNjQuOTk5MiBDMjcuMjA4NCw2MC4zNyAyMS4zNTIyLDQ5Ljk0MDQgMTkuMTc3LDQ1LjQ3ODYgQzE2Ljk0NjEsNDEuMDcyNSAxNC43NzEsMzQuODI2IDE1Ljc3NDksMzAuODEwMyBDMTUuOTQyMiwzMC4wODUzIDEzLjg3ODYsMjQuNTA4IDE0LjQzNjMsMjQuMTE3NSBDMTkuMTIxMywyMS4wNSAyMC4zNDgzLDI0LjQ1MjIgMjIuMjQ0NiwyMy4wNTc5IEMyMy4xOTI3LDIyLjMzMjggMjQuNTMxMywyMy42MTU2IDI0Ljg2NTksMjIuNDQ0NCBDMjYuMDkyOSwxOC4yMDU2IDIzLjE5MjcsMTAuODQzNiAxOS45NTc5LDcuNjY0NSBDMTguODk4Miw2LjYwNDggMTcuMjgwOCw1LjkzNTUgMTUuNDk2LDUuNjAwOSBDMTQuNzcxLDQuNjUyOCAxMy42NTU1LDMuNzA0NjIgMTIuMDkzOSwyLjg2ODAzIEMxMC4zMDkxLDEuOTE5ODkgNi40NjA4LDAuNjkyODggNC40NTMsMC4zNTgyNCBDMy4wNTg3LDAuMTM1MTUgMi43MjQsMC41MjU1NiAyLjE2NjMsMC42MzcxMSBDMi43MjQsMC42OTI4OCA1LjM0NTMsMS45NzU2NiA1Ljg0NzMsMi4wMzE0MyBDNS4zNDUzLDIuMzY2MDcgMy44Mzk1LDIuMDMxNDMgMi44OTEzLDIuNDIxODUgQzIuMzg5NCwyLjY0NDk0IDIuMDU0NywzLjQ4MTUzIDIuMDU0NywzLjg3MTk0IEM0Ljc4NzYsMy41OTMwOCA5LjA4MjEsMy44NzE5NCAxMS41OTE5LDQuOTg3NCBDOS41ODQxLDUuMjEwNSA2LjUxNjYsNS40ODk0IDUuMjMzOCw2LjE1ODYgQzEuNDQxMiw4LjE2NjUgLTAuMjg3NywxMi44NTE0IDAuNzE2MiwxOC40ODQ1IEMxLjcyMDEsMjQuMTE3NSA2LjEyNjIsNDQuNTg2MiA3LjU3NjMsNTEuNDQ2MyBDOC45NzA2LDU4LjMwNjQgNC41NjQ1LDYyLjcxMjUgMS43MjAxLDYzLjkzOTUgTDQuNzMxOCw2NC4xNjI2IEwzLjcyNzksNjYuMzkzNSBDNy4zNTMyLDY2Ljc4MzkgMTEuMzY4OCw2NS42MTI3IDExLjM2ODgsNjUuNjEyNyBDMTAuNTg4LDY3Ljg0MzYgNS4xMjIzLDY4LjYyNDQgNS4xMjIzLDY4LjYyNDQgQzUuMTIyMyw2OC42MjQ0IDcuNzQzNiw2OS40MDUyIDExLjk4MjMsNjcuODQzNiBDMTYuMjIxMSw2Ni4yMjYyIDE4Ljg0MjQsNjUuMjIyMiAxOC44NDI0LDY1LjIyMjIgTDIwLjg1MDIsNzAuNDY0OSBMMjQuNjk4Niw2Ni42NzIzIEwyNi4zMTYsNzAuNjg4IEMyNi4yMDQ0LDcwLjYzMjIgMjkuMjE2Miw2OS42MjgzIDI4LjIxMjMsNjQuOTk5MiBMMjguMjEyMyw2NC45OTkyIFoiIGZpbGw9IiNENUQ3RDgiPjwvcGF0aD4KICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTI5LjM4MzUsNjQuMTA2OCBDMjguMzc5Niw1OS40Nzc2IDIyLjUyMzQsNDkuMDQ4MSAyMC4zNDgyLDQ0LjU4NjIgQzE4LjExNzMsNDAuMTgwMiAxNS45NDIyLDMzLjkzMzYgMTYuOTQ2MSwyOS45MTc5IEMxNy4xMTM0LDI5LjE5MjkgMTcuMTEzNCwyNi4xODEyIDE3LjcyNjksMjUuNzkwNyBDMjIuNDExOCwyMi43MjMyIDIyLjA3NzIsMjUuNjc5MiAyMy45NzM1LDI0LjM0MDYgQzI0LjkyMTYsMjMuNjE1NiAyNS43MDI1LDIyLjc3OSAyNi4wMzcxLDIxLjYwNzggQzI3LjI2NDEsMTcuMzY5IDI0LjM2MzksMTAuMDA3IDIxLjEyOTEsNi44Mjc5IEMyMC4wNjk0LDUuNzY4MiAxOC40NTIsNS4wOTkgMTYuNjY3Miw0Ljc2NDMgQzE1Ljk0MjIsMy44MTYxOCAxNC44MjY3LDIuODY4MDQgMTMuMjY1MSwyLjAzMTQ1IEMxMC4yNTMzLDAuNDE0MDMgNi41MTY1LC0wLjE5OTQ3IDMuMDU4NiwwLjQxNDAzIEMzLjYxNjMsMC40Njk4MSA0Ljg5OTEsMS41ODUyNyA1LjQwMTEsMS42OTY4MSBDNC42MjAzLDIuMTk4NzcgMi41NTY3LDIuMTQzIDIuNjEyNCwzLjMxNDIzIEM1LjM0NTMsMy4wMzUzNiA4LjM1NywzLjQ4MTU1IDEwLjg2NjgsNC41OTcgQzguODU5LDQuODIwMSA2Ljk2MjcsNS4zMjIxIDUuNjc5OSw1Ljk5MTMgQzEuODMxNiw3Ljk5OTIgMC44Mjc3LDEyLjAxNDggMS44MzE2LDE3LjY0NzkgQzIuODM1NSwyMy4yODEgNy4yNDE2LDQzLjgwNTQgOC42OTE3LDUwLjYwOTcgQzEwLjA4Niw1Ny40Njk4IDUuNjc5OSw2MS44NzU5IDIuODkxMyw2My4xMDI5IEw1LjkwMyw2My4zMjYgTDQuODk5MSw2NS41NTY5IEM4LjUyNDQsNjUuOTQ3MyAxMi41NCw2NC43NzYxIDEyLjU0LDY0Ljc3NjEgQzExLjc1OTIsNjcuMDA3IDYuMjkzNCw2Ny43ODc4IDYuMjkzNCw2Ny43ODc4IEM2LjI5MzQsNjcuNzg3OCA4LjkxNDgsNjguNTY4NiAxMy4xNTM1LDY3LjAwNyBDMTcuMzkyMyw2NS4zODk2IDIwLjAxMzYsNjQuMzg1NyAyMC4wMTM2LDY0LjM4NTcgTDIyLjAyMTQsNjkuNjI4MyBMMjUuODY5OCw2NS43OCBMMjcuNDg3Miw2OS43OTU2IEMyNy4zNzU2LDY5LjY4NDEgMzAuMzg3NCw2OC42ODAyIDI5LjM4MzUsNjQuMTA2OCBMMjkuMzgzNSw2NC4xMDY4IFoiIGZpbGw9IiNGRkZGRkYiPjwvcGF0aD4KICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTYuMjkzNSwxNy45MjY4IEM2LjI5MzUsMTYuNzU1NiA3LjI0MTYsMTUuODA3NCA4LjQxMjgsMTUuODA3NCBDOS41ODQxLDE1LjgwNzQgMTAuNTMyMiwxNi43NTU2IDEwLjUzMjIsMTcuOTI2OCBDMTAuNTMyMiwxOS4wOTggOS41ODQxLDIwLjA0NjIgOC40MTI4LDIwLjA0NjIgQzcuMjQxNiwyMC4wNDYyIDYuMjkzNSwxOS4wOTggNi4yOTM1LDE3LjkyNjggWiIgZmlsbD0iIzJENEY4RSI+PC9wYXRoPgogICAgICAgICAgICAgICAgICAgICAgICA8cGF0aCBkPSJNOC44MDM1LDE3LjIwMTggQzguODAzNSwxNi45MjMgOS4wMjY2LDE2LjY0NDEgOS4zNjEyLDE2LjY0NDEgQzkuNjQwMSwxNi42NDQxIDkuOTE4OSwxNi44NjcyIDkuOTE4OSwxNy4yMDE4IEM5LjkxODksMTcuNDgwNyA5LjY5NTgsMTcuNzU5NiA5LjM2MTIsMTcuNzU5NiBDOS4wMjY2LDE3Ljc1OTYgOC44MDM1LDE3LjQ4MDcgOC44MDM1LDE3LjIwMTggWiIgZmlsbD0iI0ZGRkZGRiI+PC9wYXRoPgogICAgICAgICAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMjAuNjgzMSwxNi42NDQxIEMyMC42ODMxLDE1LjY0MDIgMjEuNTE5NywxNC44NTkzIDIyLjUyMzYsMTQuODU5MyBDMjMuNTI3NSwxNC44NTkzIDI0LjM2NDEsMTUuNjk1OSAyNC4zNjQxLDE2LjY0NDEgQzI0LjM2NDEsMTcuNjQ4IDIzLjUyNzUsMTguNDg0NiAyMi41MjM2LDE4LjQ4NDYgQzIxLjUxOTcsMTguNDg0NiAyMC42ODMxLDE3LjY0OCAyMC42ODMxLDE2LjY0NDEgWiIgZmlsbD0iIzJENEY4RSI+PC9wYXRoPgogICAgICAgICAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMjIuODU4MiwxNi4wMzA0IEMyMi44NTgyLDE1Ljc1MTYgMjMuMDgxMiwxNS41ODQzIDIzLjMwNDMsMTUuNTg0MyBDMjMuNTgzMiwxNS41ODQzIDIzLjc1MDUsMTUuODA3NCAyMy43NTA1LDE2LjAzMDQgQzIzLjc1MDUsMTYuMzA5MyAyMy41Mjc0LDE2LjQ3NjYgMjMuMzA0MywxNi40NzY2IEMyMy4wODEyLDE2LjUzMjQgMjIuODU4MiwxNi4zMDkzIDIyLjg1ODIsMTYuMDMwNCBaIiBmaWxsPSIjRkZGRkZGIj48L3BhdGg+CiAgICAgICAgICAgICAgICAgICAgICAgIDxwYXRoIGQ9Ik05LjAyNjUsMTEuNzkxNyBDOS4wMjY1LDExLjc5MTcgNy40MDkxLDExLjA2NjYgNS45MDMyLDEyLjA3MDUgQzQuMzQxNSwxMy4wMTg3IDQuMzk3MywxNC4wMjI2IDQuMzk3MywxNC4wMjI2IEM0LjM5NzMsMTQuMDIyNiAzLjU2MDcsMTIuMTgyMSA1Ljc5MTYsMTEuMjg5NyBDNy45MTEsMTAuMzk3MyA5LjAyNjUsMTEuNzkxNyA5LjAyNjUsMTEuNzkxNyBaIiBmaWxsPSJ1cmwoI2xpbmVhckdyYWRpZW50LTMpIj48L3BhdGg+CiAgICAgICAgICAgICAgICAgICAgICAgIDxwYXRoIGQ9Ik0yMy41ODMyLDExLjYyNDUgQzIzLjU4MzIsMTEuNjI0NSAyMi40MTIsMTAuOTU1MiAyMS41NzU0LDEwLjk1NTIgQzE5LjczNDksMTAuOTU1MiAxOS4yMzI5LDExLjc5MTggMTkuMjMyOSwxMS43OTE4IEMxOS4yMzI5LDExLjc5MTggMTkuNTExOCw5Ljg5NTUgMjEuODU0MiwxMC4yMzAyIEMyMy4xMzcsMTAuNTA5IDIzLjU4MzIsMTEuNjI0NSAyMy41ODMyLDExLjYyNDUgTDIzLjU4MzIsMTEuNjI0NSBaIiBmaWxsPSJ1cmwoI2xpbmVhckdyYWRpZW50LTQpIj48L3BhdGg+CiAgICAgICAgICAgICAgICAgICAgICAgIDxwYXRoIGQ9Ik0xNC44ODI3LDI2LjA2OTcgQzE1LjEwNTgsMjQuNzg2OSAxOC4zOTY0LDIyLjM4ODcgMjAuNzM4OSwyMi4yMjEzIEMyMy4wODEzLDIyLjA1NCAyMy44MDY0LDIyLjEwOTggMjUuNzU4NSwyMS42NjM2IEMyNy43MTA1LDIxLjIxNzQgMzIuNzMwMSwxOS45MzQ3IDM0LjEyNDQsMTkuMzIxMSBDMzUuNTE4NywxOC42NTE5IDQxLjQzMDcsMTkuNjU1OCAzNy4yNDc3LDIxLjk0MjUgQzM1LjQ2MywyMi45NDY0IDMwLjYxMDcsMjQuNzg2OSAyNy4wOTcsMjUuODQ2NiBDMjMuNjM5MSwyNi45MDYzIDIxLjUxOTcsMjQuODQyNyAyMC4zNDg1LDI2LjU3MTYgQzE5LjQ1NjEsMjcuOTEwMiAyMC4xODEyLDI5LjgwNjUgMjQuMzA4NCwzMC4xOTY5IEMyOS44ODU3LDMwLjY5ODggMzUuMjk1NiwyNy42ODcxIDM1Ljg1MzQsMjkuMzA0NSBDMzYuNDY2OSwzMC45MjE5IDMxLjA1NjksMzIuOTI5OCAyNy43NjYzLDMyLjk4NTUgQzI0LjQ3NTcsMzMuMDQxMyAxNy44Mzg3LDMwLjgxMDQgMTYuODM0OCwzMC4xNDExIEMxNS45NDI0LDI5LjM2MDMgMTQuNjAzOSwyNy43NDI5IDE0Ljg4MjcsMjYuMDY5NyBMMTQuODgyNywyNi4wNjk3IFoiIGZpbGw9IiNGREQyMEEiPjwvcGF0aD4KICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTE3LjM5MjYsNDIuNTIyNiBDMTcuMzkyNiw0Mi41MjI2IDkuNTI4NiwzOC4zMzk2IDkuNDE3LDQwLjAxMjggQzkuMzA1NSw0MS43NDE4IDkuNDE3LDQ4LjY1NzYgMTAuMzA5NCw0OS4yMTU0IEMxMS4yMDE4LDQ5LjcxNzMgMTcuNzgzLDQ1LjgxMzIgMTcuNzgzLDQ1LjgxMzIgTDE3LjM5MjYsNDIuNTIyNiBaIiBmaWxsPSIjNjVCQzQ2Ij48L3BhdGg+CiAgICAgICAgICAgICAgICAgICAgICAgIDxwYXRoIGQ9Ik0yMC40MDQyLDQyLjI0MzYgQzIwLjQwNDIsNDIuMjQzNiAyNS43NTg1LDM4LjE3MjIgMjYuOTg1NSwzOC40NTEgQzI4LjE1NjcsMzguNzI5OSAyOC40MzU2LDQ3LjA5NTkgMjcuMzc1OSw0Ny40ODYzIEMyNi4zMTYyLDQ3Ljg3NjcgMjAuMTgxMiw0NS4zNjY5IDIwLjE4MTIsNDUuMzY2OSBMMjAuNDA0Miw0Mi4yNDM2IFoiIGZpbGw9IiM2NUJDNDYiPjwvcGF0aD4KICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTE1LjQ5NjEsNDIuOTY4NiBDMTUuNDk2MSw0NS43MDE0IDE1LjEwNTYsNDYuODcyNyAxNi4yNzY5LDQ3LjE1MTUgQzE3LjQ0ODEsNDcuNDMwNCAxOS42NzksNDcuMTUxNSAyMC40NTk5LDQ2LjY0OTYgQzIxLjI0MDcsNDYuMTQ3NiAyMC41NzE0LDQyLjU3ODEgMjAuMzQ4Myw0MS45MDg5IEMyMC4wNjk0LDQxLjI5NTQgMTUuNDk2MSw0MS43OTczIDE1LjQ5NjEsNDIuOTY4NiBMMTUuNDk2MSw0Mi45Njg2IFoiIGZpbGw9IiM0M0EyNDQiPjwvcGF0aD4KICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTE1Ljk5ODMsNDIuMzU1MSBDMTUuOTk4Myw0NS4wODc5IDE1LjYwNzgsNDYuMzE0OSAxNi43NzkxLDQ2LjUzOCBDMTcuOTUwMyw0Ni44MTY5IDIwLjE4MTIsNDYuNTM4IDIwLjk2MjEsNDYuMDM2MSBDMjEuNzQyOSw0NS41MzQxIDIxLjA3MzYsNDEuOTY0NyAyMC44NTA1LDQxLjI5NTQgQzIwLjU3MTYsNDAuNjgxOSAxNS45OTgzLDQxLjE4MzggMTUuOTk4Myw0Mi4zNTUxIEwxNS45OTgzLDQyLjM1NTEgWiIgZmlsbD0iIzY1QkM0NiI+PC9wYXRoPgogICAgICAgICAgICAgICAgICAgIDwvZz4KICAgICAgICAgICAgICAgIDwvZz4KICAgICAgICAgICAgPC9nPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+Cg=='
const css = ""//chrome.runtime.getURL('img/ddg-logo-borderless.svg')

const sendAndWaitForAnswer = (msg, responseType) => {
    // I've hardcoded this here, in the future we can make it more flexible
    window.webkit.messageHandlers["emailHandlerGetAlias"].postMessage(msg)
    return new Promise((resolve) => {
        const handler = e => {
            if (e.origin !== window.origin) return
            if (!e.data || (e.data && e.data.type !== responseType)) return
            resolve(e.data)
            window.removeEventListener('message', handler)
        }
        window.addEventListener('message', handler)
    })
}
    
class DDGAutofill extends HTMLElement {
    constructor (input, associatedForm) {
        super()
        const shadow = this.attachShadow({mode: 'open'})
        this.input = input
        this.associatedForm = associatedForm
        this.inputRightMargin = parseInt(getComputedStyle(this.input).paddingRight)
        this.animationFrame = null
        this.topPosition = 0
        this.leftPosition = 0

        shadow.innerHTML = shadow.innerHTML = `
        <style>
            *, *::before, *::after {
                box-sizing: border-box;
            }
            .wrapper {
                position: absolute;
                top: 0;
                left: 0;
                width: 30px;
                height: 30px;
                padding: 0;
                transform: translateY(-50%);
                font-family: "Proxima Nova";
                z-index: 2147483647;
            }
            .trigger {
                display: flex;
                justify-content: center;
                align-items: center;
                width: 30px;
                height: 30px;
                padding: 0;
                border: none;
                text-align: center;
                background: transparent;
                cursor: pointer;
            }
            .trigger > img {
                width: 24px;
                height: 24px;
            }
            .tooltip {
                position: absolute;
                bottom: calc(100% + 15px);
                right: calc(100% - 60px);
                width: 350px;
                max-width: calc(100vw - 25px);
                padding: 25px;
                border: 1px solid #D0D0D0;
                border-radius: 20px;
                background-color: #FFFFFF;
                font-size: 14px;
                line-height: 1.4;
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
                z-index: 2147483647;
            }
            .tooltip::before {
                content: "";
                width: 0;
                height: 0;
                border-left: 10px solid transparent;
                border-right: 10px solid transparent;
                display: block;
                border-top: 12px solid #D0D0D0;
                position: absolute;
                right: 34px;
                bottom: -12px;
            }
            .tooltip::after {
                content: "";
                width: 0;
                height: 0;
                border-left: 10px solid transparent;
                border-right: 10px solid transparent;
                display: block;
                border-top: 12px solid #FFFFFF;
                position: absolute;
                right: 34px;
                bottom: -10px;
            }
            .tooltip strong {
                margin: 0 0 4px;
                color: #333333;
                font-size: 16px;
                font-weight: bold;
                line-height: 1.3;
            }
            .tooltip p {
                margin: 4px 0 12px;
                color: #666666;
            }
            .tooltip__button-container {
                display: flex;
            }
            .tooltip__button {
                flex: 1;
                height: 40px;
                padding: 0 10px;
                background-color: #332FF3;
                color: #FFFFFF;
                border: none;
                border-radius: 10px;
                font-weight: bold;
            }
            .tooltip__button:last-child {
                margin-left: 12px;
            }
            .tooltip__button--secondary {
                background-color: #EEEEEE;
                color: #332FF3;
            }
        </style>
        <div class="wrapper">
            <button class="trigger"><img src="${logo}" alt="Open the DuckDuckGo autofill tooltip" /></button>
            <div class="tooltip" hidden>
                <strong>Duck.com created a private alias for you.</strong>
                <p>Emails will be sent to you as usual, and you gain an extra level of privacy.</p>
                <div class="tooltip__button-container">
                    <button class="tooltip__button tooltip__button--secondary js-dismiss">Don’t use</button>
                    <button class="tooltip__button tooltip__button--primary js-confirm">Use Private Alias</button>
                </div>
            </div>
        </div>`
                this.wrapper = shadow.querySelector('.wrapper')
                this.trigger = shadow.querySelector('.trigger')
                this.tooltip = shadow.querySelector('.tooltip')
                this.dismissButton = shadow.querySelector('.js-dismiss')
                this.confirmButton = shadow.querySelector('.js-confirm')
            }

    static updateButtonPosition (el) {
        if (el.animationFrame) {
            window.cancelAnimationFrame(el.animationFrame)
        }

        el.animationFrame = window.requestAnimationFrame(() => {
            const {right, top, height} = el.input.getBoundingClientRect()
            const currentTop = `${top + window.scrollY + height / 2}px`
            const currentLeft = `${right + window.scrollX - 30 - el.inputRightMargin}px`

            if (currentTop !== el.topPosition) {
                el.wrapper.style.top = currentTop
                el.topPosition = currentTop
            }
            if (currentLeft !== el.leftPosition) {
                el.wrapper.style.left = currentLeft
                el.leftPosition = currentLeft
            }

            el.animationFrame = null
        })
    }

    connectedCallback () {
        DDGAutofill.updateButtonPosition(this)

        this.showTooltip = () => {
            if (!this.tooltip.hidden) {
                return
            }
            this.tooltip.hidden = false
            window.addEventListener('click', this.hideTooltip)
        }
        this.hideTooltip = (e) => {
            if (e && (e.target === this.input || e.target === this)) {
                return
            }
            if (this.tooltip.hidden) {
                return
            }
            this.tooltip.hidden = true
            window.removeEventListener('click', this.hideTooltip)
        }
        this.execOnInputs = (fn) => {
            this.associatedForm.relevantInputs.forEach(fn)
        }
        this.areAllInputsEmpty = () => {
            let allEmpty = true
            this.execOnInputs(input => {
                if (input.value) allEmpty = false
            })
            return allEmpty
        }
        this.autofillInputs = () => {
            sendAndWaitForAnswer({getAlias: true}, 'getAliasResponse').then(res => {
                if (res.alias) {
                    this.execOnInputs(input => {
                        input.value = res.alias
                        input.classList.add('ddg-autofilled')

                        // If the user changes the alias, remove the decoration
                        input.addEventListener('input', () => {
                            this.execOnInputs(input => {
                                input.classList.remove('ddg-autofilled')
                            })
                        }, {once: true})
                    })
                }
            });
        }
        this.resetInputs = () => {
            this.execOnInputs(input => {
                input.value = ''
                input.classList.remove('ddg-autofilled')
            })
        }
        this.input.addEventListener('mousedown', (e) => {
           e.preventDefault()
            this.autofillInputs()
        }, {once: true})

        this.trigger.addEventListener('click', () => {
            this.autofillInputs()
        })
        this.dismissButton.addEventListener('click', (e) => {
            e.stopImmediatePropagation()
            this.resetInputs()
            this.hideTooltip()
        })
        this.confirmButton.addEventListener('click', (e) => {
            e.stopImmediatePropagation()
            this.autofillInputs()
            this.hideTooltip()
        })
    }
}

module.exports = DDGAutofill

},{}],6:[function(require,module,exports){
"use strict";

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

var Form = /*#__PURE__*/function () {
  function Form(form, input, intObs) {
    _classCallCheck(this, Form);

    this.form = form;
    this.intObs = intObs;
    this.relevantInputs = new Set();
    this.addInput(input);
    this.autofillSignal = 0;
    this.signals = [];
    this.evaluateElAttributes(input, 3, true);
    form ? this.evaluateForm() : this.evaluatePage();
    return this;
  }

  _createClass(Form, [{
    key: "addInput",
    value: function addInput(input) {
      this.relevantInputs.add(input);
      return this;
    }
  }, {
    key: "decorateInputs",
    value: function decorateInputs() {
      var _this = this;

      window.requestAnimationFrame(function () {
        _this.relevantInputs.forEach(function (input) {
          input.setAttribute('data-ddg-autofill', 'true');

          _this.intObs.observe(input);
        });
      });
      return this;
    }
  }, {
    key: "increaseSignalBy",
    value: function increaseSignalBy(strength, signal) {
      this.autofillSignal += strength;
      this.signals.push("".concat(signal, ": +").concat(strength));
      return this;
    }
  }, {
    key: "decreaseSignalBy",
    value: function decreaseSignalBy(strength, signal) {
      this.autofillSignal -= strength;
      this.signals.push("".concat(signal, ": -").concat(strength));
      return this;
    }
  }, {
    key: "updateSignal",
    value: function updateSignal(_ref) {
      var string = _ref.string,
          strength = _ref.strength,
          _ref$signalType = _ref.signalType,
          signalType = _ref$signalType === void 0 ? 'generic' : _ref$signalType,
          _ref$shouldFlip = _ref.shouldFlip,
          shouldFlip = _ref$shouldFlip === void 0 ? false : _ref$shouldFlip,
          _ref$shouldCheckUnifi = _ref.shouldCheckUnifiedForm,
          shouldCheckUnifiedForm = _ref$shouldCheckUnifi === void 0 ? false : _ref$shouldCheckUnifi,
          _ref$shouldBeConserva = _ref.shouldBeConservative,
          shouldBeConservative = _ref$shouldBeConserva === void 0 ? false : _ref$shouldBeConserva;
      var loginRegex = new RegExp(/sign(ing)?.?in(?!g)|log.?in/i);
      var signupRegex = new RegExp(/sign(ing)?.?up|join|regist(er|ration)|newsletter|subscri(be|ption)|contact|create|start/i);
      var conservativeSignupRegex = new RegExp(/sign.?up|join|register|newsletter|subscri(be|ption)/i);
      var strictSignupRegex = new RegExp(/sign.?up|join|register/i);
      var loginMatches = string.match(loginRegex); // Check explicitly for unified login/signup forms. They should always be negative, so we increase signal

      if (shouldCheckUnifiedForm && loginMatches && string.match(strictSignupRegex)) {
        this.decreaseSignalBy(strength + 2, "Unified detected ".concat(signalType));
        return this;
      }

      var signupMatches = string.match(shouldBeConservative ? conservativeSignupRegex : signupRegex); // In some cases a login match means the login is somewhere else, i.e. when a link points outside

      if (shouldFlip) {
        if (loginMatches) this.increaseSignalBy(strength, signalType);
        if (signupMatches) this.decreaseSignalBy(strength, signalType);
      } else {
        if (loginMatches) this.decreaseSignalBy(strength, signalType);
        if (signupMatches) this.increaseSignalBy(strength, signalType);
      }

      return this;
    }
  }, {
    key: "evaluateElAttributes",
    value: function evaluateElAttributes(el) {
      var _this2 = this;

      var signalStrength = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 3;
      var isInput = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : false;
      Array.from(el.attributes).forEach(function (attr) {
        var attributeString = "".concat(attr.nodeName, "=").concat(attr.nodeValue);

        _this2.updateSignal({
          string: attributeString,
          strength: signalStrength,
          signalType: "".concat(el.nodeName, " attr: ").concat(attributeString),
          shouldCheckUnifiedForm: isInput
        });
      });
    }
  }, {
    key: "evaluatePageTitle",
    value: function evaluatePageTitle() {
      var pageTitle = document.title;
      this.updateSignal({
        string: pageTitle,
        strength: 2,
        signalType: "page title: ".concat(pageTitle)
      });
    }
  }, {
    key: "evaluatePageHeadings",
    value: function evaluatePageHeadings() {
      var _this3 = this;

      var headings = document.querySelectorAll('h1, h2, h3');

      if (headings) {
        headings.forEach(function (_ref2) {
          var innerText = _ref2.innerText;

          _this3.updateSignal({
            string: innerText,
            strength: 0.5,
            signalType: "heading: ".concat(innerText),
            shouldCheckUnifiedForm: true,
            shouldBeConservative: true
          });
        });
      }
    }
  }, {
    key: "evaluatePage",
    value: function evaluatePage() {
      var _this4 = this;

      this.evaluatePageTitle();
      this.evaluatePageHeadings(); // Check for submit buttons

      var buttons = document.querySelectorAll("\n                button[type=submit],\n                button:not([type]),\n                [role=button]\n            ");
      buttons.forEach(function (button) {
        // if the button has a form, it's not related to our input, because our input has no form here
        if (!button.form && !button.closest('form')) {
          _this4.evaluateElAttributes(button, 0.5);
        }
      });
    }
  }, {
    key: "getText",
    value: function getText(el) {
      // for buttons, we don't care about descendants, just get the whole text as is
      // this is important in order to give proper attribution of the text to the button
      if (el.nodeName.toUpperCase() === 'BUTTON') return el.innerText;
      if (el.nodeName.toUpperCase() === 'INPUT' && ['submit', 'button'].includes(el.type)) return el.value;
      return Array.from(el.childNodes).reduce(function (text, child) {
        return child.nodeName === '#text' ? text + ' ' + child.textContent : text;
      }, '');
    }
  }, {
    key: "evaluateElement",
    value: function evaluateElement(el) {
      var string = this.getText(el); // check button contents

      if (el.nodeName.toUpperCase() === 'INPUT' && ['submit', 'button'].includes(el.type) || el.nodeName.toUpperCase() === 'BUTTON' && el.type === 'submit' || (el.getAttribute('role') || '').toUpperCase() === 'BUTTON') {
        this.updateSignal({
          string: string,
          strength: 2,
          signalType: "submit: ".concat(string)
        });
      } // if a link points to relevant urls or contain contents outside the page…


      if (el.nodeName === 'A' && el.href && el.href !== '#' || (el.getAttribute('role') || '').toUpperCase() === 'LINK') {
        // …and matches one of the regexes, we assume the match is not pertinent to the current form
        this.updateSignal({
          string: string,
          strength: 1,
          signalType: "external link: ".concat(string),
          shouldFlip: true
        });
      } else {
        // any other case
        this.updateSignal({
          string: string,
          strength: 1,
          signalType: "generic: ".concat(string),
          shouldCheckUnifiedForm: true
        });
      }
    }
  }, {
    key: "evaluateForm",
    value: function evaluateForm() {
      var _this5 = this;

      // Check page title
      this.evaluatePageTitle(); // Check form attributes

      this.evaluateElAttributes(this.form); // Check form contents (skip select and option because they contain too much noise)

      this.form.querySelectorAll('*:not(select):not(option)').forEach(function (el) {
        return _this5.evaluateElement(el);
      }); // If we can't decide at this point, try reading page headings

      if (this.autofillSignal === 0) {
        this.evaluatePageHeadings();
      }

      return this;
    }
  }]);

  return Form;
}();

module.exports = Form;

},{}],7:[function(require,module,exports){
"use strict";

function _createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

(function () {
  // Polyfills/shims
  require('intersection-observer');

  require('./requestIdleCallback');

  require('@webcomponents/webcomponentsjs');

  var DDGAutofill = require('./DDGAutofill');

  var Form = require('./Form'); // Font-face must be declared in the host page, otherwise it won't work in the shadow dom


  var regFontUrl = "public/font/ProximaNova-Reg-webfont.woff" //chrome.runtime.getURL('public/font/ProximaNova-Reg-webfont.woff');
  var styleTag = document.createElement('style');
  document.head.appendChild(styleTag);
  var sheet = styleTag.sheet;
  sheet.insertRule("\n@font-face {\n    font-family: 'DDG_ProximaNova';\n    src: url(".concat(regFontUrl, ") format('woff');\n    font-weight: normal;\n    font-style: normal;\n}\n    "));
  sheet.insertRule("\n.ddg-autofilled {\n    background-color: #F8F498;\n    color: #333333;\n}\n    ");
  var ddgDomainRegex = new RegExp(/^https:\/\/(([a-z0-9-_]+?)\.)?duckduckgo\.com/); // Send a message to the web app (only on DDG domains)

  var notifyWebApp = function notifyWebApp(message) {
    if (window.origin.match(ddgDomainRegex)) {
      window.postMessage(message, window.origin);
    }
  }; // Listen for sign in message from the ddg email page

    var injectEmailAutofill = function injectEmailAutofill() {
      // Here we store a map of input -> button associations
      var inputButtonMap = new Map();
      var forms = new Map();
      customElements.define('ddg-autofill', DDGAutofill);

      var updateAllButtons = function updateAllButtons() {
        inputButtonMap.forEach(function (button) {
          DDGAutofill.updateButtonPosition(button);
        });
      };

      var intObs = new IntersectionObserver(function (entries) {
        var _iterator = _createForOfIteratorHelper(entries),
            _step;

        try {
          for (_iterator.s(); !(_step = _iterator.n()).done;) {
            var entry = _step.value;
            var input = entry.target;

            if (entry.isIntersecting) {
              // If is intersecting and visible (note that `display:none` will never intersect)
              if (window.getComputedStyle(input).visibility !== 'hidden') {
                var associatedForm = forms.get(input.form) || forms.get(input);
                var button = new DDGAutofill(input, associatedForm);
                document.body.appendChild(button); // Keep track of the input->button pair

                inputButtonMap.set(input, button);
              }
            } else {
              // If it's not intersecting and we have the input stored…
              if (inputButtonMap.has(input)) {
                // …remove the button from the DOM
                inputButtonMap.get(input).remove(); // …and remove the input from the map

                inputButtonMap["delete"](input);
              }
            }
          }
        } catch (err) {
          _iterator.e(err);
        } finally {
          _iterator.f();
        }
      });
      var EMAIL_SELECTOR = "\n        input:not([type])[name*=mail i]:not([readonly]):not([disabled]):not([hidden]),\n        input[type=\"\"][name*=mail i]:not([readonly]):not([disabled]):not([hidden]),\n        input[type=text][name*=mail i]:not([readonly]):not([disabled]):not([hidden]),\n        input:not([type])[id*=mail i]:not([readonly]):not([disabled]):not([hidden]),\n        input[type=\"\"][id*=mail i]:not([readonly]):not([disabled]):not([hidden]),\n        input[type=text][id*=mail i]:not([readonly]):not([disabled]):not([hidden]),\n        input[type=email]:not([readonly]):not([disabled]):not([hidden]),\n        input[aria-label*=mail i],\n        input[placeholder*=mail i]:not([readonly])\n    ";

      var findEligibleInput = function findEligibleInput(context) {
        context.querySelectorAll(EMAIL_SELECTOR).forEach(function (input) {
          var parentForm = input.form;

          if (parentForm) {
            if (forms.has(parentForm)) {
              // If we've already met the form, add the input
              forms.get(parentForm).addInput(input);
            } else {
              forms.set(parentForm, new Form(parentForm, input, intObs));
            }
          } else {
            // If input is not associated with a form, analyse the page
            forms.set(input, new Form(null, input, intObs));
          }
        });
        forms.forEach(function (formObj, formEl) {
          //console.log(formEl, formObj.autofillSignal, formObj.signals);
          if (formObj.autofillSignal > 0) {
            formObj.decorateInputs();
          }
        });
      };

      findEligibleInput(document); // For all DOM mutations, search for new eligible inputs and update existing inputs positions

      var mutObs = new MutationObserver(function (mutationList) {
        var _iterator2 = _createForOfIteratorHelper(mutationList),
            _step2;

        try {
          for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
            var mutationRecord = _step2.value;

            if (mutationRecord.type === 'childList') {
              // We query only within the context of added/removed nodes
              mutationRecord.addedNodes.forEach(function (el) {
                if (el instanceof HTMLElement) {
                  window.requestIdleCallback(function () {
                    return findEligibleInput(el);
                  });
                }
              });
            }

            if (mutationRecord.type === 'attributes') {
              updateAllButtons();
            }
          }
        } catch (err) {
          _iterator2.e(err);
        } finally {
          _iterator2.f();
        }
      });
      mutObs.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true
      });
      var resObs = new ResizeObserver(function (entries) {
        return entries.forEach(updateAllButtons);
      });
      resObs.observe(document.body); // Update the position if transitions or animations are detected just in case

      ['transitionend', 'animationend', 'load'].forEach(function (eventType) {
        return window.addEventListener(eventType, function () {
          return updateAllButtons();
        });
      });
    };
    
    var handleMessageFromIOSApp = function handleMessageFromIOSApp(event) {
        
        if (event.data.checkExtensionSignedInCallback) {
            var userData = event.data.isAppSignedIn;
            notifyWebApp({
                extensionSignedIn: {
                    value: userData
                }
            });
        }

        if (event.data.checkCanInjectAutoFillCallback) {
            var userData = event.data.canInjectAutoFill;
            if (userData) {
                injectEmailAutofill();
                notifyWebApp({
                    extensionSignedIn: {
                        value: true
                    }
                });
            }
        }
    };

    window.addEventListener('message', function (event) {
        
        if (event.data.fromIOSApp) {
            handleMessageFromIOSApp(event);
            return;
        }
        
        if (!event.origin.match(ddgDomainRegex)) return; // The web app notifies us that the user signed in

        if (event.data.addUserData) {
          window.webkit.messageHandlers["emailHandlerStoreToken"].postMessage({ token: event.data.addUserData.token, username: event.data.addUserData.userName });
        } // The web app wants to know if the user is signed in

        if (event.data.checkExtensionSignedIn) {
          window.webkit.messageHandlers["emailHandlerCheckAppSignedInStatus"].postMessage({});
        }
    }); // Check if we already have user data

    window.webkit.messageHandlers["emailHandlerCheckCanInjectAutoFill"].postMessage({})
})();

},{"./DDGAutofill":5,"./Form":6,"./requestIdleCallback":8,"@webcomponents/webcomponentsjs":1,"intersection-observer":2}],8:[function(require,module,exports){
"use strict";

/*!
 * Copyright 2015 Google Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

/*
 * @see https://developers.google.com/web/updates/2015/08/using-requestidlecallback
 */
window.requestIdleCallback = window.requestIdleCallback || function (cb) {
  return setTimeout(function () {
    var start = Date.now(); // eslint-disable-next-line standard/no-callback-literal

    cb({
      didTimeout: false,
      timeRemaining: function timeRemaining() {
        return Math.max(0, 50 - (Date.now() - start));
      }
    });
  }, 1);
};

window.cancelIdleCallback = window.cancelIdleCallback || function (id) {
  clearTimeout(id);
};

},{}]},{},[7]);
