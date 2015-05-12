(function() {
  var HatenaSocialButton, MiniSocialButton, TwitterSocialButton, buttons, prefs, requests, tabs,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  requests = require('sdk/request');

  tabs = require('sdk/tabs');

  buttons = require('sdk/ui/button/action');

  prefs = require('sdk/simple-prefs');

  MiniSocialButton = (function() {
    function MiniSocialButton() {
      this.update = bind(this.update, this);
      this.set = bind(this.set, this);
      this.init = bind(this.init, this);
      this.location = bind(this.location, this);
      this.init();
      this.cache = {};
    }

    MiniSocialButton.prototype.location = function() {
      return tabs.activeTab.url;
    };

    MiniSocialButton.prototype.init = function() {
      this.button = buttons.ActionButton({
        id: this.config.service + "-button",
        label: this.config.label,
        icon: {
          '16': "./" + this.config.service + ".png",
          '18': "./" + this.config.service + ".png",
          '32': "./" + this.config.service + "@2x.png",
          '36': "./" + this.config.service + "@2x.png",
          '64': "./" + this.config.service + "@2x.png"
        },
        badgeColor: '#000000',
        onClick: (function(_this) {
          return function() {
            return tabs.open({
              url: _this.openUrl(),
              inBackground: prefs.prefs.tabBg
            });
          };
        })(this)
      });
      tabs.on('activate', this.update);
      return tabs.on('ready', this.update);
    };

    MiniSocialButton.prototype.set = function(url) {
      var count;
      count = this.cache[url];
      if (count > 9999) {
        count = 9999;
        this.button.badgeColor = '#ff0000';
      } else {
        this.button.badgeColor = '#000000';
      }
      return this.button.badge = count;
    };

    MiniSocialButton.prototype.update = function() {
      var api, loc, self;
      loc = this.location();
      if (/(about:|file:|\/\/(localhost|\d+\.\d+\.\d+\.\d+))/.test(loc)) {
        this.button.badge = null;
        return;
      }
      if (this.cache[loc] != null) {
        this.set(loc);
        return;
      }
      if (Object.keys(this.cache).length >= 100) {
        this.cache = {};
      }
      this.cache[loc] = '...';
      api = this.api(loc);
      self = this;
      return requests.Request({
        url: api.url,
        content: api.params,
        onComplete: function() {
          self.cache[loc] = Number(api.count(this.response.text));
          return self.set(loc);
        }
      }).get();
    };

    return MiniSocialButton;

  })();

  HatenaSocialButton = (function(superClass) {
    extend(HatenaSocialButton, superClass);

    function HatenaSocialButton() {
      this.api = bind(this.api, this);
      this.openUrl = bind(this.openUrl, this);
      return HatenaSocialButton.__super__.constructor.apply(this, arguments);
    }

    HatenaSocialButton.prototype.config = {
      service: 'hatena',
      label: 'Hatena Bookmark'
    };

    HatenaSocialButton.prototype.openUrl = function() {
      var loc, s;
      loc = this.location();
      s = /^https:/.test(loc) ? 's/' : '';
      return "http://b.hatena.ne.jp/entry/" + s + (loc.replace(/^\w+:\/\//, ''));
    };

    HatenaSocialButton.prototype.api = function(url) {
      return {
        url: 'http://api.b.st-hatena.com/entry.count',
        params: {
          url: url
        },
        count: (function(_this) {
          return function(res) {
            return res;
          };
        })(this)
      };
    };

    return HatenaSocialButton;

  })(MiniSocialButton);

  TwitterSocialButton = (function(superClass) {
    extend(TwitterSocialButton, superClass);

    function TwitterSocialButton() {
      this.api = bind(this.api, this);
      this.openUrl = bind(this.openUrl, this);
      return TwitterSocialButton.__super__.constructor.apply(this, arguments);
    }

    TwitterSocialButton.prototype.config = {
      service: 'twitter',
      label: 'Twitter'
    };

    TwitterSocialButton.prototype.openUrl = function() {
      return "https://twitter.com/search/?q=" + (encodeURIComponent(this.location()));
    };

    TwitterSocialButton.prototype.api = function(url) {
      return {
        url: 'http://urls.api.twitter.com/1/urls/count.json',
        params: {
          url: url
        },
        count: (function(_this) {
          return function(res) {
            var data;
            data = JSON.parse(res);
            return data.count;
          };
        })(this)
      };
    };

    return TwitterSocialButton;

  })(MiniSocialButton);

  this.hatebu = new HatenaSocialButton;

  this.twitter = new TwitterSocialButton;

}).call(this);
