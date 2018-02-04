
//
//  password-injection.js
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

var ddgPasswords = function() {

    function updateInput(input, value) {

      input.focus()
      input.blur()
      input.value = value
      input.style.border = "2px yellow solid"

    }

    function populateField(form, types, value) {

      var elements = form.getElementsByTagName("input")
      for (var i = 0; i < elements.length; i++) {
        input = elements[i]
        if (types.indexOf(input.type) != -1) {
          updateInput(input, value)
          return 1
        }
      }
      return 0
    }

    function populate(username, password) {

      var usernames = 0
      var passwords = 0
      var forms = document.getElementsByTagName("form")
      for (var i = 0; i < forms.length; i++) {
        var form = forms[i]
        usernames += populateField(form, ["text", "username", "email"], username)
        passwords += populateField(form, ["password"], password)
      }

      return { 
        usernames: usernames, 
        passwords: passwords 
      }
    }

    return {
      populate: populate
    }

  }()
