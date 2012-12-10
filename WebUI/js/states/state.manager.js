goog.provide('example.states.StateManager');
example.states.StateManager = function() {
};
example.states.StateManager.prototype = {
    /**
     * @param buffer1 -
     *            jQuery
     * @param buffer2 -
     *            jQuery
     */
    init : function(params) {
        var that = this;
        that._$buffer1 = params.$buffer1;
        that._$buffer2 = params.$buffer2;
        that._$visibleBuffer = that._$buffer1;
        that._$hiddenBuffer = that._$buffer2;
        that._current = undefined;
        that._stopState = undefined;
        that._states = {};
        goog.events.listen(example.global.history, goog.history.EventType.NAVIGATE,goog.bind(this._urlChanged, this));
        return this;
    },
    getLocationFragment: function() {
        var href = window.location.href;
        var index = href.indexOf('#');
        return index < 0 ? '' : href.substring(index + 1);
      },
    addState:function(name,state){
        this._states[name] = state;
        return this;
    },
    _urlChanged:function(e){
        var that = this;
        that.setState(e.token);
    },
    history:function(defaultState){
        var that = this;
        var token = that.getLocationFragment();
        if (token == ''){
            token = defaultState;
        }
        that.setState(token);
    },
    getState:function(stateName){
        return this._states[stateName];
    },
    setState : function(stateName) {
        var state = this.getState(stateName);
        if (this._current == state || this._stopState != undefined || state == undefined) {
            return this;
        }
        this._stopState = this._current; 
        this._current = state;
        this._$hiddenBuffer.empty();
        if (this._current) {
            this._current.start(this._$hiddenBuffer);
        }
        this._swapBuffer();
        example.global.history.setToken(stateName);
        return this;
    },
    _swapBuffer : function() {
        var that = this;
        var $currentVisible = that._$visibleBuffer;
        that._$visibleBuffer = that._$hiddenBuffer;
        that._$hiddenBuffer = $currentVisible;
        $currentVisible.stop().fadeOut(500,function(){            
            if (that._stopState) {
                that._stopState.stop();
                that._stopState = undefined;
            }
            that._$visibleBuffer.fadeIn(500);
        });
    },
    clean : function() {
        return this;
    }
};