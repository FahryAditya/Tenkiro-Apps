# TODO: Fix White Screen Issues on All Tabs

## Tasks:
- [x] Fix lib/screens/home_screen.dart - increase bottom padding from 24 to 100 pixels
- [x] Fix lib/screens/air_screen.dart - increase bottom padding from 60-70 to 100 pixels (already done)
- [x] Add null safety checks in AirScreen for currentLocation (already done)
- [x] Add error handling in WeatherProvider to prevent white screens

## Issue Description:
The user reports that the home page, sky page, water page, air page, and earthquake page are not appearing on the phone - they show white screens instead of content.

## Root Cause Analysis:
1. The screens might have overflow issues that cause rendering problems on some devices
2. Missing null safety checks could cause runtime exceptions
3. Provider initialization might fail silently

## Fix Plan:
1. ✅ Increase bottom padding in home_screen.dart from 24 to 100
2. ✅ Increase bottom padding in air_screen.dart from 60-70 to 100 (already at 100)
3. ✅ Add null safety check for provider.currentLocation.city in AirScreen (already done)
4. ✅ Add fallback UI when weather data is null in AirScreen (already done)
5. ✅ Add error handling in WeatherProvider for location failures
