require 'json'

module Dingtalk

  class Server

    # 构造函数
    # @param [String] corp_id 钉钉提供的ID
    # @param [String] corp_secret 钉钉提供的密码
    def initialize(corp_id, corp_secret)
      @corp_id = corp_id
      @corp_secret = corp_secret
    end

    # 查询AccessToken
    # @return [String] 直接返回token，如果失败则返回nil
    def query_access_token()
      uri = URI(INTERFACE_URL + '/gettoken?' + 'corpid=' + @corp_id + '&corpsecret=' + @corp_secret)
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      @token = result['access_token']
    end
  end
end