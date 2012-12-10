goog.require('states.ui.intro');
goog.require('example.global.stateManager');
goog.require('goog.debug.Logger');


goog.provide('example.states.Intro');

example.states.Intro = function() {
    this._log = goog.debug.Logger.getLogger('Intro');
};
example.states.Intro.prototype = {
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
        that._$context = $(states.ui.intro.main({})).appendTo($context);
        that._bind();
        return this;
    },
    _bind : function() {
        var that = this;
        that._$list = $('.' + goog.getCssName('l-list'), that._$context);
        $('.' + goog.getCssName('l-create'), that._$context).on('click', function() {
            that._onCreateWorld();
        });
    },
    _onCreateWorld : function() {
        example.global.stateManager.setState('test');
    },
    stop : function() {
        var that = this;
        this._log.info("stop");
        return that;
    }
};
