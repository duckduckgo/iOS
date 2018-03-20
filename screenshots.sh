#!/bin/bash

#  screenshots.sh
#  DuckDuckGo
#
#  Copyright © 2017 DuckDuckGo. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# Inspired by https://elmland.blog/2017/08/31/reset-xcode-simulators/

echo -ne 'Resetting iOS Simulators ... '; 
osascript -e 'tell application "iOS Simulator" to quit'; 
osascript -e 'tell application "Simulator" to quit'; 
xcrun simctl erase all; 

if [ $? -ne 0 ]; then
    echo FAILED
    exit 1
fi

if [ `which fastlane` -eq "" ]; then
   echo Fastlane is not installed
   exit 2
fi

fastlane screenshots

