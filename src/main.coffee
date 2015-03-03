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
    count = @cache[url]
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

    if @cache[loc]?
      @set loc
      return

    @cache = {} if Object.keys(@cache).length >= 100
    @cache[loc] = '...'

    api = @api loc
    self = @
    requests.Request
      url: api.url
      content: api.params
      onComplete: ->
        self.cache[loc] = Number api.count(@response.text)
        self.set loc
    .get()

class HatenaSocialButton extends MiniSocialButton
  config:
    service: 'hatena'
    label: 'Hatena Bookmark'
  openUrl: () => "http://b.hatena.ne.jp/entry/#{@location().replace /^\w+:\/\//, ''}"
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
    url: 'http://urls.api.twitter.com/1/urls/count.json'
    params: url: url
    count: (res) =>
      data = JSON.parse res
      data.count

@hatebu = new HatenaSocialButton
@twitter = new TwitterSocialButton
