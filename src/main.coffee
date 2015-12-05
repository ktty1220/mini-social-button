# about:config
# extensions.jid1-DyFcns9MkdCHWw@jetpack.sdk.console.logLevel: "all"
requests = require 'sdk/request'
tabs     = require 'sdk/tabs'
buttons  = require 'sdk/ui/button/action'
prefs    = require 'sdk/simple-prefs'

class MiniSocialButton
  constructor: () ->
    @init()
    @cache = {}

  location: => tabs.activeTab.url

  init: =>
    @button = buttons.ActionButton
      id: "#{@config.service}-button"
      label: @config.label
      icon:
        '16': "./#{@config.service}.png"
        '18': "./#{@config.service}.png"
        '32': "./#{@config.service}@2x.png"
        '36': "./#{@config.service}@2x.png"
        '64': "./#{@config.service}@2x.png"
      badgeColor: '#000000'
      onClick: => tabs.open
        url: @openUrl()
        inBackground: prefs.prefs.tabBg
    tabs.on 'activate', @update
    tabs.on 'ready', @update

  set: (url) =>
    return if @config.service is 'twitter'
    count = @cache[url].count
    if count > 9999
      count = 9999
      @button.badgeColor = '#ff0000'
    else
      @button.badgeColor = '#000000'
    @button.badge = count

  update: =>
    loc = @location()
    if /(about:|file:|\/\/(localhost|\d+\.\d+\.\d+\.\d+))/.test loc
      @button.badge = null
      return

    ttl = prefs.prefs.ttl * 60000
    if Number(new Date()) < (@cache[loc]?.checked_at ? 0) + ttl
      @set loc
      return

    @cache = {} if Object.keys(@cache).length >= 100
    @cache[loc] =
      checked_at: Number new Date()
      count: '...'

    api = @api loc
    self = @
    if api.url?
      requests.Request
        url: api.url
        content: api.params
        onComplete: ->
          self.cache[loc].count = Number api.count(@response.text)
          self.set loc
      .get()

class HatenaSocialButton extends MiniSocialButton
  config:
    service: 'hatena'
    label: 'Hatena Bookmark'
  openUrl: () =>
    loc = @location()
    s = if /^https:/.test loc then 's/' else ''
    "http://b.hatena.ne.jp/entry/#{s}#{loc.replace /^\w+:\/\//, ''}"
  api: (url) =>
    url: 'http://api.b.st-hatena.com/entry.count'
    params: url: url
    count: (res) => res

class TwitterSocialButton extends MiniSocialButton
  config:
    service: 'twitter'
    label: 'Twitter'
  openUrl: () => "https://twitter.com/search/?q=#{encodeURIComponent @location()}"
  api: (url) =>
    url: null #'http://urls.api.twitter.com/1/urls/count.json'
    params: url: url
    count: (res) =>
      data = JSON.parse res
      data.count

@hatebu = new HatenaSocialButton
@twitter = new TwitterSocialButton
