goog.require('global_export');
goog.require('example.states.StateManager');
goog.require('goog.History');

goog.provide('example.global.stateManager');
goog.provide('example.global.history');
goog.provide('example.log');

/** @const */
example.log = goog.debug.Logger.getLogger('root');
/** @const */
example.global.stateManager = new example.states.StateManager();
/** @const */
example.global.history = new goog.History();
example.global.history.setEnabled(true);
