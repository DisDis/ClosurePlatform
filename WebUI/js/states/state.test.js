goog.require('states.ui.test');
goog.require('example.global.stateManager');
goog.require('goog.debug.Logger');
goog.require('example.TestType');
goog.require('example.ui.test1');

goog.provide('example.states.Test');

example.states.Test = function() {
    this._log = goog.debug.Logger.getLogger('Test');
};
example.states.Test.prototype = {
    init : function(params) {
        var that = this;
        return that;
    },
    clean : function() {
        return this;
    },
    start : function($context) {
        var that = this;
        that._log.info("start");
        that._$context = $(states.ui.test.main({})).appendTo($context);
        that._bind();
        return that;
    },
    _bind : function() {
        var that = this;
        $('.' + goog.getCssName('l-back'),that._$context).on('click', function() {
            that._onToLobbyState();
        });
        $('.'+goog.getCssName('l-test-content'),that._$context).html(example.ui.test1.testPage({
            items:["1","2","3","a","b","c"],
            currentDateTime:new Date().valueOf()
        }));
    },
    _onToLobbyState : function() {
        example.global.stateManager.setState('intro');
    },

    stop : function() {
        var that = this;
        that._log.info("stop");
        return that;
    }
};
