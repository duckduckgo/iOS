# Manual Tests


This script is designed to cover scenarios which are hard to write automated tests for and should be manually checked prior to a testflight build going out to beta testers or the public.

## Icon Force Touch

**Check that search force touch works from a non-running app**
1. If it is running, kill the app
2. Force touch the app icon and select search
3. Ensure that a new activated tab is opened

**Check that search force touch works from a running app**
1. Open the app, navigate to a deep menu (e.g tabs then settings)
2. Background the app
3. Force touch the app icon and select search
4. Ensure that a new activated tab is opened

**Check that paste force touch works from a non-running app**
1. If it is running, kill the app
2. Force touch the app icon and select paste
3. Ensure that a new tab is opened to the pasted query / url

**Check that paste force touch works from a running app**
1. Open the app, navigate to a deep menu (e.g tabs then settings)
2. Background the app
3. Force touch the app icon and select paste
4. Ensure that a new tab is opened to the pasted query / url


## Application Lock

Switch on Application lock and ensure that it works:
1. Open settings, toggle application lock on
2. Background the app and open it again
3. Ensure that the application lock is requested before you can proceed
4. Kill the app and reopen it, again ensure application lock is requested before you can proceed

Switch off Application lock and ensure that it is no longer requested
1. Open settings, toggle application lock off
2. Background the app and open it again
3. Ensure that the application lock is NOT requested
4. Kill the app and reopen it, again ensure application lock is NOT requested
