require "dingtalk/version"
require 'dingtalk/server/server'
require 'dingtalk/server/user'

module Dingtalk

  # 接口url
  INTERFACE_URL = 'https://oapi.dingtalk.com'

  class << self

    # 钉钉分配的key和secret
    attr_accessor :corpid, :corpsecret
  end
end
