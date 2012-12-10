goog.require('goog.debug');
goog.require('goog.debug.FancyWindow');
goog.require('goog.debug.Logger');

goog.provide('example.page.debug');
goog.provide('example.global.debugWindow');
// Create the debug window.
example.global.debugWindow = new goog.debug.FancyWindow('main');
example.global.debugWindow.setEnabled(true);
example.global.debugWindow.init();